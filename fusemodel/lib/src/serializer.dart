library serializers;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'club.dart';
import 'common.dart';
import 'game.dart';
import 'invite.dart';
import 'leagueortournament.dart';
import 'message.dart';
import 'player.dart';
import 'team.dart';
import 'timestampserializer.dart';
import 'userprofile.dart';

part 'serializer.g.dart';

///
/// Collection of generated serializers for the built_value chat example.
///
@SerializersFor([
  AddedUid,
  Attendance,
  Club,
  Game,
  Invite,
  InviteAsAdmin,
  InviteToClub,
  InviteToLeagueAsAdmin,
  Game,
  Message,
  FusedUserProfile,
  GamePeriod,
  GamePlace,
  GameSharedData,
  Gender,
  InviteToTeam,
  InviteType,
  LeagueOrTournament,
  LeagueOrTournamentDivison,
  LeagueOrTournamentSeason,
  Opponent,
  Player,
  RoleInTeam,
  Season,
  SeasonPlayer,
  Sport,
  Team,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(TimestampSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
