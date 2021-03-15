import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../serializer.dart';

part 'singleplayerbloc.g.dart';

///
/// The type of the player bloc state.
///
class SinglePlayerBlocStateType extends EnumClass {
  static Serializer<SinglePlayerBlocStateType> get serializer =>
      _$singlePlayerBlocStateTypeSerializer;

  static const SinglePlayerBlocStateType Uninitialized = _$uninitialized;
  static const SinglePlayerBlocStateType Loaded = _$loaded;
  static const SinglePlayerBlocStateType Deleted = _$deleted;
  static const SinglePlayerBlocStateType SaveFailed = _$saveFailed;
  static const SinglePlayerBlocStateType Saving = _$saving;
  static const SinglePlayerBlocStateType SaveDone = _$saveDone;

  const SinglePlayerBlocStateType._(String name) : super(name);

  static BuiltSet<SinglePlayerBlocStateType> get values => _$values;

  static SinglePlayerBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the singlePlayer bloc.  It tracks all the
/// exciting singlePlayer stuff.
///
@BuiltValue(instantiable: false)
abstract class SinglePlayerState {
  /// The player associated with this when loaded.
  @nullable
  Player get player;

  /// If this is the me player.
  bool get mePlayer;

  /// The type of the bloc state.
  SinglePlayerBlocStateType get type;

  // Local only data.
  /// The invites are loaded.
  @BuiltValueField(serialize: false)
  bool get loadedInvites;

  /// The loasded invites.
  @BuiltValueField(serialize: false)
  BuiltList<InviteToPlayer> get invites;

  /// If the seasons are loaded.
  @BuiltValueField(serialize: false)
  bool get loadedSeasons;

  /// The loaded seasons.
  @BuiltValueField(serialize: false)
  BuiltList<Season> get seasons;

  /// The loaded media.
  BuiltList<MediaInfo> get media;

  /// If the media is loaded.
  bool get loadedMedia;

  /// Create the state buider from the previous state.
  static SinglePlayerStateBuilder fromState(
      SinglePlayerState state, SinglePlayerStateBuilder builder) {
    return builder
      ..player = state.player?.toBuilder()
      ..mePlayer = state.mePlayer
      ..invites = state.invites.toBuilder()
      ..loadedInvites = state.loadedInvites
      ..loadedSeasons = state.loadedSeasons
      ..loadedMedia = state.loadedMedia
      ..media = state.media.toBuilder()
      ..seasons = state.seasons.toBuilder();
  }

  /// Initialize the builder from the base state.
  static void initializeStateBuilder(SinglePlayerStateBuilder b) => b
    ..loadedInvites = false
    ..loadedSeasons = false
    ..loadedMedia = false
    ..mePlayer = false;

  /// Seriaize the data from the bloc state.
  Map<String, dynamic> toMap();
}

///
/// The singlePlayer loaded from the database.
///
abstract class SinglePlayerLoaded
    implements
        SinglePlayerState,
        Built<SinglePlayerLoaded, SinglePlayerLoadedBuilder> {
  SinglePlayerLoaded._();

  /// The loaded state from the bloc.
  factory SinglePlayerLoaded(
          [void Function(SinglePlayerLoadedBuilder) updates]) =
      _$SinglePlayerLoaded;

  /// Create the builder from the state.
  static SinglePlayerLoadedBuilder fromState(SinglePlayerState state) {
    return SinglePlayerState.fromState(state, SinglePlayerLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SinglePlayerLoadedBuilder b) {
    SinglePlayerState.initializeStateBuilder(b);

    b.type = SinglePlayerBlocStateType.Loaded;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SinglePlayerLoaded.serializer, this);
  }

  /// Create the bloc from the seriaized data.
  static SinglePlayerLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SinglePlayerLoaded.serializer, jsonData);
  }

  /// The serializer for the bloc state.
  static Serializer<SinglePlayerLoaded> get serializer =>
      _$singlePlayerLoadedSerializer;
}

///
/// The singlePlayer bloc that is unitialized.
///
abstract class SinglePlayerUninitialized
    implements
        SinglePlayerState,
        Built<SinglePlayerUninitialized, SinglePlayerUninitializedBuilder> {
  SinglePlayerUninitialized._();
  factory SinglePlayerUninitialized(
          [void Function(SinglePlayerUninitializedBuilder) updates]) =
      _$SinglePlayerUninitialized;

  static SinglePlayerUninitializedBuilder fromState(SinglePlayerState state) {
    // Nothing set in this case, just the type and defaults.
    return SinglePlayerUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SinglePlayerUninitializedBuilder b) {
    SinglePlayerState.initializeStateBuilder(b);

    b.type = SinglePlayerBlocStateType.Uninitialized;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SinglePlayerUninitialized.serializer, this);
  }

  static SinglePlayerUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SinglePlayerUninitialized.serializer, jsonData);
  }

  static Serializer<SinglePlayerUninitialized> get serializer =>
      _$singlePlayerUninitializedSerializer;
}

