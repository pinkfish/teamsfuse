import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../game.dart';
import '../../../invite.dart';
import '../../../leagueortournament.dart';
import '../../../serializer.dart';
import '../../../team.dart';

part 'singleleagueortournamentteambloc.g.dart';

///
/// The type of the leagueOrTournmentTeam bloc state.
///
class SingleLeagueOrTournamentTeamBlocStateType extends EnumClass {
  static Serializer<SingleLeagueOrTournamentTeamBlocStateType> get serializer =>
      _$singleLeagueOrTournamentTeamBlocStateTypeSerializer;

  static const SingleLeagueOrTournamentTeamBlocStateType Uninitialized =
      _$uninitialized;
  static const SingleLeagueOrTournamentTeamBlocStateType Loaded = _$loaded;
  static const SingleLeagueOrTournamentTeamBlocStateType Deleted = _$deleted;
  static const SingleLeagueOrTournamentTeamBlocStateType SaveFailed =
      _$saveFailed;
  static const SingleLeagueOrTournamentTeamBlocStateType Saving = _$saving;
  static const SingleLeagueOrTournamentTeamBlocStateType SaveDone = _$saveDone;

  const SingleLeagueOrTournamentTeamBlocStateType._(String name) : super(name);

  static BuiltSet<SingleLeagueOrTournamentTeamBlocStateType> get values =>
      _$values;

  static SingleLeagueOrTournamentTeamBlocStateType valueOf(String name) =>
      _$valueOf(name);
}

///
/// The base state for the singleLeagueOrTournamentTeam bloc.  It tracks all the
/// exciting singleLeagueOrTournamentTeam stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleLeagueOrTournamentTeamState {
  LeagueOrTournamentTeam get leagueOrTournamentTeam;
  BuiltMap<String, GameSharedData> get games;
  BuiltList<InviteToLeagueTeam> get invites;
  Team get publicTeam;
  SingleLeagueOrTournamentTeamBlocStateType get type;

  @BuiltValueField(serialize: false)
  bool get firestoreLogSetup;

  static SingleLeagueOrTournamentTeamStateBuilder fromState(
      SingleLeagueOrTournamentTeamState state,
      SingleLeagueOrTournamentTeamStateBuilder builder) {
    return builder
      ..leagueOrTournamentTeam = state.leagueOrTournamentTeam.toBuilder()
      ..invites = state.invites.toBuilder()
      ..games = state.games.toBuilder()
      ..publicTeam = state.publicTeam.toBuilder()
      ..firestoreLogSetup = state.firestoreLogSetup;
  }

  static void initializeStateBuilder(
          SingleLeagueOrTournamentTeamStateBuilder b) =>
      b..firestoreLogSetup = false;

  Map<String, dynamic> toMap();
}

///
/// The singleLeagueOrTournamentTeam loaded from the database.
///
abstract class SingleLeagueOrTournamentTeamLoaded
    implements
        SingleLeagueOrTournamentTeamState,
        Built<SingleLeagueOrTournamentTeamLoaded,
            SingleLeagueOrTournamentTeamLoadedBuilder> {
  SingleLeagueOrTournamentTeamLoaded._();
  factory SingleLeagueOrTournamentTeamLoaded(
          [void Function(SingleLeagueOrTournamentTeamLoadedBuilder) updates]) =
      _$SingleLeagueOrTournamentTeamLoaded;

  static SingleLeagueOrTournamentTeamLoadedBuilder fromState(
      SingleLeagueOrTournamentTeamState state) {
    return SingleLeagueOrTournamentTeamState.fromState(
        state, SingleLeagueOrTournamentTeamLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentTeams loaded.
  static void _initializeBuilder(SingleLeagueOrTournamentTeamLoadedBuilder b) {
    SingleLeagueOrTournamentTeamState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentTeamBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentTeamLoaded.serializer, this);
  }

  static SingleLeagueOrTournamentTeamLoaded fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentTeamLoaded.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentTeamLoaded> get serializer =>
      _$singleLeagueOrTournamentTeamLoadedSerializer;
}

///
/// The singleLeagueOrTournamentTeam bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentTeamUninitialized
    implements
        SingleLeagueOrTournamentTeamState,
        Built<SingleLeagueOrTournamentTeamUninitialized,
            SingleLeagueOrTournamentTeamUninitializedBuilder> {
  SingleLeagueOrTournamentTeamUninitialized._();
  factory SingleLeagueOrTournamentTeamUninitialized(
      [void Function(SingleLeagueOrTournamentTeamUninitializedBuilder)
          updates]) = _$SingleLeagueOrTournamentTeamUninitialized;

  static SingleLeagueOrTournamentTeamUninitializedBuilder fromState(
      SingleLeagueOrTournamentTeamState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleLeagueOrTournamentTeamUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentTeams loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentTeamUninitializedBuilder b) {
    SingleLeagueOrTournamentTeamState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentTeamBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentTeamUninitialized.serializer, this);
  }

  static SingleLeagueOrTournamentTeamUninitialized fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentTeamUninitialized.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentTeamUninitialized> get serializer =>
      _$singleLeagueOrTournamentTeamUninitializedSerializer;
}

