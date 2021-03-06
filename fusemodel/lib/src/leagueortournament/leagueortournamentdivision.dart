import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../fusemodel.dart';
import '../common.dart';
import '../serializer.dart';

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
  @BuiltValueField(wireName: LEAGUEORTOURNMENTSEASONUID)
  String get leagueOrTournmentSeasonUid;
  @BuiltValueField(wireName: LEAGUEORTOURNMENTUID)
  String get leagueOrTournamentUid;

  @BuiltValueField(wireName: MEMBERS)
  BuiltMap<String, AddedOrAdmin> get membersData;

  /// List of admin user ids. This is all user ids (not players)
  @memoized
  BuiltSet<String> get adminsUids =>
      BuiltSet.of(membersData.keys.where((uid) => membersData[uid].admin));

  /// List of member user ids.  This is all user ids (not players)
  @memoized
  BuiltSet<String> get members =>
      BuiltSet.of(membersData.keys.where((uid) => !membersData[uid].admin));

  LeagueOrTournamentDivison._();
  factory LeagueOrTournamentDivison(
          [Function(LeagueOrTournamentDivisonBuilder b) updates]) =
      _$LeagueOrTournamentDivison;

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(
        LeagueOrTournamentDivison.serializer, this);
  }

  static LeagueOrTournamentDivison fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(
        LeagueOrTournamentDivison.serializer, jsonData);
  }

  static Serializer<LeagueOrTournamentDivison> get serializer =>
      _$leagueOrTournamentDivisonSerializer;

  static const String MEMBERS = 'members';
  static const String LEAGUEORTOURNMENTSEASONUID = 'seasonUid';
  static const String LEAGUEORTOURNMENTUID = 'leagueUid';

  bool isUserAdmin(String myUid) {
    return adminsUids.contains(myUid);
  }

  /// Is the current user an admin?
  bool isAdmin(String userUid) {
    return isUserAdmin(userUid);
  }
}
