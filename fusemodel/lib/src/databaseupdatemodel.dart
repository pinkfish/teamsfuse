import 'dart:async';
import 'dart:io';

import 'package:fusemodel/firestore.dart';
import 'package:meta/meta.dart';

import 'club.dart';
import 'game.dart';
import 'invite.dart';
import 'leagueortournament.dart';
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

enum GameSnapshotEventType { GameList, SharedGameUpdate }

///
/// Updates the games when things change in the snapshot.
///
class GameSnapshotEvent {
  final GameSnapshotEventType type;
  final GameSharedData sharedGame;
  final Iterable<Game> newGames;
  final Iterable<String> deletedGames;
  final String gameUid;
  final String teamUid;

  GameSnapshotEvent(
      {this.type,
      this.gameUid,
      this.teamUid,
      this.sharedGame,
      this.newGames,
      this.deletedGames});
}

typedef void FirestoreDataCallback(
    String playerUid, List<FirestoreWrappedData> data);

///
/// The initial data that comes back from all the initial subscriptions to
/// things in the startup for the system.
///
/*
class InitialSubscription {
  InitialSubscription({this.startData})
      : _controller = new StreamController<FirestoreChangedData>() {
    _stream = _controller.stream;
  }

  final Future<List<FirestoreWrappedData>> startData;
  Stream<FirestoreChangedData> _stream;
  final StreamController<FirestoreChangedData> _controller;

  Stream<FirestoreChangedData> get stream => _stream;

  void dispose() {
    _controller.close();
  }

  void addData(FirestoreChangedData data) {
    if (!_controller.isClosed) {
      _controller.add(data);
    }
  }
}
*/

