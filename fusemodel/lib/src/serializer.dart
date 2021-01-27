library serializers;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

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
import 'blocs/single/data/singlegamebloc.dart';
import 'blocs/single/data/singleleagueortournamentbloc.dart';
import 'blocs/single/data/singleleagueortournamentdivisonbloc.dart';
import 'blocs/single/data/singleleagueortournamentseasonbloc.dart';
import 'blocs/single/data/singleleagueortournamentteambloc.dart';
import 'blocs/single/data/singleopponentbloc.dart';
import 'blocs/single/data/singleplayerbloc.dart';
import 'blocs/single/data/singleprofilebloc.dart';
import 'blocs/single/data/singleseasonbloc.dart';
import 'blocs/single/data/singleteambloc.dart';
import 'club.dart';
import 'common.dart';
import 'game.dart';
import 'invite.dart';
import 'leagueortournament.dart';
import 'media.dart';
import 'message.dart';
import 'player.dart';
import 'serializer/customjsonserializerplugin.dart';
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
  FusedUserProfile,
  Game,
  GameBlocStateType,
  GameDivisionsType,
  GameEvent,
  GameEventType,
  GameFoulType,
  GameInProgress,
  GameLoaded,
  GameLog,
  GameLogType,
  GamePeriodType,
  GamePlace,
  GamePlayerSummary,
  GameResult,
  GameResultPerPeriod,
  GameScore,
  GameSharedData,
  GameState,
  GameSummary,
  GameUninitialized,
  Gender,
  Invite,
  InviteType,
  InviteAsAdmin,
  InviteToClub,
  InviteToLeagueAsAdmin,
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
  MediaInfo,
  MediaType,
  Message,
  MessagesBlocStateType,
  MessagesLoaded,
  MessagesBlocState,
  MessageReadState,
  MessagesUninitialized,
  OfficialResult,
  Opponent,
  Player,
  PlayerBlocStateType,
  PlayerSummaryData,
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
  SeasonPlayerSummary,
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
  SingleGameLoaded,
  SingleGameState,
  SingleGameBlocStateType,
  SingleGameUninitialized,
  SingleGameDeleted,
  SingleGameSaving,
  SingleGameSaveFailed,
  SingleGameSaveDone,
  SingleLeagueOrTournamentLoaded,
  SingleLeagueOrTournamentState,
  SingleLeagueOrTournamentBlocStateType,
  SingleLeagueOrTournamentUninitialized,
  SingleLeagueOrTournamentDeleted,
  SingleLeagueOrTournamentSaving,
  SingleLeagueOrTournamentSaveFailed,
  SingleLeagueOrTournamentSaveDone,
  SingleLeagueOrTournamentTeamLoaded,
  SingleLeagueOrTournamentTeamState,
  SingleLeagueOrTournamentTeamBlocStateType,
  SingleLeagueOrTournamentTeamUninitialized,
  SingleLeagueOrTournamentTeamDeleted,
  SingleLeagueOrTournamentTeamSaving,
  SingleLeagueOrTournamentTeamSaveFailed,
  SingleLeagueOrTournamentTeamSaveDone,
  SingleLeagueOrTournamentSeasonLoaded,
  SingleLeagueOrTournamentSeasonState,
  SingleLeagueOrTournamentSeasonBlocStateType,
  SingleLeagueOrTournamentSeasonUninitialized,
  SingleLeagueOrTournamentSeasonDeleted,
  SingleLeagueOrTournamentSeasonSaving,
  SingleLeagueOrTournamentSeasonSaveFailed,
  SingleLeagueOrTournamentSeasonSaveDone,
  SingleLeagueOrTournamentDivisonLoaded,
  SingleLeagueOrTournamentDivisonState,
  SingleLeagueOrTournamentDivisonBlocStateType,
  SingleLeagueOrTournamentDivisonUninitialized,
  SingleLeagueOrTournamentDivisonDeleted,
  SingleLeagueOrTournamentDivisonSaving,
  SingleLeagueOrTournamentDivisonSaveFailed,
  SingleLeagueOrTournamentDivisonSaveDone,
  SingleOpponentLoaded,
  SingleOpponentState,
  SingleOpponentBlocStateType,
  SingleOpponentUninitialized,
  SingleOpponentDeleted,
  SingleOpponentSaving,
  SingleOpponentSaveFailed,
  SingleOpponentSaveDone,
  SinglePlayerLoaded,
  SinglePlayerState,
  SinglePlayerBlocStateType,
  SinglePlayerUninitialized,
  SinglePlayerDeleted,
  SinglePlayerSaving,
  SinglePlayerSaveFailed,
  SinglePlayerSaveDone,
  SingleProfileLoaded,
  SingleProfileState,
  SingleProfileBlocStateType,
  SingleProfileUninitialized,
  SingleProfileDeleted,
  SingleProfileSaving,
  SingleProfileSaveFailed,
  SingleProfileSaveDone,
  SingleSeasonLoaded,
  SingleSeasonState,
  SingleSeasonBlocStateType,
  SingleSeasonUninitialized,
  SingleSeasonDeleted,
  SingleSeasonSaving,
  SingleSeasonSaveFailed,
  SingleSeasonSaveDone,
  SingleTeamLoaded,
  SingleTeamState,
  SingleTeamBlocStateType,
  SingleTeamUninitialized,
  SingleTeamDeleted,
  SingleTeamSaving,
  SingleTeamSaveFailed,
  SingleTeamSaveDone,
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
      ..addPlugin(CustomEnumJsonPlugin({
        GamePeriod,
      })))
    .build();
