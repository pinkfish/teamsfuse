import 'dart:async';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:fusemodel/firestore.dart';
import 'package:meta/meta.dart';

import 'club.dart';
import 'game.dart';
import 'invite.dart';
import 'leagueortournament.dart';
import 'media.dart';
import 'message.dart';
import 'player.dart';
import 'team.dart';
import 'winrecord.dart';

///
/// Wraps up the firestore data to make it easier to use in the main
/// data code, hiding the differences between the web and mobile.
///
class FirestoreWrappedData {
  FirestoreWrappedData({this.id, this.data, this.exists});
  final String id;
  final Map<String, dynamic> data;
  final bool exists;
}

///
/// Changed data back from firestore.
///
class FirestoreChangedData {
  FirestoreChangedData({this.newList, this.removed});

  final List<FirestoreWrappedData> newList;
  final List<FirestoreWrappedData> removed;
}

///
/// Updates the games when things change in the snapshot.
///
class GameSnapshotEvent {
  final GameSharedData sharedGame;
  final Iterable<Game> newGames;
  final Iterable<String> deletedGames;
  final String gameUid;
  final String teamUid;

  GameSnapshotEvent(
      {this.gameUid,
      this.teamUid,
      this.sharedGame,
      this.newGames,
      this.deletedGames});
}

typedef void FirestoreDataCallback(
    String playerUid, List<FirestoreWrappedData> data);

///
/// Details the games can be filtered on.
///
class FilterDetails {
  Set<String> teamUids = new Set<String>();
  Set<String> playerUids = new Set<String>();
  GameResult result;
  EventType eventType;
  bool allGames = false;

  bool isIncluded(Game game, Season season) {
    if (teamUids.length != 0) {
      if (!teamUids.contains(game.teamUid)) {
        return false;
      }
    }
    if (playerUids.length > 0) {
      if (season == null) {
        return false;
      }

      if (!playerUids.any((String str) => season.players.contains(str))) {
        return false;
      }
    }
    if (result != null) {
      if (game.result.result != result &&
          !(game.result.result == GameResult.Unknown)) {
        return false;
      }
    }
    if (eventType != null) {
      if (eventType != game.sharedData.type) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    return 'FilterDetails{teamUids: $teamUids, playerUids: $playerUids, result: $result, eventType: $eventType, allGames: $allGames}';
  }
}

///
/// abstract interface to handle talking to firestore, handling the
/// differences between the web and mobile.
///
abstract class DatabaseUpdateModel {
  /// The current user for calls and stuff.
  UserData get currentUser;

  // Stuff for game updates.
  Future<Game> updateFirestoreGame(Game game, bool allTeams);
  Future<String> updateFirestoreSharedGame(GameSharedData game);
  Future<void> deleteFirestoreGame(Game game);
  Future<void> updateFirestoreGameAttendence(
      Game game, String playerUid, Attendance attend);
  Future<void> updateFirestoreGameResult(
      String gameUid, GameResultDetails result);
  Future<void> updateFirestoreOfficalGameResult(
      String gameSharedUid, GameOfficialResults result);
  Stream<Iterable<GameLog>> readGameLogs(Game game);
  Future<String> addFirestoreGameLog(Game game, GameLog log);
  Stream<GameSharedData> getSharedGame(String sharedGameUid);
  Stream<Game> getGame(String gameUid);

  // Game events
  /// Loads all the game events for this game.
  Stream<BuiltList<GameEvent>> getGameEvents({@required String gameUid});

  /// Gets the UID for the game event to write out.
  Future<String> getGameEventId({@required GameEvent event});

  /// Adds the game event into the database
  Future<void> setGameEvent({@required GameEvent event});

  /// Delete the game event from the database.
  Future<void> deleteGameEvent({@required String gameEventUid});

  // Media
  /// Loads all the media for this game.
  Stream<BuiltList<MediaInfo>> getMediaForGame({@required String gameUid});

  /// Gets all the updates for this speific media info blob.
  Stream<MediaInfo> getMediaInfo({@required String mediaInfoUid});

  /// Adds the game event into the database
  Future<String> addMedia({@required MediaInfo media});