///
/// The singlePlayer bloc that is unitialized.
///
abstract class SinglePlayerDeleted
    implements
        SinglePlayerState,
        Built<SinglePlayerDeleted, SinglePlayerDeletedBuilder> {
  SinglePlayerDeleted._();
  factory SinglePlayerDeleted(
          [void Function(SinglePlayerDeletedBuilder) updates]) =
      _$SinglePlayerDeleted;

  static SinglePlayerDeletedBuilder fromState(SinglePlayerState state) {
    // Nothing set in this case, just the type.
    return SinglePlayerDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SinglePlayerDeletedBuilder b) {
    SinglePlayerState.initializeStateBuilder(b);

    b.type = SinglePlayerBlocStateType.Deleted;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SinglePlayerDeleted.serializer, this);
  }

  static SinglePlayerDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SinglePlayerDeleted.serializer, jsonData);
  }

  static Serializer<SinglePlayerDeleted> get serializer =>
      _$singlePlayerDeletedSerializer;
}

///
/// The singlePlayer bloc that is unitialized.
///
abstract class SinglePlayerSaveFailed
    implements
        SinglePlayerState,
        Built<SinglePlayerSaveFailed, SinglePlayerSaveFailedBuilder> {
  @BuiltValueField(serialize: false)
  Object get error;

  SinglePlayerSaveFailed._();
  factory SinglePlayerSaveFailed(
          [void Function(SinglePlayerSaveFailedBuilder) updates]) =
      _$SinglePlayerSaveFailed;

  static SinglePlayerSaveFailedBuilder fromState(SinglePlayerState state) {
    return SinglePlayerState.fromState(state, SinglePlayerSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SinglePlayerSaveFailedBuilder b) {
    SinglePlayerState.initializeStateBuilder(b);

    b.type = SinglePlayerBlocStateType.SaveFailed;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SinglePlayerSaveFailed.serializer, this);
  }

  static SinglePlayerSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SinglePlayerSaveFailed.serializer, jsonData);
  }

  static Serializer<SinglePlayerSaveFailed> get serializer =>
      _$singlePlayerSaveFailedSerializer;
}

///
/// The singlePlayer bloc that is unitialized.
///
abstract class SinglePlayerSaving
    implements
        SinglePlayerState,
        Built<SinglePlayerSaving, SinglePlayerSavingBuilder> {
  SinglePlayerSaving._();
  factory SinglePlayerSaving(
          [void Function(SinglePlayerSavingBuilder) updates]) =
      _$SinglePlayerSaving;

  static SinglePlayerSavingBuilder fromState(SinglePlayerState state) {
    return SinglePlayerState.fromState(state, SinglePlayerSavingBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SinglePlayerSavingBuilder b) {
    SinglePlayerState.initializeStateBuilder(b);

    b.type = SinglePlayerBlocStateType.Saving;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SinglePlayerSaving.serializer, this);
  }

  static SinglePlayerSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SinglePlayerSaving.serializer, jsonData);
  }

  static Serializer<SinglePlayerSaving> get serializer =>
      _$singlePlayerSavingSerializer;
}

///
/// The singlePlayer bloc that is saving.
///
abstract class SinglePlayerSaveDone
    implements
        SinglePlayerState,
        Built<SinglePlayerSaveDone, SinglePlayerSaveDoneBuilder> {
  SinglePlayerSaveDone._();
  factory SinglePlayerSaveDone(
          [void Function(SinglePlayerSaveDoneBuilder) updates]) =
      _$SinglePlayerSaveDone;

  static SinglePlayerSaveDoneBuilder fromState(SinglePlayerState state) {
    return SinglePlayerState.fromState(state, SinglePlayerSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SinglePlayerSaveDoneBuilder b) {
    SinglePlayerState.initializeStateBuilder(b);

    b.type = SinglePlayerBlocStateType.SaveDone;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SinglePlayerSaveDone.serializer, this);
  }

  static SinglePlayerSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SinglePlayerSaveDone.serializer, jsonData);
  }

  static Serializer<SinglePlayerSaveDone> get serializer =>
      _$singlePlayerSaveDoneSerializer;
}
