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
import 'single/data/singleclubcoachbloc.dart';
import 'single/data/singlegamebloc.dart';
import 'single/data/singleinvitebloc.dart';
import 'single/data/singleleagueortournamentbloc.dart';
import 'single/data/singleleagueortournamentdivisonbloc.dart';
import 'single/data/singleleagueortournamentseasonbloc.dart';
import 'single/data/singleleagueortournamentteambloc.dart';
import 'single/data/singlemessagebloc.dart';
import 'single/data/singlenewsitembloc.dart';
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
  InviteBlocStateType,
  InviteLoaded,
  InviteState,
  InviteUninitialized,
  LeagueOrTournamentBlocStateType,
  LeagueOrTournamentLoaded,
  LeagueOrTournamentState,
  LeagueOrTournamentUninitialized,
  MessagesBlocState,
  MessagesBlocStateType,
  MessagesLoaded,
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
  SingleClubBlocStateType,
  SingleClubCoachBlocStateType,
  SingleClubCoachDeleted,
  SingleClubCoachLoaded,
  SingleClubCoachSaveDone,
  SingleClubCoachSaveFailed,
  SingleClubCoachSaving,
  SingleClubCoachState,
  SingleClubCoachUninitialized,
  SingleNewsItemBlocStateType,
  SingleNewsItemDeleted,
  SingleNewsItemLoaded,
  SingleNewsItemSaveDone,
  SingleNewsItemSaveFailed,
  SingleNewsItemSaving,
  SingleNewsItemState,
  SingleNewsItemUninitialized,
  SingleClubDeleted,
  SingleClubLoaded,
  SingleClubSaveDone,
  SingleClubSaveFailed,
  SingleClubSaving,
  SingleClubState,
  SingleClubUninitialized,
  SingleGameBlocStateType,
  SingleGameDeleted,
  SingleGameLoaded,
  SingleGameSaveDone,
  SingleGameSaveFailed,
  SingleGameSaving,
  SingleGameState,
  SingleGameUninitialized,
  SingleInviteBlocStateType,
  SingleInviteDeleted,
  SingleInviteLoaded,
  SingleInviteSaveDone,
  SingleInviteSaveFailed,
  SingleInviteSaving,
  SingleInviteSaving,
  SingleInviteState,
  SingleInviteUninitialized,
  SingleLeagueOrTournamentBlocStateType,
  SingleLeagueOrTournamentDeleted,
  SingleLeagueOrTournamentDivisonBlocStateType,
  SingleLeagueOrTournamentDivisonDeleted,
  SingleLeagueOrTournamentDivisonLoaded,
  SingleLeagueOrTournamentDivisonSaveDone,
  SingleLeagueOrTournamentDivisonSaveFailed,
  SingleLeagueOrTournamentDivisonSaving,
  SingleLeagueOrTournamentDivisonState,
  SingleLeagueOrTournamentDivisonUninitialized,
  SingleLeagueOrTournamentLoaded,
  SingleLeagueOrTournamentSaveDone,
  SingleLeagueOrTournamentSaveFailed,
  SingleLeagueOrTournamentSaving,
  SingleLeagueOrTournamentSeasonBlocStateType,
  SingleLeagueOrTournamentSeasonDeleted,
  SingleLeagueOrTournamentSeasonLoaded,
  SingleLeagueOrTournamentSeasonSaveDone,
  SingleLeagueOrTournamentSeasonSaveFailed,
  SingleLeagueOrTournamentSeasonSaving,
  SingleLeagueOrTournamentSeasonState,
  SingleLeagueOrTournamentSeasonUninitialized,
  SingleLeagueOrTournamentState,
  SingleLeagueOrTournamentTeamBlocStateType,
  SingleLeagueOrTournamentTeamDeleted,
  SingleLeagueOrTournamentTeamLoaded,
  SingleLeagueOrTournamentTeamSaveDone,
  SingleLeagueOrTournamentTeamSaveFailed,
  SingleLeagueOrTournamentTeamSaving,
  SingleLeagueOrTournamentTeamState,
  SingleLeagueOrTournamentTeamUninitialized,
  SingleLeagueOrTournamentUninitialized,
  SingleMessageBlocStateType,
  SingleMessageDeleted,
  SingleMessageLoaded,
  SingleMessageSaveDone,
  SingleMessageSaveFailed,
  SingleMessageSaving,
  SingleMessageState,
  SingleMessageUninitialized,
  SingleOpponentBlocStateType,
  SingleOpponentDeleted,
  SingleOpponentLoaded,
  SingleOpponentSaveDone,
  SingleOpponentSaveFailed,
  SingleOpponentSaving,
  SingleOpponentState,
  SingleOpponentUninitialized,
  SinglePlayerBlocStateType,
  SinglePlayerDeleted,
  SinglePlayerLoaded,
  SinglePlayerSaveDone,
  SinglePlayerSaveFailed,
  SinglePlayerSaving,
  SinglePlayerState,
  SinglePlayerUninitialized,
  SingleProfileBlocStateType,
  SingleProfileDeleted,
  SingleProfileLoaded,
  SingleProfileSaveDone,
  SingleProfileSaveFailed,
  SingleProfileSaving,
  SingleProfileState,
  SingleProfileUninitialized,
  SingleSeasonBlocStateType,
  SingleSeasonDeleted,
  SingleSeasonLoaded,
  SingleSeasonSaveDone,
  SingleSeasonSaveFailed,
  SingleSeasonSaving,
  SingleSeasonState,
  SingleSeasonUninitialized,
  SingleSharedGameBlocStateType,
  SingleSharedGameDeleted,
  SingleSharedGameLoaded,
  SingleSharedGameSaveDone,
  SingleSharedGameSaveFailed,
  SingleSharedGameSaving,
  SingleSharedGameState,
  SingleSharedGameUninitialized,
  SingleTeamBlocStateType,
  SingleTeamDeleted,
  SingleTeamLoaded,
  SingleTeamSaveDone,
  SingleTeamSaveFailed,
  SingleTeamSaving,
  SingleTeamSeasonPlayerBlocStateType,
  SingleTeamSeasonPlayerDeleted,
  SingleTeamSeasonPlayerLoaded,
  SingleTeamSeasonPlayerSaveDone,
  SingleTeamSeasonPlayerSaveFailed,
  SingleTeamSeasonPlayerSaving,
  SingleTeamSeasonPlayerSaving,
  SingleTeamSeasonPlayerState,
  SingleTeamSeasonPlayerUninitialized,
  SingleTeamState,
  SingleTeamUninitialized,
  TeamBlocStateType,
  TeamLoaded,
  TeamState,
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
