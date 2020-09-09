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
import 'blocs/single/data/singleprofilebloc.dart';
import 'club.dart';
import 'common.dart';
import 'game.dart';
import 'invite.dart';
import 'leagueortournament.dart';
import 'message.dart';
import 'player.dart';
import 'serializer/gameperiodserializer.dart';
import 'serializer/inviteserializer.dart';
import 'serializer/timestampserializer.dart';
import 'team.dart';
import 'userprofile.dart';
import 'winrecord.dart';

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
  EventType,
  Game,
  GameBlocStateType,
  GameDivisionsType,
  GameInProgress,
  GameLoaded,
  GameLog,
  GameLogType,
  GameResult,
  GameResultPerPeriod,
  GameState,
  GamePeriodType,
  GameUninitialized,
  Invite,
  InviteType,
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
  GameDivisionsType,
  GameInProgress,
  GamePeriod,
  GamePeriodType,
  GamePlace,
  GameResult,
  GameResultPerPeriod,
  GameScore,
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
  LeagueOrTournamentTeam,
  MessageState,
  OfficialResult,
  Opponent,
  Player,
  PlayerBlocStateType,
  PlayerLoaded,
  PlayerState,
  PlayerUninitialized,
  PlayerUserInternal,
  ProfileBlocLoaded,
  ProfileBlocState,
  ProfileBlocStateType,
  ProfileBlocUninitialized,
  Relationship,
  RepeatData,
  RepeatPeriod,
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
  SinglePlayerLoaded,
  SingleProfileState,
  SingleProfileBlocStateType,
  SingleProfileUninitialized,
  SingleProfileDeleted,
  SingleProfileSaving,
  SingleProfileSaveFailed,
  SingleProfileSaveDone,
  Sport,
  Team,
  TeamLoaded,
  TeamState,
  TeamBlocStateType,
  TeamUninitialized,
  Tristate,
  WinRecord
])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(TimestampSerializer())
      ..add(InviteSerializer())
      ..add(GamePeriodSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
