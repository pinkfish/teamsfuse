import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../player.dart';
import '../../../serializer.dart';
import '../../../userprofile.dart';

part 'singleprofilebloc.g.dart';

///
/// The single bloc for handling profiles.
///
class SingleProfileBlocStateType extends EnumClass {
  static Serializer<SingleProfileBlocStateType> get serializer =>
      _$singleProfileBlocStateTypeSerializer;

  static const SingleProfileBlocStateType Uninitialized = _$uninitialized;
  static const SingleProfileBlocStateType Loaded = _$loaded;
  static const SingleProfileBlocStateType Deleted = _$deleted;
  static const SingleProfileBlocStateType SaveFailed = _$saveFailed;
  static const SingleProfileBlocStateType Saving = _$saving;
  static const SingleProfileBlocStateType SaveDone = _$saveDone;

  const SingleProfileBlocStateType._(String name) : super(name);

  static BuiltSet<SingleProfileBlocStateType> get values => _$values;

  static SingleProfileBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the singleProfile bloc.  It tracks all the
/// exciting singleProfile stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleProfileState {
  @nullable
  FusedUserProfile get profile;
  BuiltList<Player> get players;
  bool get loadedPlayers;

  SingleProfileBlocStateType get type;

  static SingleProfileStateBuilder fromState(
      SingleProfileState state, SingleProfileStateBuilder builder) {
    return builder..profile = state.profile?.toBuilder();
  }

  static void initializeStateBuilder(SingleProfileStateBuilder b) =>
      b..loadedPlayers = false;

  Map<String, dynamic> toMap();
}

///
/// The singleProfile loaded from the database.
///
abstract class SingleProfileLoaded
    implements
        SingleProfileState,
        Built<SingleProfileLoaded, SingleProfileLoadedBuilder> {
  SingleProfileLoaded._();
  factory SingleProfileLoaded(
          [void Function(SingleProfileLoadedBuilder) updates]) =
      _$SingleProfileLoaded;

  static SingleProfileLoadedBuilder fromState(SingleProfileState state) {
    return SingleProfileState.fromState(state, SingleProfileLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleProfileLoadedBuilder b) {
    SingleProfileState.initializeStateBuilder(b);

    b..type = SingleProfileBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleProfileLoaded.serializer, this);
  }

  static SingleProfileLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleProfileLoaded.serializer, jsonData);
  }

  static Serializer<SingleProfileLoaded> get serializer =>
      _$singleProfileLoadedSerializer;
}

///
/// The singleProfile bloc that is unitialized.
///
abstract class SingleProfileUninitialized
    implements
        SingleProfileState,
        Built<SingleProfileUninitialized, SingleProfileUninitializedBuilder> {
  SingleProfileUninitialized._();
  factory SingleProfileUninitialized(
          [void Function(SingleProfileUninitializedBuilder) updates]) =
      _$SingleProfileUninitialized;

  static SingleProfileUninitializedBuilder fromState(SingleProfileState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleProfileUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleProfileUninitializedBuilder b) {
    SingleProfileState.initializeStateBuilder(b);

    b..type = SingleProfileBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleProfileUninitialized.serializer, this);
  }

  static SingleProfileUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleProfileUninitialized.serializer, jsonData);
  }

  static Serializer<SingleProfileUninitialized> get serializer =>
      _$singleProfileUninitializedSerializer;
}

///
/// The singleProfile bloc that is unitialized.
///
abstract class SingleProfileDeleted
    implements
        SingleProfileState,
        Built<SingleProfileDeleted, SingleProfileDeletedBuilder> {
  SingleProfileDeleted._();
  factory SingleProfileDeleted(
          [void Function(SingleProfileDeletedBuilder) updates]) =
      _$SingleProfileDeleted;

  static SingleProfileDeletedBuilder fromState(SingleProfileState state) {
    // Nothing set in this case, just the type.
    return SingleProfileDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleProfileDeletedBuilder b) {
    SingleProfileState.initializeStateBuilder(b);

    b..type = SingleProfileBlocStateType.Deleted;
    b..loadedPlayers = false;
    b..players = ListBuilder();
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleProfileDeleted.serializer, this);
  }

  static SingleProfileDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleProfileDeleted.serializer, jsonData);
  }

  static Serializer<SingleProfileDeleted> get serializer =>
      _$singleProfileDeletedSerializer;
}

///
/// The singleProfile bloc that is unitialized.
///
abstract class SingleProfileSaveFailed
    implements
        SingleProfileState,
        Built<SingleProfileSaveFailed, SingleProfileSaveFailedBuilder> {
  Error get error;

  SingleProfileSaveFailed._();
  factory SingleProfileSaveFailed(
          [void Function(SingleProfileSaveFailedBuilder) updates]) =
      _$SingleProfileSaveFailed;

  static SingleProfileSaveFailedBuilder fromState(SingleProfileState state) {
    return SingleProfileState.fromState(
        state, SingleProfileSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleProfileSaveFailedBuilder b) {
    SingleProfileState.initializeStateBuilder(b);

    b..type = SingleProfileBlocStateType.SaveFailed;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleProfileSaveFailed.serializer, this);
  }

  static SingleProfileSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleProfileSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleProfileSaveFailed> get serializer =>
      _$singleProfileSaveFailedSerializer;
}

///
/// The singleProfile bloc that is unitialized.
///
abstract class SingleProfileSaving
    implements
        SingleProfileState,
        Built<SingleProfileSaving, SingleProfileSavingBuilder> {
  SingleProfileSaving._();
  factory SingleProfileSaving(
          [void Function(SingleProfileSavingBuilder) updates]) =
      _$SingleProfileSaving;

  static SingleProfileSavingBuilder fromState(SingleProfileState state) {
    return SingleProfileState.fromState(state, SingleProfileSavingBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleProfileSavingBuilder b) {
    SingleProfileState.initializeStateBuilder(b);

    b..type = SingleProfileBlocStateType.Saving;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleProfileSaving.serializer, this);
  }

  static SingleProfileSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleProfileSaving.serializer, jsonData);
  }

  static Serializer<SingleProfileSaving> get serializer =>
      _$singleProfileSavingSerializer;
}

///
/// The singleProfile bloc that is saving.
///
abstract class SingleProfileSaveDone
    implements
        SingleProfileState,
        Built<SingleProfileSaveDone, SingleProfileSaveDoneBuilder> {
  SingleProfileSaveDone._();
  factory SingleProfileSaveDone(
          [void Function(SingleProfileSaveDoneBuilder) updates]) =
      _$SingleProfileSaveDone;

  static SingleProfileSaveDoneBuilder fromState(SingleProfileState state) {
    return SingleProfileState.fromState(state, SingleProfileSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleProfileSaveDoneBuilder b) {
    SingleProfileState.initializeStateBuilder(b);

    b..type = SingleProfileBlocStateType.SaveDone;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleProfileSaveDone.serializer, this);
  }

  static SingleProfileSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleProfileSaveDone.serializer, jsonData);
  }

  static Serializer<SingleProfileSaveDone> get serializer =>
      _$singleProfileSaveDoneSerializer;
}
