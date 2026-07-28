// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Dir {

 int get x; int get y;
/// Create a copy of Dir
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DirCopyWith<Dir> get copyWith => _$DirCopyWithImpl<Dir>(this as Dir, _$identity);

  /// Serializes this Dir to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Dir&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y);

@override
String toString() {
  return 'Dir(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class $DirCopyWith<$Res>  {
  factory $DirCopyWith(Dir value, $Res Function(Dir) _then) = _$DirCopyWithImpl;
@useResult
$Res call({
 int x, int y
});




}
/// @nodoc
class _$DirCopyWithImpl<$Res>
    implements $DirCopyWith<$Res> {
  _$DirCopyWithImpl(this._self, this._then);

  final Dir _self;
  final $Res Function(Dir) _then;

/// Create a copy of Dir
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,}) {
  return _then(_self.copyWith(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as int,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Dir].
extension DirPatterns on Dir {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Dir value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Dir() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Dir value)  $default,){
final _that = this;
switch (_that) {
case _Dir():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Dir value)?  $default,){
final _that = this;
switch (_that) {
case _Dir() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int x,  int y)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Dir() when $default != null:
return $default(_that.x,_that.y);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int x,  int y)  $default,) {final _that = this;
switch (_that) {
case _Dir():
return $default(_that.x,_that.y);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int x,  int y)?  $default,) {final _that = this;
switch (_that) {
case _Dir() when $default != null:
return $default(_that.x,_that.y);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Dir implements Dir {
  const _Dir({required this.x, required this.y});
  factory _Dir.fromJson(Map<String, dynamic> json) => _$DirFromJson(json);

@override final  int x;
@override final  int y;

/// Create a copy of Dir
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DirCopyWith<_Dir> get copyWith => __$DirCopyWithImpl<_Dir>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DirToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Dir&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y);

@override
String toString() {
  return 'Dir(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class _$DirCopyWith<$Res> implements $DirCopyWith<$Res> {
  factory _$DirCopyWith(_Dir value, $Res Function(_Dir) _then) = __$DirCopyWithImpl;
@override @useResult
$Res call({
 int x, int y
});




}
/// @nodoc
class __$DirCopyWithImpl<$Res>
    implements _$DirCopyWith<$Res> {
  __$DirCopyWithImpl(this._self, this._then);

  final _Dir _self;
  final $Res Function(_Dir) _then;

/// Create a copy of Dir
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,}) {
  return _then(_Dir(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as int,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$WelcomeConfig {

@JsonKey(name: 'map_size') int get mapSize;@JsonKey(name: 'circle_radius') int get circleRadius;@JsonKey(name: 'player_radius') int get playerRadius;@JsonKey(name: 'interact_radius') int get interactRadius; int get speed;@JsonKey(name: 'tick_rate') int get tickRate;
/// Create a copy of WelcomeConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WelcomeConfigCopyWith<WelcomeConfig> get copyWith => _$WelcomeConfigCopyWithImpl<WelcomeConfig>(this as WelcomeConfig, _$identity);

  /// Serializes this WelcomeConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WelcomeConfig&&(identical(other.mapSize, mapSize) || other.mapSize == mapSize)&&(identical(other.circleRadius, circleRadius) || other.circleRadius == circleRadius)&&(identical(other.playerRadius, playerRadius) || other.playerRadius == playerRadius)&&(identical(other.interactRadius, interactRadius) || other.interactRadius == interactRadius)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.tickRate, tickRate) || other.tickRate == tickRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mapSize,circleRadius,playerRadius,interactRadius,speed,tickRate);

@override
String toString() {
  return 'WelcomeConfig(mapSize: $mapSize, circleRadius: $circleRadius, playerRadius: $playerRadius, interactRadius: $interactRadius, speed: $speed, tickRate: $tickRate)';
}


}

/// @nodoc
abstract mixin class $WelcomeConfigCopyWith<$Res>  {
  factory $WelcomeConfigCopyWith(WelcomeConfig value, $Res Function(WelcomeConfig) _then) = _$WelcomeConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'map_size') int mapSize,@JsonKey(name: 'circle_radius') int circleRadius,@JsonKey(name: 'player_radius') int playerRadius,@JsonKey(name: 'interact_radius') int interactRadius, int speed,@JsonKey(name: 'tick_rate') int tickRate
});




}
/// @nodoc
class _$WelcomeConfigCopyWithImpl<$Res>
    implements $WelcomeConfigCopyWith<$Res> {
  _$WelcomeConfigCopyWithImpl(this._self, this._then);

  final WelcomeConfig _self;
  final $Res Function(WelcomeConfig) _then;

/// Create a copy of WelcomeConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mapSize = null,Object? circleRadius = null,Object? playerRadius = null,Object? interactRadius = null,Object? speed = null,Object? tickRate = null,}) {
  return _then(_self.copyWith(
mapSize: null == mapSize ? _self.mapSize : mapSize // ignore: cast_nullable_to_non_nullable
as int,circleRadius: null == circleRadius ? _self.circleRadius : circleRadius // ignore: cast_nullable_to_non_nullable
as int,playerRadius: null == playerRadius ? _self.playerRadius : playerRadius // ignore: cast_nullable_to_non_nullable
as int,interactRadius: null == interactRadius ? _self.interactRadius : interactRadius // ignore: cast_nullable_to_non_nullable
as int,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as int,tickRate: null == tickRate ? _self.tickRate : tickRate // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WelcomeConfig].
extension WelcomeConfigPatterns on WelcomeConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WelcomeConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WelcomeConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WelcomeConfig value)  $default,){
final _that = this;
switch (_that) {
case _WelcomeConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WelcomeConfig value)?  $default,){
final _that = this;
switch (_that) {
case _WelcomeConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'map_size')  int mapSize, @JsonKey(name: 'circle_radius')  int circleRadius, @JsonKey(name: 'player_radius')  int playerRadius, @JsonKey(name: 'interact_radius')  int interactRadius,  int speed, @JsonKey(name: 'tick_rate')  int tickRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WelcomeConfig() when $default != null:
return $default(_that.mapSize,_that.circleRadius,_that.playerRadius,_that.interactRadius,_that.speed,_that.tickRate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'map_size')  int mapSize, @JsonKey(name: 'circle_radius')  int circleRadius, @JsonKey(name: 'player_radius')  int playerRadius, @JsonKey(name: 'interact_radius')  int interactRadius,  int speed, @JsonKey(name: 'tick_rate')  int tickRate)  $default,) {final _that = this;
switch (_that) {
case _WelcomeConfig():
return $default(_that.mapSize,_that.circleRadius,_that.playerRadius,_that.interactRadius,_that.speed,_that.tickRate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'map_size')  int mapSize, @JsonKey(name: 'circle_radius')  int circleRadius, @JsonKey(name: 'player_radius')  int playerRadius, @JsonKey(name: 'interact_radius')  int interactRadius,  int speed, @JsonKey(name: 'tick_rate')  int tickRate)?  $default,) {final _that = this;
switch (_that) {
case _WelcomeConfig() when $default != null:
return $default(_that.mapSize,_that.circleRadius,_that.playerRadius,_that.interactRadius,_that.speed,_that.tickRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WelcomeConfig implements WelcomeConfig {
  const _WelcomeConfig({@JsonKey(name: 'map_size') required this.mapSize, @JsonKey(name: 'circle_radius') required this.circleRadius, @JsonKey(name: 'player_radius') required this.playerRadius, @JsonKey(name: 'interact_radius') required this.interactRadius, required this.speed, @JsonKey(name: 'tick_rate') required this.tickRate});
  factory _WelcomeConfig.fromJson(Map<String, dynamic> json) => _$WelcomeConfigFromJson(json);

@override@JsonKey(name: 'map_size') final  int mapSize;
@override@JsonKey(name: 'circle_radius') final  int circleRadius;
@override@JsonKey(name: 'player_radius') final  int playerRadius;
@override@JsonKey(name: 'interact_radius') final  int interactRadius;
@override final  int speed;
@override@JsonKey(name: 'tick_rate') final  int tickRate;

/// Create a copy of WelcomeConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WelcomeConfigCopyWith<_WelcomeConfig> get copyWith => __$WelcomeConfigCopyWithImpl<_WelcomeConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WelcomeConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WelcomeConfig&&(identical(other.mapSize, mapSize) || other.mapSize == mapSize)&&(identical(other.circleRadius, circleRadius) || other.circleRadius == circleRadius)&&(identical(other.playerRadius, playerRadius) || other.playerRadius == playerRadius)&&(identical(other.interactRadius, interactRadius) || other.interactRadius == interactRadius)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.tickRate, tickRate) || other.tickRate == tickRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mapSize,circleRadius,playerRadius,interactRadius,speed,tickRate);

@override
String toString() {
  return 'WelcomeConfig(mapSize: $mapSize, circleRadius: $circleRadius, playerRadius: $playerRadius, interactRadius: $interactRadius, speed: $speed, tickRate: $tickRate)';
}


}

/// @nodoc
abstract mixin class _$WelcomeConfigCopyWith<$Res> implements $WelcomeConfigCopyWith<$Res> {
  factory _$WelcomeConfigCopyWith(_WelcomeConfig value, $Res Function(_WelcomeConfig) _then) = __$WelcomeConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'map_size') int mapSize,@JsonKey(name: 'circle_radius') int circleRadius,@JsonKey(name: 'player_radius') int playerRadius,@JsonKey(name: 'interact_radius') int interactRadius, int speed,@JsonKey(name: 'tick_rate') int tickRate
});




}
/// @nodoc
class __$WelcomeConfigCopyWithImpl<$Res>
    implements _$WelcomeConfigCopyWith<$Res> {
  __$WelcomeConfigCopyWithImpl(this._self, this._then);

  final _WelcomeConfig _self;
  final $Res Function(_WelcomeConfig) _then;

/// Create a copy of WelcomeConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mapSize = null,Object? circleRadius = null,Object? playerRadius = null,Object? interactRadius = null,Object? speed = null,Object? tickRate = null,}) {
  return _then(_WelcomeConfig(
mapSize: null == mapSize ? _self.mapSize : mapSize // ignore: cast_nullable_to_non_nullable
as int,circleRadius: null == circleRadius ? _self.circleRadius : circleRadius // ignore: cast_nullable_to_non_nullable
as int,playerRadius: null == playerRadius ? _self.playerRadius : playerRadius // ignore: cast_nullable_to_non_nullable
as int,interactRadius: null == interactRadius ? _self.interactRadius : interactRadius // ignore: cast_nullable_to_non_nullable
as int,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as int,tickRate: null == tickRate ? _self.tickRate : tickRate // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LobbyPlayer {

 String get id; String get name;
/// Create a copy of LobbyPlayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LobbyPlayerCopyWith<LobbyPlayer> get copyWith => _$LobbyPlayerCopyWithImpl<LobbyPlayer>(this as LobbyPlayer, _$identity);

  /// Serializes this LobbyPlayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LobbyPlayer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'LobbyPlayer(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $LobbyPlayerCopyWith<$Res>  {
  factory $LobbyPlayerCopyWith(LobbyPlayer value, $Res Function(LobbyPlayer) _then) = _$LobbyPlayerCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$LobbyPlayerCopyWithImpl<$Res>
    implements $LobbyPlayerCopyWith<$Res> {
  _$LobbyPlayerCopyWithImpl(this._self, this._then);

  final LobbyPlayer _self;
  final $Res Function(LobbyPlayer) _then;

/// Create a copy of LobbyPlayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LobbyPlayer].
extension LobbyPlayerPatterns on LobbyPlayer {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LobbyPlayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LobbyPlayer() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LobbyPlayer value)  $default,){
final _that = this;
switch (_that) {
case _LobbyPlayer():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LobbyPlayer value)?  $default,){
final _that = this;
switch (_that) {
case _LobbyPlayer() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LobbyPlayer() when $default != null:
return $default(_that.id,_that.name);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _LobbyPlayer():
return $default(_that.id,_that.name);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _LobbyPlayer() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LobbyPlayer implements LobbyPlayer {
  const _LobbyPlayer({required this.id, required this.name});
  factory _LobbyPlayer.fromJson(Map<String, dynamic> json) => _$LobbyPlayerFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of LobbyPlayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LobbyPlayerCopyWith<_LobbyPlayer> get copyWith => __$LobbyPlayerCopyWithImpl<_LobbyPlayer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LobbyPlayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LobbyPlayer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'LobbyPlayer(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$LobbyPlayerCopyWith<$Res> implements $LobbyPlayerCopyWith<$Res> {
  factory _$LobbyPlayerCopyWith(_LobbyPlayer value, $Res Function(_LobbyPlayer) _then) = __$LobbyPlayerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$LobbyPlayerCopyWithImpl<$Res>
    implements _$LobbyPlayerCopyWith<$Res> {
  __$LobbyPlayerCopyWithImpl(this._self, this._then);

  final _LobbyPlayer _self;
  final $Res Function(_LobbyPlayer) _then;

/// Create a copy of LobbyPlayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_LobbyPlayer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Flag {

 String? get owner; double get x; double get y;
/// Create a copy of Flag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlagCopyWith<Flag> get copyWith => _$FlagCopyWithImpl<Flag>(this as Flag, _$identity);

  /// Serializes this Flag to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Flag&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,owner,x,y);

@override
String toString() {
  return 'Flag(owner: $owner, x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class $FlagCopyWith<$Res>  {
  factory $FlagCopyWith(Flag value, $Res Function(Flag) _then) = _$FlagCopyWithImpl;
@useResult
$Res call({
 String? owner, double x, double y
});




}
/// @nodoc
class _$FlagCopyWithImpl<$Res>
    implements $FlagCopyWith<$Res> {
  _$FlagCopyWithImpl(this._self, this._then);

  final Flag _self;
  final $Res Function(Flag) _then;

/// Create a copy of Flag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? owner = freezed,Object? x = null,Object? y = null,}) {
  return _then(_self.copyWith(
owner: freezed == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String?,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Flag].
extension FlagPatterns on Flag {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Flag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Flag() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Flag value)  $default,){
final _that = this;
switch (_that) {
case _Flag():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Flag value)?  $default,){
final _that = this;
switch (_that) {
case _Flag() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? owner,  double x,  double y)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Flag() when $default != null:
return $default(_that.owner,_that.x,_that.y);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? owner,  double x,  double y)  $default,) {final _that = this;
switch (_that) {
case _Flag():
return $default(_that.owner,_that.x,_that.y);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? owner,  double x,  double y)?  $default,) {final _that = this;
switch (_that) {
case _Flag() when $default != null:
return $default(_that.owner,_that.x,_that.y);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Flag implements Flag {
  const _Flag({this.owner, required this.x, required this.y});
  factory _Flag.fromJson(Map<String, dynamic> json) => _$FlagFromJson(json);

@override final  String? owner;
@override final  double x;
@override final  double y;

/// Create a copy of Flag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlagCopyWith<_Flag> get copyWith => __$FlagCopyWithImpl<_Flag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FlagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Flag&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,owner,x,y);

@override
String toString() {
  return 'Flag(owner: $owner, x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class _$FlagCopyWith<$Res> implements $FlagCopyWith<$Res> {
  factory _$FlagCopyWith(_Flag value, $Res Function(_Flag) _then) = __$FlagCopyWithImpl;
@override @useResult
$Res call({
 String? owner, double x, double y
});




}
/// @nodoc
class __$FlagCopyWithImpl<$Res>
    implements _$FlagCopyWith<$Res> {
  __$FlagCopyWithImpl(this._self, this._then);

  final _Flag _self;
  final $Res Function(_Flag) _then;

/// Create a copy of Flag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? owner = freezed,Object? x = null,Object? y = null,}) {
  return _then(_Flag(
owner: freezed == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String?,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$GamePlayer {

 String get id; double get x; double get y;
/// Create a copy of GamePlayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamePlayerCopyWith<GamePlayer> get copyWith => _$GamePlayerCopyWithImpl<GamePlayer>(this as GamePlayer, _$identity);

  /// Serializes this GamePlayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlayer&&(identical(other.id, id) || other.id == id)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,x,y);

@override
String toString() {
  return 'GamePlayer(id: $id, x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class $GamePlayerCopyWith<$Res>  {
  factory $GamePlayerCopyWith(GamePlayer value, $Res Function(GamePlayer) _then) = _$GamePlayerCopyWithImpl;
@useResult
$Res call({
 String id, double x, double y
});




}
/// @nodoc
class _$GamePlayerCopyWithImpl<$Res>
    implements $GamePlayerCopyWith<$Res> {
  _$GamePlayerCopyWithImpl(this._self, this._then);

  final GamePlayer _self;
  final $Res Function(GamePlayer) _then;

/// Create a copy of GamePlayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? x = null,Object? y = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [GamePlayer].
extension GamePlayerPatterns on GamePlayer {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GamePlayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GamePlayer() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GamePlayer value)  $default,){
final _that = this;
switch (_that) {
case _GamePlayer():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GamePlayer value)?  $default,){
final _that = this;
switch (_that) {
case _GamePlayer() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double x,  double y)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GamePlayer() when $default != null:
return $default(_that.id,_that.x,_that.y);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double x,  double y)  $default,) {final _that = this;
switch (_that) {
case _GamePlayer():
return $default(_that.id,_that.x,_that.y);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double x,  double y)?  $default,) {final _that = this;
switch (_that) {
case _GamePlayer() when $default != null:
return $default(_that.id,_that.x,_that.y);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GamePlayer implements GamePlayer {
  const _GamePlayer({required this.id, required this.x, required this.y});
  factory _GamePlayer.fromJson(Map<String, dynamic> json) => _$GamePlayerFromJson(json);

@override final  String id;
@override final  double x;
@override final  double y;

/// Create a copy of GamePlayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GamePlayerCopyWith<_GamePlayer> get copyWith => __$GamePlayerCopyWithImpl<_GamePlayer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GamePlayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GamePlayer&&(identical(other.id, id) || other.id == id)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,x,y);

@override
String toString() {
  return 'GamePlayer(id: $id, x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class _$GamePlayerCopyWith<$Res> implements $GamePlayerCopyWith<$Res> {
  factory _$GamePlayerCopyWith(_GamePlayer value, $Res Function(_GamePlayer) _then) = __$GamePlayerCopyWithImpl;
@override @useResult
$Res call({
 String id, double x, double y
});




}
/// @nodoc
class __$GamePlayerCopyWithImpl<$Res>
    implements _$GamePlayerCopyWith<$Res> {
  __$GamePlayerCopyWithImpl(this._self, this._then);

  final _GamePlayer _self;
  final $Res Function(_GamePlayer) _then;

/// Create a copy of GamePlayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? x = null,Object? y = null,}) {
  return _then(_GamePlayer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

UdpMessage _$UdpMessageFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'discover':
          return Discover.fromJson(
            json
          );
                case 'serverInfo':
          return ServerInfo.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'UdpMessage',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$UdpMessage {

 int get v;
/// Create a copy of UdpMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UdpMessageCopyWith<UdpMessage> get copyWith => _$UdpMessageCopyWithImpl<UdpMessage>(this as UdpMessage, _$identity);

  /// Serializes this UdpMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UdpMessage&&(identical(other.v, v) || other.v == v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,v);

@override
String toString() {
  return 'UdpMessage(v: $v)';
}


}

/// @nodoc
abstract mixin class $UdpMessageCopyWith<$Res>  {
  factory $UdpMessageCopyWith(UdpMessage value, $Res Function(UdpMessage) _then) = _$UdpMessageCopyWithImpl;
@useResult
$Res call({
 int v
});




}
/// @nodoc
class _$UdpMessageCopyWithImpl<$Res>
    implements $UdpMessageCopyWith<$Res> {
  _$UdpMessageCopyWithImpl(this._self, this._then);

  final UdpMessage _self;
  final $Res Function(UdpMessage) _then;

/// Create a copy of UdpMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? v = null,}) {
  return _then(_self.copyWith(
v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UdpMessage].
extension UdpMessagePatterns on UdpMessage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Discover value)?  discover,TResult Function( ServerInfo value)?  serverInfo,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Discover() when discover != null:
return discover(_that);case ServerInfo() when serverInfo != null:
return serverInfo(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Discover value)  discover,required TResult Function( ServerInfo value)  serverInfo,}){
final _that = this;
switch (_that) {
case Discover():
return discover(_that);case ServerInfo():
return serverInfo(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Discover value)?  discover,TResult? Function( ServerInfo value)?  serverInfo,}){
final _that = this;
switch (_that) {
case Discover() when discover != null:
return discover(_that);case ServerInfo() when serverInfo != null:
return serverInfo(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int v)?  discover,TResult Function( int v,  String name, @JsonKey(name: 'tcp_port')  int tcpPort,  ServerState state,  int players)?  serverInfo,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Discover() when discover != null:
return discover(_that.v);case ServerInfo() when serverInfo != null:
return serverInfo(_that.v,_that.name,_that.tcpPort,_that.state,_that.players);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int v)  discover,required TResult Function( int v,  String name, @JsonKey(name: 'tcp_port')  int tcpPort,  ServerState state,  int players)  serverInfo,}) {final _that = this;
switch (_that) {
case Discover():
return discover(_that.v);case ServerInfo():
return serverInfo(_that.v,_that.name,_that.tcpPort,_that.state,_that.players);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int v)?  discover,TResult? Function( int v,  String name, @JsonKey(name: 'tcp_port')  int tcpPort,  ServerState state,  int players)?  serverInfo,}) {final _that = this;
switch (_that) {
case Discover() when discover != null:
return discover(_that.v);case ServerInfo() when serverInfo != null:
return serverInfo(_that.v,_that.name,_that.tcpPort,_that.state,_that.players);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class Discover implements UdpMessage {
  const Discover({this.v = 1, final  String? $type}): $type = $type ?? 'discover';
  factory Discover.fromJson(Map<String, dynamic> json) => _$DiscoverFromJson(json);

@override@JsonKey() final  int v;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of UdpMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoverCopyWith<Discover> get copyWith => _$DiscoverCopyWithImpl<Discover>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiscoverToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Discover&&(identical(other.v, v) || other.v == v));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,v);

@override
String toString() {
  return 'UdpMessage.discover(v: $v)';
}


}

/// @nodoc
abstract mixin class $DiscoverCopyWith<$Res> implements $UdpMessageCopyWith<$Res> {
  factory $DiscoverCopyWith(Discover value, $Res Function(Discover) _then) = _$DiscoverCopyWithImpl;
@override @useResult
$Res call({
 int v
});




}
/// @nodoc
class _$DiscoverCopyWithImpl<$Res>
    implements $DiscoverCopyWith<$Res> {
  _$DiscoverCopyWithImpl(this._self, this._then);

  final Discover _self;
  final $Res Function(Discover) _then;

/// Create a copy of UdpMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? v = null,}) {
  return _then(Discover(
v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ServerInfo implements UdpMessage {
  const ServerInfo({this.v = 1, required this.name, @JsonKey(name: 'tcp_port') required this.tcpPort, required this.state, required this.players, final  String? $type}): $type = $type ?? 'serverInfo';
  factory ServerInfo.fromJson(Map<String, dynamic> json) => _$ServerInfoFromJson(json);

@override@JsonKey() final  int v;
 final  String name;
@JsonKey(name: 'tcp_port') final  int tcpPort;
 final  ServerState state;
 final  int players;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of UdpMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerInfoCopyWith<ServerInfo> get copyWith => _$ServerInfoCopyWithImpl<ServerInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServerInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerInfo&&(identical(other.v, v) || other.v == v)&&(identical(other.name, name) || other.name == name)&&(identical(other.tcpPort, tcpPort) || other.tcpPort == tcpPort)&&(identical(other.state, state) || other.state == state)&&(identical(other.players, players) || other.players == players));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,v,name,tcpPort,state,players);

@override
String toString() {
  return 'UdpMessage.serverInfo(v: $v, name: $name, tcpPort: $tcpPort, state: $state, players: $players)';
}


}

/// @nodoc
abstract mixin class $ServerInfoCopyWith<$Res> implements $UdpMessageCopyWith<$Res> {
  factory $ServerInfoCopyWith(ServerInfo value, $Res Function(ServerInfo) _then) = _$ServerInfoCopyWithImpl;
@override @useResult
$Res call({
 int v, String name,@JsonKey(name: 'tcp_port') int tcpPort, ServerState state, int players
});




}
/// @nodoc
class _$ServerInfoCopyWithImpl<$Res>
    implements $ServerInfoCopyWith<$Res> {
  _$ServerInfoCopyWithImpl(this._self, this._then);

  final ServerInfo _self;
  final $Res Function(ServerInfo) _then;

/// Create a copy of UdpMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? v = null,Object? name = null,Object? tcpPort = null,Object? state = null,Object? players = null,}) {
  return _then(ServerInfo(
v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tcpPort: null == tcpPort ? _self.tcpPort : tcpPort // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ServerState,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

ClientMessage _$ClientMessageFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'join':
          return Join.fromJson(
            json
          );
                case 'input':
          return Input.fromJson(
            json
          );
                case 'interact':
          return Interact.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'ClientMessage',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$ClientMessage {



  /// Serializes this ClientMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientMessage);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ClientMessage()';
}


}

/// @nodoc
class $ClientMessageCopyWith<$Res>  {
$ClientMessageCopyWith(ClientMessage _, $Res Function(ClientMessage) __);
}


/// Adds pattern-matching-related methods to [ClientMessage].
extension ClientMessagePatterns on ClientMessage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Join value)?  join,TResult Function( Input value)?  input,TResult Function( Interact value)?  interact,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Join() when join != null:
return join(_that);case Input() when input != null:
return input(_that);case Interact() when interact != null:
return interact(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Join value)  join,required TResult Function( Input value)  input,required TResult Function( Interact value)  interact,}){
final _that = this;
switch (_that) {
case Join():
return join(_that);case Input():
return input(_that);case Interact():
return interact(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Join value)?  join,TResult? Function( Input value)?  input,TResult? Function( Interact value)?  interact,}){
final _that = this;
switch (_that) {
case Join() when join != null:
return join(_that);case Input() when input != null:
return input(_that);case Interact() when interact != null:
return interact(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int v,  String name)?  join,TResult Function( Dir dir)?  input,TResult Function()?  interact,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Join() when join != null:
return join(_that.v,_that.name);case Input() when input != null:
return input(_that.dir);case Interact() when interact != null:
return interact();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int v,  String name)  join,required TResult Function( Dir dir)  input,required TResult Function()  interact,}) {final _that = this;
switch (_that) {
case Join():
return join(_that.v,_that.name);case Input():
return input(_that.dir);case Interact():
return interact();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int v,  String name)?  join,TResult? Function( Dir dir)?  input,TResult? Function()?  interact,}) {final _that = this;
switch (_that) {
case Join() when join != null:
return join(_that.v,_that.name);case Input() when input != null:
return input(_that.dir);case Interact() when interact != null:
return interact();case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class Join implements ClientMessage {
  const Join({this.v = 1, required this.name, final  String? $type}): $type = $type ?? 'join';
  factory Join.fromJson(Map<String, dynamic> json) => _$JoinFromJson(json);

@JsonKey() final  int v;
 final  String name;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of ClientMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinCopyWith<Join> get copyWith => _$JoinCopyWithImpl<Join>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JoinToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Join&&(identical(other.v, v) || other.v == v)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,v,name);

@override
String toString() {
  return 'ClientMessage.join(v: $v, name: $name)';
}


}

/// @nodoc
abstract mixin class $JoinCopyWith<$Res> implements $ClientMessageCopyWith<$Res> {
  factory $JoinCopyWith(Join value, $Res Function(Join) _then) = _$JoinCopyWithImpl;
@useResult
$Res call({
 int v, String name
});




}
/// @nodoc
class _$JoinCopyWithImpl<$Res>
    implements $JoinCopyWith<$Res> {
  _$JoinCopyWithImpl(this._self, this._then);

  final Join _self;
  final $Res Function(Join) _then;

/// Create a copy of ClientMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? v = null,Object? name = null,}) {
  return _then(Join(
v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class Input implements ClientMessage {
  const Input({required this.dir, final  String? $type}): $type = $type ?? 'input';
  factory Input.fromJson(Map<String, dynamic> json) => _$InputFromJson(json);

 final  Dir dir;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of ClientMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InputCopyWith<Input> get copyWith => _$InputCopyWithImpl<Input>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Input&&(identical(other.dir, dir) || other.dir == dir));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dir);

@override
String toString() {
  return 'ClientMessage.input(dir: $dir)';
}


}

/// @nodoc
abstract mixin class $InputCopyWith<$Res> implements $ClientMessageCopyWith<$Res> {
  factory $InputCopyWith(Input value, $Res Function(Input) _then) = _$InputCopyWithImpl;
@useResult
$Res call({
 Dir dir
});


$DirCopyWith<$Res> get dir;

}
/// @nodoc
class _$InputCopyWithImpl<$Res>
    implements $InputCopyWith<$Res> {
  _$InputCopyWithImpl(this._self, this._then);

  final Input _self;
  final $Res Function(Input) _then;

/// Create a copy of ClientMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? dir = null,}) {
  return _then(Input(
dir: null == dir ? _self.dir : dir // ignore: cast_nullable_to_non_nullable
as Dir,
  ));
}

/// Create a copy of ClientMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DirCopyWith<$Res> get dir {
  
  return $DirCopyWith<$Res>(_self.dir, (value) {
    return _then(_self.copyWith(dir: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class Interact implements ClientMessage {
  const Interact({final  String? $type}): $type = $type ?? 'interact';
  factory Interact.fromJson(Map<String, dynamic> json) => _$InteractFromJson(json);



@JsonKey(name: 'type')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$InteractToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Interact);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ClientMessage.interact()';
}


}




ServerMessage _$ServerMessageFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'welcome':
          return Welcome.fromJson(
            json
          );
                case 'lobby':
          return Lobby.fromJson(
            json
          );
                case 'countdown':
          return Countdown.fromJson(
            json
          );
                case 'start':
          return Start.fromJson(
            json
          );
                case 'state':
          return StateMsg.fromJson(
            json
          );
                case 'gameOver':
          return GameOver.fromJson(
            json
          );
                case 'error':
          return ErrorMsg.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'ServerMessage',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$ServerMessage {



  /// Serializes this ServerMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerMessage);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ServerMessage()';
}


}

/// @nodoc
class $ServerMessageCopyWith<$Res>  {
$ServerMessageCopyWith(ServerMessage _, $Res Function(ServerMessage) __);
}


/// Adds pattern-matching-related methods to [ServerMessage].
extension ServerMessagePatterns on ServerMessage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Welcome value)?  welcome,TResult Function( Lobby value)?  lobby,TResult Function( Countdown value)?  countdown,TResult Function( Start value)?  start,TResult Function( StateMsg value)?  state,TResult Function( GameOver value)?  gameOver,TResult Function( ErrorMsg value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Welcome() when welcome != null:
return welcome(_that);case Lobby() when lobby != null:
return lobby(_that);case Countdown() when countdown != null:
return countdown(_that);case Start() when start != null:
return start(_that);case StateMsg() when state != null:
return state(_that);case GameOver() when gameOver != null:
return gameOver(_that);case ErrorMsg() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Welcome value)  welcome,required TResult Function( Lobby value)  lobby,required TResult Function( Countdown value)  countdown,required TResult Function( Start value)  start,required TResult Function( StateMsg value)  state,required TResult Function( GameOver value)  gameOver,required TResult Function( ErrorMsg value)  error,}){
final _that = this;
switch (_that) {
case Welcome():
return welcome(_that);case Lobby():
return lobby(_that);case Countdown():
return countdown(_that);case Start():
return start(_that);case StateMsg():
return state(_that);case GameOver():
return gameOver(_that);case ErrorMsg():
return error(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Welcome value)?  welcome,TResult? Function( Lobby value)?  lobby,TResult? Function( Countdown value)?  countdown,TResult? Function( Start value)?  start,TResult? Function( StateMsg value)?  state,TResult? Function( GameOver value)?  gameOver,TResult? Function( ErrorMsg value)?  error,}){
final _that = this;
switch (_that) {
case Welcome() when welcome != null:
return welcome(_that);case Lobby() when lobby != null:
return lobby(_that);case Countdown() when countdown != null:
return countdown(_that);case Start() when start != null:
return start(_that);case StateMsg() when state != null:
return state(_that);case GameOver() when gameOver != null:
return gameOver(_that);case ErrorMsg() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function(@JsonKey(name: 'player_id')  String playerId,  WelcomeConfig config)?  welcome,TResult Function( List<LobbyPlayer> players)?  lobby,TResult Function( int seconds)?  countdown,TResult Function()?  start,TResult Function( Flag flag,  List<GamePlayer> players)?  state,TResult Function( String winner)?  gameOver,TResult Function( String reason)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Welcome() when welcome != null:
return welcome(_that.playerId,_that.config);case Lobby() when lobby != null:
return lobby(_that.players);case Countdown() when countdown != null:
return countdown(_that.seconds);case Start() when start != null:
return start();case StateMsg() when state != null:
return state(_that.flag,_that.players);case GameOver() when gameOver != null:
return gameOver(_that.winner);case ErrorMsg() when error != null:
return error(_that.reason);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function(@JsonKey(name: 'player_id')  String playerId,  WelcomeConfig config)  welcome,required TResult Function( List<LobbyPlayer> players)  lobby,required TResult Function( int seconds)  countdown,required TResult Function()  start,required TResult Function( Flag flag,  List<GamePlayer> players)  state,required TResult Function( String winner)  gameOver,required TResult Function( String reason)  error,}) {final _that = this;
switch (_that) {
case Welcome():
return welcome(_that.playerId,_that.config);case Lobby():
return lobby(_that.players);case Countdown():
return countdown(_that.seconds);case Start():
return start();case StateMsg():
return state(_that.flag,_that.players);case GameOver():
return gameOver(_that.winner);case ErrorMsg():
return error(_that.reason);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function(@JsonKey(name: 'player_id')  String playerId,  WelcomeConfig config)?  welcome,TResult? Function( List<LobbyPlayer> players)?  lobby,TResult? Function( int seconds)?  countdown,TResult? Function()?  start,TResult? Function( Flag flag,  List<GamePlayer> players)?  state,TResult? Function( String winner)?  gameOver,TResult? Function( String reason)?  error,}) {final _that = this;
switch (_that) {
case Welcome() when welcome != null:
return welcome(_that.playerId,_that.config);case Lobby() when lobby != null:
return lobby(_that.players);case Countdown() when countdown != null:
return countdown(_that.seconds);case Start() when start != null:
return start();case StateMsg() when state != null:
return state(_that.flag,_that.players);case GameOver() when gameOver != null:
return gameOver(_that.winner);case ErrorMsg() when error != null:
return error(_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class Welcome implements ServerMessage {
  const Welcome({@JsonKey(name: 'player_id') required this.playerId, required this.config, final  String? $type}): $type = $type ?? 'welcome';
  factory Welcome.fromJson(Map<String, dynamic> json) => _$WelcomeFromJson(json);

@JsonKey(name: 'player_id') final  String playerId;
 final  WelcomeConfig config;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WelcomeCopyWith<Welcome> get copyWith => _$WelcomeCopyWithImpl<Welcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WelcomeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Welcome&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.config, config) || other.config == config));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,config);

@override
String toString() {
  return 'ServerMessage.welcome(playerId: $playerId, config: $config)';
}


}

/// @nodoc
abstract mixin class $WelcomeCopyWith<$Res> implements $ServerMessageCopyWith<$Res> {
  factory $WelcomeCopyWith(Welcome value, $Res Function(Welcome) _then) = _$WelcomeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'player_id') String playerId, WelcomeConfig config
});


$WelcomeConfigCopyWith<$Res> get config;

}
/// @nodoc
class _$WelcomeCopyWithImpl<$Res>
    implements $WelcomeCopyWith<$Res> {
  _$WelcomeCopyWithImpl(this._self, this._then);

  final Welcome _self;
  final $Res Function(Welcome) _then;

/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? config = null,}) {
  return _then(Welcome(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as WelcomeConfig,
  ));
}

/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WelcomeConfigCopyWith<$Res> get config {
  
  return $WelcomeConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class Lobby implements ServerMessage {
  const Lobby({required final  List<LobbyPlayer> players, final  String? $type}): _players = players,$type = $type ?? 'lobby';
  factory Lobby.fromJson(Map<String, dynamic> json) => _$LobbyFromJson(json);

 final  List<LobbyPlayer> _players;
 List<LobbyPlayer> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LobbyCopyWith<Lobby> get copyWith => _$LobbyCopyWithImpl<Lobby>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LobbyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lobby&&const DeepCollectionEquality().equals(other._players, _players));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_players));

@override
String toString() {
  return 'ServerMessage.lobby(players: $players)';
}


}

/// @nodoc
abstract mixin class $LobbyCopyWith<$Res> implements $ServerMessageCopyWith<$Res> {
  factory $LobbyCopyWith(Lobby value, $Res Function(Lobby) _then) = _$LobbyCopyWithImpl;
@useResult
$Res call({
 List<LobbyPlayer> players
});




}
/// @nodoc
class _$LobbyCopyWithImpl<$Res>
    implements $LobbyCopyWith<$Res> {
  _$LobbyCopyWithImpl(this._self, this._then);

  final Lobby _self;
  final $Res Function(Lobby) _then;

/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? players = null,}) {
  return _then(Lobby(
players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<LobbyPlayer>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class Countdown implements ServerMessage {
  const Countdown({required this.seconds, final  String? $type}): $type = $type ?? 'countdown';
  factory Countdown.fromJson(Map<String, dynamic> json) => _$CountdownFromJson(json);

 final  int seconds;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountdownCopyWith<Countdown> get copyWith => _$CountdownCopyWithImpl<Countdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CountdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Countdown&&(identical(other.seconds, seconds) || other.seconds == seconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,seconds);

@override
String toString() {
  return 'ServerMessage.countdown(seconds: $seconds)';
}


}

/// @nodoc
abstract mixin class $CountdownCopyWith<$Res> implements $ServerMessageCopyWith<$Res> {
  factory $CountdownCopyWith(Countdown value, $Res Function(Countdown) _then) = _$CountdownCopyWithImpl;
@useResult
$Res call({
 int seconds
});




}
/// @nodoc
class _$CountdownCopyWithImpl<$Res>
    implements $CountdownCopyWith<$Res> {
  _$CountdownCopyWithImpl(this._self, this._then);

  final Countdown _self;
  final $Res Function(Countdown) _then;

/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? seconds = null,}) {
  return _then(Countdown(
seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class Start implements ServerMessage {
  const Start({final  String? $type}): $type = $type ?? 'start';
  factory Start.fromJson(Map<String, dynamic> json) => _$StartFromJson(json);



@JsonKey(name: 'type')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$StartToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Start);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ServerMessage.start()';
}


}




/// @nodoc
@JsonSerializable()

class StateMsg implements ServerMessage {
  const StateMsg({required this.flag, required final  List<GamePlayer> players, final  String? $type}): _players = players,$type = $type ?? 'state';
  factory StateMsg.fromJson(Map<String, dynamic> json) => _$StateMsgFromJson(json);

 final  Flag flag;
 final  List<GamePlayer> _players;
 List<GamePlayer> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StateMsgCopyWith<StateMsg> get copyWith => _$StateMsgCopyWithImpl<StateMsg>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StateMsgToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StateMsg&&(identical(other.flag, flag) || other.flag == flag)&&const DeepCollectionEquality().equals(other._players, _players));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,flag,const DeepCollectionEquality().hash(_players));

@override
String toString() {
  return 'ServerMessage.state(flag: $flag, players: $players)';
}


}

/// @nodoc
abstract mixin class $StateMsgCopyWith<$Res> implements $ServerMessageCopyWith<$Res> {
  factory $StateMsgCopyWith(StateMsg value, $Res Function(StateMsg) _then) = _$StateMsgCopyWithImpl;
@useResult
$Res call({
 Flag flag, List<GamePlayer> players
});


$FlagCopyWith<$Res> get flag;

}
/// @nodoc
class _$StateMsgCopyWithImpl<$Res>
    implements $StateMsgCopyWith<$Res> {
  _$StateMsgCopyWithImpl(this._self, this._then);

  final StateMsg _self;
  final $Res Function(StateMsg) _then;

/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? flag = null,Object? players = null,}) {
  return _then(StateMsg(
flag: null == flag ? _self.flag : flag // ignore: cast_nullable_to_non_nullable
as Flag,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<GamePlayer>,
  ));
}

/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FlagCopyWith<$Res> get flag {
  
  return $FlagCopyWith<$Res>(_self.flag, (value) {
    return _then(_self.copyWith(flag: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class GameOver implements ServerMessage {
  const GameOver({required this.winner, final  String? $type}): $type = $type ?? 'gameOver';
  factory GameOver.fromJson(Map<String, dynamic> json) => _$GameOverFromJson(json);

 final  String winner;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameOverCopyWith<GameOver> get copyWith => _$GameOverCopyWithImpl<GameOver>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameOverToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameOver&&(identical(other.winner, winner) || other.winner == winner));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,winner);

@override
String toString() {
  return 'ServerMessage.gameOver(winner: $winner)';
}


}

/// @nodoc
abstract mixin class $GameOverCopyWith<$Res> implements $ServerMessageCopyWith<$Res> {
  factory $GameOverCopyWith(GameOver value, $Res Function(GameOver) _then) = _$GameOverCopyWithImpl;
@useResult
$Res call({
 String winner
});




}
/// @nodoc
class _$GameOverCopyWithImpl<$Res>
    implements $GameOverCopyWith<$Res> {
  _$GameOverCopyWithImpl(this._self, this._then);

  final GameOver _self;
  final $Res Function(GameOver) _then;

/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? winner = null,}) {
  return _then(GameOver(
winner: null == winner ? _self.winner : winner // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ErrorMsg implements ServerMessage {
  const ErrorMsg({required this.reason, final  String? $type}): $type = $type ?? 'error';
  factory ErrorMsg.fromJson(Map<String, dynamic> json) => _$ErrorMsgFromJson(json);

 final  String reason;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorMsgCopyWith<ErrorMsg> get copyWith => _$ErrorMsgCopyWithImpl<ErrorMsg>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ErrorMsgToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ErrorMsg&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'ServerMessage.error(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $ErrorMsgCopyWith<$Res> implements $ServerMessageCopyWith<$Res> {
  factory $ErrorMsgCopyWith(ErrorMsg value, $Res Function(ErrorMsg) _then) = _$ErrorMsgCopyWithImpl;
@useResult
$Res call({
 String reason
});




}
/// @nodoc
class _$ErrorMsgCopyWithImpl<$Res>
    implements $ErrorMsgCopyWith<$Res> {
  _$ErrorMsgCopyWithImpl(this._self, this._then);

  final ErrorMsg _self;
  final $Res Function(ErrorMsg) _then;

/// Create a copy of ServerMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(ErrorMsg(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
