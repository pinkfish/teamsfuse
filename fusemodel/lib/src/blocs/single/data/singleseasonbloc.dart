import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../serializer.dart';

part 'singleseasonbloc.g.dart';

///
/// The type of the season bloc state.
///
class SingleSeasonBlocStateType extends EnumClass {
  /// Serialized for the state type.
  static Serializer<SingleSeasonBlocStateType> get serializer =>
      _$singleSeasonBlocStateTypeSerializer;

  /// The uninitialized bloc state.
  static const SingleSeasonBlocStateType Uninitialized = _$uninitialized;

  /// The loaded bloc state.
  static const SingleSeasonBlocStateType Loaded = _$loaded;

  /// The season is deleted.
  static const SingleSeasonBlocStateType Deleted = _$deleted;

  /// If the save failed for this season.
  static const SingleSeasonBlocStateType SaveFailed = _$saveFailed;

  /// If the save is in progress for this season.
  static const SingleSeasonBlocStateType Saving = _$saving;

  /// If the save is done for the season.
  static const SingleSeasonBlocStateType SaveDone = _$saveDone;

  const SingleSeasonBlocStateType._(String name) : super(name);

  /// The values, all the enum types, for the season bloc type.
  static BuiltSet<SingleSeasonBlocStateType> get values => _$values;

  /// Getthe season bloc type for the specified name.
  static SingleSeasonBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the singleSeason bloc.  It tracks all the
/// exciting singleSeason stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleSeasonState with SingleSeasonStateMixin {
  /// The season information.
  @nullable
  Season get season;

  /// The games associated with the season.
  BuiltList<Game> get games;

  /// If the games are loaded.
  bool get loadedGames;

  /// The loaded media.
  BuiltList<MediaInfo> get media;

  /// If the media is loaded.
  bool get loadedMedia;

  /// If the players are loaded.
  bool get loadedPlayers;

  /// Gets the full player for the season state.
  @override
  BuiltMap<String, Player> get fullPlayer;

  /// The type of the season bloc.
  SingleSeasonBlocStateType get type;

  /// Create a season bloc from the state.
  static SingleSeasonStateBuilder fromState(
      SingleSeasonState state, SingleSeasonStateBuilder builder) {
    return builder
      ..loadedGames = state.loadedGames
      ..loadedMedia = state.loadedMedia
      ..loadedPlayers = state.loadedPlayers
      ..fullPlayer = state.fullPlayer.toBuilder()
      ..season = state.season?.toBuilder()
      ..media = state.media.toBuilder()
      ..games = state.games.toBuilder();
  }

  /// Initialize the builder from the state.
  static void initializeStateBuilder(SingleSeasonStateBuilder b) => b
    ..loadedGames = false
    ..loadedPlayers = false
    ..loadedMedia = false;

  /// Create the serialized data from the state.
  Map<String, dynamic> toMap();
}

abstract class SingleSeasonStateMixin {
  /// Gets the full player for the season state.
  BuiltMap<String, Player> get fullPlayer;

  /// Gets the name of the player, '' if not loaded.
  String getPlayerName(String playerUid) {
    if (fullPlayer.containsKey(playerUid)) {
      return fullPlayer[playerUid].name;
    }
    return '';
  }
}

///
/// The singleSeason loaded from the database.
///
abstract class SingleSeasonLoaded
    with SingleSeasonStateMixin
    implements
        SingleSeasonState,
        Built<SingleSeasonLoaded, SingleSeasonLoadedBuilder> {
  SingleSeasonLoaded._();

  /// The single season loaded data.
  factory SingleSeasonLoaded(
          [void Function(SingleSeasonLoadedBuilder) updates]) =
      _$SingleSeasonLoaded;

  /// Create the loaded builder from the state.
  static SingleSeasonLoadedBuilder fromState(SingleSeasonState state) {
    return SingleSeasonState.fromState(state, SingleSeasonLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSeasonLoadedBuilder b) {
    SingleSeasonState.initializeStateBuilder(b);

    b.type = SingleSeasonBlocStateType.Loaded;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSeasonLoaded.serializer, this);
  }

  /// Serialize the state from the bloc data.
  static SingleSeasonLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleSeasonLoaded.serializer, jsonData);
  }

  /// The serializer for the bloc type.
  static Serializer<SingleSeasonLoaded> get serializer =>
      _$singleSeasonLoadedSerializer;
}

