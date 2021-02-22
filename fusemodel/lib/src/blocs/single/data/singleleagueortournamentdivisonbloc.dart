import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../serializer.dart';

part 'singleleagueortournamentdivisonbloc.g.dart';

///
/// The type of the leagueOrTournmentDivison bloc state.
///
class SingleLeagueOrTournamentDivisonBlocStateType extends EnumClass {
  static Serializer<SingleLeagueOrTournamentDivisonBlocStateType>
      get serializer =>
          _$singleLeagueOrTournamentDivisonBlocStateTypeSerializer;

  static const SingleLeagueOrTournamentDivisonBlocStateType Uninitialized =
      _$uninitialized;
  static const SingleLeagueOrTournamentDivisonBlocStateType Loaded = _$loaded;
  static const SingleLeagueOrTournamentDivisonBlocStateType Deleted = _$deleted;
  static const SingleLeagueOrTournamentDivisonBlocStateType SaveFailed =
      _$saveFailed;
  static const SingleLeagueOrTournamentDivisonBlocStateType Saving = _$saving;
  static const SingleLeagueOrTournamentDivisonBlocStateType SaveDone =
      _$saveDone;

  const SingleLeagueOrTournamentDivisonBlocStateType._(String name)
      : super(name);

  static BuiltSet<SingleLeagueOrTournamentDivisonBlocStateType> get values =>
      _$values;

  static SingleLeagueOrTournamentDivisonBlocStateType valueOf(String name) =>
      _$valueOf(name);
}

///
/// The base state for the singleLeagueOrTournamentDivison bloc.  It tracks all the
/// exciting singleLeagueOrTournamentDivison stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleLeagueOrTournamentDivisonState {
  @nullable
  LeagueOrTournamentDivison get divison;
  BuiltMap<String, GameSharedData> get games;
  bool get loadedGames;
  BuiltMap<String, LeagueOrTournamentTeam> get teams;
  bool get loadedTeams;
  SingleLeagueOrTournamentDivisonBlocStateType get type;

  static SingleLeagueOrTournamentDivisonStateBuilder fromState(
      SingleLeagueOrTournamentDivisonState state,
      SingleLeagueOrTournamentDivisonStateBuilder builder) {
    return builder
      ..divison = state.divison?.toBuilder()
      ..games = state.games.toBuilder()
      ..teams = state.teams.toBuilder()
      ..loadedGames = state.loadedGames
      ..loadedTeams = state.loadedTeams;
  }

  static void initializeStateBuilder(
          SingleLeagueOrTournamentDivisonStateBuilder b) =>
      b
        ..loadedGames = false
        ..loadedTeams = false;

  Map<String, dynamic> toMap();
}

///
/// The singleLeagueOrTournamentDivison loaded from the database.
///
abstract class SingleLeagueOrTournamentDivisonLoaded
    implements
        SingleLeagueOrTournamentDivisonState,
        Built<SingleLeagueOrTournamentDivisonLoaded,
            SingleLeagueOrTournamentDivisonLoadedBuilder> {
  SingleLeagueOrTournamentDivisonLoaded._();
  factory SingleLeagueOrTournamentDivisonLoaded(
      [void Function(SingleLeagueOrTournamentDivisonLoadedBuilder)
          updates]) = _$SingleLeagueOrTournamentDivisonLoaded;

  static SingleLeagueOrTournamentDivisonLoadedBuilder fromState(
      SingleLeagueOrTournamentDivisonState state) {
    return SingleLeagueOrTournamentDivisonState.fromState(
        state, SingleLeagueOrTournamentDivisonLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentDivisons loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentDivisonLoadedBuilder b) {
    SingleLeagueOrTournamentDivisonState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentDivisonBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentDivisonLoaded.serializer, this);
  }

  static SingleLeagueOrTournamentDivisonLoaded fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentDivisonLoaded.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentDivisonLoaded> get serializer =>
      _$singleLeagueOrTournamentDivisonLoadedSerializer;
}

///
/// The singleLeagueOrTournamentDivison bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentDivisonUninitialized
    implements
        SingleLeagueOrTournamentDivisonState,
        Built<SingleLeagueOrTournamentDivisonUninitialized,
            SingleLeagueOrTournamentDivisonUninitializedBuilder> {
  SingleLeagueOrTournamentDivisonUninitialized._();
  factory SingleLeagueOrTournamentDivisonUninitialized(
      [void Function(SingleLeagueOrTournamentDivisonUninitializedBuilder)
          updates]) = _$SingleLeagueOrTournamentDivisonUninitialized;

  static SingleLeagueOrTournamentDivisonUninitializedBuilder fromState(
      SingleLeagueOrTournamentDivisonState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleLeagueOrTournamentDivisonUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentDivisons loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentDivisonUninitializedBuilder b) {
    SingleLeagueOrTournamentDivisonState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentDivisonBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentDivisonUninitialized.serializer, this);
  }

  static SingleLeagueOrTournamentDivisonUninitialized fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentDivisonUninitialized.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentDivisonUninitialized>
      get serializer =>
          _$singleLeagueOrTournamentDivisonUninitializedSerializer;
}

