import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../serializer.dart';

part 'singleclubcoachbloc.g.dart';

///
/// The type of the clubCoach bloc state.
///
class SingleClubCoachBlocStateType extends EnumClass {
  static Serializer<SingleClubCoachBlocStateType> get serializer =>
      _$singleClubCoachBlocStateTypeSerializer;

  static const SingleClubCoachBlocStateType Uninitialized = _$uninitialized;
  static const SingleClubCoachBlocStateType Loaded = _$loaded;
  static const SingleClubCoachBlocStateType Deleted = _$deleted;
  static const SingleClubCoachBlocStateType SaveFailed = _$saveFailed;
  static const SingleClubCoachBlocStateType Saving = _$saving;
  static const SingleClubCoachBlocStateType SaveDone = _$saveDone;

  const SingleClubCoachBlocStateType._(String name) : super(name);

  static BuiltSet<SingleClubCoachBlocStateType> get values => _$values;

  static SingleClubCoachBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the singleClubCoach bloc.  It tracks all the
/// exciting singleClubCoach stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleClubCoachState {
  /// The clubCoach for this bloc.
  @nullable
  Coach get coach;

  /// The type of the state.
  SingleClubCoachBlocStateType get type;

  static SingleClubCoachStateBuilder fromState(
      SingleClubCoachState state, SingleClubCoachStateBuilder builder) {
    return builder..coach = state.coach?.toBuilder();
  }

  static void initializeStateBuilder(SingleClubCoachStateBuilder b) => b;

  Map<String, dynamic> toMap();
}

///
/// The singleClubCoach loaded from the database.
///
abstract class SingleClubCoachLoaded
    implements
        SingleClubCoachState,
        Built<SingleClubCoachLoaded, SingleClubCoachLoadedBuilder> {
  SingleClubCoachLoaded._();
  factory SingleClubCoachLoaded(
          [void Function(SingleClubCoachLoadedBuilder) updates]) =
      _$SingleClubCoachLoaded;

  static SingleClubCoachLoadedBuilder fromState(SingleClubCoachState state) {
    return SingleClubCoachState.fromState(
        state, SingleClubCoachLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleClubCoachLoadedBuilder b) {
    SingleClubCoachState.initializeStateBuilder(b);

    b.type = SingleClubCoachBlocStateType.Loaded;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleClubCoachLoaded.serializer, this);
  }

  static SingleClubCoachLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleClubCoachLoaded.serializer, jsonData);
  }

  static Serializer<SingleClubCoachLoaded> get serializer =>
      _$singleClubCoachLoadedSerializer;
}

///
/// The singleClubCoach bloc that is unitialized.
///
abstract class SingleClubCoachUninitialized
    implements
        SingleClubCoachState,
        Built<SingleClubCoachUninitialized,
            SingleClubCoachUninitializedBuilder> {
  SingleClubCoachUninitialized._();
  factory SingleClubCoachUninitialized(
          [void Function(SingleClubCoachUninitializedBuilder) updates]) =
      _$SingleClubCoachUninitialized;

  static SingleClubCoachUninitializedBuilder fromState(
      SingleClubCoachState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleClubCoachUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleClubCoachUninitializedBuilder b) {
    SingleClubCoachState.initializeStateBuilder(b);

    b.type = SingleClubCoachBlocStateType.Uninitialized;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleClubCoachUninitialized.serializer, this);
  }

  static SingleClubCoachUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleClubCoachUninitialized.serializer, jsonData);
  }

  static Serializer<SingleClubCoachUninitialized> get serializer =>
      _$singleClubCoachUninitializedSerializer;
}

