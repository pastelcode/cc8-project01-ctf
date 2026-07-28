import 'dart:convert';

import '../core/constants.dart';

/// Exception thrown when a TCP framing error occurs.
///
/// Raised when a message exceeds [Constants.messageMaxSize] without a
/// newline delimiter, or when a single delimited line exceeds the limit.
class TcpFramingException implements Exception {
  final String message;
  const TcpFramingException(this.message);

  @override
  String toString() => 'TcpFramingException: $message';
}

/// Newline-delimited JSON framer for TCP streams per SPEC §2.1.
///
/// Accumulates raw bytes in an internal buffer and extracts complete JSON
/// lines on each [feed] call. A line is delimited by `\n` (0x0A); an
/// optional preceding `\r` (0x0D) is tolerated for Windows line endings
/// and stripped before UTF-8 decoding.
///
/// Messages exceeding [Constants.messageMaxSize] (64 KB) — including the
/// trailing `\n` — cause a [TcpFramingException].
///
/// This class is pure Dart and does not depend on Flutter.
class TcpFraming {
  final List<int> _buffer = [];

  /// Feeds raw TCP bytes into the framer and returns every complete
  /// message extracted from the current buffer contents.
  ///
  /// Any data after the last `\n` is retained in the internal buffer for
  /// the next call. Returns an empty list when no complete message is
  /// available.
  ///
  /// Throws [TcpFramingException] when a message exceeds the size limit
  /// defined by [Constants.messageMaxSize].
  List<String> feed(List<int> bytes) {
    _buffer.addAll(bytes);
    final messages = <String>[];

    while (true) {
      final newlineIndex = _buffer.indexOf(0x0A); // \n
      if (newlineIndex == -1) break;

      // Determine where the JSON content ends (strip optional \r).
      var contentEnd = newlineIndex;
      if (contentEnd > 0 && _buffer[contentEnd - 1] == 0x0D) {
        contentEnd--;
      }

      // Message size includes the trailing \n (and optional \r).
      final messageSize = newlineIndex + 1;
      if (messageSize > Constants.messageMaxSize) {
        throw TcpFramingException(
          'Message size $messageSize exceeds maximum '
          '${Constants.messageMaxSize} bytes',
        );
      }

      final lineBytes = _buffer.sublist(0, contentEnd);
      messages.add(utf8.decode(lineBytes));

      // Remove the processed message from the buffer.
      _buffer.removeRange(0, newlineIndex + 1);
    }

    // If the remaining partial message (no newline yet) exceeds the limit,
    // reject early to prevent unbounded memory growth.
    if (_buffer.length > Constants.messageMaxSize) {
      throw TcpFramingException(
        'Accumulated partial message size ${_buffer.length} exceeds '
        'maximum ${Constants.messageMaxSize} bytes without a newline '
        'delimiter',
      );
    }

    return messages;
  }

  /// Discards all accumulated data in the internal buffer.
  void clear() {
    _buffer.clear();
  }
}
