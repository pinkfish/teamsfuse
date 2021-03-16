import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../serializer.dart';

part 'singleteamseasonplayerbloc.g.dart';

///
/// The type of the teamSeason bloc state.
///
class SingleTeamSeasonPlayerBlocStateType extends EnumClass {
  static Serializer<SingleTeamSeasonPlayerBlocStateType> get serializer =>
      _$singleTeamSeasonPlayerBlocStateTypeSerializer;

  static const SingleTeamSeasonPlayerBlocStateType Uninitialized =
      _$uninitialized;
  static const SingleTeamSeasonPlayerBlocStateType Loaded = _$loaded;
  static const SingleTeamSeasonPlayerBlocStateType Deleted = _$deleted;
  static const SingleTeamSeasonPlayerBlocStateType SaveFailed = _$saveFailed;
  static const SingleTeamSeasonPlayerBlocStateType Saving = _$saving;
  static const SingleTeamSeasonPlayerBlocStateType SaveDone = _$saveDone;

  const SingleTeamSeasonPlayerBlocStateType._(String name) : super(name);

  static BuiltSet<SingleTeamSeasonPlayerBlocStateType> get values => _$values;

  static SingleTeamSeasonPlayerBlocStateType valueOf(String name) =>
      _$valueOf(name);
}

///
/// The base state for the singleTeamSeasonPlayer bloc.  It tracks all the
/// exciting singleTeamSeasonPlayer stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleTeamSeasonPlayerState {
  /// The season player that is loaded.
  @nullable
  SeasonPlayer get seasonPlayer;

  /// The type of the bloc.
  SingleTeamSeasonPlayerBlocStateType get type;

  /// Create the state from the builder.
  static SingleTeamSeasonPlayerStateBuilder fromState(
      SingleTeamSeasonPlayerState state,
      SingleTeamSeasonPlayerStateBuilder builder) {
    return builder..seasonPlayer = state.seasonPlayer?.toBuilder();
  }

  /// initialize the builder.
  static void initializeStateBuilder(SingleTeamSeasonPlayerStateBuilder b) => b;

  /// Creates the serialization to a map.
  Map<String, dynamic> toMap();
}

///
/// The singleTeamSeasonPlayer loaded from the database.
///
abstract class SingleTeamSeasonPlayerLoaded
    implements
        SingleTeamSeasonPlayerState,
        Built<SingleTeamSeasonPlayerLoaded,
            SingleTeamSeasonPlayerLoadedBuilder> {
  SingleTeamSeasonPlayerLoaded._();
  factory SingleTeamSeasonPlayerLoaded(
          [void Function(SingleTeamSeasonPlayerLoadedBuilder) updates]) =
      _$SingleTeamSeasonPlayerLoaded;

  static SingleTeamSeasonPlayerLoadedBuilder fromState(
      SingleTeamSeasonPlayerState state) {
    return SingleTeamSeasonPlayerState.fromState(
        state, SingleTeamSeasonPlayerLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleTeamSeasonPlayerLoadedBuilder b) {
    SingleTeamSeasonPlayerState.initializeStateBuilder(b);

    b.type = SingleTeamSeasonPlayerBlocStateType.Loaded;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleTeamSeasonPlayerLoaded.serializer, this);
  }

  static SingleTeamSeasonPlayerLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleTeamSeasonPlayerLoaded.serializer, jsonData);
  }

  static Serializer<SingleTeamSeasonPlayerLoaded> get serializer =>
      _$singleTeamSeasonPlayerLoadedSerializer;
}

///
/// The singleTeamSeasonPlayer bloc that is unitialized.
///
abstract class SingleTeamSeasonPlayerUninitialized
    implements
        SingleTeamSeasonPlayerState,
        Built<SingleTeamSeasonPlayerUninitialized,
            SingleTeamSeasonPlayerUninitializedBuilder> {
  SingleTeamSeasonPlayerUninitialized._();
  factory SingleTeamSeasonPlayerUninitialized(
          [void Function(SingleTeamSeasonPlayerUninitializedBuilder) updates]) =
      _$SingleTeamSeasonPlayerUninitialized;

  static SingleTeamSeasonPlayerUninitializedBuilder fromState(
      SingleTeamSeasonPlayerState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleTeamSeasonPlayerUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleTeamSeasonPlayerUninitializedBuilder b) {
    SingleTeamSeasonPlayerState.initializeStateBuilder(b);

    b.type = SingleTeamSeasonPlayerBlocStateType.Uninitialized;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleTeamSeasonPlayerUninitialized.serializer, this);
  }

  static SingleTeamSeasonPlayerUninitialized fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleTeamSeasonPlayerUninitialized.serializer, jsonData);
  }

  static Serializer<SingleTeamSeasonPlayerUninitialized> get serializer =>
      _$singleTeamSeasonPlayerUninitializedSerializer;
}

