import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import '../../fusemodel.dart';
import '../serializer.dart';
import 'data/clubblocstate.dart';
import 'data/gameblocstate.dart';
import 'data/inviteblocstate.dart';
import 'data/leagueortournamentblocstate.dart';
import 'data/messagesblocstate.dart';
import 'data/playerblocstate.dart';
import 'data/profileblocstate.dart';
import 'data/seasonblocstate.dart';
import 'data/teamblocstate.dart';
import 'single/data/singleclubbloc.dart';
import 'single/data/singlegamebloc.dart';
import 'single/data/singleinvitebloc.dart';
import 'single/data/singleleagueortournamentbloc.dart';
import 'single/data/singleleagueortournamentdivisonbloc.dart';
import 'single/data/singleleagueortournamentseasonbloc.dart';
import 'single/data/singleleagueortournamentteambloc.dart';
import 'single/data/singlemessagebloc.dart';
import 'single/data/singleopponentbloc.dart';
import 'single/data/singleplayerbloc.dart';
import 'single/data/singleprofilebloc.dart';
import 'single/data/singleseasonbloc.dart';
import 'single/data/singlesharedgamebloc.dart';
import 'single/data/singleteambloc.dart';
import 'single/data/singleteamseasonplayerbloc.dart';

part 'serializer.g.dart';

///
/// Collection of generated serializers for the built_value chat example.
///
@SerializersFor([
  AddingState,
  ClubBlocStateType,
  ClubLoaded,
  ClubState,
  ClubUninitialized,
  GameBlocStateType,
  GameLoaded,
  GameState,
  GameUninitialized,
  InviteLoaded,
  InviteState,
  InviteBlocStateType,
  InviteUninitialized,
  LeagueOrTournamentLoaded,
  LeagueOrTournamentState,
  LeagueOrTournamentBlocStateType,
  LeagueOrTournamentUninitialized,
  MessagesBlocStateType,
  MessagesLoaded,
  MessagesBlocState,
  MessagesUninitialized,
  PlayerBlocStateType,
  PlayerLoaded,
  PlayerState,
  PlayerUninitialized,
  ProfileBlocLoaded,
  ProfileBlocState,
  ProfileBlocStateType,
  ProfileBlocUninitialized,
  SeasonBlocStateType,
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
  SingleInviteLoaded,
  SingleInviteBlocStateType,
  SingleInviteUninitialized,
  SingleInviteSaving,
  SingleInviteDeleted,
  SingleInviteState,
  SingleInviteSaving,
  SingleInviteSaveFailed,
  SingleInviteSaveDone,
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
  SingleMessageLoaded,
  SingleMessageState,
  SingleMessageBlocStateType,
  SingleMessageUninitialized,
  SingleMessageDeleted,
  SingleMessageSaving,
  SingleMessageSaveFailed,
  SingleMessageSaveDone,
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
  SingleSharedGameLoaded,
  SingleSharedGameState,
  SingleSharedGameBlocStateType,
  SingleSharedGameUninitialized,
  SingleSharedGameDeleted,
  SingleSharedGameSaving,
  SingleSharedGameSaveFailed,
  SingleSharedGameSaveDone,
  SingleTeamLoaded,
  SingleTeamState,
  SingleTeamBlocStateType,
  SingleTeamUninitialized,
  SingleTeamDeleted,
  SingleTeamSaving,
  SingleTeamSaveFailed,
  SingleTeamSaveDone,
  SingleTeamSeasonPlayerLoaded,
  SingleTeamSeasonPlayerBlocStateType,
  SingleTeamSeasonPlayerUninitialized,
  SingleTeamSeasonPlayerSaving,
  SingleTeamSeasonPlayerDeleted,
  SingleTeamSeasonPlayerState,
  SingleTeamSeasonPlayerSaving,
  SingleTeamSeasonPlayerSaveFailed,
  SingleTeamSeasonPlayerSaveDone,
  TeamLoaded,
  TeamState,
  TeamBlocStateType,
  TeamUninitialized,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..merge(dataSerializers)
      ..add(TimestampSerializer())
      ..add(InviteSerializer())
      ..add(GamePeriodSerializer())
      ..addPlugin(CustomEnumJsonPlugin({
        GamePeriod,
      }))
      ..addPlugin(StandardJsonPlugin()))
    .build();
