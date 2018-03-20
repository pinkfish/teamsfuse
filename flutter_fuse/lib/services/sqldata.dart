import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class SqlData {
  Database _database;
  static SqlData _instance;
  String _path;
  Completer<bool> _completer = new Completer<bool>();
  Future<bool> _initialized;

  static const String _DBNAME = "teamfuse.db";

  static const String GAME_TABLE = "Games";
  static const String TEAMS_TABLE = "Teams";
  static const String SEASON_TABLE = "Seasons";
  static const String PLAYERS_TABLE = "Players";
  static const String INVITES_TABLE = "Invites";
  static const String OPPONENTS_TABLE = "Opponents";
  static const String PROFILE_TABLE = "Profile";

  static const String INDEX = "fluff";
  static const String DATA = "data";
  static const String TEAMUID = "teamuid";

  static const List<String> _TABLES = const [
    GAME_TABLE,
    TEAMS_TABLE,
    SEASON_TABLE,
    PLAYERS_TABLE,
    INVITES_TABLE,
    PROFILE_TABLE
  ];

  static SqlData get instance {
    if (_instance == null) {
      _instance = new SqlData();
    }
    return _instance;
  }

  SqlData() {
    _initialized = _completer.future;
  }

  Future<void> initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    _path = join(documentsDirectory.path, _DBNAME);
    _database = await openDatabase(_path, version: 1,
        onCreate: (Database db, int version) async {
      await Future.forEach(_TABLES, (String table) async {
        print('Made db $table');
        return await db.execute("CREATE TABLE IF NOT EXISTS " +
            table +
            " (" +
            INDEX +
            " text PRIMARY KEY, " +
            DATA +
            " text NOT NULL);");
      });
      await db.execute("CREATE TABLE IF NOT EXISTS " +
          OPPONENTS_TABLE +
          "(" +
          INDEX +
          " text PRIMARY KEY, " +
          TEAMUID +
          " text NOT NULL, " +
          DATA +
          " text NOT NULL);");
    });
    _completer.complete(true);
    print('out of here');
  }

  void dropDatabase() async {
    await deleteDatabase(_path);
  }

  // Gets all the data out of the json table.
  Future<Map<String, Map<String, dynamic>>> getAllElements(String table) async {
    Map<String, Map<String, dynamic>> ret =
        new Map<String, Map<String, dynamic>>();
    await _initialized;

    List<Map<String, String>> data = await _database.query(table);

    data.forEach((Map<String, dynamic> innerData) {
      ret[innerData[INDEX]] = JSON.decode(innerData[DATA]);
    });

    return ret;
  }

  Future<Map<String, dynamic>> getElement(String tableId, String key) async {
    await _initialized;
    Map<String, String> updateData = new Map<String, String>();
    updateData[INDEX] = key;

    List<Map<String, dynamic>> data =
        await _database.query(tableId, where: INDEX + " = ?", whereArgs: [key]);
    if (data == null || data.length == 0) {
      return null;
    }

    return JSON.decode(data[0][DATA]);
  }

  Future<void> updateElement(
      String tableId, String key, Map<String, dynamic> data) async {
    await _initialized;
    String json = JSON.encode(data);

    await _database.execute(
        "insert or replace into " +
            tableId +
            " (" +
            INDEX +
            ", " +
            DATA +
            ") values (?, ?)",
        [key, json]);
  }

  Future<int> deleteElement(String tableId, String key) async {
    await _initialized;
    return _database.delete(tableId, where: INDEX + " = ?", whereArgs: [key]);
  }

  // Gets all the data out of the json table.
  Future<Map<String, Map<String, dynamic>>> getAllTeamElements(
      String table, String teamUid) async {
    await _initialized;
    Map<String, Map<String, dynamic>> ret =
        new Map<String, Map<String, dynamic>>();

    List<Map<String, String>> data = await _database
        .query(table, where: TEAMUID + " = ?", whereArgs: [teamUid]);

    data.forEach((Map<String, dynamic> innerData) {
      ret[innerData[INDEX]] = JSON.decode(innerData[DATA]);
    });

    return ret;
  }

  Future<void> updateTeamElement(String tableId, String key, String teamUid,
      Map<String, dynamic> data) async {
    await _initialized;
    String json = JSON.encode(data);

    await _database.execute(
        "insert or replace into " +
            tableId +
            " (" +
            INDEX +
            ", " +
            TEAMUID +
            ", " +
            DATA +
            ") values (?, ?, ?)",
        [key, teamUid, json]);
  }

  void clearTable(String tableId) {
    _database.delete(tableId);
  }
}
