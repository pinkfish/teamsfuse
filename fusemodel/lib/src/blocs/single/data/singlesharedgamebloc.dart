import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../serializer.dart';

part 'singlesharedgamebloc.g.dart';

///
/// The type of the sharedGame bloc state.
///
class SingleSharedGameBlocStateType extends EnumClass {
  static Serializer<SingleSharedGameBlocStateType> get serializer =>
      _$singleSharedGameBlocStateTypeSerializer;

  static const SingleSharedGameBlocStateType Uninitialized = _$uninitialized;
  static const SingleSharedGameBlocStateType Loaded = _$loaded;
  static const SingleSharedGameBlocStateType Deleted = _$deleted;
  static const SingleSharedGameBlocStateType SaveFailed = _$saveFailed;
  static const SingleSharedGameBlocStateType Saving = _$saving;
  static const SingleSharedGameBlocStateType SaveDone = _$saveDone;

  const SingleSharedGameBlocStateType._(String name) : super(name);

  static BuiltSet<SingleSharedGameBlocStateType> get values => _$values;

  static SingleSharedGameBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the singleSharedGame bloc.  It tracks all the
/// exciting singleSharedGame stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleSharedGameState {
  @nullable
  GameSharedData get sharedGame;
  SingleSharedGameBlocStateType get type;


  static SingleSharedGameStateBuilder fromState(
      SingleSharedGameState state, SingleSharedGameStateBuilder builder) {
    return builder
      ..sharedGame = state.sharedGame?.toBuilder();
  }

  static void initializeStateBuilder(SingleSharedGameStateBuilder b) => b;

  Map<String, dynamic> toMap();
}

///
/// The singleSharedGame loaded from the database.
///
abstract class SingleSharedGameLoaded
    implements
        SingleSharedGameState,
        Built<SingleSharedGameLoaded, SingleSharedGameLoadedBuilder> {
  SingleSharedGameLoaded._();
  factory SingleSharedGameLoaded(
      [void Function(SingleSharedGameLoadedBuilder) updates]) =
  _$SingleSharedGameLoaded;

  static SingleSharedGameLoadedBuilder fromState(SingleSharedGameState state) {
    return SingleSharedGameState.fromState(state, SingleSharedGameLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSharedGameLoadedBuilder b) {
    SingleSharedGameState.initializeStateBuilder(b);

    b..type = SingleSharedGameBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSharedGameLoaded.serializer, this);
  }

  static SingleSharedGameLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleSharedGameLoaded.serializer, jsonData);
  }

  static Serializer<SingleSharedGameLoaded> get serializer =>
      _$singleSharedGameLoadedSerializer;
}

///
/// The singleSharedGame bloc that is unitialized.
///
abstract class SingleSharedGameUninitialized
    implements
        SingleSharedGameState,
        Built<SingleSharedGameUninitialized, SingleSharedGameUninitializedBuilder> {
  SingleSharedGameUninitialized._();
  factory SingleSharedGameUninitialized(
      [void Function(SingleSharedGameUninitializedBuilder) updates]) =
  _$SingleSharedGameUninitialized;

  static SingleSharedGameUninitializedBuilder fromState(SingleSharedGameState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleSharedGameUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSharedGameUninitializedBuilder b) {
    SingleSharedGameState.initializeStateBuilder(b);

    b..type = SingleSharedGameBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleSharedGameUninitialized.serializer, this);
  }

  static SingleSharedGameUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleSharedGameUninitialized.serializer, jsonData);
  }

  static Serializer<SingleSharedGameUninitialized> get serializer =>
      _$singleSharedGameUninitializedSerializer;
}

