import 'package:flutter_test/flutter_test.dart';

import 'package:capture_the_flag/core/constants.dart';
import 'package:capture_the_flag/core/messages.dart';
import 'package:capture_the_flag/core/validation.dart';

void main() {
  group('ProtocolValidator.validateName', () {
    test('empty string → invalid', () {
      expect(ProtocolValidator.validateName(''), isNotNull);
    });

    test('whitespace-only string → invalid (after trim is empty)', () {
      expect(ProtocolValidator.validateName('   '), isNotNull);
    });

    test('1 char → valid', () {
      expect(ProtocolValidator.validateName('A'), isNull);
    });

    test('exactly 20 chars → valid', () {
      final name = 'A' * 20;
      expect(ProtocolValidator.validateName(name), isNull);
    });

    test('21 chars → invalid', () {
      final name = 'A' * 21;
      expect(ProtocolValidator.validateName(name), isNotNull);
    });

    test('leading/trailing spaces → valid after trim', () {
      expect(ProtocolValidator.validateName('  hello  '), isNull);
    });

    test('newline \\n → invalid', () {
      expect(ProtocolValidator.validateName('hello\n'), isNotNull);
    });

    test('carriage return \\r → invalid', () {
      expect(ProtocolValidator.validateName('hello\r'), isNotNull);
    });

    test('control char \\x00 → invalid', () {
      expect(ProtocolValidator.validateName('hello\x00'), isNotNull);
    });

    test('control char \\x1F → invalid', () {
      expect(ProtocolValidator.validateName('hello\x1F'), isNotNull);
    });

    test('control char \\x7F (DEL) → invalid', () {
      expect(ProtocolValidator.validateName('hello\x7F'), isNotNull);
    });

    test('Unicode emoji → valid (counts chars correctly)', () {
      expect(ProtocolValidator.validateName('😀😀😀'), isNull);
    });

    test('CJK characters → valid (counts chars correctly)', () {
      expect(ProtocolValidator.validateName('漢字テスト'), isNull);
    });
  });

  group('ProtocolValidator.isValidDir', () {
    final validDirs = [
      Dir(x: -1, y: -1),
      Dir(x: -1, y: 0),
      Dir(x: -1, y: 1),
      Dir(x: 0, y: -1),
      Dir(x: 0, y: 0),
      Dir(x: 0, y: 1),
      Dir(x: 1, y: -1),
      Dir(x: 1, y: 0),
      Dir(x: 1, y: 1),
    ];

    for (final dir in validDirs) {
      test('valid dir (${dir.x}, ${dir.y})', () {
        expect(ProtocolValidator.isValidDir(dir), isTrue);
      });
    }

    test('invalid (2, 0) → false', () {
      expect(ProtocolValidator.isValidDir(Dir(x: 2, y: 0)), isFalse);
    });

    test('invalid (-2, 0) → false', () {
      expect(ProtocolValidator.isValidDir(Dir(x: -2, y: 0)), isFalse);
    });

    test('invalid (1, 2) → false', () {
      expect(ProtocolValidator.isValidDir(Dir(x: 1, y: 2)), isFalse);
    });
  });

  group('ProtocolValidator.isOversized', () {
    test('64 KB exactly → not oversized', () {
      expect(ProtocolValidator.isOversized(Constants.messageMaxSize), isFalse);
    });

    test('64 KB + 1 → oversized', () {
      expect(
        ProtocolValidator.isOversized(Constants.messageMaxSize + 1),
        isTrue,
      );
    });
  });

  group('ProtocolValidator.isLobbyFull', () {
    test('at 99 → not full', () {
      expect(ProtocolValidator.isLobbyFull(99), isFalse);
    });

    test('at 100 → full', () {
      expect(ProtocolValidator.isLobbyFull(100), isTrue);
    });

    test('at 101 → full', () {
      expect(ProtocolValidator.isLobbyFull(101), isTrue);
    });
  });
}
