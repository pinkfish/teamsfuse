import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';
import '../winrecord.dart';

part 'leagueortournmentteam.g.dart';

///
/// Team associated with a league or tournament.  A single team can
/// be associated with multiple divisons/seasons.
///
abstract class LeagueOrTournamentTeam
    implements Built<LeagueOrTournamentTeam, LeagueOrTournamentTeamBuilder> {
  /// Uid in the league or tournament.
  String get uid;

  /// The uid of the season of the team associated with this league.
  /// This will only be set if there is a team associated.  At this point
  /// the inviteEmail will be cleared.
  @nullable
  String get teamSeasonUid;

  /// The UID for the real team this is associated with.
  @nullable
  String get teamUid;

  /// The uid of the league/tourment divison the team is in.
  @BuiltValueField(wireName: LEAGUEORTOURNMENTDIVISONUID)
  String get leagueOrTournamentDivisonUid;

  /// The uid for the league or tournament.
  @BuiltValueField(wireName: LEAGUEORTOURNMENTUID)
  String get leagueOrTournamentUid;

  /// The uid for the league or tournament season.
  @BuiltValueField(wireName: LEAGUEORTOURNMENTSEASONUID)
  String get leagueOrTournamentSeasonUid;

  /// Name of the team in respect to this tournament/league.
  String get name;

  /// The win record of this team indexed by the divison.
  BuiltMap<String, WinRecord> get record;

  static const String TEAMUID = 'teamUid';
  static const String TEAMSEASONUID = 'teamSeasonUid';
  static const String LEAGUEORTOURNMENTDIVISONUID = 'leagueDivisonUid';
  static const String LEAGUEORTOURNMENTSEASONUID = 'seasonUid';
  static const String LEAGUEORTOURNMENTUID = 'leagueUid';
  static const String WINRECORD = 'record';

  LeagueOrTournamentTeam._();
  factory LeagueOrTournamentTeam(
          [Function(LeagueOrTournamentTeamBuilder b) updates]) =
      _$LeagueOrTournamentTeam;

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(
        LeagueOrTournamentTeam.serializer, this);
  }

  static LeagueOrTournamentTeam fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(
        LeagueOrTournamentTeam.serializer, jsonData);
  }

  static Serializer<LeagueOrTournamentTeam> get serializer =>
      _$leagueOrTournamentTeamSerializer;

  @override
  String toString() {
    return 'LeagueOrTournamentTeam{uid: $uid, teamSeasonUid: $teamSeasonUid, teamUid: $teamUid, leagueOrTournamentDivisonUid: $leagueOrTournamentDivisonUid, name: $name, record: $record}';
  }
}
