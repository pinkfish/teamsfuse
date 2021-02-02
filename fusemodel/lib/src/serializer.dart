library serializers;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

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
import 'ant/broadcaststatus.dart';
import 'ant/broadcasttype.dart';
import 'ant/broadcast.dart';

part 'serializer.g.dart';

///
/// Collection of generated serializers for the built_value chat example.
///
@SerializersFor([
  AddedUid,
  AddedOrAdmin,
  Attendance,
  Broadcast,
  BroadcastStatus,
  BroadcastType,
  Club,
  EventType,
  FusedUserProfile,
  Game,
  GameDivisionsType,
  GameEvent,
  GameEventType,
  GameFoulType,
  GameInProgress,
  GameLog,
  GameLogType,
  GamePeriodType,
  GamePlace,
  GamePlayerSummary,
  GameResult,
  GameResultPerPeriod,
  GameScore,
  GameSharedData,
  GameSummary,
  Gender,
  Invite,
  InviteType,
  InviteAsAdmin,
  InviteToClub,
  InviteToLeagueAsAdmin,
  InviteToTeam,
  InviteType,
  LeagueOrTournament,
  LeagueOrTournamentDivison,
  LeagueOrTournamentSeason,
  LeagueOrTournamentTeam,
  MediaInfo,
  MediaType,
  Message,
  MessageReadState,
  OfficialResult,
  Opponent,
  Player,
  PlayerSummaryData,
  PlayerUserInternal,
  Relationship,
  RepeatData,
  RepeatPeriod,
  RoleInTeam,
  Season,
  SeasonPlayer,
  SeasonPlayerSummary,
  Sport,
  Team,
  Tristate,
  WinRecord
])
final Serializers dataSerializers = (_$dataSerializers.toBuilder()
      ..add(TimestampSerializer())
      ..add(InviteSerializer())
      ..add(GamePeriodSerializer())
      ..addPlugin(CustomEnumJsonPlugin({
        GamePeriod,
      })))
    .build();