///
/// The singleLeagueOrTournamentTeam bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentTeamDeleted
    implements
        SingleLeagueOrTournamentTeamState,
        Built<SingleLeagueOrTournamentTeamDeleted,
            SingleLeagueOrTournamentTeamDeletedBuilder> {
  SingleLeagueOrTournamentTeamDeleted._();
  factory SingleLeagueOrTournamentTeamDeleted(
          [void Function(SingleLeagueOrTournamentTeamDeletedBuilder) updates]) =
      _$SingleLeagueOrTournamentTeamDeleted;

  static SingleLeagueOrTournamentTeamDeletedBuilder fromState(
      SingleLeagueOrTournamentTeamState state) {
    // Nothing set in this case, just the type.
    return SingleLeagueOrTournamentTeamDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentTeams loaded.
  static void _initializeBuilder(SingleLeagueOrTournamentTeamDeletedBuilder b) {
    SingleLeagueOrTournamentTeamState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentTeamBlocStateType.Deleted;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentTeamDeleted.serializer, this);
  }

  static SingleLeagueOrTournamentTeamDeleted fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentTeamDeleted.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentTeamDeleted> get serializer =>
      _$singleLeagueOrTournamentTeamDeletedSerializer;
}

///
/// The singleLeagueOrTournamentTeam bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentTeamSaveFailed
    implements
        SingleLeagueOrTournamentTeamState,
        Built<SingleLeagueOrTournamentTeamSaveFailed,
            SingleLeagueOrTournamentTeamSaveFailedBuilder> {
  Error get error;

  SingleLeagueOrTournamentTeamSaveFailed._();
  factory SingleLeagueOrTournamentTeamSaveFailed(
      [void Function(SingleLeagueOrTournamentTeamSaveFailedBuilder)
          updates]) = _$SingleLeagueOrTournamentTeamSaveFailed;

  static SingleLeagueOrTournamentTeamSaveFailedBuilder fromState(
      SingleLeagueOrTournamentTeamState state) {
    return SingleLeagueOrTournamentTeamState.fromState(
        state, SingleLeagueOrTournamentTeamSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentTeams loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentTeamSaveFailedBuilder b) {
    SingleLeagueOrTournamentTeamState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentTeamBlocStateType.SaveFailed;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentTeamSaveFailed.serializer, this);
  }

  static SingleLeagueOrTournamentTeamSaveFailed fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentTeamSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentTeamSaveFailed> get serializer =>
      _$singleLeagueOrTournamentTeamSaveFailedSerializer;
}

///
/// The singleLeagueOrTournamentTeam bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentTeamSaving
    implements
        SingleLeagueOrTournamentTeamState,
        Built<SingleLeagueOrTournamentTeamSaving,
            SingleLeagueOrTournamentTeamSavingBuilder> {
  SingleLeagueOrTournamentTeamSaving._();
  factory SingleLeagueOrTournamentTeamSaving(
          [void Function(SingleLeagueOrTournamentTeamSavingBuilder) updates]) =
      _$SingleLeagueOrTournamentTeamSaving;

  static SingleLeagueOrTournamentTeamSavingBuilder fromState(
      SingleLeagueOrTournamentTeamState state) {
    return SingleLeagueOrTournamentTeamState.fromState(
        state, SingleLeagueOrTournamentTeamSavingBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentTeams loaded.
  static void _initializeBuilder(SingleLeagueOrTournamentTeamSavingBuilder b) {
    SingleLeagueOrTournamentTeamState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentTeamBlocStateType.Saving;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentTeamSaving.serializer, this);
  }

  static SingleLeagueOrTournamentTeamSaving fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentTeamSaving.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentTeamSaving> get serializer =>
      _$singleLeagueOrTournamentTeamSavingSerializer;
}

///
/// The singleLeagueOrTournamentTeam bloc that is saving.
///
abstract class SingleLeagueOrTournamentTeamSaveDone
    implements
        SingleLeagueOrTournamentTeamState,
        Built<SingleLeagueOrTournamentTeamSaveDone,
            SingleLeagueOrTournamentTeamSaveDoneBuilder> {
  SingleLeagueOrTournamentTeamSaveDone._();
  factory SingleLeagueOrTournamentTeamSaveDone(
          [void Function(SingleLeagueOrTournamentTeamSaveDoneBuilder) updates]) =
      _$SingleLeagueOrTournamentTeamSaveDone;

  static SingleLeagueOrTournamentTeamSaveDoneBuilder fromState(
      SingleLeagueOrTournamentTeamState state) {
    return SingleLeagueOrTournamentTeamState.fromState(
        state, SingleLeagueOrTournamentTeamSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentTeams loaded.
  static void _initializeBuilder(SingleLeagueOrTournamentTeamSaveDoneBuilder b) {
    SingleLeagueOrTournamentTeamState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentTeamBlocStateType.SaveDone;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentTeamSaveDone.serializer, this);
  }

  static SingleLeagueOrTournamentTeamSaveDone fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentTeamSaveDone.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentTeamSaveDone> get serializer =>
      _$singleLeagueOrTournamentTeamSaveDoneSerializer;
}
