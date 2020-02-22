import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import '../common.dart';
import '../team.dart';
import 'invite.dart';

part 'invitetoteam.g.dart';

///
/// This is used in parts of the api to handle an invite to the team without
/// everything that is needed for it.
///
abstract class InviteTeamData
    implements Built<InviteTeamData, InviteTeamDataBuilder> {
  String get email;
  String get playerName;
  RoleInTeam get role;

  factory InviteTeamData([void Function(InviteTeamDataBuilder) updates]) =
      _$InviteTeamData;
  InviteTeamData._();
}

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
}
