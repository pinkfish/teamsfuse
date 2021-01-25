import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleseasonprovider.dart';
import '../blocs/singleteamprovider.dart';
import '../util/playerimage.dart';
import '../util/playername.dart';

///
/// Show the players of the team.
///
class TeamPlayers extends StatefulWidget {
  /// Constructor taking the team to find the players of
  TeamPlayers(this._teamUid);

  final String _teamUid;

  @override
  _TeamPlayersState createState() {
    return _TeamPlayersState();
  }
}

class _TeamPlayersState extends State<TeamPlayers> {
  String _seasonUid;

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, SingleTeamState teamState) {
    var ret = <DropdownMenuItem<String>>[];
    var seasons = teamState.fullSeason.toList();
    seasons.sort((s1, s2) => s1.name.compareTo(s2.name));
    for (var s in seasons) {
      ret.add(DropdownMenuItem<String>(child: Text(s.name), value: s.uid));
    }

    return ret;
  }

  void _deleteInvite(InviteToTeam invite) async {
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
            FlatButton(
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
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

  List<Widget> _buildPlayers(
      SingleSeasonState state, SingleTeamState teamState) {
    var ret = <Widget>[];
    var theme = Theme.of(context);

    for (var player in state.season.players) {
      ret.add(
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context,
                "PlayerDetails/${widget._teamUid}/$_seasonUid/${player.playerUid}");
          },
          child: ListTile(
            leading: PlayerImage(playerUid: player.playerUid),
            title: PlayerName(playerUid: player.playerUid),
            subtitle: Text(
              Messages.of(context).roleingame(player.role),
            ),
          ),
        ),
      );
    }
    ret.add(
      ListTile(
        title: FlatButton(
          textColor: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.pushNamed(
                context, "AddPlayer/${widget._teamUid}/$_seasonUid");
          },
          child: Text(Messages.of(context).addplayer),
        ),
      ),
    );

    // Put in an expansion bar if there are pending invites.
    if (state.invites != null &&
        state.invites.length > 0 &&
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
                Text(Messages.of(context).roleingame(inv.role)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteInvite(inv);
              },
            ),
          ),
        );
      }
      ret.add(ExpansionTile(
          title: Text(Messages.of(context).invitedpeople(state.invites.length)),
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
          if (seasonState is SingleSeasonUninitialized || seasonState is SingleSeasonDeleted) {
            return Column(children: [
              Text(Messages.of(context).loading),
            ]);
          }
          return Column(children: _buildPlayers(seasonState, teamState));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var messsages = Messages.of(context);

    return SingleTeamProvider(
      teamUid: widget._teamUid,
      builder: (context, bloc) => BlocBuilder(
        cubit: bloc,
        builder: (context, teamState) {
          if (teamState is SingleTeamDeleted) {
            return CircularProgressIndicator();
          } else {
            if (_seasonUid == null) {
              _seasonUid = teamState.team.currentSeason;
            }
            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    DropdownButton<String>(
                      hint: Text(messsages.seasonselect),
                      value: _seasonUid,
                      items: _buildItems(context, teamState),
                      onChanged: (val) {
                        print('changed $val');
                        setState(() {
                          _seasonUid = val;
                        });
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(),
                    margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                    decoration: BoxDecoration(color: theme.cardColor),
                    child: SingleChildScrollView(
                      child: _buildSeason(context, teamState),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
