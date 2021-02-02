import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../common.dart';
import '../serializer.dart';

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
  @BuiltValueField(wireName: LEAGUEORTOURNMENTUID)
  String get leagueOrTournmentUid;

  @BuiltValueField(wireName: MEMBERS)
  BuiltMap<String, AddedOrAdmin> get membersData;

  /// List of admin user ids. This is all user ids (not players)
  @memoized
  BuiltSet<String> get adminsUids =>
      membersData.keys.where((uid) => membersData[uid].admin);

  /// List of member user ids.  This is all user ids (not players)
  @memoized
  BuiltSet<String> get members =>
      membersData.keys.where((uid) => !membersData[uid].admin);

  LeagueOrTournamentSeason._();
  factory LeagueOrTournamentSeason(
          [updates(LeagueOrTournamentSeasonBuilder b)]) =
      _$LeagueOrTournamentSeason;

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(
        LeagueOrTournamentSeason.serializer, this);
  }

  static LeagueOrTournamentSeason fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(
        LeagueOrTournamentSeason.serializer, jsonData);
  }

  static Serializer<LeagueOrTournamentSeason> get serializer =>
      _$leagueOrTournamentSeasonSerializer;

  static const String MEMBERS = "members";
  static const String LEAGUEORTOURNMENTUID = "leagueUid";
}
