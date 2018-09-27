import 'dart:async';

import '../common.dart';
import '../winrecord.dart';
import 'package:fusemodel/src/game/game.dart';
import '../userdatabasedata.dart';

///
/// An opponent for a team with all the opponent metadata associated with it.
///
class Opponent {
  String name;
  String teamUid;
  String contact;
  String uid;
  List<String> leagueTeamUid;
  Map<String, WinRecord> record;

  Opponent(
      {this.record,
        this.name,
        this.teamUid,
        this.contact,
        this.uid,
        this.leagueTeamUid}) {
    if (record == null) {
      record = new Map<String, WinRecord>();
    }
  }

  Opponent.copy(Opponent copy) {
    name = copy.name;
    teamUid = copy.teamUid;
    contact = copy.contact;
    uid = copy.uid;
    leagueTeamUid = copy.leagueTeamUid;
    record = new Map<String, WinRecord>.from(copy.record);
  }

  static const String _CONTACT = 'contact';
  static const String _SEASONS = 'seasons';
  static const String _LEAGUETEAMUID = 'leagueTeamUid';

  void fromJSON(String uid, String teamUid, Map<String, dynamic> data) {
    this.uid = uid;
    this.teamUid = teamUid;
    name = getString(data[NAME]);
    contact = getString(data[_CONTACT]);
    if (data[_LEAGUETEAMUID] != null) {
      List<String> newLeagues = new List<String>();
      data[_LEAGUETEAMUID].forEach((dynamic key, dynamic data) {
        if (data is Map<dynamic, dynamic>) {
          if (data[ADDED]) {
            newLeagues.add(key as String);
          }
        }
      });
      leagueTeamUid = newLeagues;
    }
    Map<String, WinRecord> newRecord = new Map<String, WinRecord>();
    if (data[_SEASONS] != null) {
      Map<dynamic, dynamic> innerSeason =
      data[_SEASONS] as Map<dynamic, dynamic>;
      // Load the seasons.
      innerSeason.forEach((dynamic seasonUid, dynamic value) {
        WinRecord newData =
        new WinRecord.fromJSON(value as Map<dynamic, dynamic>);
        newRecord[seasonUid.toString()] = newData;
      });
    }
    record = newRecord;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = name;
    ret[_CONTACT] = contact;
    Map<String, Map<String, dynamic>> fluff = <String, Map<String, dynamic>>{};
    for (String league in leagueTeamUid) {
      fluff[league] = <String, dynamic>{
        ADDED: true,
      };
    }
    ret[_LEAGUETEAMUID] = fluff;
    Map<String, dynamic> recordSection = new Map<String, dynamic>();
    record.forEach((String key, WinRecord record) {
      recordSection[key] = record.toJSON();
    });
    ret[_SEASONS] = recordSection;
    return ret;
  }

  Future<void> updateFirestore() {
    return UserDatabaseData.instance.updateModel.updateFirestoreOpponent(this);
  }

  Future<void> deleteFromFirestore() {
    return UserDatabaseData.instance.updateModel.deleteFirestoreOpponent(this);
  }

  String toString() {
    return "Opponent {$uid $name $contact team: $teamUid}";
  }

  Future<Iterable<Game>> getGames() {
    // Get all the games for this season.
    return UserDatabaseData.instance.updateModel.getOpponentGames(this);
  }
}
