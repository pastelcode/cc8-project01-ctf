import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

import '../core/messages.dart';
import '../shared/logger.dart';
import 'tcp_framing.dart';

/// Represents a single connected client session.
///
/// Wraps the raw [socket], applies [TcpFraming] to incoming bytes, parses
/// JSON into [ClientMessage] objects, and exposes them via [messages].
///
/// The `playerId` is assigned externally by the server engine layer after
/// a `join` message is validated. Until then it remains `null`.
class ClientSession {
  final Socket socket;

  /// Assigned by the server engine after a valid `join`. `null` until then.
  String? playerId;

  /// Per-session newline-delimited JSON framer.
  final TcpFraming framing = TcpFraming();

  final StreamController<ClientMessage> _msgCtrl =
      StreamController<ClientMessage>.broadcast();

  /// Stream of parsed [ClientMessage] instances emitted as they arrive.
  Stream<ClientMessage> get messages => _msgCtrl.stream;

  /// Whether the underlying socket is still open for reading and writing.
  bool get isActive => !_closed;

  // -- Coalescence state -----------------------------------------------------

  /// Whether a write/flush cycle is currently in progress.
  bool _writeInProgress = false;

  /// The most recent [StateMsg] that arrived while [_writeInProgress] was
  /// `true`. Written out as soon as the current flush completes.
  StateMsg? _pendingState;

  bool _closed = false;