///
/// The singleSharedGame bloc that is unitialized.
///
abstract class SingleSharedGameDeleted
    implements
        SingleSharedGameState,
        Built<SingleSharedGameDeleted, SingleSharedGameDeletedBuilder> {
  SingleSharedGameDeleted._();
  factory SingleSharedGameDeleted(
      [void Function(SingleSharedGameDeletedBuilder) updates]) =
  _$SingleSharedGameDeleted;

  static SingleSharedGameDeletedBuilder fromState(SingleSharedGameState state) {
    // Nothing set in this case, just the type.
    return SingleSharedGameDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSharedGameDeletedBuilder b) {
    SingleSharedGameState.initializeStateBuilder(b);

    b..type = SingleSharedGameBlocStateType.Deleted;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSharedGameDeleted.serializer, this);
  }

  static SingleSharedGameDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleSharedGameDeleted.serializer, jsonData);
  }

  static Serializer<SingleSharedGameDeleted> get serializer =>
      _$singleSharedGameDeletedSerializer;
}

///
/// The singleSharedGame bloc that is unitialized.
///
abstract class SingleSharedGameSaveFailed
    implements
        SingleSharedGameState,
        Built<SingleSharedGameSaveFailed, SingleSharedGameSaveFailedBuilder> {
  @BuiltValueField(serialize: false)
  Object get error;

  SingleSharedGameSaveFailed._();
  factory SingleSharedGameSaveFailed(
      [void Function(SingleSharedGameSaveFailedBuilder) updates]) =
  _$SingleSharedGameSaveFailed;

  static SingleSharedGameSaveFailedBuilder fromState(SingleSharedGameState state) {
    return SingleSharedGameState.fromState(state, SingleSharedGameSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSharedGameSaveFailedBuilder b) {
    SingleSharedGameState.initializeStateBuilder(b);

    b..type = SingleSharedGameBlocStateType.SaveFailed;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSharedGameSaveFailed.serializer, this);
  }

  static SingleSharedGameSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleSharedGameSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleSharedGameSaveFailed> get serializer =>
      _$singleSharedGameSaveFailedSerializer;
}

///
/// The singleSharedGame bloc that is unitialized.
///
abstract class SingleSharedGameSaving
    implements
        SingleSharedGameState,
        Built<SingleSharedGameSaving, SingleSharedGameSavingBuilder> {
  SingleSharedGameSaving._();
  factory SingleSharedGameSaving(
      [void Function(SingleSharedGameSavingBuilder) updates]) =
  _$SingleSharedGameSaving;

  static SingleSharedGameSavingBuilder fromState(SingleSharedGameState state) {
    return SingleSharedGameState.fromState(state, SingleSharedGameSavingBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSharedGameSavingBuilder b) {
    SingleSharedGameState.initializeStateBuilder(b);

    b..type = SingleSharedGameBlocStateType.Saving;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSharedGameSaving.serializer, this);
  }

  static SingleSharedGameSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleSharedGameSaving.serializer, jsonData);
  }

  static Serializer<SingleSharedGameSaving> get serializer =>
      _$singleSharedGameSavingSerializer;
}

///
/// The singleSharedGame bloc that is saving.
///
abstract class SingleSharedGameSaveDone
    implements
        SingleSharedGameState,
        Built<SingleSharedGameSaveDone, SingleSharedGameSaveDoneBuilder> {
  SingleSharedGameSaveDone._();
  factory SingleSharedGameSaveDone(
      [void Function(SingleSharedGameSaveDoneBuilder) updates]) =
  _$SingleSharedGameSaveDone;

  static SingleSharedGameSaveDoneBuilder fromState(SingleSharedGameState state) {
    return SingleSharedGameState.fromState(state, SingleSharedGameSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSharedGameSaveDoneBuilder b) {
    SingleSharedGameState.initializeStateBuilder(b);

    b..type = SingleSharedGameBlocStateType.SaveDone;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSharedGameSaveDone.serializer, this);
  }

  static SingleSharedGameSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleSharedGameSaveDone.serializer, jsonData);
  }

  static Serializer<SingleSharedGameSaveDone> get serializer =>
      _$singleSharedGameSaveDoneSerializer;
}
