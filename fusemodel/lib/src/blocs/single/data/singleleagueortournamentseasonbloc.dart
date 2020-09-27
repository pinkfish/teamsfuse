import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../leagueortournament.dart';
import '../../../serializer.dart';

part 'singleleagueortournamentseasonbloc.g.dart';

///
/// The type of the leagueOrTournmentSeason bloc state.
///
class SingleLeagueOrTournamentSeasonBlocStateType extends EnumClass {
  static Serializer<SingleLeagueOrTournamentSeasonBlocStateType>
      get serializer => _$singleLeagueOrTournamentSeasonBlocStateTypeSerializer;

  static const SingleLeagueOrTournamentSeasonBlocStateType Uninitialized =
      _$uninitialized;
  static const SingleLeagueOrTournamentSeasonBlocStateType Loaded = _$loaded;
  static const SingleLeagueOrTournamentSeasonBlocStateType Deleted = _$deleted;
  static const SingleLeagueOrTournamentSeasonBlocStateType SaveFailed =
      _$saveFailed;
  static const SingleLeagueOrTournamentSeasonBlocStateType Saving = _$saving;
  static const SingleLeagueOrTournamentSeasonBlocStateType SaveDone =
      _$saveDone;

  const SingleLeagueOrTournamentSeasonBlocStateType._(String name)
      : super(name);

  static BuiltSet<SingleLeagueOrTournamentSeasonBlocStateType> get values =>
      _$values;

  static SingleLeagueOrTournamentSeasonBlocStateType valueOf(String name) =>
      _$valueOf(name);
}

///
/// The base state for the singleLeagueOrTournamentSeason bloc.  It tracks all the
/// exciting singleLeagueOrTournamentSeason stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleLeagueOrTournamentSeasonState {
  @nullable
  LeagueOrTournamentSeason get season;
  BuiltMap<String, LeagueOrTournamentDivison> get divisons;
  bool get loadedDivisons;
  SingleLeagueOrTournamentSeasonBlocStateType get type;

  @BuiltValueField(serialize: false)
  bool get firestoreLogSetup;

  static SingleLeagueOrTournamentSeasonStateBuilder fromState(
      SingleLeagueOrTournamentSeasonState state,
      SingleLeagueOrTournamentSeasonStateBuilder builder) {
    return builder
      ..season = state.season?.toBuilder()
      ..divisons = state.divisons.toBuilder()
      ..loadedDivisons = state.loadedDivisons;
  }

  static void initializeStateBuilder(
          SingleLeagueOrTournamentSeasonStateBuilder b) =>
      b..loadedDivisons = false;

  Map<String, dynamic> toMap();
}

///
/// The singleLeagueOrTournamentSeason loaded from the database.
///
abstract class SingleLeagueOrTournamentSeasonLoaded
    implements
        SingleLeagueOrTournamentSeasonState,
        Built<SingleLeagueOrTournamentSeasonLoaded,
            SingleLeagueOrTournamentSeasonLoadedBuilder> {
  SingleLeagueOrTournamentSeasonLoaded._();
  factory SingleLeagueOrTournamentSeasonLoaded(
      [void Function(SingleLeagueOrTournamentSeasonLoadedBuilder)
          updates]) = _$SingleLeagueOrTournamentSeasonLoaded;

  static SingleLeagueOrTournamentSeasonLoadedBuilder fromState(
      SingleLeagueOrTournamentSeasonState state) {
    return SingleLeagueOrTournamentSeasonState.fromState(
        state, SingleLeagueOrTournamentSeasonLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentSeasons loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentSeasonLoadedBuilder b) {
    SingleLeagueOrTournamentSeasonState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentSeasonBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentSeasonLoaded.serializer, this);
  }

  static SingleLeagueOrTournamentSeasonLoaded fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentSeasonLoaded.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentSeasonLoaded> get serializer =>
      _$singleLeagueOrTournamentSeasonLoadedSerializer;
}

///
/// The singleLeagueOrTournamentSeason bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentSeasonUninitialized
    implements
        SingleLeagueOrTournamentSeasonState,
        Built<SingleLeagueOrTournamentSeasonUninitialized,
            SingleLeagueOrTournamentSeasonUninitializedBuilder> {
  SingleLeagueOrTournamentSeasonUninitialized._();
  factory SingleLeagueOrTournamentSeasonUninitialized(
      [void Function(SingleLeagueOrTournamentSeasonUninitializedBuilder)
          updates]) = _$SingleLeagueOrTournamentSeasonUninitialized;

  static SingleLeagueOrTournamentSeasonUninitializedBuilder fromState(
      SingleLeagueOrTournamentSeasonState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleLeagueOrTournamentSeasonUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentSeasons loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentSeasonUninitializedBuilder b) {
    SingleLeagueOrTournamentSeasonState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentSeasonBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentSeasonUninitialized.serializer, this);
  }

  static SingleLeagueOrTournamentSeasonUninitialized fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentSeasonUninitialized.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentSeasonUninitialized>
      get serializer => _$singleLeagueOrTournamentSeasonUninitializedSerializer;
}

