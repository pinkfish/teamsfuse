import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../serializer.dart';

part 'teamblocstate.g.dart';

class TeamBlocStateType extends EnumClass {
  static Serializer<TeamBlocStateType> get serializer =>
      _$teamBlocStateTypeSerializer;

  static const TeamBlocStateType Uninitialized = _$uninitialized;
  static const TeamBlocStateType Loaded = _$loaded;

  const TeamBlocStateType._(String name) : super(name);

  static BuiltSet<TeamBlocStateType> get values => _$values;

  static TeamBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the team bloc.  It tracks all the
/// exciting team stuff.
///
@BuiltValue(instantiable: false)
abstract class TeamState with TeamStateUpdates {
  @override
  BuiltMap<String, Team> get adminTeams;
  @override
  BuiltMap<String, Team> get playerTeams;
  @override
  BuiltMap<String, BuiltMap<String, Team>> get clubTeams;
  @override
  BuiltMap<String, Team> get publicTeams;
  TeamBlocStateType get type;

  // Don't save this stuff.
  @BuiltValueField(serialize: false)
  bool get loadedFirestore;

  @memoized
  @override
  Set<String> get allTeamUids {
    var set = Set<String>.from(adminTeams.keys);
    clubTeams.forEach(
        (String clubUid, BuiltMap<String, Team> data) => set.addAll(data.keys));
    set.addAll(clubTeams.keys);
    set.addAll(playerTeams.keys);
    return set;
  }

  static TeamStateBuilder fromState(TeamState state, TeamStateBuilder builder) {
    return builder
      ..adminTeams = state.adminTeams.toBuilder()
      ..playerTeams = state.playerTeams.toBuilder()
      ..clubTeams = state.clubTeams.toBuilder()
      ..publicTeams = state.publicTeams.toBuilder()
      ..loadedFirestore = state.loadedFirestore;
  }

  static void initializeStateBuilder(TeamStateBuilder b) =>
      b..loadedFirestore = false;

  Map<String, dynamic> toMap();
}

abstract class TeamStateUpdates {
  BuiltMap<String, Team> get playerTeams;
  BuiltMap<String, Team> get adminTeams;
  BuiltMap<String, BuiltMap<String, Team>> get clubTeams;
  BuiltMap<String, Team> get publicTeams;

  ///
  /// Get the team from the various places it could exist.
  ///
  Team getTeam(String uid) {
    if (playerTeams.containsKey(uid)) {
      return playerTeams[uid];
    }

    if (adminTeams.containsKey(uid)) {
      return adminTeams[uid];
    }
    for (var ts in clubTeams.values) {
      if (ts.containsKey(uid)) {
        return ts[uid];
      }
    }
    if (publicTeams.containsKey(uid)) {
      return publicTeams[uid];
    }

    return null;
  }

  ///
  /// Gets the public details for the team.
  ///
  Team getPublicTeam(String uid) {
    var t = getTeam(uid);
    if (t == null && publicTeams.containsKey(uid)) {
      return publicTeams[uid];
    }
    return t;
  }

  Set<String> get allTeamUids {
    var set = Set<String>.from(adminTeams.keys);
    clubTeams.forEach(
        (String clubUid, BuiltMap<String, Team> data) => set.addAll(data.keys));
    set.addAll(publicTeams.keys);
    set.addAll(playerTeams.keys);
    return set;
  }
}

///
/// The team loaded from the database.
///
abstract class TeamLoaded
    with TeamStateUpdates
    implements TeamState, Built<TeamLoaded, TeamLoadedBuilder> {
  TeamLoaded._();
  factory TeamLoaded([void Function(TeamLoadedBuilder) updates]) = _$TeamLoaded;

  static TeamLoadedBuilder fromState(TeamState state) {
    return TeamState.fromState(state, TeamLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(TeamLoadedBuilder b) {
    TeamState.initializeStateBuilder(b);

    b.type = TeamBlocStateType.Loaded;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(TeamLoaded.serializer, this);
  }

  static TeamLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(TeamLoaded.serializer, jsonData);
  }

  static Serializer<TeamLoaded> get serializer => _$teamLoadedSerializer;
}

///
/// The team bloc that is unitialized.
///
abstract class TeamUninitialized
    with TeamStateUpdates
    implements TeamState, Built<TeamUninitialized, TeamUninitializedBuilder> {
  TeamUninitialized._();
  factory TeamUninitialized([void Function(TeamUninitializedBuilder) updates]) =
      _$TeamUninitialized;

  static TeamUninitializedBuilder fromState(TeamState state) {
    return TeamState.fromState(state, TeamUninitializedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(TeamUninitializedBuilder b) {
    TeamState.initializeStateBuilder(b);

    b.type = TeamBlocStateType.Uninitialized;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(TeamUninitialized.serializer, this);
  }

  static TeamUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(TeamUninitialized.serializer, jsonData);
  }

  static Serializer<TeamUninitialized> get serializer =>
      _$teamUninitializedSerializer;
}
