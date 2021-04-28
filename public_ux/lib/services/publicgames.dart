import 'dart:async';
import 'dart:convert';
import 'package:fusemodel/fusemodel.dart';
import 'package:built_collection/built_collection.dart';
import 'package:http/http.dart' as http;

///
/// Get the public games for the specific player and season.
///
class PublicGames {
  /// The season uid to get the data for.
  final String seasonUid;

  /// The player uid to get the data for.
  final String playerUid;

  /// Create the class.
  PublicGames(this.seasonUid, this.playerUid);

  /// Get the games from the backend.
  Future<BuiltList<Game>> getGames() async {
    print('Calling data');
    final res = await http.post(
      Uri.https(
        'us-central1-teamsfuse.cloudfunctions.net',
        'functionsGamestats',
      ),
      headers: {
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'playerUid': playerUid,
        'seasonUid': seasonUid,
      }),
    );
    if (res.statusCode == 200) {
      final myData = jsonDecode(res.body);
      try {
        if (myData['playerUid'] == playerUid &&
            myData['seasonUid'] == seasonUid) {
          // Decode the games.
          final games = myData['games'].map<Game>((d) {
            return Game.fromMap(d);
          }).toList();
          games.sort((Game g1, Game g2) =>
              g1.sharedData.time.compareTo(g2.sharedData.time));
          return BuiltList.of(games);
        }
      } catch (e) {
        print(e);
      }
    }
    return BuiltList.of([]);
  }
}