///
/// The singleTeamSeasonPlayer bloc that is deleted.
///
abstract class SingleTeamSeasonPlayerDeleted
    implements
        SingleTeamSeasonPlayerState,
        Built<SingleTeamSeasonPlayerDeleted,
            SingleTeamSeasonPlayerDeletedBuilder> {
  SingleTeamSeasonPlayerDeleted._();
  factory SingleTeamSeasonPlayerDeleted(
          [void Function(SingleTeamSeasonPlayerDeletedBuilder) updates]) =
      _$SingleTeamSeasonPlayerDeleted;

  static SingleTeamSeasonPlayerDeletedBuilder fromState(
      SingleTeamSeasonPlayerState state) {
    // Nothing set in this case, just the type.
    return SingleTeamSeasonPlayerDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleTeamSeasonPlayerDeletedBuilder b) {
    SingleTeamSeasonPlayerState.initializeStateBuilder(b);

    b.type = SingleTeamSeasonPlayerBlocStateType.Deleted;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleTeamSeasonPlayerDeleted.serializer, this);
  }

  static SingleTeamSeasonPlayerDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleTeamSeasonPlayerDeleted.serializer, jsonData);
  }

  static Serializer<SingleTeamSeasonPlayerDeleted> get serializer =>
      _$singleTeamSeasonPlayerDeletedSerializer;
}

///
/// The singleTeamSeasonPlayer bloc that has failed to save, with error.
///
abstract class SingleTeamSeasonPlayerSaveFailed
    implements
        SingleTeamSeasonPlayerState,
        Built<SingleTeamSeasonPlayerSaveFailed,
            SingleTeamSeasonPlayerSaveFailedBuilder> {
  @BuiltValueField(serialize: false)
  Object get error;

  SingleTeamSeasonPlayerSaveFailed._();
  factory SingleTeamSeasonPlayerSaveFailed(
          [void Function(SingleTeamSeasonPlayerSaveFailedBuilder) updates]) =
      _$SingleTeamSeasonPlayerSaveFailed;

  static SingleTeamSeasonPlayerSaveFailedBuilder fromState(
      SingleTeamSeasonPlayerState state) {
    return SingleTeamSeasonPlayerState.fromState(
        state, SingleTeamSeasonPlayerSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleTeamSeasonPlayerSaveFailedBuilder b) {
    SingleTeamSeasonPlayerState.initializeStateBuilder(b);

    b.type = SingleTeamSeasonPlayerBlocStateType.SaveFailed;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleTeamSeasonPlayerSaveFailed.serializer, this);
  }

  static SingleTeamSeasonPlayerSaveFailed fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleTeamSeasonPlayerSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleTeamSeasonPlayerSaveFailed> get serializer =>
      _$singleTeamSeasonPlayerSaveFailedSerializer;
}

///
/// The singleTeamSeasonPlayer bloc that is saving.
///
abstract class SingleTeamSeasonPlayerSaving
    implements
        SingleTeamSeasonPlayerState,
        Built<SingleTeamSeasonPlayerSaving,
            SingleTeamSeasonPlayerSavingBuilder> {
  SingleTeamSeasonPlayerSaving._();
  factory SingleTeamSeasonPlayerSaving(
          [void Function(SingleTeamSeasonPlayerSavingBuilder) updates]) =
      _$SingleTeamSeasonPlayerSaving;

  static SingleTeamSeasonPlayerSavingBuilder fromState(
      SingleTeamSeasonPlayerState state) {
    return SingleTeamSeasonPlayerState.fromState(
        state, SingleTeamSeasonPlayerSavingBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleTeamSeasonPlayerSavingBuilder b) {
    SingleTeamSeasonPlayerState.initializeStateBuilder(b);

    b.type = SingleTeamSeasonPlayerBlocStateType.Saving;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleTeamSeasonPlayerSaving.serializer, this);
  }

  static SingleTeamSeasonPlayerSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleTeamSeasonPlayerSaving.serializer, jsonData);
  }

  static Serializer<SingleTeamSeasonPlayerSaving> get serializer =>
      _$singleTeamSeasonPlayerSavingSerializer;
}

///
/// The singleTeamSeasonPlayer bloc that is saving.
///
abstract class SingleTeamSeasonPlayerSaveDone
    implements
        SingleTeamSeasonPlayerState,
        Built<SingleTeamSeasonPlayerSaveDone,
            SingleTeamSeasonPlayerSaveDoneBuilder> {
  SingleTeamSeasonPlayerSaveDone._();
  factory SingleTeamSeasonPlayerSaveDone(
          [void Function(SingleTeamSeasonPlayerSaveDoneBuilder) updates]) =
      _$SingleTeamSeasonPlayerSaveDone;

  static SingleTeamSeasonPlayerSaveDoneBuilder fromState(
      SingleTeamSeasonPlayerState state) {
    return SingleTeamSeasonPlayerState.fromState(
        state, SingleTeamSeasonPlayerSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleTeamSeasonPlayerSaveDoneBuilder b) {
    SingleTeamSeasonPlayerState.initializeStateBuilder(b);

    b.type = SingleTeamSeasonPlayerBlocStateType.SaveDone;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleTeamSeasonPlayerSaveDone.serializer, this);
  }

  static SingleTeamSeasonPlayerSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleTeamSeasonPlayerSaveDone.serializer, jsonData);
  }

  static Serializer<SingleTeamSeasonPlayerSaveDone> get serializer =>
      _$singleTeamSeasonPlayerSaveDoneSerializer;
}
