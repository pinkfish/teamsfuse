import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../leagueortournament.dart';
import '../../../serializer.dart';

part 'singleleagueortournamentbloc.g.dart';

///
/// The type of the leagueOrTournment bloc state.
///
class SingleLeagueOrTournamentBlocStateType extends EnumClass {
  static Serializer<SingleLeagueOrTournamentBlocStateType> get serializer =>
      _$singleLeagueOrTournamentBlocStateTypeSerializer;

  static const SingleLeagueOrTournamentBlocStateType Uninitialized =
      _$uninitialized;
  static const SingleLeagueOrTournamentBlocStateType Loaded = _$loaded;
  static const SingleLeagueOrTournamentBlocStateType Deleted = _$deleted;
  static const SingleLeagueOrTournamentBlocStateType SaveFailed = _$saveFailed;
  static const SingleLeagueOrTournamentBlocStateType Saving = _$saving;
  static const SingleLeagueOrTournamentBlocStateType SaveDone = _$saveDone;

  const SingleLeagueOrTournamentBlocStateType._(String name) : super(name);

  static BuiltSet<SingleLeagueOrTournamentBlocStateType> get values => _$values;

  static SingleLeagueOrTournamentBlocStateType valueOf(String name) =>
      _$valueOf(name);
}

///
/// The base state for the singleLeagueOrTournament bloc.  It tracks all the
/// exciting singleLeagueOrTournament stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleLeagueOrTournamentState {
  @nullable
  LeagueOrTournament get league;
  BuiltMap<String, LeagueOrTournamentSeason> get seasons;
  bool get loadedSeasons;
  SingleLeagueOrTournamentBlocStateType get type;

  @BuiltValueField(serialize: false)
  bool get firestoreLogSetup;

  static SingleLeagueOrTournamentStateBuilder fromState(
      SingleLeagueOrTournamentState state,
      SingleLeagueOrTournamentStateBuilder builder) {
    return builder
      ..league = state.league?.toBuilder()
      ..seasons = state.seasons.toBuilder()
      ..loadedSeasons = state.loadedSeasons;
  }

  static void initializeStateBuilder(SingleLeagueOrTournamentStateBuilder b) =>
      b..loadedSeasons = false;

  Map<String, dynamic> toMap();
}

