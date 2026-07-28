import 'constants.dart';
import 'messages.dart';

/// Server-side input validation for protocol messages.
///
/// All methods are static. Pure Dart — no Flutter dependencies.
class ProtocolValidator {
  ProtocolValidator._();

  /// Validates a player name per SPEC rules.
  ///
  /// Returns `null` if valid, or the wire-format error code (e.g. `"NAME_INVALID"`)
  /// if invalid.
  ///
  /// Rules:
  /// - No control characters (U+0000–U+001F, U+007F) — checked on the raw input
  ///   so that newlines and other control chars are never silently stripped.
  /// - Trim leading/trailing whitespace.
  /// - Length must be 1–20 UTF-8 characters after trimming.
  static String? validateName(String raw) {
    // Control character check on the raw input (before trimming).
    for (final r in raw.runes) {
      if ((r >= 0x00 && r <= 0x1F) || r == 0x7F) {
        return ErrorReason.nameInvalid.wireValue;
      }
    }

    final trimmed = raw.trim();
    final runes = trimmed.runes.toList();

    // Length check: must be 1–20 characters after trimming.
    if (runes.isEmpty || runes.length > Constants.nameMaxLength) {
      return ErrorReason.nameInvalid.wireValue;
    }

    return null;
  }

  /// Returns `true` when both [dir.x] and [dir.y] are in {-1, 0, 1}.
  static bool isValidDir(Dir dir) {
    const validValues = {-1, 0, 1};
    return validValues.contains(dir.x) && validValues.contains(dir.y);
  }

  /// Returns `true` when [byteLength] exceeds [Constants.messageMaxSize] (64 KiB).
  static bool isOversized(int byteLength) {
    return byteLength > Constants.messageMaxSize;
  }

  /// Returns `true` when [currentCount] has reached or exceeded
  /// [Constants.maxPlayers] (100).
  static bool isLobbyFull(int currentCount) {
    return currentCount >= Constants.maxPlayers;
  }
}