///
/// The singleLeagueOrTournamentSeason bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentSeasonDeleted
    implements
        SingleLeagueOrTournamentSeasonState,
        Built<SingleLeagueOrTournamentSeasonDeleted,
            SingleLeagueOrTournamentSeasonDeletedBuilder> {
  SingleLeagueOrTournamentSeasonDeleted._();
  factory SingleLeagueOrTournamentSeasonDeleted(
      [void Function(SingleLeagueOrTournamentSeasonDeletedBuilder)
          updates]) = _$SingleLeagueOrTournamentSeasonDeleted;

  static SingleLeagueOrTournamentSeasonDeletedBuilder fromState(
      SingleLeagueOrTournamentSeasonState state) {
    // Nothing set in this case, just the type.
    return SingleLeagueOrTournamentSeasonDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentSeasons loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentSeasonDeletedBuilder b) {
    SingleLeagueOrTournamentSeasonState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentSeasonBlocStateType.Deleted;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentSeasonDeleted.serializer, this);
  }

  static SingleLeagueOrTournamentSeasonDeleted fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentSeasonDeleted.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentSeasonDeleted> get serializer =>
      _$singleLeagueOrTournamentSeasonDeletedSerializer;
}

///
/// The singleLeagueOrTournamentSeason bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentSeasonSaveFailed
    implements
        SingleLeagueOrTournamentSeasonState,
        Built<SingleLeagueOrTournamentSeasonSaveFailed,
            SingleLeagueOrTournamentSeasonSaveFailedBuilder> {
  Error get error;

  SingleLeagueOrTournamentSeasonSaveFailed._();
  factory SingleLeagueOrTournamentSeasonSaveFailed(
      [void Function(SingleLeagueOrTournamentSeasonSaveFailedBuilder)
          updates]) = _$SingleLeagueOrTournamentSeasonSaveFailed;

  static SingleLeagueOrTournamentSeasonSaveFailedBuilder fromState(
      SingleLeagueOrTournamentSeasonState state) {
    return SingleLeagueOrTournamentSeasonState.fromState(
        state, SingleLeagueOrTournamentSeasonSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentSeasons loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentSeasonSaveFailedBuilder b) {
    SingleLeagueOrTournamentSeasonState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentSeasonBlocStateType.SaveFailed;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentSeasonSaveFailed.serializer, this);
  }

  static SingleLeagueOrTournamentSeasonSaveFailed fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentSeasonSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentSeasonSaveFailed> get serializer =>
      _$singleLeagueOrTournamentSeasonSaveFailedSerializer;
}

///
/// The singleLeagueOrTournamentSeason bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentSeasonSaving
    implements
        SingleLeagueOrTournamentSeasonState,
        Built<SingleLeagueOrTournamentSeasonSaving,
            SingleLeagueOrTournamentSeasonSavingBuilder> {
  SingleLeagueOrTournamentSeasonSaving._();
  factory SingleLeagueOrTournamentSeasonSaving(
      [void Function(SingleLeagueOrTournamentSeasonSavingBuilder)
          updates]) = _$SingleLeagueOrTournamentSeasonSaving;

  static SingleLeagueOrTournamentSeasonSavingBuilder fromState(
      SingleLeagueOrTournamentSeasonState state) {
    return SingleLeagueOrTournamentSeasonState.fromState(
        state, SingleLeagueOrTournamentSeasonSavingBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentSeasons loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentSeasonSavingBuilder b) {
    SingleLeagueOrTournamentSeasonState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentSeasonBlocStateType.Saving;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentSeasonSaving.serializer, this);
  }

  static SingleLeagueOrTournamentSeasonSaving fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentSeasonSaving.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentSeasonSaving> get serializer =>
      _$singleLeagueOrTournamentSeasonSavingSerializer;
}

///
/// The singleLeagueOrTournamentSeason bloc that is saving.
///
abstract class SingleLeagueOrTournamentSeasonSaveDone
    implements
        SingleLeagueOrTournamentSeasonState,
        Built<SingleLeagueOrTournamentSeasonSaveDone,
            SingleLeagueOrTournamentSeasonSaveDoneBuilder> {
  SingleLeagueOrTournamentSeasonSaveDone._();
  factory SingleLeagueOrTournamentSeasonSaveDone(
      [void Function(SingleLeagueOrTournamentSeasonSaveDoneBuilder)
          updates]) = _$SingleLeagueOrTournamentSeasonSaveDone;

  static SingleLeagueOrTournamentSeasonSaveDoneBuilder fromState(
      SingleLeagueOrTournamentSeasonState state) {
    return SingleLeagueOrTournamentSeasonState.fromState(
        state, SingleLeagueOrTournamentSeasonSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournmentSeasons loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentSeasonSaveDoneBuilder b) {
    SingleLeagueOrTournamentSeasonState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentSeasonBlocStateType.SaveDone;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentSeasonSaveDone.serializer, this);
  }

  static SingleLeagueOrTournamentSeasonSaveDone fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentSeasonSaveDone.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentSeasonSaveDone> get serializer =>
      _$singleLeagueOrTournamentSeasonSaveDoneSerializer;
}
