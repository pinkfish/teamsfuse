import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';
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

  factory InviteToTeam([void Function(InviteToTeamBuilder) updates]) =
      _$InviteToTeam;
  InviteToTeam._();

  static const String TEAMUID = 'teamUid';
  static const String TEAMNAME = 'teamName';
  static const String SEASONNAME = 'seasonName';
  static const String SEASONUID = 'seasonUid';
  static const String ROLE = 'role';

  Map<String, dynamic> toMap({bool includeMembers}) {
    return dataSerializers.serializeWith(InviteToTeam.serializer, this);
  }

  static InviteToTeam fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(InviteToTeam.serializer, jsonData);
  }

  static Serializer<InviteToTeam> get serializer => _$inviteToTeamSerializer;

  static void _initializeBuilder(InviteToTeamBuilder b) =>
      b..type = InviteType.Team;
}
