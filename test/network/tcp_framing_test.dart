import 'dart:convert';

import 'package:capture_the_flag/core/constants.dart';
import 'package:capture_the_flag/network/tcp_framing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TcpFraming', () {
    late TcpFraming framing;

    setUp(() {
      framing = TcpFraming();
    });

    test('single complete message', () {
      const raw = '{"type":"join","v":1,"name":"test"}\n';
      final bytes = utf8.encode(raw);

      final messages = framing.feed(bytes);

      expect(messages, hasLength(1));
      expect(messages[0], '{"type":"join","v":1,"name":"test"}');
    });

    test('two concatenated messages', () {
      const raw = '{"a":1}\n{"b":2}\n';
      final bytes = utf8.encode(raw);

      final messages = framing.feed(bytes);

      expect(messages, hasLength(2));
      expect(messages[0], '{"a":1}');
      expect(messages[1], '{"b":2}');
    });

    test('split message across two feeds', () {
      final part1 = utf8.encode('{"hel');
      final part2 = utf8.encode('lo":"world"}\n');

      var messages = framing.feed(part1);
      expect(messages, isEmpty);

      messages = framing.feed(part2);
      expect(messages, hasLength(1));
      expect(messages[0], '{"hello":"world"}');
    });

    test('partial buffer retained after complete message', () {
      final bytes = utf8.encode('{"a":1}\n{"b":');

      final messages = framing.feed(bytes);

      expect(messages, hasLength(1));
      expect(messages[0], '{"a":1}');
      // The partial '{"b":' stays in the buffer — verify by feeding the rest.
      final rest = utf8.encode('2}\n');
      final messages2 = framing.feed(rest);
      expect(messages2, hasLength(1));
      expect(messages2[0], '{"b":2}');
    });

    test('Windows \\r\\n line ending tolerance', () {
      final bytes = utf8.encode('{"a":1}\r\n');

      final messages = framing.feed(bytes);

      expect(messages, hasLength(1));
      expect(messages[0], '{"a":1}');
    });

    test('multiple \\r\\n messages', () {
      final bytes = utf8.encode('{"a":1}\r\n{"b":2}\r\n');

      final messages = framing.feed(bytes);

      expect(messages, hasLength(2));
      expect(messages[0], '{"a":1}');
      expect(messages[1], '{"b":2}');
    });

    test('empty feed returns empty list', () {
      final messages = framing.feed([]);

      expect(messages, isEmpty);
    });

    test('message exactly at messageMaxSize boundary', () {
      // Build a message: 65535 bytes of content + \n = 65536 total.
      final bytes = List<int>.filled(Constants.messageMaxSize, 0x41);
      bytes[Constants.messageMaxSize - 1] = 0x0A; // \n at the last position

      final messages = framing.feed(bytes);

      expect(messages, hasLength(1));
      expect(
        messages[0],
        String.fromCharCodes(bytes.sublist(0, Constants.messageMaxSize - 1)),
      );
    });

    test('message exceeding messageMaxSize throws', () {
      // Build bytes: messageMaxSize + 1 bytes with \n at the very end.
      final bytes = List<int>.filled(Constants.messageMaxSize + 1, 0x41);
      bytes[Constants.messageMaxSize] = 0x0A;

      expect(() => framing.feed(bytes), throwsA(isA<TcpFramingException>()));
    });

    test('partial buffer exceeding messageMaxSize throws', () {
      // Feed bytes without any newline that exceed the limit.
      final bytes = List<int>.filled(Constants.messageMaxSize + 1, 0x41);

      expect(() => framing.feed(bytes), throwsA(isA<TcpFramingException>()));
    });

    test('no newline — data stays in buffer, returns empty', () {
      final bytes = utf8.encode('{"incomplete":');

      final messages = framing.feed(bytes);

      expect(messages, isEmpty);
      // Feed the rest to confirm buffer retention.
      final rest = utf8.encode('true}\n');
      final messages2 = framing.feed(rest);
      expect(messages2, hasLength(1));
      expect(messages2[0], '{"incomplete":true}');
    });

    test('clear discards partial data', () {
      final bytes = utf8.encode('{"incomplete":');
      framing.feed(bytes);
      framing.clear();

      // After clear, feeding a complete message should work afresh.
      final rest = utf8.encode('{"fresh":1}\n');
      final messages = framing.feed(rest);
      expect(messages, hasLength(1));
      expect(messages[0], '{"fresh":1}');
    });

    test('\\r without following \\n is treated as content', () {
      // \r not immediately before \n should remain in the content.
      final bytes = utf8.encode('{"a":"b\\r"}\n');

      final messages = framing.feed(bytes);

      expect(messages, hasLength(1));
      expect(messages[0], '{"a":"b\\r"}');
    });
  });
}
