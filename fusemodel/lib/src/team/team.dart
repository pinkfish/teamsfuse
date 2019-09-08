import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import '../club.dart';
import '../common.dart';

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
  num get arriveEarlyInternal;
  String get currentSeason;
  Gender get gender;
  String get league;
  Sport get sport;
  String get uid;
  String get photoUrl;
  bool get archived;
  // The user id in this team.
  String get userUid;

  /// If this is not null signifies that this team is a member of a club.
  @nullable
  String get clubUid;

  /// If we can only see public details of this team.
  bool get publicOnly;

  /// If we should track attendecne for games in this team.  This is
  /// overridden by the club potentially.
  bool get trackAttendenceInternal;

  /// This is a list of user ids, not player Ids.
  BuiltSet<String> get admins;

  Team._();
  factory Team([updates(TeamBuilder b)]) = _$Team;

  static const String _CURRENTSEASON = 'currentSeason';
  static const String _LEAGUE = 'league';
  static const String _GENDER = 'gender';
  static const String _SPORT = 'sport';
  static const String ADMINS = 'admins';
  static const String _TRACKATTENDENDCE = 'trackAttendence';
  static const String CLUBUID = 'clubUid';
  static const String LEAGUEUID = 'leagueuid';
  static const String ARCHIVED = 'archived';
  static const String USER = 'user';

  /// Deserialize the team.
  static TeamBuilder fromJSON(
      String userUid, String teamUid, Map<String, dynamic> data,
      {bool publicOnly = false}) {
    TeamBuilder builder = TeamBuilder();
    builder.publicOnly = publicOnly;
    builder.uid = teamUid;

    onTeamUpdated(
        builder: builder, teamUid: teamUid, userUid: userUid, data: data);
    return builder;
  }

  /// Serialize the team.
  Map<String, dynamic> toJSON() {
    assert(!publicOnly);
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = name;
    ret[ARRIVALTIME] = arriveEarlyInternal;
    ret[_CURRENTSEASON] = currentSeason;
    ret[_LEAGUE] = league;
    ret[_GENDER] = gender.toString();
    ret[_SPORT] = sport.toString();
    ret[PHOTOURL] = photoUrl;
    ret[_TRACKATTENDENDCE] = trackAttendenceInternal;
    ret[CLUBUID] = clubUid;
    ret[ARCHIVED + "." + userUid] = archived;
    Map<String, bool> adminMap = new Map<String, bool>();
    admins.forEach((String key) {
      adminMap[key] = true;
    });
    ret[ADMINS] = adminMap;
    return ret;
  }

  static void onTeamUpdated(
      {TeamBuilder builder,
      String teamUid,
      String userUid,
      Map<String, dynamic> data}) {
    builder.uid = teamUid;
    builder.userUid = userUid;
    builder.name = getString(data[NAME]);
    builder.arriveEarlyInternal = getNum(data[ARRIVALTIME]);
    builder.currentSeason = getString(data[_CURRENTSEASON]);
    builder.league = getString(data[_LEAGUE]);
    builder.photoUrl = getString(data[PHOTOURL]);
    builder.archived = false;
    if (data[ARCHIVED] != null) {
      if (data[ARCHIVED] is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> stuff = data[ARCHIVED] as Map<dynamic, dynamic>;
        builder.archived = getBool(stuff[userUid]);
      }
    }
    builder.clubUid = data[CLUBUID];
    builder.gender = Gender.values.firstWhere(
        (e) => e.toString() == data[_GENDER],
        orElse: () => Gender.NA);
    builder.sport = Sport.values.firstWhere((e) => e.toString() == data[_SPORT],
        orElse: () => Sport.Other);
    builder.trackAttendenceInternal =
        getBool(data[_TRACKATTENDENDCE], defaultValue: true);
    if (!builder.publicOnly) {
      if (data[ADMINS] != null) {
        List<String> newAdmin = new List<String>();
        data[ADMINS].forEach((dynamic key, dynamic data) {
          if (data is bool && data) {
            newAdmin.add(key as String);
          }
        });
        builder.admins.addAll(newAdmin);
      }
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
