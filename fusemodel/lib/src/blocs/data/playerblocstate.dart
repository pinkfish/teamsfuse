import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../serializer.dart';

part 'playerblocstate.g.dart';

class PlayerBlocStateType extends EnumClass {
  static Serializer<PlayerBlocStateType> get serializer =>
      _$playerBlocStateTypeSerializer;

  static const PlayerBlocStateType Uninitialized = _$uninitialized;
  static const PlayerBlocStateType Loaded = _$loaded;

  const PlayerBlocStateType._(String name) : super(name);

  static BuiltSet<PlayerBlocStateType> get values => _$values;

  static PlayerBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the player bloc.  It tracks all the
/// exciting player stuff.
///
@BuiltValue(instantiable: false)
abstract class PlayerState with PlayerMixin {
  @override
  BuiltMap<String, Player> get players;
  @override
  BuiltMap<String, Player> get extraPlayers;
  @nullable
  Player get me;
  PlayerBlocStateType get type;

  // Don't save this stuff.
  @BuiltValueField(serialize: false)
  bool get loadedFirestore;

  static PlayerStateBuilder fromState(
      PlayerState state, PlayerStateBuilder builder) {
    return builder
      ..players = state.players.toBuilder()
      ..extraPlayers = state.extraPlayers.toBuilder()
      ..me = state.me?.toBuilder()
      ..loadedFirestore = state.loadedFirestore;
  }

  static void initializeStateBuilder(PlayerStateBuilder b) =>
      b..loadedFirestore = false;

  Map<String, dynamic> toMap();
}

///
/// Mixin to handle some extra stuff.
///
abstract class PlayerMixin {
  BuiltMap<String, Player> get players;
  BuiltMap<String, Player> get extraPlayers;

  ///
  /// Look up the specific player in the current state.
  ///
  Player getPlayer(String uid) {
    if (players.containsKey(uid)) {
      return players[uid];
    }
    if (extraPlayers.containsKey(uid)) {
      return extraPlayers[uid];
    }
    return null;
  }
}

///
/// The player loaded from the database.
///
abstract class PlayerLoaded
    with PlayerMixin
    implements PlayerState, Built<PlayerLoaded, PlayerLoadedBuilder> {
  PlayerLoaded._();
  factory PlayerLoaded([void Function(PlayerLoadedBuilder) updates]) =
      _$PlayerLoaded;

  static PlayerLoadedBuilder fromState(PlayerState state) {
    return PlayerState.fromState(state, PlayerLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(PlayerLoadedBuilder b) {
    PlayerState.initializeStateBuilder(b);

    b..type = PlayerBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(PlayerLoaded.serializer, this);
  }

  static PlayerLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(PlayerLoaded.serializer, jsonData);
  }

  static Serializer<PlayerLoaded> get serializer => _$playerLoadedSerializer;
}

///
/// The player bloc that is unitialized.
///
abstract class PlayerUninitialized
    with PlayerMixin
    implements
        PlayerState,
        Built<PlayerUninitialized, PlayerUninitializedBuilder> {
  PlayerUninitialized._();
  factory PlayerUninitialized(
          [void Function(PlayerUninitializedBuilder) updates]) =
      _$PlayerUninitialized;

  static PlayerUninitializedBuilder fromState(PlayerState state) {
    return PlayerState.fromState(state, PlayerUninitializedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(PlayerUninitializedBuilder b) {
    PlayerState.initializeStateBuilder(b);

    b..type = PlayerBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(PlayerUninitialized.serializer, this);
  }

  static PlayerUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        PlayerUninitialized.serializer, jsonData);
  }

  static Serializer<PlayerUninitialized> get serializer =>
      _$playerUninitializedSerializer;
}