///
/// The singleLeagueOrTournament loaded from the database.
///
abstract class SingleLeagueOrTournamentLoaded
    implements
        SingleLeagueOrTournamentState,
        Built<SingleLeagueOrTournamentLoaded,
            SingleLeagueOrTournamentLoadedBuilder> {
  SingleLeagueOrTournamentLoaded._();
  factory SingleLeagueOrTournamentLoaded(
          [void Function(SingleLeagueOrTournamentLoadedBuilder) updates]) =
      _$SingleLeagueOrTournamentLoaded;

  static SingleLeagueOrTournamentLoadedBuilder fromState(
      SingleLeagueOrTournamentState state) {
    return SingleLeagueOrTournamentState.fromState(
        state, SingleLeagueOrTournamentLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournments loaded.
  static void _initializeBuilder(SingleLeagueOrTournamentLoadedBuilder b) {
    SingleLeagueOrTournamentState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentLoaded.serializer, this);
  }

  static SingleLeagueOrTournamentLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentLoaded.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentLoaded> get serializer =>
      _$singleLeagueOrTournamentLoadedSerializer;
}

///
/// The singleLeagueOrTournament bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentUninitialized
    implements
        SingleLeagueOrTournamentState,
        Built<SingleLeagueOrTournamentUninitialized,
            SingleLeagueOrTournamentUninitializedBuilder> {
  SingleLeagueOrTournamentUninitialized._();
  factory SingleLeagueOrTournamentUninitialized(
      [void Function(SingleLeagueOrTournamentUninitializedBuilder)
          updates]) = _$SingleLeagueOrTournamentUninitialized;

  static SingleLeagueOrTournamentUninitializedBuilder fromState(
      SingleLeagueOrTournamentState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleLeagueOrTournamentUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no leagueOrTournments loaded.
  static void _initializeBuilder(
      SingleLeagueOrTournamentUninitializedBuilder b) {
    SingleLeagueOrTournamentState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentUninitialized.serializer, this);
  }

  static SingleLeagueOrTournamentUninitialized fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentUninitialized.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentUninitialized> get serializer =>
      _$singleLeagueOrTournamentUninitializedSerializer;
}

///
/// The singleLeagueOrTournament bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentDeleted
    implements
        SingleLeagueOrTournamentState,
        Built<SingleLeagueOrTournamentDeleted,
            SingleLeagueOrTournamentDeletedBuilder> {
  SingleLeagueOrTournamentDeleted._();
  factory SingleLeagueOrTournamentDeleted(
          [void Function(SingleLeagueOrTournamentDeletedBuilder) updates]) =
      _$SingleLeagueOrTournamentDeleted;

  static SingleLeagueOrTournamentDeletedBuilder fromState(
      SingleLeagueOrTournamentState state) {
    // Nothing set in this case, just the type.
    return SingleLeagueOrTournamentDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no leagueOrTournments loaded.
  static void _initializeBuilder(SingleLeagueOrTournamentDeletedBuilder b) {
    SingleLeagueOrTournamentState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentBlocStateType.Deleted;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentDeleted.serializer, this);
  }

  static SingleLeagueOrTournamentDeleted fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentDeleted.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentDeleted> get serializer =>
      _$singleLeagueOrTournamentDeletedSerializer;
}

///
/// The singleLeagueOrTournament bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentSaveFailed
    implements
        SingleLeagueOrTournamentState,
        Built<SingleLeagueOrTournamentSaveFailed,
            SingleLeagueOrTournamentSaveFailedBuilder> {
  Error get error;

  SingleLeagueOrTournamentSaveFailed._();
  factory SingleLeagueOrTournamentSaveFailed(
          [void Function(SingleLeagueOrTournamentSaveFailedBuilder) updates]) =
      _$SingleLeagueOrTournamentSaveFailed;

  static SingleLeagueOrTournamentSaveFailedBuilder fromState(
      SingleLeagueOrTournamentState state) {
    return SingleLeagueOrTournamentState.fromState(
        state, SingleLeagueOrTournamentSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournments loaded.
  static void _initializeBuilder(SingleLeagueOrTournamentSaveFailedBuilder b) {
    SingleLeagueOrTournamentState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentBlocStateType.SaveFailed;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentSaveFailed.serializer, this);
  }

  static SingleLeagueOrTournamentSaveFailed fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentSaveFailed> get serializer =>
      _$singleLeagueOrTournamentSaveFailedSerializer;
}

///
/// The singleLeagueOrTournament bloc that is unitialized.
///
abstract class SingleLeagueOrTournamentSaving
    implements
        SingleLeagueOrTournamentState,
        Built<SingleLeagueOrTournamentSaving,
            SingleLeagueOrTournamentSavingBuilder> {
  SingleLeagueOrTournamentSaving._();
  factory SingleLeagueOrTournamentSaving(
          [void Function(SingleLeagueOrTournamentSavingBuilder) updates]) =
      _$SingleLeagueOrTournamentSaving;

  static SingleLeagueOrTournamentSavingBuilder fromState(
      SingleLeagueOrTournamentState state) {
    return SingleLeagueOrTournamentState.fromState(
        state, SingleLeagueOrTournamentSavingBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournments loaded.
  static void _initializeBuilder(SingleLeagueOrTournamentSavingBuilder b) {
    SingleLeagueOrTournamentState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentBlocStateType.Saving;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentSaving.serializer, this);
  }

  static SingleLeagueOrTournamentSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentSaving.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentSaving> get serializer =>
      _$singleLeagueOrTournamentSavingSerializer;
}

///
/// The singleLeagueOrTournament bloc that is saving.
///
abstract class SingleLeagueOrTournamentSaveDone
    implements
        SingleLeagueOrTournamentState,
        Built<SingleLeagueOrTournamentSaveDone,
            SingleLeagueOrTournamentSaveDoneBuilder> {
  SingleLeagueOrTournamentSaveDone._();
  factory SingleLeagueOrTournamentSaveDone(
          [void Function(SingleLeagueOrTournamentSaveDoneBuilder) updates]) =
      _$SingleLeagueOrTournamentSaveDone;

  static SingleLeagueOrTournamentSaveDoneBuilder fromState(
      SingleLeagueOrTournamentState state) {
    return SingleLeagueOrTournamentState.fromState(
        state, SingleLeagueOrTournamentSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no leagueOrTournments loaded.
  static void _initializeBuilder(SingleLeagueOrTournamentSaveDoneBuilder b) {
    SingleLeagueOrTournamentState.initializeStateBuilder(b);

    b..type = SingleLeagueOrTournamentBlocStateType.SaveDone;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleLeagueOrTournamentSaveDone.serializer, this);
  }

  static SingleLeagueOrTournamentSaveDone fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleLeagueOrTournamentSaveDone.serializer, jsonData);
  }

  static Serializer<SingleLeagueOrTournamentSaveDone> get serializer =>
      _$singleLeagueOrTournamentSaveDoneSerializer;
}
