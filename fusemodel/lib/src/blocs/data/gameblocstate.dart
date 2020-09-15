import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../game.dart';
import '../../serializer.dart';

part 'gameblocstate.g.dart';

class GameBlocStateType extends EnumClass {
  static Serializer<GameBlocStateType> get serializer =>
      _$gameBlocStateTypeSerializer;

  static const GameBlocStateType Uninitialized = _$uninitialized;
  static const GameBlocStateType Loaded = _$loaded;

  const GameBlocStateType._(String name) : super(name);

  static BuiltSet<GameBlocStateType> get values => _$values;

  static GameBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the game bloc.  It tracks all the
/// exciting game stuff.
///
@BuiltValue(instantiable: false)
abstract class GameState with GameMixin {
  DateTime get start;
  DateTime get end;
  GameBlocStateType get type;

  @override
  BuiltMap<String, Game> get gamesByTeamToSerialize;
  @override
  BuiltMap<String, GameSharedData> get sharedGameDataToSerialize;

  // Don't save this stuff
  @BuiltValueField(serialize: false)
  bool get loadedFirestore;
  @override
  @BuiltValueField(serialize: false)
  BuiltMap<String, BuiltMap<String, Game>> get gamesByTeam;
  @override
  @BuiltValueField(serialize: false)
  BuiltMap<String, GameSharedData> get sharedGameData;

  static GameStateBuilder fromState(GameState state, GameStateBuilder builder) {
    return builder
      ..gamesByTeam = state.gamesByTeam.toBuilder()
      ..sharedGameData = state.sharedGameData.toBuilder()
      ..start = state.start
      ..end = state.end
      ..loadedFirestore = state.loadedFirestore;
  }

  static void initializeStateBuilder(GameStateBuilder b) => b
    ..loadedFirestore = false
    ..start = new DateTime.now().subtract(new Duration(days: 60)).toUtc()
    ..end = new DateTime.now().add(new Duration(days: 240)).toUtc();

  Map<String, dynamic> toMap();
}

abstract class GameMixin {
  BuiltMap<String, BuiltMap<String, Game>> get gamesByTeam;
  BuiltMap<String, GameSharedData> get sharedGameData;

  ///
  /// Finds the game in the currently loaded set of games.
  ///
  Game getGame(String uid) {
    for (BuiltMap<String, Game> games in gamesByTeam.values) {
      if (games.containsKey(uid)) {
        return games[uid];
      }
    }
    return null;
  }

  ///
  /// Finds the shared details for the game out of the loaded set.
  ///
  GameSharedData getSharedData(String uid) {
    if (sharedGameData.containsKey(uid)) {
      return sharedGameData[uid];
    }
    return null;
  }
}

///
/// The game loaded from the database.
///
abstract class GameLoaded
    with GameMixin
    implements GameState, Built<GameLoaded, GameLoadedBuilder> {
  GameLoaded._();
  factory GameLoaded([void Function(GameLoadedBuilder) updates]) = _$GameLoaded;

  static GameLoadedBuilder fromState(GameState state) {
    return GameState.fromState(state, GameLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(GameLoadedBuilder b) {
    GameState.initializeStateBuilder(b);

    b..type = GameBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GameLoaded.serializer, this);
  }

  static GameLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(GameLoaded.serializer, jsonData);
  }

  static Serializer<GameLoaded> get serializer => _$gameLoadedSerializer;
}

///
/// The game bloc that is uninitialized.
///
abstract class GameUninitialized
    with GameMixin
    implements GameState, Built<GameUninitialized, GameUninitializedBuilder> {
  GameUninitialized._();
  factory GameUninitialized([void Function(GameUninitializedBuilder) updates]) =
      _$GameUninitialized;

  static GameUninitializedBuilder fromState(GameState state) {
    return GameUninitializedBuilder()
      ..gamesByTeam.clear()
      ..sharedGameData.clear()
      ..loadedFirestore = false;
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(GameUninitializedBuilder b) {
    GameState.initializeStateBuilder(b);

    b..type = GameBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GameUninitialized.serializer, this);
  }

  static GameUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(GameUninitialized.serializer, jsonData);
  }

  static Serializer<GameUninitialized> get serializer =>
      _$gameUninitializedSerializer;
}