  /// Updates the season in the database.
  Future<void> updateMediaInfoThumbnail(
      {@required MediaInfo mediaInfo, @required String thumbnailUrl});
  Future<void> deleteMedia({@required String mediaInfoUid});

  // Invite firestore updates
  Future<void> firestoreInviteDelete(String inviteUid);
  Stream<Invite> getSingleInvite(String inviteUid);

  // Message Recipients
  Future<void> updateMessageRecipientState(
      MessageRecipient rec, MessageReadState state);
  Future<void> deleteRecipient(MessageRecipient rec);

  // Message for firestore.
  Future<Message> updateFirestoreMessage(MessageBuilder mess);
  Future<void> updateFirestoreMessageBody({String messageUid, String body});
  Stream<String> loadMessageBody(String messageUid);
  Future<Message> getMessage(String messageId);

  // Opponent update
  Future<void> updateFirestoreOpponent(Opponent opponent);
  Future<Opponent> addFirestoreOpponent(Opponent opponent);
  Future<void> deleteFirestoreOpponent(Opponent opponent);
  Stream<Iterable<Game>> getOpponentGames(Opponent opponent);
  Stream<Opponent> getFirestoreOpponent(
      {@required String teamUid, @required String opponentUid});

  // Team stuff
  Future<void> updateFirestoreTeam(Team team);
  Future<void> addTrainingEvents(Game game, Iterable<DateTime> dates);
  Future<String> addFirestoreTeam(Team team, DocumentReferenceWrapper pregen,
      Season season, File imageFile);
  Future<Uri> updateTeamImage(String teamUid, File imgFile);
  DocumentReferenceWrapper precreateClubUid();
  Future<String> inviteAdminToTeam(
      {@required String myUid,
      @required String teamUid,
      @required String teamName,
      @required String email});
  Future<void> deleteAdmin(Team team, String uid);
  Future<String> addAdmin(String teamUid, String uid);
  Stream<Iterable<InviteAsAdmin>> getInviteForTeamStream(Team team);
  Future<Team> getPublicTeamDetails({@required String teamUid});
  Stream<Iterable<InviteAsAdmin>> getInvitesForTeam(String teamUid);
  Stream<Iterable<Opponent>> getTeamOpponents(String teamUid);
  Stream<Team> getTeamDetails({@required String teamUid});
  Stream<BuiltList<Season>> getSeasonsForTeam(String teamUid);
  Stream<Iterable<Team>> getTeams();
  Stream<Iterable<Team>> getTeamAdmins();

  // Player stuff.
  Future<void> updateFirestorePlayer(Player player, bool includeUsers);
  Future<String> addFirestorePlayer(Player player);
  Future<Uri> updatePlayerImage(String playerUid, File imgFile);
  // Send an invite to a user for this season and team.
  Future<String> inviteUserToPlayer(
      {@required String playerUid,
      @required String playerName,
      @required String email,
      @required myUid});
  Stream<Iterable<InviteToPlayer>> getInviteForPlayerStream({String playerUid});
  Future<void> removeUserFromPlayer(Player player, String userId);
  Future<bool> playerExists(String uid);
  Future<Player> getPlayerDetails(String uid);
  Future<bool> addUserToPlayer(String playerUid, PlayerUser player);
  Future<String> createPlayer(Player player);
  Future<void> deletePlayer(String playerUid);

  // Season updates
  Stream<Iterable<Season>> getPlayerSeasons(String playerUid);
  Future<void> updateFirestoreSeason(Season season, bool includePlayers);
  Future<Season> addFirestoreSeason(
      Season season, DocumentReferenceWrapper pregen);
  Future<void> removePlayerFromSeason(String seasonUid, String playerUid);
  Future<void> updateRoleInTeamForSeason(
      Season season, SeasonPlayer player, RoleInTeam role);
  Stream<Iterable<InviteToTeam>> getInviteForSeasonStream(
      {@required String seasonUid, @required String teamUid});
  Stream<GameSnapshotEvent> getSeasonGames(Season season);
  // Send an invite to a user for this season and team.
  Future<String> inviteUserToSeason(
      {@required String seasonUid,
      @required String seasonName,
      @required String teamUid,
      @required String teamName,
      @required String playername,
      @required String email,
      @required RoleInTeam role});
  Stream<Season> getSingleSeason(String seasonUid);
  Stream<BuiltList<Season>> getSeasons();
  Future<void> addPlayerToSeason(String seasonUid, SeasonPlayer player);
  DocumentReferenceWrapper precreateUidSeason();