  ClientSession(this.socket) {
    socket.listen(
      _onData,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Internal data path
  // ---------------------------------------------------------------------------

  void _onData(List<int> bytes) {
    List<String> lines;
    try {
      lines = framing.feed(bytes);
    } on TcpFramingException {
      // Oversized message — close the connection per SPEC §2.1.
      close();
      return;
    }

    for (final line in lines) {
      logMessage('RECV', line);

      Map<String, dynamic> json;
      try {
        json = jsonDecode(line) as Map<String, dynamic>;
      } on FormatException {
        // Malformed JSON — close the connection.
        close();
        return;
      }

      json = canonicalizeDiscriminator(json);

      try {
        final msg = ClientMessage.fromJson(json);
        _msgCtrl.add(msg);
      } on CheckedFromJsonException {
        // Unknown type or missing fields — close the connection.
        close();
        return;
      }
    }
  }

  void _onError(Object error, [StackTrace? stackTrace]) {
    appLogger.e('ClientSession socket error: $error', stackTrace: stackTrace);
    close();
  }

  void _onDone() {
    close();
  }

  // ---------------------------------------------------------------------------
  // Write helpers
  // ---------------------------------------------------------------------------

  /// Serializes [message] to JSON, restores wire-format discriminators,
  /// appends `\n`, and writes to the socket.
  ///
  /// Returns a [Future] that completes when the data has been flushed to the
  /// OS network buffer.
  Future<void> send(ServerMessage message) async {
    if (!isActive) return;

    var json = message.toJson();
    json = restoreDiscriminator(json);
    final raw = '${jsonEncode(json)}\n';

    logMessage('SEND', raw.trimRight());

    socket.write(raw);
    await socket.flush();
  }

  /// Sends a coalescible [StateMsg] to this session.
  ///
  /// If a previous write is still in flight the message is queued as
  /// [_pendingState], overwriting any previously queued state. Once the
  /// current write completes the latest queued state is flushed. This
  /// guarantees that slow clients always receive the most recent snapshot
  /// and never build up a backlog.
  Future<void> sendCoalescible(StateMsg message) async {
    if (!isActive) return;

    // Always keep the latest state.
    _pendingState = message;

    // If a write is already in progress, do nothing — it will pick up
    // _pendingState when the flush completes.
    if (_writeInProgress) return;

    _writeInProgress = true;

    // Drain loop: write the latest pending state, flush, repeat if a
    // newer state arrived during the flush.
    while (_pendingState != null) {
      final msg = _pendingState!;
      _pendingState = null;

      var json = msg.toJson();
      json = restoreDiscriminator(json);
      final raw = '${jsonEncode(json)}\n';

      logMessage('SEND', raw.trimRight());

      socket.write(raw);
      try {
        await socket.flush();
      } catch (_) {
        // Socket died during flush — exit the loop.
        break;
      }
    }

    _writeInProgress = false;
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Closes the socket and message stream.
  ///
  /// Idempotent — safe to call multiple times.
  void close() {
    if (_closed) return;
    _closed = true;
    _writeInProgress = false;
    _pendingState = null;
    try {
      socket.destroy();
    } catch (_) {
      // Socket may already be closed.
    }
    // ignore: invalid_use_of_internal_placeholder
    _msgCtrl.close();
  }
}

// =============================================================================
// TcpServer
// =============================================================================

/// TCP game server that accepts client connections, manages sessions, and
/// supports broadcast + coalescible sends.
///
/// Usage:
/// ```dart
/// final server = TcpServer();
/// await server.start(port: 0);
///
/// server.onJoin.listen((session) {
///   // session.messages.listen((msg) { ... });
///   // Assign session.playerId on valid join.
/// });
///
/// server.broadcast(ServerMessage.lobby(players: [...]));
/// server.stop();
/// ```
class TcpServer {
  final StreamController<ClientSession> _onJoinCtrl =
      StreamController<ClientSession>.broadcast();

  /// Stream of newly connected [ClientSession] instances.
  ///
  /// Subscribers should listen to `session.messages` for incoming
  /// [ClientMessage] events and assign `session.playerId` after a valid
  /// `join`.
  Stream<ClientSession> get onJoin => _onJoinCtrl.stream;

  final Map<String, ClientSession> _sessions = {};

  ServerSocket? _server;

  /// The port this server is listening on, or `-1` when not running.
  int get port => _server?.port ?? -1;

  /// Number of currently registered sessions (those with a non-null
  /// [ClientSession.playerId]).
  int get connectionCount => _sessions.length;

  /// Whether the server socket is currently bound and listening.
  bool get isRunning => _server != null;

  // ---------------------------------------------------------------------------
  // Server lifecycle
  // ---------------------------------------------------------------------------

  /// Starts listening for TCP connections on [port].
  ///
  /// Pass `0` to let the OS assign an available port automatically (useful
  /// for tests). After this call completes, [port] reflects the actual port.
  Future<void> start({int port = 0}) async {
    if (_server != null) {
      throw StateError('Server is already running on port ${_server!.port}');
    }

    _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);

    _server!.listen(
      (Socket socket) {
        final session = ClientSession(socket);
        // Do NOT assign playerId here — the server engine does that on Join.
        _onJoinCtrl.add(session);
      },
      onError: (Object error, StackTrace stackTrace) {
        // Server-level errors are logged but not re-thrown so that the
        // server stays alive for remaining clients.
        appLogger.e('TcpServer accept error: $error', stackTrace: stackTrace);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Session management
  // ---------------------------------------------------------------------------

  /// Registers [session] under [playerId].
  ///
  /// Called by the server engine after a valid `join` is processed.
  /// Replaces any previous session with the same [playerId].
  ///
  /// Returns `true` if a previous session was replaced, `false` otherwise.
  bool registerSession(String playerId, ClientSession session) {
    session.playerId = playerId;
    final replaced = _sessions.containsKey(playerId);
    _sessions[playerId] = session;
    return replaced;
  }

  /// Removes and closes the session associated with [playerId].
  ///
  /// Safe to call when [playerId] is not registered (no-op).
  void removeSession(String playerId) {
    final session = _sessions.remove(playerId);
    session?.close();
  }

  // ---------------------------------------------------------------------------
  // Messaging
  // ---------------------------------------------------------------------------

  /// Broadcasts [message] to **all** connected clients.
  ///
  /// Serializes each message, applies [restoreDiscriminator] for wire-format
  /// discriminators, then writes `JSON\n` to the socket. Errors on individual
  /// sockets (e.g. dead connections) cause that session to be closed.
  void broadcast(ServerMessage message) {
    final deadSessions = <String>[];

    for (final entry in _sessions.entries) {
      final session = entry.value;
      if (!session.isActive) {
        deadSessions.add(entry.key);
        continue;
      }

      // Fire-and-forget — errors are handled by the session's own listener.
      session.send(message).catchError((_) {
        // If writing fails, the socket is dead. Mark for removal.
        deadSessions.add(entry.key);
      });
    }

    for (final id in deadSessions) {
      removeSession(id);
    }
  }

  /// Coalescible broadcast for [StateMsg] only.
  ///
  /// For each session that already has a pending write (tracked via a
  /// per-session flag), the message is **skipped** so that only the most
  /// recent state is sent once the current write completes. Non-pending
  /// sessions receive the message normally.
  void broadcastCoalescible(StateMsg message) {
    final deadSessions = <String>[];

    for (final entry in _sessions.entries) {
      final session = entry.value;
      if (!session.isActive) {
        deadSessions.add(entry.key);
        continue;
      }

      session.sendCoalescible(message).catchError((_) {
        deadSessions.add(entry.key);
      });
    }

    for (final id in deadSessions) {
      removeSession(id);
    }
  }

  /// Sends [message] to the client identified by [playerId].
  ///
  /// No-op if no session is registered for [playerId].
  void sendTo(String playerId, ServerMessage message) {
    final session = _sessions[playerId];
    if (session == null || !session.isActive) {
      if (session != null) removeSession(playerId);
      return;
    }

    session.send(message).catchError((_) {
      removeSession(playerId);
    });
  }

  // ---------------------------------------------------------------------------
  // Shutdown
  // ---------------------------------------------------------------------------

  /// Stops the server and disconnects all clients.
  ///
  /// All sessions are closed, the server socket is shut down, and internal
  /// state is reset. Safe to call multiple times.
  Future<void> stop() async {
    // Close all sessions first.
    for (final session in _sessions.values) {
      session.close();
    }
    _sessions.clear();

    // Shut down the server socket.
    final server = _server;
    _server = null;
    await server?.close();

    // Close the onJoin stream to signal subscribers.
    await _onJoinCtrl.close();
  }
}
