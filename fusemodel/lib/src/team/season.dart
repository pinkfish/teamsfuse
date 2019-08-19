import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:fusemodel/src/team/team.dart';

import '../club.dart';
import '../common.dart';
import '../winrecord.dart';
import 'seasonplayer.dart';

part 'season.g.dart';

abstract class Season implements Built<Season, SeasonBuilder> {
  String get name;
  String get uid;
  String get teamUid;
  WinRecord get record;
  BuiltList<SeasonPlayer> get players;

  Season._();
  factory Season([updates(SeasonBuilder b)]) = _$Season;

  static const String RECORD = 'record';
  static const String PLAYERS = 'players';
  static const String TEAMUID = 'teamUid';

  static SeasonBuilder fromJSON(String uid, Map<String, dynamic> data) {
    SeasonBuilder builder = SeasonBuilder();
    builder.uid = uid;
    builder.name = getString(data[NAME]);
    builder.record = WinRecord.fromJSON(data[RECORD] as Map<dynamic, dynamic>);
    builder.teamUid = data[TEAMUID];
    Map<dynamic, dynamic> playersData = data[PLAYERS];
    List<SeasonPlayer> newPlayers = new List<SeasonPlayer>();
    if (playersData == null) {
      playersData = {};
    }
    playersData.forEach((dynamic key, dynamic val) {
      String playerUid = key;
      SeasonPlayerBuilder player = new SeasonPlayerBuilder();
      player.playerUid = playerUid;
      if (val != null) {
        newPlayers.add(
            SeasonPlayer.fromJSON(val as Map<dynamic, dynamic>, playerUid));
      }
    });
    builder.players.addAll(newPlayers);
    print('Update Season ' + uid);
    return builder;
  }

  Map<String, dynamic> toJSON({bool includePlayers: false}) {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = name;
    ret[RECORD] = record.toJSON();
    ret[TEAMUID] = teamUid;
    if (includePlayers) {
      Map<String, dynamic> output = new Map<String, dynamic>();
      players.forEach((value) {
        output[value.playerUid] = value.toJSON();
      });
      ret[PLAYERS] = output;
    }
    return ret;
  }

  ///
  /// Is the current user an admin for this season
  ///
  bool isAdmin(Map<String, Team> teams, Club club) {
    //Find the team and check there.
    if (teams.containsKey(teamUid)) {
      return teams[teamUid].isAdmin(club);
    }
    return false;
  }
}
