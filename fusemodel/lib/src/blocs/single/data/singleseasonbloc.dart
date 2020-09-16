import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../game.dart';
import '../../../invite.dart';
import '../../../serializer.dart';
import '../../../team.dart';

part 'singleseasonbloc.g.dart';

///
/// The type of the season bloc state.
///
class SingleSeasonBlocStateType extends EnumClass {
  static Serializer<SingleSeasonBlocStateType> get serializer =>
      _$singleSeasonBlocStateTypeSerializer;

  static const SingleSeasonBlocStateType Uninitialized = _$uninitialized;
  static const SingleSeasonBlocStateType Loaded = _$loaded;
  static const SingleSeasonBlocStateType Deleted = _$deleted;
  static const SingleSeasonBlocStateType SaveFailed = _$saveFailed;
  static const SingleSeasonBlocStateType Saving = _$saving;
  static const SingleSeasonBlocStateType SaveDone = _$saveDone;

  const SingleSeasonBlocStateType._(String name) : super(name);

  static BuiltSet<SingleSeasonBlocStateType> get values => _$values;

  static SingleSeasonBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the singleSeason bloc.  It tracks all the
/// exciting singleSeason stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleSeasonState {
  @nullable
  Season get season;
  BuiltList<Game> get games;
  bool get loadedGames;

  SingleSeasonBlocStateType get type;

  @BuiltValueField(serialize: false)
  bool get loadedInvites;
  @BuiltValueField(serialize: false)
  BuiltList<InviteToTeam> get invites;

  static SingleSeasonStateBuilder fromState(
      SingleSeasonState state, SingleSeasonStateBuilder builder) {
    return builder
      ..season = state.season?.toBuilder()
      ..loadedInvites = state.loadedInvites
      ..loadedGames = state.loadedGames
      ..games = state.games.toBuilder();
  }

  static void initializeStateBuilder(SingleSeasonStateBuilder b) => b
    ..loadedGames = false
    ..loadedInvites = false;

  Map<String, dynamic> toMap();
}

///
/// The singleSeason loaded from the database.
///
abstract class SingleSeasonLoaded
    implements
        SingleSeasonState,
        Built<SingleSeasonLoaded, SingleSeasonLoadedBuilder> {
  SingleSeasonLoaded._();
  factory SingleSeasonLoaded(
          [void Function(SingleSeasonLoadedBuilder) updates]) =
      _$SingleSeasonLoaded;

  static SingleSeasonLoadedBuilder fromState(SingleSeasonState state) {
    return SingleSeasonState.fromState(state, SingleSeasonLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleSeasonLoadedBuilder b) {
    SingleSeasonState.initializeStateBuilder(b);

    b..type = SingleSeasonBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleSeasonLoaded.serializer, this);
  }

  static SingleSeasonLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleSeasonLoaded.serializer, jsonData);
  }

  static Serializer<SingleSeasonLoaded> get serializer =>
      _$singleSeasonLoadedSerializer;
}

///
/// The singleSeason bloc that is unitialized.
///
abstract class SingleSeasonUninitialized
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

    b..type = SingleSeasonBlocStateType.Uninitialized;
  }

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

    b..type = SingleSeasonBlocStateType.Deleted;
  }

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
    implements
        SingleSeasonState,
        Built<SingleSeasonSaveFailed, SingleSeasonSaveFailedBuilder> {
  Error get error;

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

    b..type = SingleSeasonBlocStateType.SaveFailed;
  }

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

    b..type = SingleSeasonBlocStateType.Saving;
  }

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

    b..type = SingleSeasonBlocStateType.SaveDone;
  }

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
