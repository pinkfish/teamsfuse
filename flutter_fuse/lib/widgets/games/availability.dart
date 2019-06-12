import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/util/playername.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleteamprovider.dart';
import 'attendancedialog.dart';
import 'attendanceicon.dart';

class Availaility extends StatelessWidget {
  Availaility(this._game);

  final SingleGameBloc _game;

  void _updateAttendance(
      BuildContext context, SeasonPlayer player, Attendance current) async {
    Attendance attend = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AttendanceDialog(current: current);
        });
    if (attend != null) {
      _game.dispatch(SingleGameUpdateAttendance(
          playerUid: player.playerUid, attendance: attend));
    }
  }

  Widget _buildAvailability(
      BuildContext context, Game game, SeasonPlayer player) {
    PlayerBloc players = BlocProvider.of<PlayerBloc>(context);
    if (players.currentState.players.containsKey(player.playerUid)) {
      return new GestureDetector(
        onTap: () => _updateAttendance(
              context,
              player,
              game.attendance[player.playerUid],
            ),
        child: new AttendanceIcon(
          game.attendance[player.playerUid],
        ),
      );
    }
    return new AttendanceIcon(game.attendance[player.playerUid]);
  }

  void _showPlayer(BuildContext context, Game game, String playerUid) {
    Navigator.pushNamed(
        context,
        "PlayerDetails/" +
            game.teamUid +
            "/" +
            game.seasonUid +
            "/" +
            playerUid);
  }

  Iterable<Widget> _buildChildren(BuildContext context, Team team, Game game) {
    Season season = team.seasons[game.seasonUid];
    ThemeData theme = Theme.of(context);

    return season.players.map((SeasonPlayer player) {
      PlayerBloc players = BlocProvider.of<PlayerBloc>(context);
      bool canEdit = players.currentState.players.containsKey(player.playerUid);
      return new ListTile(
        onTap: () => _showPlayer(context, game, player.playerUid),
        leading: canEdit
            ? new Icon(Icons.person, color: theme.accentColor)
            : const Icon(Icons.person),
        title: new PlayerName(playerUid: player.playerUid),
        trailing: _buildAvailability(context, game, player),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _game,
      builder: (BuildContext context, SingleGameState gameState) =>
          SingleTeamProvider(
            teamUid: gameState.game.teamUid,
            builder: (BuildContext context, SingleTeamBloc teamBloc) =>
                BlocBuilder(
                  bloc: teamBloc,
                  builder: (BuildContext context, SingleTeamState teamState) {
                    return ListBody(
                      children: _buildChildren(
                              context, teamState.team, gameState.game)
                          .toList(),
                    );
                  },
                ),
          ),
    );
  }
}