///
/// The singleSeason bloc that is unitialized.
///
abstract class SingleSeasonUninitialized
    with SingleSeasonStateMixin
    implements
        SingleSeasonState,
        Built<SingleSeasonUninitialized, SingleSeasonUninitializedBuilder> {
  SingleSeasonUninitialized._();
  factory SingleSeasonUninitialized(
          [void Function(SingleSeasonUninitializedBuilder) updates]) =
      _$SingleSeasonUninitialized;

  static SingleSeasonUninitializedBuilder fromState(SingleSeasonState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleSeasonUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSeasonUninitializedBuilder b) {
    SingleSeasonState.initializeStateBuilder(b);

    b.type = SingleSeasonBlocStateType.Uninitialized;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleSeasonUninitialized.serializer, this);
  }

  static SingleSeasonUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleSeasonUninitialized.serializer, jsonData);
  }

  static Serializer<SingleSeasonUninitialized> get serializer =>
      _$singleSeasonUninitializedSerializer;
}

///
/// The singleSeason bloc that is unitialized.
///
abstract class SingleSeasonDeleted
    with SingleSeasonStateMixin
    implements
        SingleSeasonState,
        Built<SingleSeasonDeleted, SingleSeasonDeletedBuilder> {
  SingleSeasonDeleted._();
  factory SingleSeasonDeleted(
          [void Function(SingleSeasonDeletedBuilder) updates]) =
      _$SingleSeasonDeleted;

  static SingleSeasonDeletedBuilder fromState(SingleSeasonState state) {
    // Nothing set in this case, just the type.
    return SingleSeasonDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSeasonDeletedBuilder b) {
    SingleSeasonState.initializeStateBuilder(b);

    b.type = SingleSeasonBlocStateType.Deleted;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSeasonDeleted.serializer, this);
  }

  static SingleSeasonDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleSeasonDeleted.serializer, jsonData);
  }

  static Serializer<SingleSeasonDeleted> get serializer =>
      _$singleSeasonDeletedSerializer;
}

///
/// The singleSeason bloc that is unitialized.
///
abstract class SingleSeasonSaveFailed
    with SingleSeasonStateMixin
    implements
        SingleSeasonState,
        Built<SingleSeasonSaveFailed, SingleSeasonSaveFailedBuilder> {
  @BuiltValueField(serialize: false)
  Object get error;

  SingleSeasonSaveFailed._();
  factory SingleSeasonSaveFailed(
          [void Function(SingleSeasonSaveFailedBuilder) updates]) =
      _$SingleSeasonSaveFailed;

  static SingleSeasonSaveFailedBuilder fromState(SingleSeasonState state) {
    return SingleSeasonState.fromState(state, SingleSeasonSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSeasonSaveFailedBuilder b) {
    SingleSeasonState.initializeStateBuilder(b);

    b.type = SingleSeasonBlocStateType.SaveFailed;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSeasonSaveFailed.serializer, this);
  }

  static SingleSeasonSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleSeasonSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleSeasonSaveFailed> get serializer =>
      _$singleSeasonSaveFailedSerializer;
}

///
/// The singleSeason bloc that is unitialized.
///
abstract class SingleSeasonSaving
    with SingleSeasonStateMixin
    implements
        SingleSeasonState,
        Built<SingleSeasonSaving, SingleSeasonSavingBuilder> {
  SingleSeasonSaving._();
  factory SingleSeasonSaving(
          [void Function(SingleSeasonSavingBuilder) updates]) =
      _$SingleSeasonSaving;

  static SingleSeasonSavingBuilder fromState(SingleSeasonState state) {
    return SingleSeasonState.fromState(state, SingleSeasonSavingBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSeasonSavingBuilder b) {
    SingleSeasonState.initializeStateBuilder(b);

    b.type = SingleSeasonBlocStateType.Saving;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSeasonSaving.serializer, this);
  }

  static SingleSeasonSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleSeasonSaving.serializer, jsonData);
  }

  static Serializer<SingleSeasonSaving> get serializer =>
      _$singleSeasonSavingSerializer;
}

///
/// The singleSeason bloc that is saving.
///
abstract class SingleSeasonSaveDone
    with SingleSeasonStateMixin
    implements
        SingleSeasonState,
        Built<SingleSeasonSaveDone, SingleSeasonSaveDoneBuilder> {
  SingleSeasonSaveDone._();
  factory SingleSeasonSaveDone(
          [void Function(SingleSeasonSaveDoneBuilder) updates]) =
      _$SingleSeasonSaveDone;

  static SingleSeasonSaveDoneBuilder fromState(SingleSeasonState state) {
    return SingleSeasonState.fromState(state, SingleSeasonSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSeasonSaveDoneBuilder b) {
    SingleSeasonState.initializeStateBuilder(b);

    b.type = SingleSeasonBlocStateType.SaveDone;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSeasonSaveDone.serializer, this);
  }

  static SingleSeasonSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleSeasonSaveDone.serializer, jsonData);
  }

  static Serializer<SingleSeasonSaveDone> get serializer =>
      _$singleSeasonSaveDoneSerializer;
}
