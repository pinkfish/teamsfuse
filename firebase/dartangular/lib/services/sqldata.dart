import 'dart:async';
import 'package:fusemodel/fusemodel.dart';

class SqlData implements PersistenData {
  static SqlData _instance;

  static const String GAME_TABLE = "Games";
  static const String TEAMS_TABLE = "Teams";
  static const String SEASON_TABLE = "Seasons";
  static const String PLAYERS_TABLE = "Players";
  static const String INVITES_TABLE = "Invites";
  static const String OPPONENTS_TABLE = "Opponents";
  static const String PROFILE_TABLE = "Profile";
  static const String MESSAGES_TABLE = "Messages";

  static const String INDEX = "fluff";
  static const String DATA = "data";
  static const String TEAMUID = "teamuid";

  static const List<String> _TABLES = const [
    GAME_TABLE,
    TEAMS_TABLE,
    SEASON_TABLE,
    PLAYERS_TABLE,
    INVITES_TABLE,
    PROFILE_TABLE,
    MESSAGES_TABLE
  ];

  static SqlData get instance {
    if (_instance == null) {
      _instance = new SqlData();
    }
    return _instance;
  }

  SqlData() {
  }

  Future<void> initDatabase() async {}

  Future<void> dropDatabase() async {}

  // Gets all the data out of the json table.
  Future<Map<String, Map<String, dynamic>>> getAllElements(String table) async {
    Map<String, Map<String, dynamic>> ret =
        new Map<String, Map<String, dynamic>>();

    return ret;
  }

  Future<Map<String, dynamic>> getElement(String tableId, String key) async {
    Map<String, Map<String, dynamic>> ret =
        new Map<String, Map<String, dynamic>>();

    return ret;
  }

  Future<void> updateElement(
      String tableId, String key, Map<String, dynamic> data) async {
  }

  Future<int> deleteElement(String tableId, String key) async {
    return 0;
  }

  // Gets all the data out of the json table.
  Future<Map<String, Map<String, dynamic>>> getAllTeamElements(
      String table, String teamUid) async {

    return {};
  }

  Future<void> updateTeamElement(String tableId, String key, String teamUid,
      Map<String, dynamic> data) async {
  }

  Future<void> clearTable(String tableId) {
    return null;
  }
}
