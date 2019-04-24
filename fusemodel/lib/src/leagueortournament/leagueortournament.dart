import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:meta/meta.dart';

import '../common.dart';

part 'leagueortournament.g.dart';

///
/// The type of the league or tournment.
///
enum LeagueOrTournamentType {
  Tournament,
  League,
}

///
/// Keeps track of the league details.
///
abstract class LeagueOrTournament
    implements Built<LeagueOrTournament, LeagueOrTournamentBuilder> {
  String get uid;
  String get name;
  String get photoUrl;
  String get currentSeason;
  String get shortDescription;
  String get longDescription;
  LeagueOrTournamentType get type;
  Gender get gender;
  Sport get sport;
  String get userUid;

  /// List of admin user ids. This is all user ids (not players)
  BuiltList<String> get adminsUids;

  /// List of member user ids.  This is all user ids (not players)
  BuiltList<String> get members;

  LeagueOrTournament._();
  factory LeagueOrTournament([updates(LeagueOrTournamentBuilder b)]) =
      _$LeagueOrTournament;

  ///
  /// Load this from the wire format.
  ///
  static LeagueOrTournamentBuilder fromJSON(
      {@required String myUid,
      @required String userUid,
      @required Map<String, dynamic> data}) {
    LeagueOrTournamentBuilder builder;
    builder
      ..uid = myUid
      ..userUid = userUid
      ..name = data[NAME]
      ..photoUrl = data[PHOTOURL]
      ..currentSeason = data[_CURRENTSEASON]
      ..shortDescription = data[SHORTDESCRIPTION]
      ..longDescription = data[LONGDESCRIPTION]
      ..gender = Gender.values.firstWhere(
          (Gender g) => g.toString() == data[GENDER],
          orElse: () => Gender.NA)
      ..sport = Sport.values.firstWhere(
          (Sport s) => s.toString() == data[SPORT],
          orElse: () => Sport.Other)
      ..type = LeagueOrTournamentType.values.firstWhere(
          (LeagueOrTournamentType t) => t.toString() == data[TYPE],
          orElse: () => LeagueOrTournamentType.League);
    print('fromJSON $data');
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
    return builder;
  }

  static const String TYPE = "type";
  static const String SHORTDESCRIPTION = "shortDescription";
  static const String LONGDESCRIPTION = "description";
  static const String MEMBERS = "members";
  static const String ADMIN = "admin";
  static const String SPORT = "sport";
  static const String GENDER = "gender";
  static const String _CURRENTSEASON = "currentSeason";

  ///
  /// Convrt this league into the format to use to send over the wire.
  ///
  Map<String, dynamic> toJson({bool includeMembers = false}) {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret[NAME] = name;
    ret[PHOTOURL] = photoUrl;
    ret[SHORTDESCRIPTION] = shortDescription;
    ret[LONGDESCRIPTION] = longDescription;
    ret[_CURRENTSEASON] = currentSeason;
    ret[GENDER] = gender.toString();
    ret[SPORT] = sport.toString();
    ret[TYPE] = type.toString();
    Map<String, dynamic> data = <String, dynamic>{};
    if (includeMembers) {
      for (String admin in adminsUids) {
        data[admin] = <String, bool>{ADDED: true, ADMIN: true};
      }
      for (String member in members) {
        data[member] = <String, bool>{ADDED: true, ADMIN: false};
      }
      ret[MEMBERS] = data;
    }
    return ret;
  }

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
