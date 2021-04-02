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
      body: jsonEncode({
        'playerUid': playerUid,
        'seasonUid': seasonUid,
      }),
    );
    print('Calling data ${res.body} ${res.statusCode}');
    if (res.statusCode == 200) {
      final myData = jsonDecode(res.body);
      if (myData['playerUid'] == playerUid &&
          myData['seasonUid'] == seasonUid) {
        // Decode the games.
        return myData['games'].map((d) => Game(d));
      }
    }
    return BuiltList.of([]);
  }
}
