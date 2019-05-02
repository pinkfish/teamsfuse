import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import '../common.dart';
import '../team.dart';
import 'invite.dart';

part 'invitetoteam.g.dart';

///
/// Invited to the team.
///
abstract class InviteToTeam
    implements Invite, Built<InviteToTeam, InviteToTeamBuilder> {
  String get teamName;
  String get seasonName;
  String get teamUid;
  String get seasonUid;
  RoleInTeam get role;
  BuiltList<String> get playerName;

  InviteType getType() => InviteType.Team;

  factory InviteToTeam([void Function(InviteToTeamBuilder) updates]) =
      _$InviteToTeam;
  InviteToTeam._();

  /*
  InviteToTeam(
      {String email,
      String uid,
      String sentByUid,
      this.teamUid,
      this.teamName,
      this.seasonName,
      this.seasonUid,
      this.playerName,
      this.role = RoleInTeam.Player})
      : super(
            email: email,
            uid: uid,
            type: InviteType.Team,
            sentByUid: sentByUid);

  InviteToTeam.copy(InviteToTeam invite)
      : teamName = invite.teamName,
        seasonName = invite.seasonName,
        teamUid = invite.teamUid,
        seasonUid = invite.seasonUid,
        playerName = new List<String>.from(invite.playerName),
        role = invite.role,
        super.copy(invite) {}
        */

  static const String TEAMUID = 'teamUid';
  static const String TEAMNAME = 'teamName';
  static const String SEASONNAME = 'seasonName';
  static const String SEASONUID = 'seasonUid';
  static const String ROLE = 'role';

  static InviteToTeamBuilder fromJSON(String uid, Map<String, dynamic> data) {
    InviteToTeamBuilder builder = InviteToTeamBuilder();
    Invite.fromJSON(builder, uid, data);
    if (data.containsKey(NAME) && data[NAME] is List) {
      List<dynamic> nameList = data[NAME];
      builder.playerName
          .addAll(nameList.map((dynamic d) => d is String ? d : ""));
      //playerName = nameList.map((dynamic d) => d is String ? d : "").toList();
    }

    return builder
      ..teamUid = getString(data[TEAMUID])
      ..seasonUid = getString(data[SEASONUID])
      ..teamName = getString(data[TEAMNAME])
      ..seasonName = getString(data[SEASONNAME])
      ..role = RoleInTeam.values.firstWhere((e) => e.toString() == data[ROLE],
          orElse: () => RoleInTeam.NonPlayer);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = Invite.toJSONInternal(this);
    ret[TEAMUID] = teamUid;
    ret[SEASONUID] = seasonUid;
    ret[NAME] = playerName;
    ret[TEAMNAME] = teamName;
    ret[SEASONNAME] = seasonName;
    ret[ROLE] = role.toString();
    return ret;
  }

  /*
  @override
  int compareTo(Invite other) {
    if (baseCompareTo(other) != 0) {
      return -1;
    }
    if (other is InviteToTeam) {
      if (teamName.compareTo(other.teamName) != 0) {
        return -1;
      }
      if (teamUid.compareTo(other.teamUid) != 0) {
        return -1;
      }
      if (seasonUid.compareTo(other.seasonUid) != 0) {
        return -1;
      }
      if (playerName.length != other.playerName.length) {
        return 1;
      }
      if (playerName.any((p) => !other.playerName.contains(p)) != 0) {
        return -1;
      }
      if (seasonName.compareTo(other.seasonName) != 0) {
        return -1;
      }
      if (role != other.role) {
        return -1;
      }
      return 0;
    }
    return 1;
  }
  */
}
