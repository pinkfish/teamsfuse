import 'dart:async';
import 'dart:convert';

import 'package:fusemodel/fusemodel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

///
/// Wrapper to handle all the sql data.
///
class SqlData {
  /// The SqlData constrcutor.
  SqlData() {
    _initialized = _completer.future;
  }

  Database _database;
  String _path;
  Completer<bool> _completer = Completer<bool>();
  Future<bool> _initialized;
  bool _recreating = false;

  static const String _dbName = 'teamfuse.db';

  static const String _indexColumn = 'fluff';
  static const String _dataColumn = 'data';
  static const String _teamUidColumn = 'teamuid';

  static const List<String> _tables = <String>[
    PersistenDataFrog.teamsTable,
    PersistenDataFrog.seasonTable,
    PersistenDataFrog.playersTable,
    PersistenDataFrog.invitesTable,
    PersistenDataFrog.profileTable,
    PersistenDataFrog.messagesTable,
    PersistenDataFrog.clubsTable,
    PersistenDataFrog.leagueOrTournamentTable,
  ];
  static const List<String> _teamSpecificTables = <String>[
    PersistenDataFrog.opponentsTable,
    PersistenDataFrog.gameTable
  ];

  /// Initialize the sql database.
  Future<void> initDatabase() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    _path = join(documentsDirectory.path, _dbName);
    _database = await openDatabase(_path, version: 6,
        onUpgrade: (db, oldVersion, newVersion) async {
      print('Upgrading db $oldVersion $newVersion');
      print('Finish upgrade');
    }, onCreate: (db, version) async {
      await Future.forEach(_tables, (table) async {
        print('Made db $table');
        return await db.execute('CREATE TABLE IF NOT EXISTS $table'
            ' ($_indexColumn)'
            ' text PRIMARY KEY, $_dataColumn '
            ' text NOT NULL);');
      });
      await Future.forEach(_teamSpecificTables, (table) async {
        return db.execute('CREATE TABLE IF NOT EXISTS $table'
            '($_indexColumn)'
            ' text PRIMARY KEY, $_teamUidColumn '
            ' text NOT NULL, $_dataColumn'
            ' text NOT NULL);');
      });
    });
    _completer.complete(true);
  }

  /// Close the database, delete everything and then reopen it.
  Future<void> recreateDatabase() async {
    if (_recreating) {
      return;
    }
    _recreating = true;
    try {
      _completer = Completer<bool>();
      _initialized = _completer.future;
      await _database.close();
      await deleteDatabase(_path);
      await initDatabase();
    } finally {
      _recreating = false;
    }
  }

  /// Gets all the data out of the json table.
  Future<Map<String, Map<String, dynamic>>> getAllElements(String table) async {
    var ret = <String, Map<String, dynamic>>{};
    await _initialized;

    var data = await _database.query(table);

    for (var innerData in data) {
      ret[innerData[_indexColumn].toString()] = json
          .decode(innerData[_dataColumn].toString()) as Map<String, dynamic>;
    }

    return ret;
  }

  /// Gets a specific element from the database.
  Future<Map<String, dynamic>> getElement(String tableId, String key) async {
    await _initialized;
    var updateData = <String, String>{};
    updateData[_indexColumn] = key;

    var data = await _database
        .query(tableId, where: '$_indexColumn = ?', whereArgs: <String>[key]);
    if (data == null || data.isEmpty) {
      return null;
    }

    return json.decode(data[0][_dataColumn].toString()) as Map<String, dynamic>;
  }

  /// Update a specific element in the database.
  Future<void> updateElement(
      String tableId, String key, Map<String, dynamic> data) async {
    await _initialized;
    var myJson = json.encode(data);

    await _database.execute(
        'insert or replace into $tableId '
        ' ($_indexColumn, $_dataColumn'
        ') values (?, ?)',
        <String>[key, myJson]);
  }

  /// Delete a specific method from the database.
  Future<int> deleteElement(String tableId, String key) async {
    await _initialized;
    return _database
        .delete(tableId, where: '$_indexColumn = ?', whereArgs: <String>[key]);
  }

  /// Gets all the data out of the json table.
  Future<Map<String, Map<String, dynamic>>> getAllTeamElements(
      String table, String teamUid) async {
    await _initialized;
    var ret = <String, Map<String, dynamic>>{};

    var data = await _database.query(table,
        where: '$_teamUidColumn = ?', whereArgs: <String>[teamUid]);

    for (var innerData in data) {
      ret[innerData[_indexColumn].toString()] = json
          .decode(innerData[_dataColumn].toString()) as Map<String, dynamic>;
    }

    return ret;
  }

  /// Update a team specific element.
  Future<void> updateTeamElement(String tableId, String key, String teamUid,
      Map<String, dynamic> data) async {
    await _initialized;
    var myJson = json.encode(data);

    await _database.execute(
        'insert or replace into $tableId '
        ' ($_indexColumn, $_teamUidColumn, $_dataColumn) '
        ') values (?, ?, ?)',
        <String>[key, teamUid, myJson]);
  }

  /// Clears the specific table.
  Future<void> clearTable(String tableId) {
    return _database.delete(tableId);
  }
}
