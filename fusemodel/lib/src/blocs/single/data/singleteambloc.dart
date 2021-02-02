import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../serializer.dart';

part 'singleteambloc.g.dart';

///
/// The type of the team bloc state.
///
class SingleTeamBlocStateType extends EnumClass {
  static Serializer<SingleTeamBlocStateType> get serializer =>
      _$singleTeamBlocStateTypeSerializer;

  static const SingleTeamBlocStateType Uninitialized = _$uninitialized;
  static const SingleTeamBlocStateType Loaded = _$loaded;
  static const SingleTeamBlocStateType Deleted = _$deleted;
  static const SingleTeamBlocStateType SaveFailed = _$saveFailed;
  static const SingleTeamBlocStateType Saving = _$saving;
  static const SingleTeamBlocStateType SaveDone = _$saveDone;

  const SingleTeamBlocStateType._(String name) : super(name);

  static BuiltSet<SingleTeamBlocStateType> get values => _$values;

  static SingleTeamBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the singleTeam bloc.  It tracks all the
/// exciting singleTeam stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleTeamState with SingleTeamStateMixin {
  @override
  @nullable
  Team get team;
  @override
  @nullable
  Club get club;
  BuiltList<InviteAsAdmin> get invitesAsAdmin;
  @override
  BuiltList<Season> get fullSeason;
  BuiltMap<String, Opponent> get opponents;
  bool get loadedInvites;
  bool get loadedOpponents;
  bool get loadedSeasons;

  SingleTeamBlocStateType get type;

  static SingleTeamStateBuilder fromState(
      SingleTeamState state, SingleTeamStateBuilder builder) {
    return builder
      ..team = state.team?.toBuilder()
      ..club = state.club?.toBuilder()
      ..invitesAsAdmin = state.invitesAsAdmin.toBuilder()
      ..fullSeason = state.fullSeason.toBuilder()
      ..opponents = state.opponents.toBuilder()
      ..loadedInvites = state.loadedInvites
      ..loadedSeasons = state.loadedSeasons
      ..loadedOpponents = state.loadedOpponents;
  }

  static void initializeStateBuilder(SingleTeamStateBuilder b) => b
    ..loadedSeasons = false
    ..loadedInvites = false
    ..loadedOpponents = false;

  Map<String, dynamic> toMap();
}

abstract class SingleTeamStateMixin {
  Team get team;
  BuiltList<Season> get fullSeason;
  Club get club;

  ///
  /// Gets the specified sweason.
  ///
  Season getSeason(String uid) {
    return fullSeason.firstWhere((Season s) => s.uid == uid,
        orElse: () => null);
  }

  ///
  /// Checks to see if the user is an admin for this team.
  ///
  bool isAdmin() {
    return team.isAdmin(club);
  }
}

///
/// The singleTeam loaded from the database.
///
abstract class SingleTeamLoaded
    with SingleTeamStateMixin
    implements
        SingleTeamState,
        Built<SingleTeamLoaded, SingleTeamLoadedBuilder> {
  SingleTeamLoaded._();
  factory SingleTeamLoaded([void Function(SingleTeamLoadedBuilder) updates]) =
      _$SingleTeamLoaded;

  static SingleTeamLoadedBuilder fromState(SingleTeamState state) {
    return SingleTeamState.fromState(state, SingleTeamLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleTeamLoadedBuilder b) {
    SingleTeamState.initializeStateBuilder(b);

    b..type = SingleTeamBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleTeamLoaded.serializer, this);
  }

  static SingleTeamLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleTeamLoaded.serializer, jsonData);
  }

  static Serializer<SingleTeamLoaded> get serializer =>
      _$singleTeamLoadedSerializer;
}

///
/// The singleTeam bloc that is unitialized.
///
abstract class SingleTeamUninitialized
    with SingleTeamStateMixin
    implements
        SingleTeamState,
        Built<SingleTeamUninitialized, SingleTeamUninitializedBuilder> {
  SingleTeamUninitialized._();
  factory SingleTeamUninitialized(
          [void Function(SingleTeamUninitializedBuilder) updates]) =
      _$SingleTeamUninitialized;

  static SingleTeamUninitializedBuilder fromState(SingleTeamState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleTeamUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleTeamUninitializedBuilder b) {
    SingleTeamState.initializeStateBuilder(b);

    b..type = SingleTeamBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleTeamUninitialized.serializer, this);
  }

  static SingleTeamUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleTeamUninitialized.serializer, jsonData);
  }

  static Serializer<SingleTeamUninitialized> get serializer =>
      _$singleTeamUninitializedSerializer;
}

