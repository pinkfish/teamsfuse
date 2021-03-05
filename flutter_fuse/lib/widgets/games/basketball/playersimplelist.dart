import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/messages.dart';

///
/// Shows the list of players in the team, sorts by the name.
///
class PlayerSimpleList extends StatelessWidget {
  final Season season;
  final Game game;
  final Map<String, Player> additonalPlayers;
  final TextStyle style;

  PlayerSimpleList(
      {@required this.game,
      @required this.season,
      this.additonalPlayers,
      this.style});

  @override
  Widget build(BuildContext context) {
    var fullList = game.players.keys.toList();
    if (season != null) {
      var seasonList = season.playersData.keys.toList();
      // Only track things not in the current list and not ignored.
      seasonList.removeWhere(
          (e) => game.ignoreFromSeason.contains(e) || fullList.contains(e));
      fullList.addAll(seasonList);
    }
    if (additonalPlayers != null) {
      fullList.addAll(additonalPlayers.keys);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: FutureBuilder(
          future: Future.wait(fullList.map((s) =>
              RepositoryProvider.of<DatabaseUpdateModel>(context)
                  .getPlayerDetails(s)
                  .first)),
          builder:
              (BuildContext context, AsyncSnapshot<List<Player>> snapshot) {
            if (!snapshot.hasData) {
              return Text(Messages.of(context).loading);
            }
            var names = snapshot.data;
            names.sort((a, b) => a.name.compareTo(b.name));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: names
                  .map((Player p) => Text(
                        p.name,
                        style: style ?? Theme.of(context).textTheme.headline6,
                        overflow: TextOverflow.ellipsis,
                      ))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