///
/// The singleClubCoach bloc that is deleted.
///
abstract class SingleClubCoachDeleted
    implements
        SingleClubCoachState,
        Built<SingleClubCoachDeleted, SingleClubCoachDeletedBuilder> {
  SingleClubCoachDeleted._();
  factory SingleClubCoachDeleted(
          [void Function(SingleClubCoachDeletedBuilder) updates]) =
      _$SingleClubCoachDeleted;

  static SingleClubCoachDeletedBuilder fromState(SingleClubCoachState state) {
    // Nothing set in this case, just the type.
    return SingleClubCoachDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleClubCoachDeletedBuilder b) {
    SingleClubCoachState.initializeStateBuilder(b);

    b.type = SingleClubCoachBlocStateType.Deleted;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleClubCoachDeleted.serializer, this);
  }

  static SingleClubCoachDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleClubCoachDeleted.serializer, jsonData);
  }

  static Serializer<SingleClubCoachDeleted> get serializer =>
      _$singleClubCoachDeletedSerializer;
}

///
/// The singleClubCoach bloc that has failed to save, with error.
///
abstract class SingleClubCoachSaveFailed
    implements
        SingleClubCoachState,
        Built<SingleClubCoachSaveFailed, SingleClubCoachSaveFailedBuilder> {
  /// The error associatedf with this clubCoach.
  @BuiltValueField(serialize: false)
  Object get error;

  SingleClubCoachSaveFailed._();
  factory SingleClubCoachSaveFailed(
          [void Function(SingleClubCoachSaveFailedBuilder) updates]) =
      _$SingleClubCoachSaveFailed;

  static SingleClubCoachSaveFailedBuilder fromState(
      SingleClubCoachState state) {
    return SingleClubCoachState.fromState(
        state, SingleClubCoachSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleClubCoachSaveFailedBuilder b) {
    SingleClubCoachState.initializeStateBuilder(b);

    b.type = SingleClubCoachBlocStateType.SaveFailed;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleClubCoachSaveFailed.serializer, this);
  }

  static SingleClubCoachSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleClubCoachSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleClubCoachSaveFailed> get serializer =>
      _$singleClubCoachSaveFailedSerializer;
}

///
/// The singleClubCoach bloc that is saving.
///
abstract class SingleClubCoachSaving
    implements
        SingleClubCoachState,
        Built<SingleClubCoachSaving, SingleClubCoachSavingBuilder> {
  SingleClubCoachSaving._();
  factory SingleClubCoachSaving(
          [void Function(SingleClubCoachSavingBuilder) updates]) =
      _$SingleClubCoachSaving;

  static SingleClubCoachSavingBuilder fromState(SingleClubCoachState state) {
    return SingleClubCoachState.fromState(
        state, SingleClubCoachSavingBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleClubCoachSavingBuilder b) {
    SingleClubCoachState.initializeStateBuilder(b);

    b.type = SingleClubCoachBlocStateType.Saving;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleClubCoachSaving.serializer, this);
  }

  static SingleClubCoachSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleClubCoachSaving.serializer, jsonData);
  }

  static Serializer<SingleClubCoachSaving> get serializer =>
      _$singleClubCoachSavingSerializer;
}

///
/// The singleClubCoach bloc that is saving.
///
abstract class SingleClubCoachSaveDone
    implements
        SingleClubCoachState,
        Built<SingleClubCoachSaveDone, SingleClubCoachSaveDoneBuilder> {
  SingleClubCoachSaveDone._();
  factory SingleClubCoachSaveDone(
          [void Function(SingleClubCoachSaveDoneBuilder) updates]) =
      _$SingleClubCoachSaveDone;

  static SingleClubCoachSaveDoneBuilder fromState(SingleClubCoachState state) {
    return SingleClubCoachState.fromState(
        state, SingleClubCoachSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleClubCoachSaveDoneBuilder b) {
    SingleClubCoachState.initializeStateBuilder(b);

    b.type = SingleClubCoachBlocStateType.SaveDone;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleClubCoachSaveDone.serializer, this);
  }

  static SingleClubCoachSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleClubCoachSaveDone.serializer, jsonData);
  }

  static Serializer<SingleClubCoachSaveDone> get serializer =>
      _$singleClubCoachSaveDoneSerializer;
}
