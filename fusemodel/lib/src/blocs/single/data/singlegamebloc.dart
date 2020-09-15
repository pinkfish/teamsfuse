import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../game.dart';
import '../../../invite.dart';
import '../../../serializer.dart';

part 'singlegamebloc.g.dart';

///
/// The type of the game bloc state.
///
class SingleGameBlocStateType extends EnumClass {
  static Serializer<SingleGameBlocStateType> get serializer =>
      _$singleGameBlocStateTypeSerializer;

  static const SingleGameBlocStateType Uninitialized = _$uninitialized;
  static const SingleGameBlocStateType Loaded = _$loaded;
  static const SingleGameBlocStateType Deleted = _$deleted;
  static const SingleGameBlocStateType SaveFailed = _$saveFailed;
  static const SingleGameBlocStateType Saving = _$saving;
  static const SingleGameBlocStateType SaveDone = _$saveDone;

  const SingleGameBlocStateType._(String name) : super(name);

  static BuiltSet<SingleGameBlocStateType> get values => _$values;

  static SingleGameBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the singleGame bloc.  It tracks all the
/// exciting singleGame stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleGameState {
  Game get game;
  BuiltList<GameLog> get gameLog;
  bool get loadedLogs;

  SingleGameBlocStateType get type;

  @BuiltValueField(serialize: false)
  bool get firestoreLogSetup;

  static SingleGameStateBuilder fromState(
      SingleGameState state, SingleGameStateBuilder builder) {
    return builder
      ..game = state.game.toBuilder()
      ..gameLog = state.gameLog.toBuilder()
      ..loadedLogs = state.loadedLogs;
  }

  static void initializeStateBuilder(SingleGameStateBuilder b) =>
      b..firestoreLogSetup = false;

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

    b..type = SingleGameBlocStateType.Loaded;
  }

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

    b..type = SingleGameBlocStateType.Uninitialized;
  }

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

    b..type = SingleGameBlocStateType.Deleted;
  }

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
  Error get error;

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

    b..type = SingleGameBlocStateType.SaveFailed;
  }

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

    b..type = SingleGameBlocStateType.Saving;
  }

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

    b..type = SingleGameBlocStateType.SaveDone;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleGameSaveDone.serializer, this);
  }

  static SingleGameSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleGameSaveDone.serializer, jsonData);
  }

  static Serializer<SingleGameSaveDone> get serializer =>
      _$singleGameSaveDoneSerializer;
}