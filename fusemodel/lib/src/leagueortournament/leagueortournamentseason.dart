import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import '../common.dart';

part 'leagueortournamentseason.g.dart';

///
/// The season associated with this league or tournment.  The
/// games connect to the season, the season is part of the division
/// and the divison is part of the league.
///
abstract class LeagueOrTournamentSeason
    implements
        Built<LeagueOrTournamentSeason, LeagueOrTournamentSeasonBuilder> {
  String get name;
  String get uid;
  String get leagueOrTournmentUid;

  /// List of admin user ids. This is all user ids (not players)
  BuiltList<String> get adminsUids;

  /// List of member user ids.  This is all user ids (not players)
  BuiltList<String> get members;

  LeagueOrTournamentSeason._();
  factory LeagueOrTournamentSeason(
          [updates(LeagueOrTournamentSeasonBuilder b)]) =
      _$LeagueOrTournamentSeason;

  static LeagueOrTournamentSeasonBuilder fromJSON(
      String myUid, Map<String, dynamic> data) {
    LeagueOrTournamentSeasonBuilder builder = LeagueOrTournamentSeasonBuilder();
    builder
      ..uid = myUid
      ..name = data[NAME]
      ..leagueOrTournmentUid = data[LEAGUEORTOURNMENTUID];
    if (data.containsKey(MEMBERS)) {
      for (String adminUid in data[MEMBERS].keys) {
        Map<dynamic, dynamic> adminData = data[MEMBERS][adminUid];
        if (adminData[ADDED]) {
          if (adminData[ADMIN]) {
            builder.adminsUids.add(adminUid.toString());
          } else {
            builder.members.add(adminUid.toString());
          }
        }
      }
    }
    return builder;
  }

  static const String LEAGUEORTOURNMENTUID = "leagueUid";
  static const String MEMBERS = "members";
  static const String ADMIN = "admin";

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = <String, dynamic>{};

    ret[NAME] = name;
    ret[LEAGUEORTOURNMENTUID] = leagueOrTournmentUid;
    return ret;
  }
}
