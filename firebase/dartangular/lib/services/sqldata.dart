import 'dart:async';
import 'package:fusemodel/fusemodel.dart';
import 'dart:indexed_db';
import 'dart:html';

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

  static const List<String> kTables = [
    GAME_TABLE,
    TEAMS_TABLE,
    SEASON_TABLE,
    PLAYERS_TABLE,
    INVITES_TABLE,
    OPPONENTS_TABLE,
    PROFILE_TABLE,
    MESSAGES_TABLE
  ];

  static const String INDEX = "fluff";
  static const String DATA = "data";
  static const String TEAMUID = "teamuid";

  Database _database;
  Completer<bool> _loaded = Completer();
  Future<bool> _initialized;

  static SqlData get instance {
    if (_instance == null) {
      _instance = new SqlData();
    }
    return _instance;
  }

  SqlData() {
    if (IdbFactory.supported) {
      window.indexedDB
          .open('myIndexedDB', version: 1, onUpgradeNeeded: _initializeDatabase)
          .then(_loadFromDB);
    }
    _initialized = _loaded.future;
  }

  void _initializeDatabase(VersionChangeEvent e) {}

  void _loadFromDB(Database d) {
    _database = d;
    _loaded.complete(true);
  }

  Future<void> initDatabase() async {}

  @override
  Future<void> dropDatabase() async {
    await _initialized;

    for (String db in kTables) {
      _database.createObjectStore(db);
    }
  }

  // Gets all the data out of the json table.
  @override
  Future<Map<String, Map<String, dynamic>>> getAllElements(String table) async {
    Map<String, Map<String, dynamic>> ret = <String, Map<String, dynamic>>{};
    await _initialized;

    return ret;
  }

  @override
  Future<Map<String, dynamic>> getElement(String tableId, String key) async {
    Map<String, Map<String, dynamic>> ret = <String, Map<String, dynamic>>{};
    await _initialized;

    return ret;
  }

  @override
  Future<void> updateElement(
      String tableId, String key, Map<String, dynamic> data) async {
    await _initialized;
  }

  @override
  Future<int> deleteElement(String tableId, String key) async {
    await _initialized;
    return 0;
  }

  // Gets all the data out of the json table.
  @override
  Future<Map<String, Map<String, dynamic>>> getAllTeamElements(
      String table, String teamUid) async {
    await _initialized;
    return {};
  }

  @override
  Future<void> updateTeamElement(String tableId, String key, String teamUid,
      Map<String, dynamic> data) async {
    await _initialized;
  }

  @override
  Future<void> clearTable(String tableId) {
    return null;
  }

  @override
  Future<void> recreateDatabase() {
    return null;
  }
}
