import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleteamprovider.dart';
import '../player/playername.dart';
import 'attendancedialog.dart';
import 'attendanceicon.dart';

///
/// The availability widget shows all the current availability for this team.
///
class Availability extends StatelessWidget {
  /// Constructor.
  Availability(this._game);

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
      return Ink(
        decoration: ShapeDecoration(
          color: Colors.lightBlue.shade50,
          shape: CircleBorder(),
        ),
        child: IconButton(
          onPressed: () => _updateAttendance(
            context,
            player,
            game.attendance[player.playerUid],
          ),
          icon: AttendanceIcon(
            game.attendance[player.playerUid],
          ),
        ),
      );
    }
    return AttendanceIcon(game.attendance[player.playerUid]);
  }

  void _showPlayer(BuildContext context, Game game, String playerUid) {
    Navigator.pushNamed(
        context, 'PlayerDetails/${game.teamUid}/${game.seasonUid}/$playerUid');
  }

  Widget _playerCard(BuildContext context, SingleGameState game,
      SeasonPlayer player, PlayerBloc players) {
    var canEdit = players.state.players.containsKey(player.playerUid);
    return Card(
      margin: EdgeInsets.only(right: 5, left: 20, top: 5, bottom: 5),
      child: ListTile(
        onTap: () => _showPlayer(context, game.game, player.playerUid),
        leading: canEdit
            ? Icon(Icons.person, color: Theme.of(context).accentColor)
            : const Icon(Icons.person),
        title: PlayerName(playerUid: player.playerUid),
        trailing: _buildAvailability(context, game.game, player),
      ),
    );
  }

  Iterable<Widget> _buildChildren(
      BuildContext context, SingleTeamState teamState, SingleGameState game) {
    var season = teamState.getSeason(game.game.seasonUid);
    var data = season.players.toList();

    var players = BlocProvider.of<PlayerBloc>(context);
    data.sort((a, b) {
      // Put the ones we own up the top.
      if (players.state.players.containsKey(a.playerUid)) {
        if (!players.state.players.containsKey(b.playerUid)) {
          return -1;
        }
      } else if (players.state.players.containsKey(b.playerUid)) {
        return 1;
      }
      if (game.players.containsKey(a.playerUid) &&
          game.players.containsKey(b.playerUid)) {
        return game.players[a.playerUid].name
            .compareTo(game.players[b.playerUid].name);
      }
      return a.jerseyNumber.compareTo(b.jerseyNumber);
    });

    var editable = data
        .where((p) => players.state.players.containsKey(p.playerUid))
        .map((player) {
      return _playerCard(context, game, player, players);
    });
    var going = data
        .where((p) => game.game.attendance[p.playerUid] == Attendance.Yes)
        .map((player) {
      return _playerCard(context, game, player, players);
    }).toList();
    if (going.isEmpty) {
      going.add(Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(Messages.of(context).attendanceEmpty,
              style: Theme.of(context).textTheme.headline5)));
    }
    var maybe = data
        .where((p) =>
            game.game.attendance[p.playerUid] == Attendance.Maybe ||
            !game.game.attendance.containsKey(p.playerUid))
        .map((player) {
      return _playerCard(context, game, player, players);
    });
    var no = data
        .where((p) => game.game.attendance[p.playerUid] == Attendance.No)
        .map((player) {
      return _playerCard(context, game, player, players);
    }).toList();
    if (no.isEmpty) {
      no.add(Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(Messages.of(context).attendanceEmpty,
              style: Theme.of(context).textTheme.headline5)));
    }
    return [
      ...editable,
      SizedBox(height: 10),
      Text(Messages.of(context).attendanceYes,
          style: Theme.of(context).textTheme.headline4),
      ...going,
      maybe.isEmpty ? SizedBox(height: 0) : SizedBox(height: 10),
      maybe.isEmpty
          ? SizedBox(height: 0)
          : Text(Messages.of(context).attendanceMaybe,
              style: Theme.of(context).textTheme.headline4),
      ...maybe,
      SizedBox(height: 10),
      Text(Messages.of(context).attendanceNo,
          style: Theme.of(context).textTheme.headline4),
      ...no,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _game,
      builder: (context, gameState) => SingleTeamProvider(
        teamUid: gameState.game.teamUid,
        builder: (context, teamBloc) => BlocBuilder(
          bloc: teamBloc,
          builder: (context, teamState) {
            if (!gameState.loadedPlayers) {
              _game.add(SingleGameLoadPlayers());
            }
            return ListBody(
              children: _buildChildren(context, teamState, gameState).toList(),
            );
          },
        ),
      ),
    );
  }
}
