import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../common.dart';
import '../serializer.dart';

part 'leagueortournament.g.dart';

///
/// The type of the league or tournment.
///
class LeagueOrTournamentType extends EnumClass {
  static Serializer<LeagueOrTournamentType> get serializer =>
      _$leagueOrTournamentTypeSerializer;

  static const LeagueOrTournamentType Tournament = _$Tournament;
  static const LeagueOrTournamentType League = _$League;

  const LeagueOrTournamentType._(String name) : super(name);

  static BuiltSet<LeagueOrTournamentType> get values =>
      _$LeagueOrTournamentTypeValues;

  static LeagueOrTournamentType valueOf(String name) =>
      _$LeagueOrTournamentTypeValueOf(name);
}

///
/// Keeps track of the league details.
///
abstract class LeagueOrTournament
    implements Built<LeagueOrTournament, LeagueOrTournamentBuilder> {
  String get uid;
  String get name;
  @nullable
  String get photoUrl;
  String get currentSeason;
  String get shortDescription;
  @BuiltValueField(wireName: LONGDESCRIPTION)
  String get longDescription;
  LeagueOrTournamentType get type;
  Gender get gender;
  Sport get sport;
  @BuiltValueField(serialize: false)
  @nullable
  String get userUid;

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

  LeagueOrTournament._();
  factory LeagueOrTournament([updates(LeagueOrTournamentBuilder b)]) =
      _$LeagueOrTournament;

  static void _initializeBuilder(LeagueOrTournamentBuilder b) => b
    ..gender = Gender.NA
    ..sport = Sport.Other
    ..type = LeagueOrTournamentType.League;

  Map<String, dynamic> toMap({bool includeMembers = false}) {
    Map<String, dynamic> ret =
        serializers.serializeWith(LeagueOrTournament.serializer, this);
    if (!includeMembers) {
      ret.remove(MEMBERS);
    }
    return ret;
  }

  static LeagueOrTournament fromMap(
      String userUid, Map<String, dynamic> jsonData) {
    return serializers
        .deserializeWith(LeagueOrTournament.serializer, jsonData)
        .rebuild((b) => b..userUid = userUid);
  }

  static Serializer<LeagueOrTournament> get serializer =>
      _$leagueOrTournamentSerializer;

  static const String TYPE = "type";
  static const String LONGDESCRIPTION = "description";
  static const String MEMBERS = "members";
  static const String ADMIN = "admin";
  static const String SPORT = "sport";
  static const String GENDER = "gender";

  bool isUserMember(String myUid) {
    return adminsUids.contains(myUid) || members.contains(myUid);
  }

  /// Is the current user a member (or admin)?
  bool isMember() {
    return isUserMember(userUid);
  }

  bool isUserAdmin(String myUid) {
    return adminsUids.contains(myUid);
  }

  /// Is the current user an admin?
  bool isAdmin() {
    return isUserAdmin(userUid);
  }

  @override
  String toString() {
    return 'LeagueOrTournament{uid: $uid, name: $name, photoUrl: '
        '$photoUrl, currentSeason: $currentSeason, shortDescription: $shortDescription, '
        'longDescription: $longDescription, type: $type, adminsUids: $adminsUids, '
        'members: $members, sport: $sport, gender: $gender}';
  }
}
