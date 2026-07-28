// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Dir _$DirFromJson(Map<String, dynamic> json) =>
    _Dir(x: (json['x'] as num).toInt(), y: (json['y'] as num).toInt());

Map<String, dynamic> _$DirToJson(_Dir instance) => <String, dynamic>{
  'x': instance.x,
  'y': instance.y,
};

_WelcomeConfig _$WelcomeConfigFromJson(Map<String, dynamic> json) =>
    _WelcomeConfig(
      mapSize: (json['map_size'] as num).toInt(),
      circleRadius: (json['circle_radius'] as num).toInt(),
      playerRadius: (json['player_radius'] as num).toInt(),
      interactRadius: (json['interact_radius'] as num).toInt(),
      speed: (json['speed'] as num).toInt(),
      tickRate: (json['tick_rate'] as num).toInt(),
    );

Map<String, dynamic> _$WelcomeConfigToJson(_WelcomeConfig instance) =>
    <String, dynamic>{
      'map_size': instance.mapSize,
      'circle_radius': instance.circleRadius,
      'player_radius': instance.playerRadius,
      'interact_radius': instance.interactRadius,
      'speed': instance.speed,
      'tick_rate': instance.tickRate,
    };

_LobbyPlayer _$LobbyPlayerFromJson(Map<String, dynamic> json) =>
    _LobbyPlayer(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$LobbyPlayerToJson(_LobbyPlayer instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_Flag _$FlagFromJson(Map<String, dynamic> json) => _Flag(
  owner: json['owner'] as String?,
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
);

Map<String, dynamic> _$FlagToJson(_Flag instance) => <String, dynamic>{
  'owner': instance.owner,
  'x': instance.x,
  'y': instance.y,
};

_GamePlayer _$GamePlayerFromJson(Map<String, dynamic> json) => _GamePlayer(
  id: json['id'] as String,
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
);

Map<String, dynamic> _$GamePlayerToJson(_GamePlayer instance) =>
    <String, dynamic>{'id': instance.id, 'x': instance.x, 'y': instance.y};

Discover _$DiscoverFromJson(Map<String, dynamic> json) => Discover(
  v: (json['v'] as num?)?.toInt() ?? 1,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$DiscoverToJson(Discover instance) => <String, dynamic>{
  'v': instance.v,
  'type': instance.$type,
};

ServerInfo _$ServerInfoFromJson(Map<String, dynamic> json) => ServerInfo(
  v: (json['v'] as num?)?.toInt() ?? 1,
  name: json['name'] as String,
  tcpPort: (json['tcp_port'] as num).toInt(),
  state: $enumDecode(_$ServerStateEnumMap, json['state']),
  players: (json['players'] as num).toInt(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$ServerInfoToJson(ServerInfo instance) =>
    <String, dynamic>{
      'v': instance.v,
      'name': instance.name,
      'tcp_port': instance.tcpPort,
      'state': _$ServerStateEnumMap[instance.state]!,
      'players': instance.players,
      'type': instance.$type,
    };

const _$ServerStateEnumMap = {
  ServerState.lobby: 'lobby',
  ServerState.playing: 'playing',
};

Join _$JoinFromJson(Map<String, dynamic> json) => Join(
  v: (json['v'] as num?)?.toInt() ?? 1,
  name: json['name'] as String,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$JoinToJson(Join instance) => <String, dynamic>{
  'v': instance.v,
  'name': instance.name,
  'type': instance.$type,
};

Input _$InputFromJson(Map<String, dynamic> json) => Input(
  dir: Dir.fromJson(json['dir'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$InputToJson(Input instance) => <String, dynamic>{
  'dir': instance.dir,
  'type': instance.$type,
};

Interact _$InteractFromJson(Map<String, dynamic> json) =>
    Interact($type: json['type'] as String?);

Map<String, dynamic> _$InteractToJson(Interact instance) => <String, dynamic>{
  'type': instance.$type,
};

Welcome _$WelcomeFromJson(Map<String, dynamic> json) => Welcome(
  playerId: json['player_id'] as String,
  config: WelcomeConfig.fromJson(json['config'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$WelcomeToJson(Welcome instance) => <String, dynamic>{
  'player_id': instance.playerId,
  'config': instance.config,
  'type': instance.$type,
};

Lobby _$LobbyFromJson(Map<String, dynamic> json) => Lobby(
  players: (json['players'] as List<dynamic>)
      .map((e) => LobbyPlayer.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$LobbyToJson(Lobby instance) => <String, dynamic>{
  'players': instance.players,
  'type': instance.$type,
};

Countdown _$CountdownFromJson(Map<String, dynamic> json) => Countdown(
  seconds: (json['seconds'] as num).toInt(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$CountdownToJson(Countdown instance) => <String, dynamic>{
  'seconds': instance.seconds,
  'type': instance.$type,
};

Start _$StartFromJson(Map<String, dynamic> json) =>
    Start($type: json['type'] as String?);

Map<String, dynamic> _$StartToJson(Start instance) => <String, dynamic>{
  'type': instance.$type,
};

StateMsg _$StateMsgFromJson(Map<String, dynamic> json) => StateMsg(
  flag: Flag.fromJson(json['flag'] as Map<String, dynamic>),
  players: (json['players'] as List<dynamic>)
      .map((e) => GamePlayer.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$StateMsgToJson(StateMsg instance) => <String, dynamic>{
  'flag': instance.flag,
  'players': instance.players,
  'type': instance.$type,
};

GameOver _$GameOverFromJson(Map<String, dynamic> json) =>
    GameOver(winner: json['winner'] as String, $type: json['type'] as String?);

Map<String, dynamic> _$GameOverToJson(GameOver instance) => <String, dynamic>{
  'winner': instance.winner,
  'type': instance.$type,
};

ErrorMsg _$ErrorMsgFromJson(Map<String, dynamic> json) =>
    ErrorMsg(reason: json['reason'] as String, $type: json['type'] as String?);

Map<String, dynamic> _$ErrorMsgToJson(ErrorMsg instance) => <String, dynamic>{
  'reason': instance.reason,
  'type': instance.$type,
};