///
/// The singleTeam bloc that is deleted.
///
abstract class SingleTeamDeleted
    with SingleTeamStateMixin
    implements
        SingleTeamState,
        Built<SingleTeamDeleted, SingleTeamDeletedBuilder> {
  SingleTeamDeleted._();
  factory SingleTeamDeleted([void Function(SingleTeamDeletedBuilder) updates]) =
      _$SingleTeamDeleted;

  static SingleTeamDeletedBuilder fromState(SingleTeamState state) {
    // Nothing set in this case, just the type.
    return SingleTeamDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleTeamDeletedBuilder b) {
    SingleTeamState.initializeStateBuilder(b);

    b..type = SingleTeamBlocStateType.Deleted;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleTeamDeleted.serializer, this);
  }

  static SingleTeamDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleTeamDeleted.serializer, jsonData);
  }

  static Serializer<SingleTeamDeleted> get serializer =>
      _$singleTeamDeletedSerializer;
}

///
/// The singleTeam bloc that has failed to save, with error.
///
abstract class SingleTeamSaveFailed
    with SingleTeamStateMixin
    implements
        SingleTeamState,
        Built<SingleTeamSaveFailed, SingleTeamSaveFailedBuilder> {
  Error get error;

  SingleTeamSaveFailed._();
  factory SingleTeamSaveFailed(
          [void Function(SingleTeamSaveFailedBuilder) updates]) =
      _$SingleTeamSaveFailed;

  static SingleTeamSaveFailedBuilder fromState(SingleTeamState state) {
    return SingleTeamState.fromState(state, SingleTeamSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleTeamSaveFailedBuilder b) {
    SingleTeamState.initializeStateBuilder(b);

    b..type = SingleTeamBlocStateType.SaveFailed;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleTeamSaveFailed.serializer, this);
  }

  static SingleTeamSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleTeamSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleTeamSaveFailed> get serializer =>
      _$singleTeamSaveFailedSerializer;
}

///
/// The singleTeam bloc that is saving.
///
abstract class SingleTeamSaving
    with SingleTeamStateMixin
    implements
        SingleTeamState,
        Built<SingleTeamSaving, SingleTeamSavingBuilder> {
  SingleTeamSaving._();
  factory SingleTeamSaving([void Function(SingleTeamSavingBuilder) updates]) =
      _$SingleTeamSaving;

  static SingleTeamSavingBuilder fromState(SingleTeamState state) {
    return SingleTeamState.fromState(state, SingleTeamSavingBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleTeamSavingBuilder b) {
    SingleTeamState.initializeStateBuilder(b);

    b..type = SingleTeamBlocStateType.Saving;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleTeamSaving.serializer, this);
  }

  static SingleTeamSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleTeamSaving.serializer, jsonData);
  }

  static Serializer<SingleTeamSaving> get serializer =>
      _$singleTeamSavingSerializer;
}

///
/// The singleTeam bloc that is saving.
///
abstract class SingleTeamSaveDone
    with SingleTeamStateMixin
    implements
        SingleTeamState,
        Built<SingleTeamSaveDone, SingleTeamSaveDoneBuilder> {
  SingleTeamSaveDone._();
  factory SingleTeamSaveDone(
          [void Function(SingleTeamSaveDoneBuilder) updates]) =
      _$SingleTeamSaveDone;

  static SingleTeamSaveDoneBuilder fromState(SingleTeamState state) {
    return SingleTeamState.fromState(state, SingleTeamSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleTeamSaveDoneBuilder b) {
    SingleTeamState.initializeStateBuilder(b);

    b..type = SingleTeamBlocStateType.SaveDone;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleTeamSaveDone.serializer, this);
  }

  static SingleTeamSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleTeamSaveDone.serializer, jsonData);
  }

  static Serializer<SingleTeamSaveDone> get serializer =>
      _$singleTeamSaveDoneSerializer;
}
