import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleseasonprovider.dart';
import '../blocs/singleteamprovider.dart';
import '../player/playerimage.dart';
import '../player/playername.dart';
import '../player/playertilebasketball.dart';

///
/// Show the players of the team and a specific season.
///
class TeamPlayersSeason extends StatelessWidget {
  /// Constructor taking the team to find the players of
  TeamPlayersSeason(this._teamUid, this._seasonUid);

  final String _teamUid;
  final String _seasonUid;

  List<Widget> _buildPlayers(BuildContext context, SingleSeasonState state,
      SingleTeamState teamState) {
    var ret = <Widget>[];

    for (var player in state.season.players) {
      ret.add(
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context,
                'PlayerDetails/$_teamUid/$_seasonUid/${player.playerUid}');
          },
          child: teamState.team.sport == Sport.Basketball
              ? PlayerTileBasketball(
                  playerUid: player.playerUid,
                  seasonUid: _seasonUid,
                  showChips: true,
                  // Edit for the season parts of the player.
                  onEdit: (playerUid) => Navigator.pushNamed(context,
                      '/Season/Player/$_seasonUid/${player.playerUid}'),
                )
              : ListTile(
                  leading: PlayerImage(playerUid: player.playerUid),
                  title: PlayerName(playerUid: player.playerUid),
                  subtitle: Text(
                    Messages.of(context).roleInGame(player.role),
                  ),
                ),
        ),
      );
    }
    // Only do this if we are an admin.
    if (teamState.isAdmin()) {
      ret.add(
        ButtonBar(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, 'AddPlayer/$_teamUid/$_seasonUid');
              },
              style:
                  TextButton.styleFrom(primary: Theme.of(context).accentColor),
              child: Text(Messages.of(context).addPlayerButton),
            ),
          ],
        ),
      );
    }

    return ret;
  }

  Widget _buildSeason(BuildContext context, SingleTeamState teamState) {
    return SingleSeasonProvider(
      seasonUid: _seasonUid,
      builder: (context, seasonBloc) => BlocBuilder(
        bloc: seasonBloc,
        builder: (context, seasonState) {
          if (seasonState is SingleSeasonUninitialized ||
              seasonState is SingleSeasonDeleted) {
            return Column(children: [
              Text(Messages.of(context).loading),
            ]);
          }
          return Column(
              children: _buildPlayers(context, seasonState, teamState));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return SingleTeamProvider(
      teamUid: _teamUid,
      builder: (context, bloc) => BlocBuilder(
        bloc: bloc,
        builder: (context, teamState) {
          if (teamState is SingleTeamUninitialized) {
            return CircularProgressIndicator();
          } else {
            return Container(
              constraints: BoxConstraints(),
              margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
              decoration: BoxDecoration(color: theme.cardColor),
              child: SingleChildScrollView(
                child: _buildSeason(context, teamState),
              ),
            );
          }
        },
      ),
    );
  }
}
