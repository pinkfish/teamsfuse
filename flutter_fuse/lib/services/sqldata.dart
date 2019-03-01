import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fusemodel/fusemodel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SqlData implements PersistenData {
  SqlData() {
    _initialized = _completer.future;
  }

  Database _database;
  static SqlData _instance;
  String _path;
  Completer<bool> _completer = new Completer<bool>();
  Future<bool> _initialized;
  bool _recreating = false;

  static const String _dbName = "teamfuse.db";

  static const String indexColumn = "fluff";
  static const String dataColumn = "data";
  static const String teamUidColumn = "teamuid";

  static const List<String> _tables = const <String>[
    PersistenData.teamsTable,
    PersistenData.seasonTable,
    PersistenData.playersTable,
    PersistenData.invitesTable,
    PersistenData.profileTable,
    PersistenData.messagesTable,
    PersistenData.clubsTable,
    PersistenData.leagueOrTournamentTable,
  ];
  static const List<String> _teamSpecificTables = const <String>[
    PersistenData.opponentsTable,
    PersistenData.gameTable
  ];

  static SqlData get instance {
    if (_instance == null) {
      _instance = new SqlData();
    }
    return _instance;
  }

  Future<void> initDatabase() async {
    print('_initDatabase()');
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    _path = join(documentsDirectory.path, _dbName);
    _database = await openDatabase(_path, version: 6,
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
      print('Upgrading db $oldVersion $newVersion');
      if (newVersion == 5) {
        await db.execute("DROP TABLE " + PersistenData.gameTable);
        return db.execute("CREATE TABLE IF NOT EXISTS " +
            PersistenData.gameTable +
            "(" +
            indexColumn +
            " text PRIMARY KEY, " +
            teamUidColumn +
            " text NOT NULL, " +
            dataColumn +
            " text NOT NULL);");
      } else if (newVersion == 6) {
        print('Making league table');
        return db.execute("CREATE TABLE IF NOT EXISTS " +
            PersistenData.leagueOrTournamentTable +
            "(" +
            indexColumn +
            " text PRIMARY KEY, " +
            teamUidColumn +
            " text NOT NULL, " +
            dataColumn +
            " text NOT NULL);");
      }
      print('Finish upgrade');
    }, onCreate: (Database db, int version) async {
      await Future.forEach(_tables, (String table) async {
        print('Made db $table');
        return await db.execute("CREATE TABLE IF NOT EXISTS " +
            table +
            " (" +
            indexColumn +
            " text PRIMARY KEY, " +
            dataColumn +
            " text NOT NULL);");
      });
      await Future.forEach(_teamSpecificTables, (String table) async {
        return db.execute("CREATE TABLE IF NOT EXISTS " +
            table +
            "(" +
            indexColumn +
            " text PRIMARY KEY, " +
            teamUidColumn +
            " text NOT NULL, " +
            dataColumn +
            " text NOT NULL);");
      });
    });
    _completer.complete(true);
    print('out of here');
  }

  // Close the database, delete everything and then reopen it.
  @override
  Future<void> recreateDatabase() async {
    if (_recreating) {
      return;
    }
    _recreating = true;
    try {
      _completer = new Completer<bool>();
      _initialized = _completer.future;
      await _database.close();
      await deleteDatabase(_path);
      await initDatabase();
    } finally {
      _recreating = false;
    }
  }

  // Gets all the data out of the json table.
  @override
  Future<Map<String, Map<String, dynamic>>> getAllElements(String table) async {
    Map<String, Map<String, dynamic>> ret = <String, Map<String, dynamic>>{};
    await _initialized;

    List<Map<String, dynamic>> data = await _database.query(table);

    for (Map<String, dynamic> innerData in data) {
      ret[innerData[indexColumn].toString()] =
          json.decode(innerData[dataColumn].toString()) as Map<String, dynamic>;
    }

    return ret;
  }

  @override
  Future<Map<String, dynamic>> getElement(String tableId, String key) async {
    await _initialized;
    Map<String, String> updateData = <String, String>{};
    updateData[indexColumn] = key;

    List<Map<String, dynamic>> data = await _database
        .query(tableId, where: indexColumn + " = ?", whereArgs: <String>[key]);
    if (data == null || data.length == 0) {
      return null;
    }

    return json.decode(data[0][dataColumn].toString()) as Map<String, dynamic>;
  }

  @override
  Future<void> updateElement(
      String tableId, String key, Map<String, dynamic> data) async {
    await _initialized;
    String myJson = json.encode(data);

    await _database.execute(
        "insert or replace into " +
            tableId +
            " (" +
            indexColumn +
            ", " +
            dataColumn +
            ") values (?, ?)",
        <String>[key, myJson]);
  }

  @override
  Future<int> deleteElement(String tableId, String key) async {
    await _initialized;
    return _database
        .delete(tableId, where: indexColumn + " = ?", whereArgs: <String>[key]);
  }

  // Gets all the data out of the json table.
  @override
  Future<Map<String, Map<String, dynamic>>> getAllTeamElements(
      String table, String teamUid) async {
    await _initialized;
    Map<String, Map<String, dynamic>> ret = <String, Map<String, dynamic>>{};

    List<Map<String, dynamic>> data = await _database.query(table,
        where: teamUidColumn + " = ?", whereArgs: <String>[teamUid]);

    for (Map<String, dynamic> innerData in data) {
      ret[innerData[indexColumn].toString()] =
          json.decode(innerData[dataColumn].toString()) as Map<String, dynamic>;
    }

    return ret;
  }

  @override
  Future<void> updateTeamElement(String tableId, String key, String teamUid,
      Map<String, dynamic> data) async {
    await _initialized;
    String myJson = json.encode(data);

    await _database.execute(
        "insert or replace into " +
            tableId +
            " (" +
            indexColumn +
            ", " +
            teamUidColumn +
            ", " +
            dataColumn +
            ") values (?, ?, ?)",
        <String>[key, teamUid, myJson]);
  }

  @override
  Future<void> clearTable(String tableId) {
    return _database.delete(tableId);
  }
}
