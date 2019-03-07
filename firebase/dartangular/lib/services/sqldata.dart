import 'dart:async';
import 'dart:html';
import 'dart:indexed_db';

import 'package:fusemodel/fusemodel.dart';

class SqlData implements PersistenData {
  static SqlData _instance;

  static const List<String> kTables = [
    PersistenData.gameTable,
    PersistenData.teamsTable,
    PersistenData.seasonTable,
    PersistenData.playersTable,
    PersistenData.invitesTable,
    PersistenData.opponentsTable,
    PersistenData.profileTable,
    PersistenData.messagesTable,
    PersistenData.clubsTable,
    PersistenData.leagueOrTournamentTable
  ];

  static const String kIndex = "fluff";
  static const String kData = "data";
  static const String kTeamUid = "teamuid";

  static Database _database;
  Completer<bool> _loaded = Completer();
  Future<bool> _initialized;

  static SqlData get instance {
    if (_instance == null) {
      _instance = new SqlData();
    }
    return _instance;
  }

  SqlData() {
    if (IdbFactory.supported && _database == null) {
      print('indexDBSupported');
      window.indexedDB
          .open('fluffyIndexDb',
              version: 1, onUpgradeNeeded: _initializeDatabase)
          .then(_loadFromDB);
    }
    _initialized = _loaded.future;
  }

  void _initializeDatabase(VersionChangeEvent e) {
    Database db = (e.target.result as Request).result as Database;

    for (String table in kTables) {
      print('Creating table $table');
      ObjectStore store = db.createObjectStore(table);
      // Create the index for both of them.
      store.createIndex(kTeamUid + '-index', kTeamUid, unique: false);
    }
  }

  void _loadFromDB(Database d) {
    print('Loaded from the db');
    _database = d;
    _loaded.complete(true);
  }

  // Gets all the data out of the json table.
  @override
  Future<Map<String, Map<String, dynamic>>> getAllElements(String table) async {
    if (!IdbFactory.supported) {
      return {};
    }
    Map<String, Map<String, dynamic>> ret = <String, Map<String, dynamic>>{};
    await _initialized;

    Transaction t = _database.transaction(table, 'readonly');
    ObjectStore store = t.objectStore(table);
    await for (CursorWithValue data
        in store.openCursor(autoAdvance: true).asBroadcastStream()) {
      ret[data.key as String] = _toMap(data.value);
    }
    await t.completed;
    return ret;
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data == null) {
      return null;
    }
    Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;
    return map.map(
        (dynamic k, dynamic v) => MapEntry<String, dynamic>(k as String, v));
  }

  @override
  Future<Map<String, dynamic>> getElement(String tableId, String key) async {
    if (!IdbFactory.supported) {
      return null;
    }
    await _initialized;

    Transaction t = _database.transaction(tableId, 'readonly');
    ObjectStore store = t.objectStore(tableId);
    Map<dynamic, dynamic> ret =
        await store.getObject(key) as Map<dynamic, dynamic>;
    await t.completed;
    return _toMap(ret);
  }

  @override
  Future<void> updateElement(
      String tableId, String key, Map<String, dynamic> data) async {
    if (!IdbFactory.supported) {
      return null;
    }
    await _initialized;

    Transaction t = _database.transaction(tableId, 'readwrite');
    ObjectStore store = t.objectStore(tableId);
    await store.put(data, key);
    return t.completed;
  }

  @override
  Future<void> deleteElement(String tableId, String key) async {
    if (!IdbFactory.supported) {
      return null;
    }
    await _initialized;
    Transaction t = _database.transaction(tableId, 'readwrite');
    ObjectStore store = t.objectStore(tableId);
    await store.delete(key);
    return t.completed;
  }

  // Gets all the data out of the json table.
  @override
  Future<Map<String, Map<String, dynamic>>> getAllTeamElements(
      String table, String teamUid) async {
    if (!IdbFactory.supported) {
      return {};
    }
    Map<String, Map<String, dynamic>> ret = <String, Map<String, dynamic>>{};

    await _initialized;
    Transaction t = _database.transaction(table, 'readonly');
    ObjectStore store = t.objectStore(table);
    Index index = store.index(kTeamUid + '-index');
    await for (CursorWithValue data in index
        .openCursor(key: teamUid, autoAdvance: true)
        .asBroadcastStream()) {
      ret[data.primaryKey as String] = _toMap(data.value);
    }
    await t.completed;
    return ret;
  }

  @override
  Future<void> updateTeamElement(String tableId, String key, String teamUid,
      Map<String, dynamic> data) async {
    if (!IdbFactory.supported) {
      return null;
    }
    await _initialized;

    Transaction t = _database.transaction(tableId, 'readwrite');
    ObjectStore store = t.objectStore(tableId);
    data[kTeamUid] = teamUid;
    await store.put(data, key);
    return t.completed;
  }

  @override
  Future<void> clearTable(String tableId) async {
    if (!IdbFactory.supported) {
      return null;
    }
    Transaction t = _database.transaction(tableId, 'readwrite');
    ObjectStore store = t.objectStore(tableId);
    await store.clear();
    return t.completed;
  }

  @override
  Future<void> recreateDatabase() {
    if (!IdbFactory.supported) {
      return null;
    }
    _loaded = new Completer<bool>();
    _initialized = _loaded.future;
    if (IdbFactory.supported) {
      return window.indexedDB
          .open('myIndexedDB', version: 1, onUpgradeNeeded: _initializeDatabase)
          .then(_loadFromDB);
    }
    return null;
  }
}
