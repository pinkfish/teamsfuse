import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../serializer.dart';

part 'leagueortournamentblocstate.g.dart';

class AddingState extends EnumClass {
  static Serializer<AddingState> get serializer => _$addingStateSerializer;

  static const AddingState None = _$none;
  static const AddingState Adding = _$adding;
  static const AddingState Failed = _$failed;
  static const AddingState Success = _$success;

  const AddingState._(String name) : super(name);

  static BuiltSet<AddingState> get values => _$addingValues;

  static AddingState valueOf(String name) => _$addingValueOf(name);
}

class LeagueOrTournamentBlocStateType extends EnumClass {
  static Serializer<LeagueOrTournamentBlocStateType> get serializer =>
      _$leagueOrTournamentBlocStateTypeSerializer;

  static const LeagueOrTournamentBlocStateType Uninitialized = _$uninitialized;
  static const LeagueOrTournamentBlocStateType Loaded = _$loaded;

  const LeagueOrTournamentBlocStateType._(String name) : super(name);

  static BuiltSet<LeagueOrTournamentBlocStateType> get values => _$values;

  static LeagueOrTournamentBlocStateType valueOf(String name) =>
      _$valueOf(name);
}

///
/// The base state for the leagueOrTournament bloc.  It tracks all the
/// exciting leagueOrTournament stuff.
///
@BuiltValue(instantiable: false)
abstract class LeagueOrTournamentState {
  BuiltMap<String, LeagueOrTournament> get leagueOrTournaments;
  LeagueOrTournamentBlocStateType get type;

  // Don't save this stuff.
  @BuiltValueField(serialize: false)
  bool get loadedFirestore;

  static LeagueOrTournamentStateBuilder fromState(
      LeagueOrTournamentState state, LeagueOrTournamentStateBuilder builder) {
    return builder
      ..leagueOrTournaments = state.leagueOrTournaments.toBuilder()
      ..loadedFirestore = state.loadedFirestore;
  }

  static void initializeStateBuilder(LeagueOrTournamentStateBuilder b) =>
      b..loadedFirestore = false;

  Map<String, dynamic> toMap();
}

///
/// The leagueOrTournament loaded from the database.
///
abstract class LeagueOrTournamentLoaded
    implements
        LeagueOrTournamentState,
        Built<LeagueOrTournamentLoaded, LeagueOrTournamentLoadedBuilder> {
  LeagueOrTournamentLoaded._();
  factory LeagueOrTournamentLoaded(
          [void Function(LeagueOrTournamentLoadedBuilder) updates]) =
      _$LeagueOrTournamentLoaded;

  static LeagueOrTournamentLoadedBuilder fromState(
      LeagueOrTournamentState state) {
    return LeagueOrTournamentState.fromState(
        state, LeagueOrTournamentLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(LeagueOrTournamentLoadedBuilder b) {
    LeagueOrTournamentState.initializeStateBuilder(b);

    b..type = LeagueOrTournamentBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(LeagueOrTournamentLoaded.serializer, this);
  }

  static LeagueOrTournamentLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        LeagueOrTournamentLoaded.serializer, jsonData);
  }

  static Serializer<LeagueOrTournamentLoaded> get serializer =>
      _$leagueOrTournamentLoadedSerializer;
}

///
/// The leagueOrTournament bloc that is unitialized.
///
abstract class LeagueOrTournamentUninitialized
    implements
        LeagueOrTournamentState,
        Built<LeagueOrTournamentUninitialized,
            LeagueOrTournamentUninitializedBuilder> {
  LeagueOrTournamentUninitialized._();
  factory LeagueOrTournamentUninitialized(
          [void Function(LeagueOrTournamentUninitializedBuilder) updates]) =
      _$LeagueOrTournamentUninitialized;

  static LeagueOrTournamentUninitializedBuilder fromState(
      LeagueOrTournamentState state) {
    return LeagueOrTournamentState.fromState(
        state, LeagueOrTournamentUninitializedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(LeagueOrTournamentUninitializedBuilder b) {
    LeagueOrTournamentState.initializeStateBuilder(b);

    b..type = LeagueOrTournamentBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        LeagueOrTournamentUninitialized.serializer, this);
  }

  static LeagueOrTournamentUninitialized fromMap(
      Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        LeagueOrTournamentUninitialized.serializer, jsonData);
  }

  static Serializer<LeagueOrTournamentUninitialized> get serializer =>
      _$leagueOrTournamentUninitializedSerializer;
}