///
/// Subscription to a list of iterable items that contains a startup set and
/// a stream.  Handles management of the stream and the controller associated
/// with the data.
///
/*
class IterableSubscription<T> {
  Stream<Iterable<T>> _stream;
  Iterable<T> initialData;
  bool loaded = false;
  final StreamController<Iterable<T>> _controller =
      new StreamController<Iterable<T>>();

  final List<StreamSubscription<dynamic>> subscriptions = [];

  Stream<Iterable<T>> get stream => _stream;

  IterableSubscription({this.initialData = const []}) {
    _stream = _controller.stream.asBroadcastStream();
  }

  void dispose() {
    _controller?.close();
    for (StreamSubscription<dynamic> str in subscriptions) {
      str.cancel();
    }
    subscriptions.clear();
  }

  void addUpdate(Iterable<T> teams) {
    if (!_controller.isClosed) {
      _controller.add(teams);
    }
  }
}

///
/// Specialization of the iterable subscription that handles teams.
///
class TeamSubscription extends IterableSubscription<Team> {}

///
/// Specialization of the iterable subscription that handles a league or
/// tournament team.
///
class LeagueOrTournmentTeamSubscription
    extends IterableSubscription<LeagueOrTournamentTeam> {}

///
/// Specialization of the iterable subscription that handle a
/// league division.
///
class LeagueOrTournamentDivisonSubscription
    extends IterableSubscription<LeagueOrTournamentDivison> {}

///
/// Specialization of the iterable subscription that handles a
/// league season.
///
class LeagueOrTournamentSeasonSubscription
    extends IterableSubscription<LeagueOrTournamentSeason> {}

///
/// Specialization of the iterable subscription that handles games.
///
class GameSubscription extends IterableSubscription<Game> {
  GameSubscription(Iterable<Game> data) : super(initialData: data);
}

///
/// Specialization of the iterable subscription that handles shared
/// games.
///
class SharedGameSubscription extends IterableSubscription<GameSharedData> {}

///
/// Specialization of the iterable subscription that handles seasons.
///
class SeasonSubscription extends IterableSubscription<Season> {}
*/

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
  // Stuff for game updates.
  Future<Game> updateFirestoreGame(Game game, bool allTeams);
  Future<String> updateFirestoreSharedGame(GameSharedData game);
  Future<void> deleteFirestoreGame(Game game);
  Future<void> deleteFirestoreSharedGame(GameSharedData game);
  Future<void> updateFirestoreGameAttendence(
      Game game, String playerUid, Attendance attend);
  Future<void> updateFirestoreGameResult(Game game, GameResultDetails result);
  Future<void> updateFirestoreOfficalGameResult(
      GameSharedData game, GameOfficialResults result);
  Stream<Iterable<GameLog>> readGameLogs(Game game);
  Future<String> addFirestoreGameLog(Game game, GameLog log);
  Stream<GameSharedData> getSharedGame(String sharedGameUid);
  Future<Game> getGame(String gameUid);

  // Invite firestore updates
  Future<void> firestoreInviteDelete(Invite invite);

  // Message Recipients
  Future<void> updateMessageRecipientState(
      MessageRecipient rec, MessageState state);
  Future<void> deleteRecipient(MessageRecipient rec);

  // Message for firestore.
  Future<Message> updateFirestoreMessage(MessageBuilder mess);
  Future<void> updateFirestoreMessageBody({String messageUid, String body});
  Future<String> loadMessage(Message mess);
  Future<Message> getMessage(String messageId);

  // Opponent update
  Future<void> updateFirestoreOpponent(Opponent opponent);
  Future<Opponent> addFirestoreOpponent(Opponent opponent);
  Future<void> deleteFirestoreOpponent(Opponent opponent);
  Future<Iterable<Game>> getOpponentGames(Opponent season);

  // Team stuff
  Future<void> updateFirestoreTeam(Team team);
  Future<String> addFirestoreTeam(Team team, DocumentReferenceWrapper pregen);
  Future<Team> updateTeamImage(Team team, File imgFile);
  DocumentReferenceWrapper precreateClubUid();
  Future<String> inviteAdminToTeam(
      {@required String myUid,
      @required String teamUid,
      @required String teamName,
      @required String email});
  Future<void> deleteAdmin(Team team, String uid);
  Future<String> addAdmin(String teamUid, String uid);
  Stream<Iterable<InviteAsAdmin>> getInviteForTeamStream(Team team);
  Stream<Iterable<Season>> getAllSeasons(String teamUid);
  Future<Team> getPublicTeamDetails(
      {@required String userUid, @required String teamUid});
  Stream<Iterable<InviteAsAdmin>> getInvitesForTeam(String teamUid);
  Stream<Iterable<Opponent>> getTeamOpponents(String teamUid);
  Stream<TeamBuilder> getTeamDetails(
      {@required String userUid, @required String teamUid});

  // Player stuff.
  Future<void> updateFirestorePlayer(Player player, bool includeUsers);
  Future<String> addFirestorePlayer(Player player);
  Future<Uri> updatePlayerImage(Player player, File imgFile);
  Stream<Iterable<Season>> getPlayerSeasons(String playerUid);
  // Send an invite to a user for this season and team.
  Future<String> inviteUserToPlayer(
      {@required String playerUid,
      @required String playerName,
      @required String email,
      @required myUid});
  Stream<Iterable<InviteToPlayer>> getInviteForPlayerStream(
      {String userUid, Player player});
  Future<void> removeUserFromPlayer(Player player, String userId);
  Future<bool> playerExists(String uid);
  Future<Player> getPlayerDetails(String uid);
  Future<bool> addUserToPlayer(String playerUid, PlayerUser player);
  Future<String> createPlayer(Player player);
  Future<void> deletePlayer(String playerUid);

  // Season updates
  Future<void> updateFirestoreSeason(Season season, bool includePlayers);
  Future<Season> addFirestoreSeason(
      Season season, DocumentReferenceWrapper pregen);
  Future<void> removePlayerFromSeason(Season season, SeasonPlayer player);
  Future<void> updateRoleInTeamForSeason(
      Season season, SeasonPlayer player, RoleInTeam role);
  Stream<Iterable<InviteToTeam>> getInviteForSeasonStream(
      {@required String userUid,
      @required String seasonUid,
      @required String teamUid});
  Stream<GameSnapshotEvent> getSeasonGames(Season season);
  // Send an invite to a user for this season and team.
  Future<String> inviteUserToSeason(
      {@required String seasonUid,
      @required String userId,
      @required String playername,
      @required String email,
      @required RoleInTeam role});
  Future<Season> getSeason(String seasonUid);
  Future<void> addPlayerToSeason(String seasonUid, SeasonPlayer player);
  DocumentReferenceWrapper precreateUidSeason();

  // Games!

  //GameSubscription getGames(Iterable<Game> cachedGames, Set<String> teams,
  //    DateTime start, DateTime end, FilterDetails filterDetails);
  Stream<GameSnapshotEvent> getBasicGames(
      {DateTime start, DateTime end, String teamUid, String seasonUid});

  // Clubs and stuff.
  Stream<Iterable<Team>> getClubTeams(String userUid, Club club);
  Future<String> updateClub(Club club, {bool includeMembers});
  Future<String> addClub(DocumentReferenceWrapper ref, Club club);
  Future<Uri> updateClubImage(Club club, File imageFile);
  Future<void> addUserToClub(String clubUid, String userId, bool admin);
  Future<String> inviteUserToClub(
      {String clubName, String clubUid, bool admin, String email});
  Future<void> deleteClubMember(Club club, String memberUid);
  DocumentReferenceWrapper precreateTeamUid();
  Stream<Iterable<InviteToClub>> getInviteToClubStream(String clubUid);
  Future<Club> getClubData(
      {@required String userUid, @required String clubUid});

  // League and stuff.
  Stream<Iterable<GameSharedData>> getLeagueGamesForDivison(
      String leagueDivisonUid);
  Stream<Iterable<GameSharedData>> getLeagueGamesForTeam(String leagueTeamUid);
  Stream<Iterable<LeagueOrTournamentSeason>> getLeagueSeasons(
      {String userUid, String leagueUid});
  Stream<Iterable<LeagueOrTournamentDivison>> getLeagueDivisonsForSeason(
      String leagueSeasonUid);
  Stream<Iterable<LeagueOrTournamentTeam>> getLeagueTeamsForTeamSeason(
      String teamSeasonUid);
  Future<String> updateLeague(LeagueOrTournament league, {bool includeMembers});
  Future<Uri> updateLeagueImage(LeagueOrTournament league, File imageFile);
  Future<void> addUserToLeague(String leagueUid, String userId, bool admin);
  Future<void> addUserToLeagueSeason(
      String leagueUid, String userId, bool admin);
  Future<void> addUserToLeagueDivison(
      String leagueUid, String userId, bool admin);
  Future<String> inviteUserToLeague(InviteToLeagueAsAdmin invite);
  Future<void> deleteLeagueMember(LeagueOrTournament league, String memberUid);
  Future<LeagueOrTournament> getLeagueData({String userUid, String leagueUid});
  Future<LeagueOrTournamentTeam> getLeagueTeamData(String teamUid);
  Future<void> updateLeagueTeam(LeagueOrTournamentTeam team);
  Future<void> updateLeagueTeamRecord(
      LeagueOrTournamentTeam team, String season, WinRecord record);
  Future<String> inviteUserToLeagueTeam(
      {String userUid,
      LeagueOrTournament league,
      LeagueOrTournamentSeason season,
      LeagueOrTournamentTeam leagueTeam,
      String email});
  Stream<Iterable<InviteToLeagueTeam>> getLeagueOrTournmentTeamInvitesStream(
      String leagueTeamUid);

  // League Season/Division.
  Future<LeagueOrTournamentDivison> getLeagueDivisionData(
      String leagueDivisionUid);
  Future<LeagueOrTournamentSeason> getLeagueSeasonData(String leagueSeasonUid);
  Future<void> updateLeagueSeason(LeagueOrTournamentSeason season);
  Future<void> updateLeagueDivison(LeagueOrTournamentDivison division);
  Stream<Iterable<LeagueOrTournamentTeam>> getLeagueDivisionTeams(
      String leagueDivisionUid);

  /// Returns true if this connected correctly, false if there was an error.
  Future<bool> connectLeagueTeamToSeason(
      String leagueTeamUid, String userUid, Season season);

  // Initialized subscfriptions.
  Stream<Iterable<LeagueOrTournament>> getMainLeagueOrTournaments(
      String userUid);
  Stream<Iterable<Club>> getMainClubs(String userUid);
  Stream<Iterable<Player>> getPlayers(String userUid);
  Stream<Iterable<Invite>> getInvites(String userUid);
  Stream<Iterable<MessageRecipient>> getMessages(String userUid, bool unread);
  Stream<Iterable<Team>> getTeamAdmins(String userUid);
}
