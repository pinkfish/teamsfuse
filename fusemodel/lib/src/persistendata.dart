import 'dart:async';

abstract class PersistenDataFrog {
  static const String gameTable = "Games";
  static const String teamsTable = "Teams";
  static const String seasonTable = "Seasons";
  static const String playersTable = "Players";
  static const String invitesTable = "Invites";
  static const String opponentsTable = "Opponents";
  static const String profileTable = "Profile";
  static const String messagesTable = "Messages";
  static const String clubsTable = "Clubs";
  static const String sharedGameTable = "SharedGameTable";
  static const String leagueOrTournamentTable = "LeagueOrTournamentTable";

  static const String INDEX = "fluff";
  static const String DATA = "data";
  static const String TEAMUID = "teamuid";

  // Gets all the data out of the json table.
  Future<Map<String, Map<String, dynamic>>> getAllElements(String table);

  Future<Map<String, dynamic>> getElement(String tableId, String key);

  Future<void> updateElement(
      String tableId, String key, Map<String, dynamic> data);

  Future<void> deleteElement(String tableId, String key);

  // Gets all the data out of the json table.
  Future<Map<String, Map<String, dynamic>>> getAllTeamElements(
      String table, String teamUid);

  Future<void> updateTeamElement(
      String tableId, String key, String teamUid, Map<String, dynamic> data);

  Future<void> recreateDatabase();

  Future<void> clearTable(String name);
}
