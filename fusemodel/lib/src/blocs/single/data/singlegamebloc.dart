import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../serializer.dart';

part 'singlegamebloc.g.dart';

///
/// The type of the game bloc state.
///
class SingleGameBlocStateType extends EnumClass {
  /// The serializer for the enum class.
  static Serializer<SingleGameBlocStateType> get serializer =>
      _$singleGameBlocStateTypeSerializer;

  /// The game bloc is uninitialized.
  static const SingleGameBlocStateType Uninitialized = _$uninitialized;

  /// The game bloc is loaded.
  static const SingleGameBlocStateType Loaded = _$loaded;

  /// The game bloc is deleted.
  static const SingleGameBlocStateType Deleted = _$deleted;

  /// The game save failed.
  static const SingleGameBlocStateType SaveFailed = _$saveFailed;

  /// The game is saving.
  static const SingleGameBlocStateType Saving = _$saving;

  /// The game saving is done.
  static const SingleGameBlocStateType SaveDone = _$saveDone;

  /// If there was a game change that happened.
  static const SingleGameBlocStateType SingleGameChange = _$singleGameChange;

  const SingleGameBlocStateType._(String name) : super(name);

  static BuiltSet<SingleGameBlocStateType> get values => _$values;

  static SingleGameBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The summary with the opponent flag.
///
class PlayerSummaryWithOpponent {
  /// The game player summary to find.
  final GamePlayerSummary summary;

  /// If this is for an opponent.
  final bool opponent;

  /// Creates the player summary.
  PlayerSummaryWithOpponent(this.opponent, this.summary);
}

///
/// The base state for the singleGame bloc.  It tracks all the
/// exciting singleGame stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleGameState {
  /// The game that is loaded.
  @nullable
  Game get game;

  /// The game log associated with the name.
  @BuiltValueField(serialize: false)
  BuiltList<GameLog> get gameLog;

  /// The logs associated with the game
  @BuiltValueField(serialize: false)
  bool get loadedLogs;

  /// The events associated with the events.
  @BuiltValueField(serialize: false)
  BuiltList<GameEvent> get gameEvents;

  /// The events are loaded.
  @BuiltValueField(serialize: false)
  bool get loadedEvents;

  /// The list of media for the game.
  @BuiltValueField(serialize: false)
  BuiltList<MediaInfo> get media;

  /// If the media is loaded.
  @BuiltValueField(serialize: false)
  bool get loadedMedia;

  /// The players associated with the game.
  @BuiltValueField(serialize: false)
  BuiltMap<String, Player> get players;

  /// If the playerss are loaded.
  @BuiltValueField(serialize: false)
  bool get loadedPlayers;

  /// If the opponent players are loaded.
  @BuiltValueField(serialize: false)
  bool get loadedOpponentPlayers;

  /// The type of the game bloc.
  SingleGameBlocStateType get type;

  /// Create a builder from the current state.
  static SingleGameStateBuilder fromState(
      SingleGameState state, SingleGameStateBuilder builder) {
    return builder
      ..game = state.game?.toBuilder()
      ..gameLog = state.gameLog.toBuilder()
      ..gameEvents = state.gameEvents.toBuilder()
      ..media = state.media.toBuilder()
      ..players = state.players.toBuilder()
      ..loadedLogs = state.loadedLogs
      ..loadedEvents = state.loadedEvents
      ..loadedMedia = state.loadedMedia
      ..loadedPlayers = state.loadedPlayers
      ..loadedOpponentPlayers = state.loadedOpponentPlayers;
  }

  /// Initialize the builder with the defaults.
  static void initializeStateBuilder(SingleGameStateBuilder b) => b
    ..loadedLogs = false
    ..loadedEvents = false
    ..loadedMedia = false
    ..loadedOpponentPlayers = false
    ..loadedPlayers = false;

  /// Create a map from the state, serialize it.
  Map<String, dynamic> toMap();
}

///
/// The singleGame loaded from the database.
///
abstract class SingleGameLoaded
    implements
        SingleGameState,
        Built<SingleGameLoaded, SingleGameLoadedBuilder> {
  SingleGameLoaded._();
  factory SingleGameLoaded([void Function(SingleGameLoadedBuilder) updates]) =
      _$SingleGameLoaded;

  static SingleGameLoadedBuilder fromState(SingleGameState state) {
    return SingleGameState.fromState(state, SingleGameLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleGameLoadedBuilder b) {
    SingleGameState.initializeStateBuilder(b);

    b.type = SingleGameBlocStateType.Loaded;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameLoaded.serializer, this);
  }

  static SingleGameLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleGameLoaded.serializer, jsonData);
  }

  static Serializer<SingleGameLoaded> get serializer =>
      _$singleGameLoadedSerializer;
}

