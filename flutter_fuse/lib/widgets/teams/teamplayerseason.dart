import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
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

  void _deleteInvite(BuildContext context, InviteToTeam invite) async {
    var mess = Messages.of(context);
    // Show an alert dialog first.
    var result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: Text(mess.deleteinvite),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(mess.confirmdelete(invite)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
    if (result) {
      var bloc = BlocProvider.of<InviteBloc>(context);
      bloc.add(InviteEventDeleteInvite(inviteUid: invite.uid));
    }
  }

  List<Widget> _buildPlayers(BuildContext context, SingleSeasonState state,
      SingleTeamState teamState) {
    var ret = <Widget>[];
    var theme = Theme.of(context);

    for (var player in state.season.players) {
      ret.add(
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context,
                "PlayerDetails/$_teamUid/$_seasonUid/${player.playerUid}");
          },
          child: teamState.team.sport == Sport.Basketball
              ? PlayerTileBasketball(
                  playerUid: player.playerUid,
                  seasonUid: _seasonUid,
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
        ListTile(
          title: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, "AddPlayer/$_teamUid/$_seasonUid");
            },
            style: TextButton.styleFrom(primary: Theme.of(context).accentColor),
            child: Text(Messages.of(context).addPlayerButton),
          ),
        ),
      );
    }

    // Put in an expansion bar if there are pending invites.
    if (state.invites != null &&
        state.invites.isNotEmpty &&
        teamState.isAdmin()) {
      var kids = <Widget>[];
      for (var inv in state.invites) {
        kids.add(
          ListTile(
            title: Row(
              children: inv.playerName.map((name) {
                return Chip(
                    backgroundColor: Colors.lightBlueAccent, label: Text(name));
              }).toList(),
            ),
            leading: const Icon(Icons.email),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 5.0),
                Text(
                  inv.email,
                  style: theme.textTheme.bodyText2
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5.0),
                Text(Messages.of(context).roleInGame(inv.role)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteInvite(context, inv);
              },
            ),
          ),
        );
      }
      ret.add(ExpansionTile(
          title: Text(Messages.of(context).invitedPeople(state.invites.length)),
          children: kids));
    }
    return ret;
  }

  Widget _buildSeason(BuildContext context, SingleTeamState teamState) {
    return SingleSeasonProvider(
      seasonUid: _seasonUid,
      builder: (context, seasonBloc) => BlocBuilder(
        cubit: seasonBloc,
        builder: (context, seasonState) {
          if (seasonState is SingleSeasonUninitialized ||
              seasonState is SingleSeasonDeleted) {
            return Column(children: [
              Text(Messages.of(context).loading),
            ]);
          }
          if (!seasonState.loadedInvites) {
            seasonBloc.add(SingleSeasonLoadInvites());
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
        cubit: bloc,
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
