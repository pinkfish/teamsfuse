library serializers;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'blocs/data/clubblocstate.dart';
import 'blocs/data/leagueortournamentblocstate.dart';
import 'blocs/data/profileblocstate.dart';
import 'blocs/data/seasonblocstate.dart';
import 'blocs/data/teamblocstate.dart';
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
  AddedOrAdmin,
  AddingState,
  Attendance,
  Club,
  ClubBlocStateType,
  ClubLoaded,
  ClubState,
  ClubUninitialized,
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
  LeagueOrTournamentLoaded,
  LeagueOrTournamentState,
  LeagueOrTournamentBlocStateType,
  LeagueOrTournamentUninitialized,
  Opponent,
  Player,
  ProfileBlocLoaded,
  ProfileBlocState,
  ProfileBlocStateType,
  ProfileBlocUninitialized,
  RoleInTeam,
  Season,
  SeasonBlocStateType,
  SeasonPlayer,
  SeasonLoaded,
  SeasonState,
  SeasonUninitialized,
  Sport,
  Team,
  TeamLoaded,
  TeamState,
  TeamBlocStateType,
  TeamUninitialized,
  Tristate,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(TimestampSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
