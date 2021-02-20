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
  /// The email to add the invite.
  String get email;

  /// The name of the player in the invite.
  String get playerName;

  /// The role the user is added as.
  RoleInTeam get role;

  /// The factory to crete the invite data.
  factory InviteTeamData([void Function(InviteTeamDataBuilder) updates]) =
      _$InviteTeamData;
  InviteTeamData._();
}
