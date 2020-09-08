import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';
import 'invite.dart';

part 'invitetoleagueteam.g.dart';

///
/// Invited to a league team.
///
abstract class InviteToLeagueTeam
    implements Invite, Built<InviteToLeagueTeam, InviteToLeagueTeamBuilder> {
  String get leagueName;
  String get leagueTeamName;
  String get leagueTeamUid;
  String get leagueUid;
  String get leagueDivisonUid;
  String get leagueSeasonName;

  factory InviteToLeagueTeam(
          [void Function(InviteToLeagueTeamBuilder) updates]) =
      _$InviteToLeagueTeam;
  InviteToLeagueTeam._();

  static const String LEAGUETEAMUID = 'leagueTeamUid';
  static const String LEAGUENAME = 'leagueName';
  static const String LEAGUETEAMNAME = 'leagueTeamName';
  static const String LEAGUESEASONNAME = 'leagueSeasonName';
  static const String LEAGUEDIVISONUID = 'leagueDivisonUid';
  static const String LEAGUEUID = 'leagueUid';

  Map<String, dynamic> toMap({bool includeMembers}) {
    return serializers.serializeWith(InviteToLeagueTeam.serializer, this);
  }

  static InviteToLeagueTeam fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(InviteToLeagueTeam.serializer, jsonData);
  }

  static Serializer<InviteToLeagueTeam> get serializer =>
      _$inviteToLeagueTeamSerializer;

  static void _initializeBuilder(InviteToLeagueTeamBuilder b) =>
      b..type = InviteType.LeagueTeam;
}
