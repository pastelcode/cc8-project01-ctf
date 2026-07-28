import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../core/constants.dart';
import '../core/messages.dart';

/// UDP server-discovery module per SPEC §1.3.
///
/// Handles broadcasting [discover] requests, listening for [server_info]
/// responses (client side), and listening for incoming [discover] requests
/// (server side).
///
/// All UDP communication uses [Constants.discoveryPort] (8888).
class UdpDiscovery {
  static const int discoveryPort = Constants.discoveryPort;

  // ---------------------------------------------------------------------------
  // Client-side: send
  // ---------------------------------------------------------------------------

  /// Sends a discover broadcast to 255.255.255.255:8888 AND the subnet
  /// broadcast for every active IPv4 interface.
  ///
  /// Enables [RawDatagramSocket.broadcastEnabled] before sending.  On
  /// platforms that do not support `SO_BROADCAST` (e.g. the iOS simulator)
  /// the attempt is silently ignored — the caller should offer manual
  /// fallback via [sendDiscoverUnicast].
  static Future<void> sendDiscover() async {
    final data = utf8.encode(jsonEncode({'type': 'discover', 'v': 1}));

    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    try {
      // Enable broadcast — required by SPEC §1.3.
      try {
        socket.broadcastEnabled = true;
      } catch (_) {
        // Platform may not support SO_BROADCAST (e.g. iOS simulator).
      }

      // 1) Limited broadcast (255.255.255.255)
      try {
        socket.send(data, InternetAddress('255.255.255.255'), discoveryPort);
      } catch (_) {
        // Broadcast send failed — network may disallow it.
      }

      // 2) Subnet broadcast for each active IPv4 interface.
      try {
        final interfaces = await NetworkInterface.list();
        for (final interface in interfaces) {
          for (final addr in interface.addresses) {
            if (addr.type != InternetAddressType.IPv4) continue;
            final parts = addr.address.split('.');
            if (parts.length != 4) continue;
            // Without subnet-mask info from dart:io we assume /24, the
            // most common home-network prefix.  Even when the assumption
            // is wrong the limited broadcast sent above still covers the
            // local subnet on virtually all consumer routers.
            final broadcast = '${parts[0]}.${parts[1]}.${parts[2]}.255';
            try {
              socket.send(data, InternetAddress(broadcast), discoveryPort);
            } catch (_) {
              // Gracefully ignore per-interface send failures.
            }
          }
        }
      } catch (_) {
        // NetworkInterface.list() may fail on some platforms.
      }
    } finally {
      socket.close();
    }
  }

  /// Sends a discover unicast to `ip:8888` (manual fallback per SPEC §1.3).
  ///
  /// No broadcast flag is required — unicast UDP works even on networks
  /// that block directed broadcasts.
  static Future<void> sendDiscoverUnicast(String ip) async {
    final data = utf8.encode(jsonEncode({'type': 'discover', 'v': 1}));

    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    try {
      socket.send(data, InternetAddress(ip), discoveryPort);
      // Allow the kernel to flush the datagram before closing.
      await Future<void>.delayed(const Duration(milliseconds: 20));
    } finally {
      socket.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Client-side: listen for server_info
  // ---------------------------------------------------------------------------

  /// Listens for [server_info] responses on [discoveryPort] and returns a
  /// broadcast stream of [ServerInfo] objects.
  ///
  /// Binds with `SO_REUSEADDR` and (on macOS / Linux) `SO_REUSEPORT` per
  /// SPEC §1.3.  Non-JSON datagrams and messages whose `v` field is not 1
  /// are silently discarded.
  static Stream<ServerInfo> listen() {
    final controller = StreamController<ServerInfo>.broadcast();
    RawDatagramSocket? socket;
    var cancelSubscription = false;

    void start() {
      if (socket != null) return;
      RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
        reuseAddress: true,
        reusePort: Platform.isMacOS || Platform.isLinux,
      ).then(
        (s) {
          // If cancelled before bind completed, close immediately and bail.
          if (cancelSubscription) {
            s.close();
            return;
          }
          socket = s;
          s.listen(
            _onRead(s, controller),
            onError: (Object e, StackTrace st) {
              if (!controller.isClosed) controller.addError(e, st);
            },
            onDone: () {
              if (!controller.isClosed) controller.close();
            },
            cancelOnError: false,
          );
        },
        onError: (Object e, StackTrace st) {
          if (!controller.isClosed) controller.addError(e, st);
        },
      );
    }

    controller.onListen = start;
    controller.onCancel = () {
      cancelSubscription = true;
      socket?.close();
      socket = null;
    };

    return controller.stream;
  }

  // ---------------------------------------------------------------------------
  // Client-side: listen for server_info with source address
  // ---------------------------------------------------------------------------

  /// Like [listen], but each event also includes the source [InternetAddress]
  /// of the responding server.
  static Stream<({InternetAddress source, ServerInfo info})>
  listenWithSource() {
    final controller =
        StreamController<
          ({InternetAddress source, ServerInfo info})
        >.broadcast();
    RawDatagramSocket? socket;
    var cancelSubscription = false;

    void start() {
      if (socket != null) return;
      RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
        reuseAddress: true,
        reusePort: Platform.isMacOS || Platform.isLinux,
      ).then(
        (s) {
          if (cancelSubscription) {
            s.close();
            return;
          }
          socket = s;
          s.listen(
            _onReadWithSource(s, controller),
            onError: (Object e, StackTrace st) {
              if (!controller.isClosed) controller.addError(e, st);
            },
            onDone: () {
              if (!controller.isClosed) controller.close();
            },
            cancelOnError: false,
          );
        },
        onError: (Object e, StackTrace st) {
          if (!controller.isClosed) controller.addError(e, st);
        },
      );
    }

    controller.onListen = start;
    controller.onCancel = () {
      cancelSubscription = true;
      socket?.close();
      socket = null;
    };

    return controller.stream;
  }

