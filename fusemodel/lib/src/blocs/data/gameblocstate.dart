import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:clock/clock.dart';
import 'package:fusemodel/fusemodel.dart';

import '../serializer.dart';

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

  BuiltMap<String, Game> get gamesByTeamToSerialize;

  // Don't save this stuff
  @BuiltValueField(serialize: false)
  bool get loadedFirestore;
  @override
  @BuiltValueField(serialize: false)
  BuiltMap<String, BuiltList<Game>> get gamesByTeam;

  static GameStateBuilder fromState(GameState state, GameStateBuilder builder) {
    return builder
      ..gamesByTeam = state.gamesByTeam.toBuilder()
      ..gamesByTeamToSerialize = state.gamesByTeamToSerialize.toBuilder()
      ..start = state.start
      ..end = state.end
      ..loadedFirestore = state.loadedFirestore;
  }

  static void initializeStateBuilder(GameStateBuilder b) => b
    ..loadedFirestore = false
    ..start = clock.now().subtract(Duration(days: 60)).toUtc()
    ..end = clock.now().add(Duration(days: 240)).toUtc();

  Map<String, dynamic> toMap();
}

abstract class GameMixin {
  BuiltMap<String, BuiltList<Game>> get gamesByTeam;

  ///
  /// Finds the game in the currently loaded set of games.
  ///
  Game getGame(String uid) {
    for (var games in gamesByTeam.values) {
      var val = games.where((g) => g.uid == uid);
      if (val.isNotEmpty) {
        return val.first;
      }
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
