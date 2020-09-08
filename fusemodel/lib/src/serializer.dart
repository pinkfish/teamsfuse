library serializers;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'blocs/data/clubblocstate.dart';
import 'blocs/data/gameblocstate.dart';
import 'blocs/data/inviteblocstate.dart';
import 'blocs/data/leagueortournamentblocstate.dart';
import 'blocs/data/messagesblocstate.dart';
import 'blocs/data/playerblocstate.dart';
import 'blocs/data/profileblocstate.dart';
import 'blocs/data/seasonblocstate.dart';
import 'blocs/data/teamblocstate.dart';
import 'blocs/single/data/singleclubbloc.dart';
import 'blocs/single/data/singleplayerbloc.dart';
import 'club.dart';
import 'common.dart';
import 'game.dart';
import 'invite.dart';
import 'leagueortournament.dart';
import 'message.dart';
import 'player.dart';
import 'serializer/inviteserializer.dart';
import 'serializer/timestampserializer.dart';
import 'team.dart';
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
  GameBlocStateType,
  GameLoaded,
  GameState,
  GameUninitialized,
  Invite,
  InviteAsAdmin,
  InviteToClub,
  InviteToLeagueAsAdmin,
  Game,
  Message,
  MessagesBlocStateType,
  MessagesLoaded,
  MessagesState,
  MessagesUninitialized,
  FusedUserProfile,
  GamePeriod,
  GamePlace,
  GameSharedData,
  Gender,
  InviteToTeam,
  InviteType,
  InviteLoaded,
  InviteState,
  InviteBlocStateType,
  InviteUninitialized,
  LeagueOrTournament,
  LeagueOrTournamentDivison,
  LeagueOrTournamentSeason,
  LeagueOrTournamentLoaded,
  LeagueOrTournamentState,
  LeagueOrTournamentBlocStateType,
  LeagueOrTournamentUninitialized,
  Opponent,
  Player,
  PlayerBlocStateType,
  PlayerLoaded,
  PlayerState,
  PlayerUninitialized,
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
  SingleClubLoaded,
  SingleClubState,
  SingleClubBlocStateType,
  SingleClubUninitialized,
  SingleClubDeleted,
  SingleClubSaving,
  SingleClubSaveFailed,
  SingleClubSaveDone,
  SinglePlayerLoaded,
  SinglePlayerState,
  SinglePlayerBlocStateType,
  SinglePlayerUninitialized,
  SinglePlayerDeleted,
  SinglePlayerSaving,
  SinglePlayerSaveFailed,
  SinglePlayerSaveDone,
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
      ..add(InviteSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
