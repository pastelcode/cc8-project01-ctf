/// Protocol constants per SPEC §2.3 "Agreed constants and limits".
///
/// These values are non-configurable — every class server MUST use exactly
/// these constants so that all projects remain interoperable.
class Constants {
  // -------------------------------------------------------------------------
  // welcome.config values (SPEC §2.3 table, rows 1–6)
  // -------------------------------------------------------------------------

  /// Map side length in logical units.
  static const int mapSize = 1000;

  /// Central circle radius in logical units.
  static const int circleRadius = 300;

  /// Player body radius in logical units.
  static const int playerRadius = 15;

  /// Maximum distance to capture or steal the flag.
  static const int interactRadius = 40;

  /// Movement speed in units per second.
  static const int speed = 200;

  /// State broadcasts per second (20 Hz).
  static const int tickRate = 20;

  // -------------------------------------------------------------------------
  // Server constants
  // -------------------------------------------------------------------------

  /// Pre-game countdown duration in seconds.
  static const int countdownSeconds = 5;

  /// Minimum players required to start or continue the countdown.
  /// SPEC says 2, lowered to 1 for solo testing.
  static const int minPlayers = 1;

  /// Pause after game_over before returning to lobby, in seconds.
  static const int postGameSeconds = 5;

  /// Center of the map and circle (both X and Y).
  static const double circleCenterX = 500;
  static const double circleCenterY = 500;

  /// Spawn ring inner radius.
  static const double spawnRadiusMin = 350;

  /// Spawn ring outer radius.
  static const double spawnRadiusMax = 450;

  /// Distance from center that must be exceeded to win
  /// (= circleRadius + playerRadius).
  static const double victoryDistance = 315;

  /// Fixed UDP discovery port.
  static const int discoveryPort = 8888;

  // -------------------------------------------------------------------------
  // Protocol limits
  // -------------------------------------------------------------------------

  /// Maximum players per match.
  static const int maxPlayers = 100;

  /// Maximum player name length in UTF-8 characters.
  static const int nameMaxLength = 20;

  /// Maximum size of an individual message in bytes (64 KB).
  static const int messageMaxSize = 64 * 1024;

  // -------------------------------------------------------------------------
  // Protocol version
  // -------------------------------------------------------------------------

  /// The CTF protocol version this implementation speaks.
  static const int protocolVersion = 1;

  Constants._();
}
