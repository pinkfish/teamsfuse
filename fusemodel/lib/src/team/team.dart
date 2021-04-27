import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../club.dart';
import '../common.dart';
import '../serializer.dart';

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
  /// The name of the team.
  String get name;

  /// How early people should arrive for the game by default.  This is
  /// overridden by the club potentially.
  @BuiltValueField(wireName: ARRIVALTIME)
  num get arriveEarlyInternal;

  /// The uid associated with the currnet season.
  String get currentSeason;

  /// the gender of the team.
  Gender get gender;

  /// the league name the team is associated with.
  String get league;

  /// The sport the team plays.
  Sport get sport;

  /// the uid for the team.
  String get uid;

  /// The url to get the photo from
  @nullable
  @BuiltValueField(wireName: photoUrlField)
  String get photoUrl;

  /// If this team has been archived.
  @BuiltValueField(wireName: archivedField)
  BuiltMap<String, bool> get archivedData;

  /// The user id in this team.
  @BuiltValueField(serialize: false)
  String get userUid;

  /// If this is not null signifies that this team is a member of a club.
  @nullable
  String get clubUid;

  /// If we can only see public details of this team.
  @BuiltValueField(serialize: false)
  bool get publicOnly;

  /// If this team is publicaly visible.
  @BuiltValueField(wireName: isPublicField)
  bool get isPublic;

  /// If we should track attendecne for games in this team.  This is
  /// overridden by the club potentially.
  @BuiltValueField(wireName: attendanceField)
  bool get trackAttendanceInternal;

  /// This is a list of user ids, not player Ids.
  @BuiltValueField(wireName: adminsField)
  BuiltMap<String, BuiltMap<String, bool>> get adminsData;

  @memoized
  BuiltSet<String> get admins => BuiltSet.of(adminsData.keys);

  /// The users setup for the team.
  @BuiltValueField(wireName: userField)
  BuiltMap<String, BuiltMap<String, bool>> get users;

  /// If the user is archvied from the team.
  @memoized
  bool get archived =>
      archivedData.containsKey(userUid) && archivedData[userUid];

  Team._();

  /// Create a new team.
  factory Team([Function(TeamBuilder b) updates]) = _$Team;

  /// The admins field.
  static const String adminsField = 'admins';

  /// The track attendance field.
  static const String attendanceField = 'trackAttendance';

  /// The club uid field.
  static const String clubUidField = 'clubUid';

  /// The archived field.
  static const String archivedField = 'archived';

  /// The users field.
  static const String userField = 'users';

  /// The isPublic field.
  static const String isPublicField = 'isPublic';

  /// The photo url field.
  static const String photoUrlField = 'photoUrl';

  static void _initializeBuilder(TeamBuilder b) => b
    ..userUid = ''
    ..isPublic = false
    ..publicOnly = false;

  /// Deserialize the team.
  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(Team.serializer, this);
  }

  /// Creates a team from a mapping.
  static Team fromMap(String userUid, Map<String, dynamic> jsonData) {
    return dataSerializers
        .deserializeWith(Team.serializer, jsonData)
        .rebuild((b) => b..userUid = userUid);
  }

  static Serializer<Team> get serializer => _$teamSerializer;

  /// Get the attendance tracking, potentially from the club.
  bool trackAttendance(Club club) {
    if (clubUid == null) {
      return trackAttendanceInternal;
    }
    if (club != null) {
      if (club.trackAttendence != Tristate.Unset) {
        return club.trackAttendence == Tristate.Yes;
      }
    }
    return trackAttendanceInternal;
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
