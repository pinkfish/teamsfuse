library serializers;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'ant/broadcast.dart';
import 'ant/broadcaststatus.dart';
import 'ant/broadcasttype.dart';
import 'club.dart';
import 'clubs/newsitem.dart';
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
  AddedOrAdmin,
  AddedUid,
  Attendance,
  Broadcast,
  BroadcastStatus,
  BroadcastType,
  Club,
  Coach,
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
  InviteAsAdmin,
  InviteToClub,
  InviteToLeagueAsAdmin,
  InviteToTeam,
  InviteType,
  InviteType,
  LeagueOrTournament,
  LeagueOrTournamentDivison,
  LeagueOrTournamentSeason,
  LeagueOrTournamentTeam,
  MediaInfo,
  MediaType,
  Message,
  MessageReadState,
  NewsItem,
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
      }))
      ..addPlugin(StandardJsonPlugin()))
    .build();
