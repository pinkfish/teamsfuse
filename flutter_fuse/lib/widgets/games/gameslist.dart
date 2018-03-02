import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';

class GameList extends StatelessWidget {

  Widget _buildGameCard(Game game) {
    Team team = UserDatabaseData.instance.teams[game.teamUid];
    Opponent op = team.opponents[game.opponentUid];

    return new Card(
      child: new ListTile(
        leading: const Icon(Icons.games),
        title:
      )
    );
  }

  Widget _buildGames(BuildContext context, AsyncSnapshot<UpdateReason> reason) {
    List<Game> games = UserDatabaseData.instance.games.values.toList().sort(
        (a, b) => a.time.compareTo(b.time)
    );
    return new Column();
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: UserDatabaseData.instance.gameStream,
        builder: this._buildGames
    );
  }
}