///
/// The singleLeagueOrTournamentDivison bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentDivisonDeleted
    implements
        SingleLeagueOrTournamentDivisonState,
        Built<SingleLeagueOrTournamentDivisonDeleted,
            SingleLeagueOrTournamentDivisonDeletedBuilder> {
  SingleLeagueOrTournamentDivisonDeleted._();
  factory SingleLeagueOrTournamentDivisonDeleted(
      [void Function(SingleLeagueOrTournamentDivisonDeletedBuilder)
          updates]) = _$SingleLeagueOrTournamentDivisonDeleted;

  static SingleLeagueOrTournamentDivisonDeletedBuilder fromState(
      SingleLeagueOrTournamentDivisonState state) {
    // Nothing set in this case, just the type.
    return SingleLeagueOrTournamentDivisonDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentDivisons loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentDivisonDeletedBuilder b) {
    SingleLeagueOrTournamentDivisonState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentDivisonBlocStateType.Deleted;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentDivisonDeleted.serializer, this);
  }

  static SingleLeagueOrTournamentDivisonDeleted fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentDivisonDeleted.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentDivisonDeleted> get serializer =>
      _$singleLeagueOrTournamentDivisonDeletedSerializer;
}

///
/// The singleLeagueOrTournamentDivison bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentDivisonSaveFailed
    implements
        SingleLeagueOrTournamentDivisonState,
        Built<SingleLeagueOrTournamentDivisonSaveFailed,
            SingleLeagueOrTournamentDivisonSaveFailedBuilder> {
  @BuiltValueField(serialize: false)
  Object get error;

  SingleLeagueOrTournamentDivisonSaveFailed._();
  factory SingleLeagueOrTournamentDivisonSaveFailed(
      [void Function(SingleLeagueOrTournamentDivisonSaveFailedBuilder)
          updates]) = _$SingleLeagueOrTournamentDivisonSaveFailed;

  static SingleLeagueOrTournamentDivisonSaveFailedBuilder fromState(
      SingleLeagueOrTournamentDivisonState state) {
    return SingleLeagueOrTournamentDivisonState.fromState(
        state, SingleLeagueOrTournamentDivisonSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentDivisons loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentDivisonSaveFailedBuilder b) {
    SingleLeagueOrTournamentDivisonState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentDivisonBlocStateType.SaveFailed;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentDivisonSaveFailed.serializer, this);
  }

  static SingleLeagueOrTournamentDivisonSaveFailed fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentDivisonSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentDivisonSaveFailed> get serializer =>
      _$singleLeagueOrTournamentDivisonSaveFailedSerializer;
}

///
/// The singleLeagueOrTournamentDivison bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentDivisonSaving
    implements
        SingleLeagueOrTournamentDivisonState,
        Built<SingleLeagueOrTournamentDivisonSaving,
            SingleLeagueOrTournamentDivisonSavingBuilder> {
  SingleLeagueOrTournamentDivisonSaving._();
  factory SingleLeagueOrTournamentDivisonSaving(
      [void Function(SingleLeagueOrTournamentDivisonSavingBuilder)
          updates]) = _$SingleLeagueOrTournamentDivisonSaving;

  static SingleLeagueOrTournamentDivisonSavingBuilder fromState(
      SingleLeagueOrTournamentDivisonState state) {
    return SingleLeagueOrTournamentDivisonState.fromState(
        state, SingleLeagueOrTournamentDivisonSavingBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentDivisons loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentDivisonSavingBuilder b) {
    SingleLeagueOrTournamentDivisonState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentDivisonBlocStateType.Saving;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentDivisonSaving.serializer, this);
  }

  static SingleLeagueOrTournamentDivisonSaving fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentDivisonSaving.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentDivisonSaving> get serializer =>
      _$singleLeagueOrTournamentDivisonSavingSerializer;
}

///
/// The singleLeagueOrTournamentDivison bloc that is saving.
///
abstract class SingleLeagueOrTournamentDivisonSaveDone
    implements
        SingleLeagueOrTournamentDivisonState,
        Built<SingleLeagueOrTournamentDivisonSaveDone,
            SingleLeagueOrTournamentDivisonSaveDoneBuilder> {
  SingleLeagueOrTournamentDivisonSaveDone._();
  factory SingleLeagueOrTournamentDivisonSaveDone(
      [void Function(SingleLeagueOrTournamentDivisonSaveDoneBuilder)
          updates]) = _$SingleLeagueOrTournamentDivisonSaveDone;

  static SingleLeagueOrTournamentDivisonSaveDoneBuilder fromState(
      SingleLeagueOrTournamentDivisonState state) {
    return SingleLeagueOrTournamentDivisonState.fromState(
        state, SingleLeagueOrTournamentDivisonSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentDivisons loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentDivisonSaveDoneBuilder b) {
    SingleLeagueOrTournamentDivisonState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentDivisonBlocStateType.SaveDone;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentDivisonSaveDone.serializer, this);
  }

  static SingleLeagueOrTournamentDivisonSaveDone fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentDivisonSaveDone.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentDivisonSaveDone> get serializer =>
      _$singleLeagueOrTournamentDivisonSaveDoneSerializer;
}
