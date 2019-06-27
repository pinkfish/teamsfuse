import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import '../common.dart';

part 'leagueortournamentdivision.g.dart';

///
/// A division in a league or tournament.  The seasons are associated
/// with the division and the division is connected back to the
/// league or tournament.
///
abstract class LeagueOrTournamentDivison
    implements
        Built<LeagueOrTournamentDivison, LeagueOrTournamentDivisonBuilder> {
  String get name;
  String get uid;
  String get leagueOrTournmentSeasonUid;
  String get userUid;

  /// List of admin user ids. This is all user ids (not players)
  BuiltSet<String> get adminsUids;

  /// List of member user ids.  This is all user ids (not players)
  BuiltSet<String> get members;

  LeagueOrTournamentDivison._();
  factory LeagueOrTournamentDivison(
          [updates(LeagueOrTournamentDivisonBuilder b)]) =
      _$LeagueOrTournamentDivison;

  static LeagueOrTournamentDivisonBuilder fromJSON(
      String myUid, String userUid, Map<String, dynamic> data) {
    LeagueOrTournamentDivisonBuilder builder =
        LeagueOrTournamentDivisonBuilder();
    builder
      ..userUid = userUid
      ..uid = myUid
      ..name = data[NAME]
      ..leagueOrTournmentSeasonUid = data[LEAGUEORTOURNMENTSEASONUID];
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

  static const String LEAGUEORTOURNMENTSEASONUID = "seasonUid";
  static const String MEMBERS = "members";
  static const String ADMIN = "admin";

  bool isUserAdmin(String myUid) {
    return adminsUids.contains(myUid);
  }

  /// Is the current user an admin?
  bool isAdmin() {
    return isUserAdmin(userUid);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = <String, dynamic>{};

    ret[NAME] = name;
    ret[LEAGUEORTOURNMENTSEASONUID] = leagueOrTournmentSeasonUid;
    return ret;
  }
}