///
/// We have a game, events gone wild.
///
abstract class SingleGameChangeEvents
    implements
        SingleGameState,
        Built<SingleGameChangeEvents, SingleGameChangeEventsBuilder> {
  BuiltList<GameEvent> get removedEvents;
  BuiltList<GameEvent> get newEvents;

  SingleGameChangeEvents._();
  factory SingleGameChangeEvents(
          [void Function(SingleGameChangeEventsBuilder) updates]) =
      _$SingleGameChangeEvents;

  static SingleGameChangeEventsBuilder fromState(SingleGameState state) {
    return SingleGameState.fromState(state, SingleGameChangeEventsBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.

  static void _initializeBuilder(SingleGameChangeEventsBuilder b) {
    SingleGameState.initializeStateBuilder(b);

    b.type = SingleGameBlocStateType.SingleGameChange;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameChangeEvents.serializer, this);
  }

  static SingleGameChangeEvents fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleGameChangeEvents.serializer, jsonData);
  }

  static Serializer<SingleGameChangeEvents> get serializer =>
      _$singleGameChangeEventsSerializer;
}

///
/// The singleGame bloc that is unitialized.
///
abstract class SingleGameUninitialized
    implements
        SingleGameState,
        Built<SingleGameUninitialized, SingleGameUninitializedBuilder> {
  SingleGameUninitialized._();
  factory SingleGameUninitialized(
          [void Function(SingleGameUninitializedBuilder) updates]) =
      _$SingleGameUninitialized;

  static SingleGameUninitializedBuilder fromState(SingleGameState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleGameUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleGameUninitializedBuilder b) {
    SingleGameState.initializeStateBuilder(b);

    b.type = SingleGameBlocStateType.Uninitialized;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameUninitialized.serializer, this);
  }

  static SingleGameUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleGameUninitialized.serializer, jsonData);
  }

  static Serializer<SingleGameUninitialized> get serializer =>
      _$singleGameUninitializedSerializer;
}

///
/// The singleGame bloc that is unitialized.
///
abstract class SingleGameDeleted
    implements
        SingleGameState,
        Built<SingleGameDeleted, SingleGameDeletedBuilder> {
  SingleGameDeleted._();
  factory SingleGameDeleted([void Function(SingleGameDeletedBuilder) updates]) =
      _$SingleGameDeleted;

  static SingleGameDeletedBuilder fromState(SingleGameState state) {
    // Nothing set in this case, just the type.
    return SingleGameDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleGameDeletedBuilder b) {
    SingleGameState.initializeStateBuilder(b);

    b.type = SingleGameBlocStateType.Deleted;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameDeleted.serializer, this);
  }

  static SingleGameDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleGameDeleted.serializer, jsonData);
  }

  static Serializer<SingleGameDeleted> get serializer =>
      _$singleGameDeletedSerializer;
}

///
/// The singleGame bloc that is unitialized.
///
abstract class SingleGameSaveFailed
    implements
        SingleGameState,
        Built<SingleGameSaveFailed, SingleGameSaveFailedBuilder> {
  @BuiltValueField(serialize: false)
  Object get error;

  SingleGameSaveFailed._();
  factory SingleGameSaveFailed(
          [void Function(SingleGameSaveFailedBuilder) updates]) =
      _$SingleGameSaveFailed;

  static SingleGameSaveFailedBuilder fromState(SingleGameState state) {
    return SingleGameState.fromState(state, SingleGameSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleGameSaveFailedBuilder b) {
    SingleGameState.initializeStateBuilder(b);

    b.type = SingleGameBlocStateType.SaveFailed;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameSaveFailed.serializer, this);
  }

  static SingleGameSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleGameSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleGameSaveFailed> get serializer =>
      _$singleGameSaveFailedSerializer;
}

///
/// The singleGame bloc that is unitialized.
///
abstract class SingleGameSaving
    implements
        SingleGameState,
        Built<SingleGameSaving, SingleGameSavingBuilder> {
  SingleGameSaving._();
  factory SingleGameSaving([void Function(SingleGameSavingBuilder) updates]) =
      _$SingleGameSaving;

  static SingleGameSavingBuilder fromState(SingleGameState state) {
    return SingleGameState.fromState(state, SingleGameSavingBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleGameSavingBuilder b) {
    SingleGameState.initializeStateBuilder(b);

    b.type = SingleGameBlocStateType.Saving;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameSaving.serializer, this);
  }

  static SingleGameSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleGameSaving.serializer, jsonData);
  }

  static Serializer<SingleGameSaving> get serializer =>
      _$singleGameSavingSerializer;
}

///
/// The singleGame bloc that is saving.
///
abstract class SingleGameSaveDone
    implements
        SingleGameState,
        Built<SingleGameSaveDone, SingleGameSaveDoneBuilder> {
  SingleGameSaveDone._();
  factory SingleGameSaveDone(
          [void Function(SingleGameSaveDoneBuilder) updates]) =
      _$SingleGameSaveDone;

  static SingleGameSaveDoneBuilder fromState(SingleGameState state) {
    return SingleGameState.fromState(state, SingleGameSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleGameSaveDoneBuilder b) {
    SingleGameState.initializeStateBuilder(b);

    b.type = SingleGameBlocStateType.SaveDone;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameSaveDone.serializer, this);
  }

  static SingleGameSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleGameSaveDone.serializer, jsonData);
  }

  static Serializer<SingleGameSaveDone> get serializer =>
      _$singleGameSaveDoneSerializer;
}
