import 'dart:async';
import 'dart:convert';
import 'package:fusemodel/fusemodel.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
    print('Calling data  ${res.statusCode}');
    if (res.statusCode == 200) {
      final myData = jsonDecode(res.body);
      try {
        print(myData['games'].map((d) {
          d['sharedData']['uid'] = '1234';
          d['sharedData']['type'] = 'Game';

          d['sharedData']['endTime'] = d['sharedData']['time'];
          d['sharedDataUid'] = '12345';
          d['notes'] = '';
          d['teamUid'] = '23333';
          d['uniform'] = '';
          print(Game.fromMap(d));

          return Game.fromMap(d);
        }));
        if (myData['playerUid'] == playerUid &&
            myData['seasonUid'] == seasonUid) {
          // Decode the games.
          return myData['games'].map((d) {
            d['sharedData']['uid'] = '1234';
            d['sharedData']['type'] = 'Game';

            d['sharedData']['endTime'] = d['sharedData']['time'];
            d['sharedDataUid'] = '12345';
            d['notes'] = '';
            d['teamUid'] = '23333';
            d['uniform'] = '';

            return Game.fromMap(d);
          });
        }
      } catch (e) {
        print('Exception: ' + e);
      }
    }
    return BuiltList.of([]);
  }
}
