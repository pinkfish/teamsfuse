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
  @nullable
  Player get player;
  bool get mePlayer;
  SinglePlayerBlocStateType get type;

  // Local only data.
  @BuiltValueField(serialize: false)
  bool get invitesLoaded;
  @BuiltValueField(serialize: false)
  BuiltList<InviteToPlayer> get invites;

  static SinglePlayerStateBuilder fromState(
      SinglePlayerState state, SinglePlayerStateBuilder builder) {
    return builder
      ..player = state.player?.toBuilder()
      ..mePlayer = state.mePlayer
      ..invites = state.invites.toBuilder()
      ..invitesLoaded = state.invitesLoaded;
  }

  static void initializeStateBuilder(SinglePlayerStateBuilder b) => b
    ..invitesLoaded = false
    ..mePlayer = false;

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
  factory SinglePlayerLoaded(
          [void Function(SinglePlayerLoadedBuilder) updates]) =
      _$SinglePlayerLoaded;

  static SinglePlayerLoadedBuilder fromState(SinglePlayerState state) {
    return SinglePlayerState.fromState(state, SinglePlayerLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SinglePlayerLoadedBuilder b) {
    SinglePlayerState.initializeStateBuilder(b);

    b..type = SinglePlayerBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SinglePlayerLoaded.serializer, this);
  }

  static SinglePlayerLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SinglePlayerLoaded.serializer, jsonData);
  }

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

    b..type = SinglePlayerBlocStateType.Uninitialized;
  }

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

    b..type = SinglePlayerBlocStateType.Deleted;
  }

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
  Error get error;

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

    b..type = SinglePlayerBlocStateType.SaveFailed;
  }

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

    b..type = SinglePlayerBlocStateType.Saving;
  }

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

    b..type = SinglePlayerBlocStateType.SaveDone;
  }

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
