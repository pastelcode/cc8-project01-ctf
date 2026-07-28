import 'package:freezed_annotation/freezed_annotation.dart';

part 'messages.freezed.dart';
part 'messages.g.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Server state in server_info response (§2.3).
enum ServerState {
  @JsonValue('lobby')
  lobby,
  @JsonValue('playing')
  playing,
}

/// Game phase — drives screen transitions and logic guards (§3.1).
enum GamePhase {
  @JsonValue('lobby')
  lobby,
  @JsonValue('countdown')
  countdown,
  @JsonValue('playing')
  playing,
  @JsonValue('game_over')
  gameOver,
}

/// Protocol error codes per SPEC §5.1.
///
/// Used server-side to construct valid error strings. The [ServerMessage.error]
/// variant carries the raw [String] on the wire (matching the SPEC), but
/// servers SHOULD use this enum to avoid typos.
enum ErrorReason {
  @JsonValue('INVALID_JSON')
  invalidJson,
  @JsonValue('UNKNOWN_TYPE')
  unknownType,
  @JsonValue('MISSING_FIELD')
  missingField,
  @JsonValue('INVALID_FIELD')
  invalidField,
  @JsonValue('INVALID_PHASE')
  invalidPhase,
  @JsonValue('VERSION_MISMATCH')
  versionMismatch,
  @JsonValue('LOBBY_FULL')
  lobbyFull,
  @JsonValue('NAME_INVALID')
  nameInvalid,
  @JsonValue('GAME_STARTED')
  gameStarted,
  @JsonValue('MESSAGE_TOO_LARGE')
  messageTooLarge,
  @JsonValue('NOT_JOINED')
  notJoined;

  /// Returns the wire-format string (e.g. `"INVALID_JSON"`).
  String get wireValue {
    // The @JsonValue annotation value is not directly accessible at runtime
    // through `json_annotation`. We use a hardcoded mapping for speed.
    return switch (this) {
      ErrorReason.invalidJson => 'INVALID_JSON',
      ErrorReason.unknownType => 'UNKNOWN_TYPE',
      ErrorReason.missingField => 'MISSING_FIELD',
      ErrorReason.invalidField => 'INVALID_FIELD',
      ErrorReason.invalidPhase => 'INVALID_PHASE',
      ErrorReason.versionMismatch => 'VERSION_MISMATCH',
      ErrorReason.lobbyFull => 'LOBBY_FULL',
      ErrorReason.nameInvalid => 'NAME_INVALID',
      ErrorReason.gameStarted => 'GAME_STARTED',
      ErrorReason.messageTooLarge => 'MESSAGE_TOO_LARGE',
      ErrorReason.notJoined => 'NOT_JOINED',
    };
  }
}

// ---------------------------------------------------------------------------
// Nested data types
// ---------------------------------------------------------------------------

@freezed
abstract class Dir with _$Dir {
  const factory Dir({required int x, required int y}) = _Dir;
  factory Dir.fromJson(Map<String, dynamic> json) => _$DirFromJson(json);
}

@freezed
abstract class WelcomeConfig with _$WelcomeConfig {
  const factory WelcomeConfig({
    @JsonKey(name: 'map_size') required int mapSize,
    @JsonKey(name: 'circle_radius') required int circleRadius,
    @JsonKey(name: 'player_radius') required int playerRadius,
    @JsonKey(name: 'interact_radius') required int interactRadius,
    required int speed,
    @JsonKey(name: 'tick_rate') required int tickRate,
  }) = _WelcomeConfig;
  factory WelcomeConfig.fromJson(Map<String, dynamic> json) =>
      _$WelcomeConfigFromJson(json);
}

@freezed
abstract class LobbyPlayer with _$LobbyPlayer {
  const factory LobbyPlayer({required String id, required String name}) =
      _LobbyPlayer;
  factory LobbyPlayer.fromJson(Map<String, dynamic> json) =>
      _$LobbyPlayerFromJson(json);
}

@freezed
abstract class Flag with _$Flag {
  const factory Flag({String? owner, required double x, required double y}) =
      _Flag;
  factory Flag.fromJson(Map<String, dynamic> json) => _$FlagFromJson(json);
}

@freezed
abstract class GamePlayer with _$GamePlayer {
  const factory GamePlayer({
    required String id,
    required double x,
    required double y,
  }) = _GamePlayer;
  factory GamePlayer.fromJson(Map<String, dynamic> json) =>
      _$GamePlayerFromJson(json);
}

// ---------------------------------------------------------------------------
// Protocol message sealed unions
// ---------------------------------------------------------------------------

/// Maps SPEC snake_case discriminator values to Freezed camelCase, and
/// vice-versa. Freezed uses the factory name as the `type` value, but the
/// SPEC requires snake_case (e.g. `server_info`, `game_over`).
///
/// Call `canonicalizeDiscriminator` on incoming JSON before parsing, and
/// `restoreDiscriminator` on outgoing JSON after serializing.
Map<String, dynamic> canonicalizeDiscriminator(Map<String, dynamic> json) {
  return switch (json['type']) {
    'server_info' => {...json, 'type': 'serverInfo'},
    'game_over' => {...json, 'type': 'gameOver'},
    _ => json,
  };
}

Map<String, dynamic> restoreDiscriminator(Map<String, dynamic> json) {
  return switch (json['type']) {
    'serverInfo' => {...json, 'type': 'server_info'},
    'gameOver' => {...json, 'type': 'game_over'},
    _ => json,
  };
}

// --- UDP Messages ---

@Freezed(unionKey: 'type')
sealed class UdpMessage with _$UdpMessage {
  const factory UdpMessage.discover({@Default(1) int v}) = Discover;

  const factory UdpMessage.serverInfo({
    @Default(1) int v,
    required String name,
    @JsonKey(name: 'tcp_port') required int tcpPort,
    required ServerState state,
    required int players,
  }) = ServerInfo;

  factory UdpMessage.fromJson(Map<String, dynamic> json) =>
      _$UdpMessageFromJson(json);
}

// --- TCP Messages (Client → Server) ---

@Freezed(unionKey: 'type')
sealed class ClientMessage with _$ClientMessage {
  const factory ClientMessage.join({@Default(1) int v, required String name}) =
      Join;

  const factory ClientMessage.input({required Dir dir}) = Input;

  const factory ClientMessage.interact() = Interact;

  factory ClientMessage.fromJson(Map<String, dynamic> json) =>
      _$ClientMessageFromJson(json);
}

// --- TCP Messages (Server → Client) ---

@Freezed(unionKey: 'type')
sealed class ServerMessage with _$ServerMessage {
  const factory ServerMessage.welcome({
    @JsonKey(name: 'player_id') required String playerId,
    required WelcomeConfig config,
  }) = Welcome;

  const factory ServerMessage.lobby({required List<LobbyPlayer> players}) =
      Lobby;

  const factory ServerMessage.countdown({required int seconds}) = Countdown;

  const factory ServerMessage.start() = Start;

  const factory ServerMessage.state({
    required Flag flag,
    required List<GamePlayer> players,
  }) = StateMsg;

  const factory ServerMessage.gameOver({required String winner}) = GameOver;

  const factory ServerMessage.error({required String reason}) = ErrorMsg;

  factory ServerMessage.fromJson(Map<String, dynamic> json) =>
      _$ServerMessageFromJson(json);
}
