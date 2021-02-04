import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../club.dart';
import '../common.dart';
import '../serializer.dart';

part 'team.g.dart';

///
/// Used to pre-create an id before we write to the db.  This lets us put this
/// id into other places when we do the submit.
///
class PregenUidRet {
  String uid;
  dynamic extra;
}

///
/// Represents a team in the system.  All the data associated with the team
/// and the database manipulation for the team.
///
abstract class Team implements Built<Team, TeamBuilder> {
  String get name;

  /// How early people should arrive for the game by default.  This is
  /// overridden by the club potentially.
  @BuiltValueField(wireName: ARRIVALTIME)
  num get arriveEarlyInternal;
  String get currentSeason;
  Gender get gender;
  String get league;
  Sport get sport;
  String get uid;
  @nullable
  String get photoUrl;
  @BuiltValueField(wireName: ARCHIVED)
  BuiltMap<String, bool> get archivedData;
  // The user id in this team.
  @BuiltValueField(serialize: false)
  String get userUid;

  /// If this is not null signifies that this team is a member of a club.
  @nullable
  String get clubUid;

  /// If we can only see public details of this team.
  @BuiltValueField(serialize: false)
  bool get publicOnly;

  /// If this team is publicaly visible.
  bool get isPublic;
  
  /// If we should track attendecne for games in this team.  This is
  /// overridden by the club potentially.
  @BuiltValueField(wireName: ATTENDANCE)
  bool get trackAttendenceInternal;

  /// This is a list of user ids, not player Ids.
  @BuiltValueField(wireName: ADMINS)
  BuiltMap<String, bool> get adminsData;

  @memoized
  BuiltSet<String> get admins => BuiltSet.of(adminsData.keys);

  @memoized
  bool get archived =>
      archivedData.containsKey(userUid) && archivedData[userUid];

  Team._();
  factory Team([updates(TeamBuilder b)]) = _$Team;

  static const String ADMINS = 'admins';
  static const String ATTENDANCE = 'trackAttendence';
  static const String CLUBUID = 'clubUid';
  static const String LEAGUEUID = 'leagueuid';
  static const String ARCHIVED = 'archived';
  static const String USER = 'users';

  static void _initializeBuilder(TeamBuilder b) => b
    ..userUid = ""
    ..isPublic = false
    ..publicOnly = false;

  /// Deserialize the team.
  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(Team.serializer, this);
  }

  static Team fromMap(String userUid, Map<String, dynamic> jsonData) {
    return dataSerializers
        .deserializeWith(Team.serializer, jsonData)
        .rebuild((b) => b..userUid = userUid);
  }

  static Serializer<Team> get serializer => _$teamSerializer;

  static void onTeamUpdated(
      {TeamBuilder builder,
      String teamUid,
      String userUid,
      Map<String, dynamic> data}) {
    var newTeam = Team.fromMap(userUid, data);
    builder.uid = teamUid;
    builder.userUid = userUid;
    builder.name = newTeam.name;
    builder.arriveEarlyInternal = newTeam.arriveEarlyInternal;
    builder.currentSeason = newTeam.currentSeason;
    builder.league = newTeam.league;
    builder.photoUrl = newTeam.photoUrl;
    builder.archivedData = newTeam.archivedData.toBuilder();
    builder.clubUid = newTeam.clubUid;
    builder.gender = newTeam.gender;
    builder.sport = newTeam.sport;
    builder.trackAttendenceInternal = newTeam.trackAttendenceInternal;
    if (!builder.publicOnly) {
      builder.adminsData = newTeam.adminsData.toBuilder();
    }
  }

  /// Get the attendence tracking, potentially from the club.
  bool trackAttendence(Club club) {
    if (clubUid == null) {
      return trackAttendenceInternal;
    }
    if (club != null) {
      if (club.trackAttendence != Tristate.Unset) {
        return club.trackAttendence == Tristate.Yes;
      }
    }
    return trackAttendenceInternal;
  }

  /// Get the early arrive, using the club value if this is 0.
  num arriveEarly(Club club) {
    if (publicOnly) {
      return 0;
    }
    if (arriveEarlyInternal == 0 && club != null) {
      num ret = club.arriveBeforeGame;
      if (ret != null) {
        return ret;
      }
    }
    return arriveEarlyInternal;
  }

  ///
  /// Is the current user an admin for this team.
  ///
  bool isUserAdmin(String userId) {
    if (publicOnly) {
      return false;
    }
    return admins.contains(userId);
  }

  ///
  /// Check if the current user is an admin
  ///
  bool isAdmin(Club club) {
    if (publicOnly) {
      return false;
    }
    if (club != null) {
      return isUserAdmin(userUid) || club.isUserAdmin(userUid);
    }
    return isUserAdmin(userUid);
  }
}
