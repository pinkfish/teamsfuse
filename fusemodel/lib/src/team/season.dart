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
        newPlayers.add(SeasonPlayer.fromJSON(val as Map<dynamic, dynamic>));
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

  /*
  Future<void> updateFirestore({bool includePlayers = false}) async {
    return UserDatabaseData.instance.updateModel
        .updateFirestoreSeason(this, includePlayers, _pregen);
  }

  Future<void> removePlayer(SeasonPlayer player) async {
    return UserDatabaseData.instance.updateModel
        .removePlayerFromSeason(this, player);
  }

  Future<void> updateRoleInTeam(SeasonPlayer player, RoleInTeam role) async {
    return UserDatabaseData.instance.updateModel
        .updateRoleInTeamForSeason(this, player, role);
  }

  // Send an invite to a user for this season and team.
  Future<void> inviteUser(
      {String userId, String playername, String email, RoleInTeam role}) async {
    return UserDatabaseData.instance.updateModel.inviteUserToSeason(this,
        userId: userId,
        playername: playername,
        email: normalizeEmail(email),
        role: role);
  }




  /// This will make the uid for this without doing a query to the backend.
  String precreateUid() {
    if (_pregen == null) {
      _pregen = UserDatabaseData.instance.updateModel.precreateUidSeason(this);
    }
    return _pregen.uid;
  }


  */

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
