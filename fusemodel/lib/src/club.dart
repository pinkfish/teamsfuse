import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import 'common.dart';
import 'serializer.dart';

part 'club.g.dart';

///
/// Keeps track of the club details.  The tracks a list of teams,
/// the admins of the club are admins of the teams.  The members of the
/// club can see other teams in the club, as a member/visitor.  You are a
/// member if you are a member of a subteam or if you are in a member in
/// the club itself.
///
abstract class Club implements Built<Club, ClubBuilder> {
  String get uid;
  String get name;
  @nullable
  String get photoUrl;

  /// Some text describing what the club is about.
  String get about;

  // The sport associated with this club.
  Sport get sport;

  /// This pulls through to all the teams in a club as a default and overrides
  /// the team specific settings, if this is not null.
  Tristate get trackAttendence;

  /// This is the default to arrive before a game,  It overrides the defaults
  /// on the team if this is not null.
  int get arriveBeforeGame;

  /// If the club is a public club.
  bool get isPublic;

  /// List of admin user ids. This is all user ids (not players)
  @BuiltValueField(wireName: MEMBERS)
  BuiltMap<String, AddedOrAdmin> get membersData;

  /// List of member user ids.  This is all user ids (not players)
  @memoized
  BuiltSet<String> get members => BuiltSet.of(membersData.keys);

  @memoized
  BuiltSet<String> get adminsUids =>
      BuiltSet.of(membersData.keys.where((e) => membersData[e].admin));

  @BuiltValueField(serialize: false)
  String get userUid;

  Club._();
  factory Club([updates(ClubBuilder b)]) => _$Club((b) => b..about = "");

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(ClubBuilder b) => b
    ..about = ""
    ..arriveBeforeGame = 0
    ..trackAttendence = Tristate.Yes
    ..isPublic = false
    ..userUid = "";

  Map<String, dynamic> toMap({bool includeMembers}) {
    Map<String, dynamic> ret =
        dataSerializers.serializeWith(Club.serializer, this);
    if (includeMembers) {
      return ret;
    }
    ret.remove(MEMBERS);
    return ret;
  }

  static Club fromMap(String userUid, Map<String, dynamic> jsonData) {
    return dataSerializers
        .deserializeWith(Club.serializer, jsonData)
        .rebuild((b) => b..userUid = userUid ?? "");
  }

  static Serializer<Club> get serializer => _$clubSerializer;

  static const String MEMBERS = "members";
  static const String ADMIN = "admin";

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
}
