import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../serializer.dart';

part 'singleopponentbloc.g.dart';

///
/// The type of the opponent bloc state.
///
class SingleOpponentBlocStateType extends EnumClass {
  static Serializer<SingleOpponentBlocStateType> get serializer =>
      _$singleOpponentBlocStateTypeSerializer;

  static const SingleOpponentBlocStateType Uninitialized = _$uninitialized;
  static const SingleOpponentBlocStateType Loaded = _$loaded;
  static const SingleOpponentBlocStateType Deleted = _$deleted;
  static const SingleOpponentBlocStateType SaveFailed = _$saveFailed;
  static const SingleOpponentBlocStateType Saving = _$saving;
  static const SingleOpponentBlocStateType SaveDone = _$saveDone;

  const SingleOpponentBlocStateType._(String name) : super(name);

  static BuiltSet<SingleOpponentBlocStateType> get values => _$values;

  static SingleOpponentBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the singleOpponent bloc.  It tracks all the
/// exciting singleOpponent stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleOpponentState {
  @nullable
  Opponent get opponent;
  BuiltList<Game> get games;
  bool get loadedGames;

  SingleOpponentBlocStateType get type;

  static SingleOpponentStateBuilder fromState(
      SingleOpponentState state, SingleOpponentStateBuilder builder) {
    return builder
      ..opponent = state.opponent?.toBuilder()
      ..loadedGames = state.loadedGames
      ..games = state.games.toBuilder();
  }

  static void initializeStateBuilder(SingleOpponentStateBuilder b) =>
      b..loadedGames = false;

  Map<String, dynamic> toMap();
}

///
/// The singleOpponent loaded from the database.
///
abstract class SingleOpponentLoaded
    implements
        SingleOpponentState,
        Built<SingleOpponentLoaded, SingleOpponentLoadedBuilder> {
  SingleOpponentLoaded._();
  factory SingleOpponentLoaded(
          [void Function(SingleOpponentLoadedBuilder) updates]) =
      _$SingleOpponentLoaded;

  static SingleOpponentLoadedBuilder fromState(SingleOpponentState state) {
    return SingleOpponentState.fromState(state, SingleOpponentLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleOpponentLoadedBuilder b) {
    SingleOpponentState.initializeStateBuilder(b);

    b..type = SingleOpponentBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleOpponentLoaded.serializer, this);
  }

  static SingleOpponentLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleOpponentLoaded.serializer, jsonData);
  }

  static Serializer<SingleOpponentLoaded> get serializer =>
      _$singleOpponentLoadedSerializer;
}

///
/// The singleOpponent bloc that is unitialized.
///
abstract class SingleOpponentUninitialized
    implements
        SingleOpponentState,
        Built<SingleOpponentUninitialized, SingleOpponentUninitializedBuilder> {
  SingleOpponentUninitialized._();
  factory SingleOpponentUninitialized(
          [void Function(SingleOpponentUninitializedBuilder) updates]) =
      _$SingleOpponentUninitialized;

  static SingleOpponentUninitializedBuilder fromState(
      SingleOpponentState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleOpponentUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleOpponentUninitializedBuilder b) {
    SingleOpponentState.initializeStateBuilder(b);

    b..type = SingleOpponentBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleOpponentUninitialized.serializer, this);
  }

  static SingleOpponentUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleOpponentUninitialized.serializer, jsonData);
  }

  static Serializer<SingleOpponentUninitialized> get serializer =>
      _$singleOpponentUninitializedSerializer;
}

///
/// The singleOpponent bloc that is unitialized.
///
abstract class SingleOpponentDeleted
    implements
        SingleOpponentState,
        Built<SingleOpponentDeleted, SingleOpponentDeletedBuilder> {
  SingleOpponentDeleted._();
  factory SingleOpponentDeleted(
          [void Function(SingleOpponentDeletedBuilder) updates]) =
      _$SingleOpponentDeleted;

  static SingleOpponentDeletedBuilder fromState(SingleOpponentState state) {
    // Nothing set in this case, just the type.
    return SingleOpponentDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleOpponentDeletedBuilder b) {
    SingleOpponentState.initializeStateBuilder(b);

    b..type = SingleOpponentBlocStateType.Deleted;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleOpponentDeleted.serializer, this);
  }

  static SingleOpponentDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleOpponentDeleted.serializer, jsonData);
  }

  static Serializer<SingleOpponentDeleted> get serializer =>
      _$singleOpponentDeletedSerializer;
}

///
/// The singleOpponent bloc that is unitialized.
///
abstract class SingleOpponentSaveFailed
    implements
        SingleOpponentState,
        Built<SingleOpponentSaveFailed, SingleOpponentSaveFailedBuilder> {
  Error get error;

  SingleOpponentSaveFailed._();
  factory SingleOpponentSaveFailed(
          [void Function(SingleOpponentSaveFailedBuilder) updates]) =
      _$SingleOpponentSaveFailed;

  static SingleOpponentSaveFailedBuilder fromState(SingleOpponentState state) {
    return SingleOpponentState.fromState(
        state, SingleOpponentSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleOpponentSaveFailedBuilder b) {
    SingleOpponentState.initializeStateBuilder(b);

    b..type = SingleOpponentBlocStateType.SaveFailed;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleOpponentSaveFailed.serializer, this);
  }

  static SingleOpponentSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleOpponentSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleOpponentSaveFailed> get serializer =>
      _$singleOpponentSaveFailedSerializer;
}

///
/// The singleOpponent bloc that is unitialized.
///
abstract class SingleOpponentSaving
    implements
        SingleOpponentState,
        Built<SingleOpponentSaving, SingleOpponentSavingBuilder> {
  SingleOpponentSaving._();
  factory SingleOpponentSaving(
          [void Function(SingleOpponentSavingBuilder) updates]) =
      _$SingleOpponentSaving;

  static SingleOpponentSavingBuilder fromState(SingleOpponentState state) {
    return SingleOpponentState.fromState(state, SingleOpponentSavingBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleOpponentSavingBuilder b) {
    SingleOpponentState.initializeStateBuilder(b);

    b..type = SingleOpponentBlocStateType.Saving;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleOpponentSaving.serializer, this);
  }

  static SingleOpponentSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleOpponentSaving.serializer, jsonData);
  }

  static Serializer<SingleOpponentSaving> get serializer =>
      _$singleOpponentSavingSerializer;
}

///
/// The singleOpponent bloc that is saving.
///
abstract class SingleOpponentSaveDone
    implements
        SingleOpponentState,
        Built<SingleOpponentSaveDone, SingleOpponentSaveDoneBuilder> {
  SingleOpponentSaveDone._();
  factory SingleOpponentSaveDone(
          [void Function(SingleOpponentSaveDoneBuilder) updates]) =
      _$SingleOpponentSaveDone;

  static SingleOpponentSaveDoneBuilder fromState(SingleOpponentState state) {
    return SingleOpponentState.fromState(
        state, SingleOpponentSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleOpponentSaveDoneBuilder b) {
    SingleOpponentState.initializeStateBuilder(b);

    b..type = SingleOpponentBlocStateType.SaveDone;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleOpponentSaveDone.serializer, this);
  }

  static SingleOpponentSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleOpponentSaveDone.serializer, jsonData);
  }

  static Serializer<SingleOpponentSaveDone> get serializer =>
      _$singleOpponentSaveDoneSerializer;
}
