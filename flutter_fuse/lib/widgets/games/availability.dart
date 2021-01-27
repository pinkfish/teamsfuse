import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleteamprovider.dart';
import '../player/playername.dart';
import 'attendancedialog.dart';
import 'attendanceicon.dart';

///
/// The availability widget shows all the current availability for this team.
///
class Availaility extends StatelessWidget {
  /// Constructor.
  Availaility(this._game);

  final SingleGameBloc _game;

  void _updateAttendance(
      BuildContext context, SeasonPlayer player, Attendance current) async {
    var attend = await showDialog(
        context: context,
        builder: (context) {
          return AttendanceDialog(current: current);
        });
    if (attend != null) {
      _game.add(SingleGameUpdateAttendance(
          playerUid: player.playerUid, attendance: attend));
    }
  }

  Widget _buildAvailability(
      BuildContext context, Game game, SeasonPlayer player) {
    var players = BlocProvider.of<PlayerBloc>(context);
    if (players.state.players.containsKey(player.playerUid)) {
      return GestureDetector(
        onTap: () => _updateAttendance(
          context,
          player,
          game.attendance[player.playerUid],
        ),
        child: AttendanceIcon(
          game.attendance[player.playerUid],
        ),
      );
    }
    return AttendanceIcon(game.attendance[player.playerUid]);
  }

  void _showPlayer(BuildContext context, Game game, String playerUid) {
    Navigator.pushNamed(
        context, "PlayerDetails/${game.teamUid}/${game.seasonUid}/$playerUid");
  }

  Iterable<Widget> _buildChildren(
      BuildContext context, SingleTeamState teamState, Game game) {
    var season = teamState.getSeason(game.seasonUid);
    var theme = Theme.of(context);

    return season.players.map((player) {
      var players = BlocProvider.of<PlayerBloc>(context);
      var canEdit = players.state.players.containsKey(player.playerUid);
      return ListTile(
        onTap: () => _showPlayer(context, game, player.playerUid),
        leading: canEdit
            ? Icon(Icons.person, color: theme.accentColor)
            : const Icon(Icons.person),
        title: PlayerName(playerUid: player.playerUid),
        trailing: _buildAvailability(context, game, player),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: _game,
      builder: (context, gameState) => SingleTeamProvider(
        teamUid: gameState.game.teamUid,
        builder: (context, teamBloc) => BlocBuilder(
          cubit: teamBloc,
          builder: (context, teamState) {
            return ListBody(
              children:
                  _buildChildren(context, teamState, gameState.game).toList(),
            );
          },
        ),
      ),
    );
  }
}