  // Games!

  //GameSubscription getGames(Iterable<Game> cachedGames, Set<String> teams,
  //    DateTime start, DateTime end, FilterDetails filterDetails);
  Stream<GameSnapshotEvent> getBasicGames(
      {DateTime start, DateTime end, String teamUid, String seasonUid});

  // Clubs and stuff.
  Stream<BuiltList<Team>> getClubTeams(Club club);
  Future<String> updateClub(Club club, {bool includeMembers});
  Future<String> addClub(DocumentReferenceWrapper ref, Club club);
  Future<Uri> updateClubImage(Club club, File imageFile);
  Future<void> addUserToClub(String clubUid, String newUserUid, bool admin);
  Future<String> inviteUserToClub(
      {String clubName, String clubUid, bool admin, String email});
  Future<void> deleteClubMember(Club club, String memberUid);
  DocumentReferenceWrapper precreateTeamUid();
  Stream<BuiltList<InviteToClub>> getInviteToClubStream(String clubUid);
  Stream<Club> getClubData({@required String clubUid});

  // League and stuff.
  Stream<BuiltList<GameSharedData>> getLeagueGamesForDivison(
      String leagueDivisonUid);
  Stream<BuiltList<GameSharedData>> getLeagueGamesForTeam(String leagueTeamUid);
  Stream<BuiltList<LeagueOrTournamentSeason>> getLeagueSeasons(
      {String leagueUid});
  Stream<BuiltList<LeagueOrTournamentDivison>> getLeagueDivisonsForSeason(
      {String leagueSeasonUid, String memberUid});
  Stream<BuiltList<LeagueOrTournamentTeam>> getLeagueTeamsForTeamSeason(
      String teamSeasonUid);
  Future<String> updateLeague(LeagueOrTournament league, {bool includeMembers});
  Future<Uri> updateLeagueImage(LeagueOrTournament league, File imageFile);
  Future<void> addUserToLeague(String leagueUid, bool admin);
  Future<void> addUserToLeagueSeason(String leagueUid, bool admin);
  Future<void> addUserToLeagueDivison(String leagueUid, bool admin);
  Future<String> inviteUserToLeague(InviteToLeagueAsAdmin invite);
  Future<void> deleteLeagueMember(LeagueOrTournament league, String memberUid);
  Stream<LeagueOrTournament> getLeagueData({String leagueUid});
  Stream<LeagueOrTournamentTeam> getLeagueTeamData(String teamUid);
  Future<void> updateLeagueTeam(LeagueOrTournamentTeam team);
  Future<void> updateLeagueTeamRecord(
      LeagueOrTournamentTeam team, String season, WinRecord record);
  Future<String> inviteUserToLeagueTeam(
      {String leagueSeasonUid,
      LeagueOrTournamentTeam leagueTeam,
      String email});
  Stream<BuiltList<InviteToLeagueTeam>> getLeagueOrTournmentTeamInvitesStream(
      String leagueTeamUid);

  // League Season/Division.
  Stream<LeagueOrTournamentDivison> getLeagueDivisionData(
      {String leagueDivisionUid, String memberUid});
  Stream<LeagueOrTournamentSeason> getLeagueSeasonData(String leagueSeasonUid);
  Future<void> updateLeagueSeason(LeagueOrTournamentSeason season);
  Future<void> updateLeagueDivison(LeagueOrTournamentDivison division);
  Stream<BuiltList<LeagueOrTournamentTeam>> getLeagueDivisionTeams(
      String leagueDivisionUid);

  /// Returns true if this connected correctly, false if there was an error.
  Future<bool> connectLeagueTeamToSeason(String leagueTeamUid, Season season);

  // Initialized subscfriptions.
  Stream<BuiltList<LeagueOrTournament>> getMainLeagueOrTournaments();
  Stream<BuiltList<Club>> getMainClubs();
  Stream<BuiltList<Player>> getPlayers();
  Stream<BuiltList<Invite>> getInvites();
  Stream<BuiltList<MessageRecipient>> getMessages(bool unread);
}
