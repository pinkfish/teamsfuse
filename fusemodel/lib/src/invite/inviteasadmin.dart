import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';
import 'invite.dart';

part 'inviteasadmin.g.dart';

///
/// Invited as an admin to the team.
///
abstract class InviteAsAdmin
    implements Invite, Built<InviteAsAdmin, InviteAsAdminBuilder> {
  String get teamName;
  String get teamUid;

  factory InviteAsAdmin([void Function(InviteAsAdminBuilder) updates]) =
      _$InviteAsAdmin;
  InviteAsAdmin._();

  static const String TEAMUID = 'teamUid';
  static const String TEAMNAME = 'teamName';

  Map<String, dynamic> toMap({bool includeMembers}) {
    return dataSerializers.serializeWith(InviteAsAdmin.serializer, this);
  }

  static InviteAsAdmin fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(InviteAsAdmin.serializer, jsonData);
  }

  static Serializer<InviteAsAdmin> get serializer => _$inviteAsAdminSerializer;

  /// Defaults for the state.  Set the type.
  static void _initializeBuilder(InviteAsAdminBuilder b) =>
      b..type = InviteType.Admin;
}
