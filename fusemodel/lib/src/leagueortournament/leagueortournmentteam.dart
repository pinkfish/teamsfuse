import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import '../common.dart';
import '../winrecord.dart';

part 'leagueortournmentteam.g.dart';

///
/// Team associated with a league or tournament.  A single team can
/// be associated with multiple divisons/seasons.
///
abstract class LeagueOrTournamentTeam
    implements Built<LeagueOrTournamentTeam, LeagueOrTournamentTeamBuilder> {
  String get uid;

  /// The uid of the season of the team associated with this league.
  /// This will only be set if there is a team associated.  At this point
  /// the inviteEmail will be cleared.
  String get seasonUid;

  /// The UID for the real team this is associated with.
  String get teamUid;

  /// The uid of the league/tourment divison the team is in.
  String get leagueOrTournamentDivisonUid;

  /// Name of the team in respect to this tournament/league.
  String get name;

  /// The win record of this team indexed by the divison.
  BuiltMap<String, WinRecord> get record;

  static const String TEAMUID = "teamUid";
  static const String SEASONUID = "seasonUid";
  static const String LEAGUEORTOURNMENTDIVISONUID = "leagueDivisonUid";
  static const String WINRECORD = "record";

  LeagueOrTournamentTeam._();
  factory LeagueOrTournamentTeam([updates(LeagueOrTournamentTeamBuilder b)]) =
      _$LeagueOrTournamentTeam;

  ///
  /// Convrt this league team into the format to use to send over the wire.
  ///
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret[NAME] = name;
    ret[SEASONUID] = seasonUid;
    ret[TEAMUID] = teamUid;
    ret[LEAGUEORTOURNMENTDIVISONUID] = leagueOrTournamentDivisonUid;
    Map<String, dynamic> inner = {};
    for (String str in record.keys) {
      inner[str] = record[str].toJSON();
    }
    ret[WINRECORD] = inner;
    return ret;
  }

  ///
  /// Load this from the wire format.
  ///
  static LeagueOrTournamentTeamBuilder fromJSON(
      String myUid, Map<String, dynamic> data) {
    LeagueOrTournamentTeamBuilder builder = LeagueOrTournamentTeamBuilder();
    builder
      ..teamUid = data[TEAMUID]
      ..seasonUid = data[SEASONUID]
      ..name = data[NAME]
      ..uid = myUid
      ..leagueOrTournamentDivisonUid = data[LEAGUEORTOURNMENTDIVISONUID];
    if (data[WINRECORD] is Map<dynamic, dynamic>) {
      Map<dynamic, dynamic> stuff = data[WINRECORD] as Map<dynamic, dynamic>;
      for (String key in stuff.keys) {
        if (stuff[key] is Map<dynamic, dynamic>) {
          builder.record[key] = WinRecord.fromJSON(stuff[key]).build();
        }
      }
    }
    return builder;
  }

  @override
  String toString() {
    return 'LeagueOrTournamentTeam{uid: $uid, seasonUid: $seasonUid, teamUid: $teamUid, leagueOrTournamentDivisonUid: $leagueOrTournamentDivisonUid, name: $name, record: $record}';
  }
}
