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

  static SqlData get instance {
    if (_instance == null) {
      _instance = new SqlData();
    }
    return _instance;
  }

  SqlData();

  Future<void> initDatabase() async {}

  @override
  Future<void> dropDatabase() async {}

  // Gets all the data out of the json table.
  @override
  Future<Map<String, Map<String, dynamic>>> getAllElements(String table) async {
    Map<String, Map<String, dynamic>> ret =
        <String, Map<String, dynamic>>{};

    return ret;
  }

  @override
  Future<Map<String, dynamic>> getElement(String tableId, String key) async {
    Map<String, Map<String, dynamic>> ret =
        <String, Map<String, dynamic>>{};

    return ret;
  }

  @override
  Future<void> updateElement(
      String tableId, String key, Map<String, dynamic> data) async {
  }

  @override
  Future<int> deleteElement(String tableId, String key) async {
    return 0;
  }

  // Gets all the data out of the json table.
  @override
  Future<Map<String, Map<String, dynamic>>> getAllTeamElements(
      String table, String teamUid) async {

    return {};
  }

  @override
  Future<void> updateTeamElement(String tableId, String key, String teamUid,
      Map<String, dynamic> data) async {
  }

  @override
  Future<void> clearTable(String tableId) {
    return null;
  }
}