  // ---------------------------------------------------------------------------
  // Server-side: listen for discover
  // ---------------------------------------------------------------------------

  /// Listens for [discover] requests on [discoveryPort] and returns a
  /// broadcast stream of the source [InternetAddress] for each valid request.
  ///
  /// Messages with the wrong protocol version (`v != 1`) or that cannot be
  /// parsed as JSON are silently discarded per SPEC §1.3.
  static Stream<InternetAddress> listenForDiscovery() {
    final controller = StreamController<InternetAddress>.broadcast();
    RawDatagramSocket? socket;
    var cancelSubscription = false;

    void start() {
      if (socket != null) return;
      RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
        reuseAddress: true,
        reusePort: Platform.isMacOS || Platform.isLinux,
      ).then(
        (s) {
          if (cancelSubscription) {
            s.close();
            return;
          }
          socket = s;
          s.listen(
            _onDiscoveryRead(s, controller),
            onError: (Object e, StackTrace st) {
              if (!controller.isClosed) controller.addError(e, st);
            },
            onDone: () {
              if (!controller.isClosed) controller.close();
            },
            cancelOnError: false,
          );
        },
        onError: (Object e, StackTrace st) {
          if (!controller.isClosed) controller.addError(e, st);
        },
      );
    }

    controller.onListen = start;
    controller.onCancel = () {
      cancelSubscription = true;
      socket?.close();
      socket = null;
    };

    return controller.stream;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Returns a callback that parses incoming datagrams as [ServerInfo].
  ///
  /// Drains all available datagrams from the socket buffer on each `read`
  /// event to avoid silently buffering messages that arrive between event
  /// loop iterations.
  static void Function(RawSocketEvent) _onRead(
    RawDatagramSocket socket,
    StreamController<ServerInfo> controller,
  ) {
    return (RawSocketEvent event) {
      if (event != RawSocketEvent.read) return;
      for (Datagram? d = socket.receive(); d != null; d = socket.receive()) {
        final datagram = d;
        try {
          final text = utf8.decode(datagram.data);
          final json = jsonDecode(text) as Map<String, dynamic>;
          if (json['type'] != 'server_info') continue;
          if (json['v'] != 1) continue;
          final canonical = canonicalizeDiscriminator(json);
          final msg = UdpMessage.fromJson(canonical);
          if (msg is ServerInfo) {
            if (!controller.isClosed) controller.add(msg);
          }
        } catch (_) {
          // Silently discard non-JSON datagrams (SPEC §1.3).
        }
      }
    };
  }

  /// Returns a callback that parses incoming datagrams as [ServerInfo] and
  /// includes the source [InternetAddress].
  ///
  /// Drains all available datagrams from the socket buffer on each `read`
  /// event to avoid silently buffering messages that arrive between event
  /// loop iterations.
  static void Function(RawSocketEvent) _onReadWithSource(
    RawDatagramSocket socket,
    StreamController<({InternetAddress source, ServerInfo info})> controller,
  ) {
    return (RawSocketEvent event) {
      if (event != RawSocketEvent.read) return;
      for (Datagram? d = socket.receive(); d != null; d = socket.receive()) {
        final datagram = d;
        try {
          final text = utf8.decode(datagram.data);
          final json = jsonDecode(text) as Map<String, dynamic>;
          if (json['type'] != 'server_info') continue;
          if (json['v'] != 1) continue;
          final canonical = canonicalizeDiscriminator(json);
          final msg = UdpMessage.fromJson(canonical);
          if (msg is ServerInfo) {
            if (!controller.isClosed) {
              controller.add((source: datagram.address, info: msg));
            }
          }
        } catch (_) {
          // Silently discard non-JSON datagrams (SPEC §1.3).
        }
      }
    };
  }

  /// Returns a callback that extracts the source address from valid
  /// [discover] datagrams.
  ///
  /// Drains all available datagrams from the socket buffer on each `read`
  /// event so that no messages are silently queued behind a discarded one.
  static void Function(RawSocketEvent) _onDiscoveryRead(
    RawDatagramSocket socket,
    StreamController<InternetAddress> controller,
  ) {
    return (RawSocketEvent event) {
      if (event != RawSocketEvent.read) return;
      for (Datagram? d = socket.receive(); d != null; d = socket.receive()) {
        final datagram = d;
        try {
          final text = utf8.decode(datagram.data);
          final json = jsonDecode(text) as Map<String, dynamic>;
          if (json['type'] != 'discover') continue;
          if (json['v'] != 1) continue;
          if (!controller.isClosed) controller.add(datagram.address);
        } catch (_) {
          // Silently discard non-JSON datagrams.
        }
      }
    };
  }
}
