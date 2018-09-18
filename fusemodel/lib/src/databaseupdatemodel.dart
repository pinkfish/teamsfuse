import 'dart:io';
import 'dart:async';
import 'model.dart';

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
/// The initial data that comes back from all the initial subscriptions to
/// things in the startup for the system.
///
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

///
/// Subscription to a list of iterable items that contains a startup set and
/// a stream.  Handles management of the stream and the controller associated
/// with the data.
///
class IterableSubscription<T> {
  Stream<Iterable<T>> _stream;
  final Iterable<T> initialData;
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

///
/// Details the games can be filtered on.
///
class FilterDetails {
  Set<String> teamUids = new Set<String>();
  Set<String> playerUids = new Set<String>();
  GameResult result;
  EventType eventType;
  bool allGames = false;
}

///
/// abstract interface to handle talking to firestore, handling the
/// differences between the web and mobile.
///
abstract class DatabaseUpdateModel {
  // Stuff for game updates.
  Future<void> updateFirestoreGame(Game game, bool allTeams);
  Future<void> deleteFirestoreGame(Game game);
  Future<void> updateFirestoreGameAttendence(
      Game game, String playerUid, Attendance attend);
  Future<void> updateFirestoreGameResult(Game game, GameResultDetails result);
  GameLogReturnData readGameLogs(Game game);
  Future<String> addFirestoreGameLog(Game game, GameLog log);

  // Invite firestore updates
  Future<void> firestoreInviteDelete(Invite invite);

  // Message Recipients
  Future<void> updateMessageRecipientState(
      MessageRecipient rec, MessageState state);
  Future<void> deleteRecipient(MessageRecipient rec);

  // Message for firestore.
  Future<void> updateFirestoreMessage(Message mess);
  Future<String> loadMessage(Message mess);
  Future<Message> getMessage(String messageId);

  // Opponent update
  Future<void> updateFirestoreOpponent(Opponent opponent);
  Future<void> deleteFirestoreOpponent(Opponent opponent);
  Future<Iterable<Game>> getOpponentGames(Opponent season);

  // Team stuff
  Future<List<StreamSubscription<dynamic>>> setupSnapForTeam(Team team);
  Future<void> loadOpponents(Team team);
  Future<void> updateFirestoreTeam(Team team, PregenUidRet optionalPreGen);
  Future<Uri> updateTeamImage(Team team, File imgFile);
  PregenUidRet precreateUid(Team team);
  Future<String> inviteAdminToTeam(Team team, String email);
  Future<void> deleteAdmin(Team team, String uid);
  Future<String> addAdmin(String teamUid, String uid);
  StreamSubscription<dynamic> getInviteForTeamStream(Team team);
  SeasonSubscription getAllSeasons(String teamUid);
  Future<Team> getPublicTeamDetails(String teamUid);

  // Player stuff.
  Future<void> updateFirestorePlayer(Player player, bool includeUsers);
  Future<Uri> updatePlayerImage(Player player, File imgFile);
  List<StreamSubscription<dynamic>> setupPlayerSnap(Player player);
  // Send an invite to a user for this season and team.
  Future<void> inviteUserToPlayer(Player season, {String email});
  Future<StreamSubscription<dynamic>> getInviteForPlayerStream(Player season);
  Future<void> removeUserFromPlayer(Player player, String userId);
  Future<bool> playerExists(String uid);
  Future<Player> getPlayerDetails(String uid);
  Future<bool> addUserToPlayer(String playerUid, PlayerUser player);
  Future<String> createPlayer(Player player);
  Future<void> deletePlayer(String playerUid);

  // Season updates
  Future<void> updateFirestoreSeason(
      Season season, bool includePlayers, PregenUidRet pregen);
  Future<void> removePlayerFromSeason(Season season, SeasonPlayer player);
  Future<void> updateRoleInTeamForSeason(
      Season season, SeasonPlayer player, RoleInTeam role);
  Future<StreamSubscription<dynamic>> getInviteForSeasonStream(Season season);
  GameSubscription getSeasonGames(Iterable<Game> games, Season season);
  // Send an invite to a user for this season and team.
  Future<void> inviteUserToSeason(Season season,
      {String userId, String playername, String email, RoleInTeam role});
  Future<Season> getSeason(String seasonUid);
  Future<void> addPlayerToSeason(String seasonUid, SeasonPlayer player);
  PregenUidRet precreateUidSeason(Season team);

  // Games!
  GameSubscription getGames(Iterable<Game> cachedGames, Set<String> teams,
      DateTime start, DateTime end);

  // Clubs and stuff.
  TeamSubscription getClubTeams(String clubUid);
  Future<String> updateClub(Club club, {bool includeMembers});
  Future<Uri> updateClubImage(Club club, File imageFile);
  Future<void> addUserToClub(String clubUid, String userId, bool admin);
  Future<String> inviteUserToClub(InviteToClub invite);
  Future<void> deleteClubMember(Club club, String memberUid);
  Future<Club> getClubData(String clubUid);

  // League and stuff.
  SharedGameSubscription getLeagueGamesForDivison(String leagueDivisonUid);
  LeagueOrTournamentSeasonSubscription getLeagueSeasons(String leagueUid);
  LeagueOrTournamentDivisonSubscription getLeagueDivisonsForSeason(
      String leagueSeasonUid);
  LeagueOrTournmentTeamSubscription getLeagueTeamsForTeamSeason(
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
  Future<LeagueOrTournament> getLeagueData(String leagueUid);
  Future<LeagueOrTournamentTeam> getLeagueTeamData(String teamUid);
  Future<void> updateLeagueTeam(LeagueOrTournamentTeam team);
  Future<void> updateLeagueTeamRecord(
      LeagueOrTournamentTeam team, String season);

  // League Season/Division.
  Future<LeagueOrTournamentDivison> getLeagueDivisionData(
      String leagueDivisionUid);
  Future<LeagueOrTournamentSeason> getLeagueSeasonData(String leagueSeasonUid);
  Future<void> updateLeagueSeason(LeagueOrTournamentSeason season);
  Future<void> updateLeagueDivison(LeagueOrTournamentDivison division);
  LeagueOrTournmentTeamSubscription getLeagueDivisionTeams(
      String leagueDivisionUid);

  /// Returns true if this connected correctly, false if there was an error.
  Future<bool> connectLeagueTeamToSeason(
      String leagueTeamUid, String userUid, Season season);

  // Initialized subscfriptions.
  InitialSubscription getMainLeagueOrTournaments(String userUid);
  InitialSubscription getMainClubs(String userUid);
  InitialSubscription getPlayers(String userUid);
  InitialSubscription getInvites(String userUid);
  InitialSubscription getMessages(String userUid, bool unread);
}
