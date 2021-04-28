import 'dart:async';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:meta/meta.dart';

import 'club.dart';
import 'firestore/firestore.dart';
import 'game.dart';
import 'invite.dart';
import 'leagueortournament.dart';
import 'media.dart';
import 'message.dart';
import 'player/player.dart';
import 'team.dart';
import 'winrecord.dart';

///
/// Details the games can be filtered on.
///
class FilterDetails {
  Set<String> teamUids = <String>{};
  Set<String> playerUids = <String>{};
  GameResult result;
  EventType eventType;
  bool allGames = false;

  bool isIncluded(Game game, Season season) {
    if (teamUids.isNotEmpty) {
      if (!teamUids.contains(game.teamUid)) {
        return false;
      }
    }
    if (playerUids.isNotEmpty) {
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

  Future<void> updateFirestoreGameAttendance(
      Game game, String playerUid, Attendance attend);

  Future<void> updateFirestoreGameResult(
      String gameUid, GameResultDetails result);

  Future<void> updateFirestoreOfficialGameResult(
      String gameSharedUid, GameOfficialResults result);

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
  Future<void> deleteGameEvent(
      {@required String gameUid, @required String gameEventUid});

  // Media
  /// Loads all the media for this season.
  Stream<BuiltList<MediaInfo>> getMediaForGame({@required String gameUid});

  /// Loads all the media for this season.
  Stream<BuiltList<MediaInfo>> getMediaForSeason({@required String seasonUid});

  /// Loads all the media for this player.
  Stream<BuiltList<MediaInfo>> getMediaForPlayer({@required String playerUid});

  /// Gets all the updates for this specific media info blob.
  Stream<MediaInfo> getMediaInfo({@required String mediaInfoUid});

  /// Adds the game event into the database
  Future<String> addMedia(
      {@required MediaInfo media, @required Uint8List imageFile});

  /// Updates the game player in the database.
  Future<void> updateGamePlayerData(
      {@required String gameUid,
      @required String playerUid,
      @required GamePlayerSummary summary});

  /// Updates the game player in the database.
  Future<void> updateGameOpponentData({
    @required String gameUid,
    @required String opponentUid,
    @required GamePlayerSummary summary,
  });

  ///
  /// Add a player for opponent for a specific opponent.
  ///
  Future<void> addGameOpponentPlayer({
    @required String teamUid,
    @required String gameUid,
    @required String opponentUid,
    @required String opponentName,
    @required String jerseyNumber,
  });

  ///
  /// Add a guest player just for one game.
  ///
  Future<void> addGameGuestPlayer({
    @required String gameUid,
    @required String guestName,
    @required String jerseyNumber,
  });

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

  //Future<void> updateFirestoreMessageBody({String messageUid, String body});
  Stream<String> loadMessageBody(String messageUid);

  Stream<Message> getMessage(String messageId);

  /// Add the message into firestore and do wild things with it.
  Future<Message> addMessage(Message mess, String body);

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
      Season season, Uint8List imageFile);

  Future<Uri> updateTeamImage(String teamUid, Uint8List imgFile);

  DocumentReferenceWrapper preCreateClubUid();

  Future<String> inviteAdminToTeam(
      {@required String myUid,
      @required String teamUid,
      @required String teamName,
      @required String email});

  Future<void> deleteAdmin(Team team, String uid);

  Future<String> addAdmin(String teamUid, String uid);

  Stream<Iterable<InviteAsAdmin>> getInviteForTeamStream(Team team);

  Stream<Team> getPublicTeamDetails({@required String teamUid});

  Stream<Iterable<InviteAsAdmin>> getInvitesForTeam(String teamUid);

  Stream<Iterable<Opponent>> getTeamOpponents(String teamUid);

  Stream<Team> getTeamDetails({@required String teamUid});

  Stream<BuiltList<Season>> getSeasonsForTeam(String teamUid);

  Stream<Iterable<Team>> getTeams();

  Stream<Iterable<Team>> getTeamAdmins();

  // Player stuff.
  Future<void> updateFirestorePlayer(Player player, bool includeUsers);

  Future<String> addFirestorePlayer(Player player);

  Future<Uri> updatePlayerImage(String playerUid, Uint8List imgFile);

  Stream<Player> getMePlayer(String userUid);

  // Send an invite to a user for this season and team.
  Future<String> inviteUserToPlayer(
      {@required String playerUid,
      @required String playerName,
      @required String email,
      @required myUid});

  Stream<Iterable<InviteToPlayer>> getInviteForPlayerStream({String playerUid});

  Future<void> removeUserFromPlayer(Player player, String userId);

  Future<bool> playerExists(String uid);

  Stream<Player> getPlayerDetails(String uid);

  Future<bool> addUserToPlayer(String playerUid, PlayerUser player);

  Future<String> createPlayer(Player player);

  Future<void> deletePlayer(String playerUid);

  // Season updates
  Stream<Iterable<Season>> getPlayerSeasons(String playerUid);

  Future<void> updateFirestoreSeason(Season season, bool includePlayers);

  Future<Season> addFirestoreSeason(
      Season season, DocumentReferenceWrapper preGenerated);

  Future<void> removePlayerFromSeason(String seasonUid, String playerUid);

  /// Update the season player pieces for the season.
  Future<void> updateSeasonPlayerForSeason(
      String seasonUid, SeasonPlayer player);

  Stream<BuiltList<Game>> getSeasonGames(Season season);

  // Send an invite to a user for this season and team.
  Future<String> inviteUserToSeason({
    @required String email,
    @required String playerName,
    @required RoleInTeam role,
    @required String seasonUid,
    @required String seasonName,
    @required String teamUid,
    @required String teamName,
    String playerUid,
    String jerseyNumber,
  });

  Stream<Season> getSingleSeason(String seasonUid);

  Stream<BuiltList<Season>> getSeasons();

  Future<void> addPlayerToSeason(String seasonUid, SeasonPlayer player);

  DocumentReferenceWrapper preCreateUidSeason();

  // Games!
  Stream<BuiltList<Game>> getBasicGames(
      {DateTime start, DateTime end, String teamUid, String seasonUid});

  //
  // Clubs and stuff.
  //

  /// Get all the teams associated with the club.
  Stream<BuiltList<Team>> getClubTeams(Club club, bool isPublic);

  /// Update the club in the database.
  Future<String> updateClub(Club club, {bool includeMembers});

  /// Add a new club to the database
  Future<String> addClub(DocumentReferenceWrapper ref, Club club);

  /// Update the image with the club.
  Future<Uri> updateClubImage(Club club, Uint8List imageFile);

  /// add a user to the club.
  Future<void> addUserToClub(String clubUid, String newUserUid, bool admin);

  /// Invite a user to the club.
  Future<String> inviteUserToClub(
      {String clubName, String clubUid, bool admin, String email});

  /// Delete a member from the club
  Future<void> deleteClubMember(Club club, String memberUid);

  /// PreCreates a teamUid to use for places where the uis is needed ahead of time.
  DocumentReferenceWrapper preCreateTeamUid();

  /// Get all the invites to the club.
  Stream<BuiltList<InviteToClub>> getInviteToClubStream(String clubUid);

  /// Gets the data associated with the club.
  Stream<Club> getClubData({@required String clubUid});

  /// Get all the clubs associated with the club.
  Stream<BuiltList<Coach>> getClubCoaches(String clubUid);

  /// Add the coach to the club.
  Future<Coach> addClubCoach(Coach coach, Uint8List imageData);

  /// Update the coach club stuff.
  Future<Coach> updateClubCoach(Coach coach, Uint8List imageData);

  /// Delete the coach club stuff.
  Future<void> deleteClubCoach(Coach coach);

  Stream<Coach> getSingleClubCoach(String clubUid, String coachUid);

  /// Get all the single news item for the club.
  Stream<NewsItem> getSingleClubNews(String clubUid, String newsUid);

  /// Get all the news items associated with the club.
  Stream<BuiltList<NewsItem>> getClubNews(String clubUid,
      {DateTime start, int limit});

  /// Add the news to the club.
  Future<NewsItem> addClubNews(NewsItem news);

  /// Update the news club stuff.
  Future<NewsItem> updateClubNews(NewsItem news);

  /// Delete the news club stuff.
  Future<void> deleteClubNews(NewsItem news);

  // League and stuff.
  Stream<BuiltList<GameSharedData>> getLeagueGamesForDivision(
      String leagueDivisionUid);

  Stream<BuiltList<GameSharedData>> getLeagueGamesForTeam(String leagueTeamUid);

  Stream<BuiltList<LeagueOrTournamentSeason>> getLeagueSeasons(
      {String leagueUid});

  Stream<BuiltList<LeagueOrTournamentDivison>> getLeagueDivisionsForSeason(
      {String leagueSeasonUid, String memberUid});

  Stream<BuiltList<LeagueOrTournamentTeam>> getLeagueTeamsForTeamSeason(
      String teamSeasonUid);

  Future<String> updateLeague(LeagueOrTournament league, {bool includeMembers});

  Future<Uri> updateLeagueImage(LeagueOrTournament league, Uint8List imageFile);

  Future<void> addUserToLeague(String leagueUid, bool admin);

  Future<void> addUserToLeagueSeason(String leagueUid, bool admin);

  Future<void> addUserToLeagueDivision(String leagueUid, bool admin);

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

  Stream<BuiltList<InviteToLeagueTeam>> getLeagueOrTournamentTeamInvitesStream(
      String leagueTeamUid);

  // League Season/Division.
  Stream<LeagueOrTournamentDivison> getLeagueDivisionData(
      {String leagueDivisionUid});

  Stream<LeagueOrTournamentSeason> getLeagueSeasonData(String leagueSeasonUid);

  Future<void> updateLeagueSeason(LeagueOrTournamentSeason season);

  Future<void> updateLeagueDivision(LeagueOrTournamentDivison division);

  Stream<BuiltList<LeagueOrTournamentTeam>> getLeagueDivisionTeams(
      String leagueDivisionUid);

  /// Returns true if this connected correctly, false if there was an error.
  Future<bool> connectLeagueTeamToSeason(String leagueTeamUid, Season season);

  // Initialized subscriptions.
  Stream<BuiltList<LeagueOrTournament>> getMainLeagueOrTournaments();

  Stream<BuiltList<Club>> getMainClubs();

  Stream<BuiltList<Player>> getPlayers();

  Stream<BuiltList<Invite>> getInvites();

  /// Gets the opponent players for the team/opponent.
  Stream<BuiltList<Player>> getPlayersForOpponent(
      {@required String teamUid, @required opponentUid});

  ///
  /// Get the messages for the current user, with an optional start point
  /// for pagination.
  ///
  Stream<BuiltList<MessageRecipient>> getMessages(bool unread,
      {DateTime start});
}
