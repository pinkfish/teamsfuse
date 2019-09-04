import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/playerimage.dart';
import 'package:flutter_fuse/widgets/util/playername.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleseasonprovider.dart';
import '../blocs/singleteamprovider.dart';

class TeamPlayers extends StatefulWidget {
  TeamPlayers(this._teamUid);

  final String _teamUid;

  @override
  TeamPlayersState createState() {
    return new TeamPlayersState();
  }
}

class TeamPlayersState extends State<TeamPlayers> {
  TeamPlayersState();

  String _seasonUid;

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, SingleTeamState teamState) {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    List<Season> seasons = teamState.fullSeason.toList();
    seasons.sort();
    for (Season s in seasons) {
      ret.add(
          new DropdownMenuItem<String>(child: new Text(s.name), value: s.uid));
    }

    return ret;
  }

  void _deleteInvite(InviteToTeam invite) async {
    Messages mess = Messages.of(context);
    // Show an alert dialog first.
    bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(mess.deleteinvite),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(mess.confirmdelete(invite)),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
            ),
            new FlatButton(
              child:
                  new Text(MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
    if (result) {
      InviteBloc bloc = BlocProvider.of<InviteBloc>(context);
      bloc.dispatch(InviteEventDeleteInvite(inviteUid: invite.uid));
    }
  }

  List<Widget> _buildPlayers(
      SingleSeasonState state, SingleTeamState teamState) {
    List<Widget> ret = <Widget>[];
    ThemeData theme = Theme.of(context);

    for (SeasonPlayer player in state.season.players) {
      ret.add(
        new GestureDetector(
          onTap: () {
            Navigator.pushNamed(
                context,
                "PlayerDetails/" +
                    widget._teamUid +
                    "/" +
                    _seasonUid +
                    "/" +
                    player.playerUid);
          },
          child: new ListTile(
            leading: new PlayerImage(playerUid: player.playerUid),
            title: new PlayerName(playerUid: player.playerUid),
            subtitle: new Text(
              Messages.of(context).roleingame(player.role),
            ),
          ),
        ),
      );
    }
    ret.add(
      new ListTile(
        title: new FlatButton(
          textColor: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.pushNamed(
                context, "AddPlayer/" + widget._teamUid + "/" + _seasonUid);
          },
          child: new Text(Messages.of(context).addplayer),
        ),
      ),
    );

    // Put in an expansion bar if there are pending invites.
    if (state.invites != null &&
        state.invites.length > 0 &&
        teamState.isAdmin()) {
      List<Widget> kids = <Widget>[];
      for (InviteToTeam inv in state.invites) {
        kids.add(
          new ListTile(
            title: new Row(
              children: inv.playerName.map((String name) {
                return new Chip(
                    backgroundColor: Colors.lightBlueAccent,
                    label: new Text(name));
              }).toList(),
            ),
            leading: const Icon(Icons.email),
            subtitle: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 5.0),
                new Text(
                  inv.email,
                  style: theme.textTheme.body1
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5.0),
                new Text(Messages.of(context).roleingame(inv.role)),
              ],
            ),
            trailing: new IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteInvite(inv);
              },
            ),
          ),
        );
      }
      ret.add(new ExpansionTile(
          title: new Text(
              Messages.of(context).invitedpeople(state.invites.length)),
          children: kids));
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Messages messsages = Messages.of(context);

    return SingleTeamProvider(
      teamUid: widget._teamUid,
      builder: (BuildContext context, SingleTeamBloc bloc) => BlocBuilder(
        bloc: bloc,
        builder: (BuildContext context, SingleTeamState state) {
          if (state is SingleTeamDeleted) {
            return CircularProgressIndicator();
          } else {
            return Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new DropdownButton<String>(
                      hint: new Text(messsages.seasonselect),
                      value: _seasonUid,
                      items: _buildItems(context, state),
                      onChanged: (String val) {
                        print('changed $val');
                        setState(() {
                          _seasonUid = val;
                        });
                      },
                    ),
                  ],
                ),
                new Expanded(
                  child: new Container(
                    constraints: new BoxConstraints(),
                    margin:
                        new EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                    decoration: new BoxDecoration(color: theme.cardColor),
                    child: new SingleChildScrollView(
                      child: SingleSeasonProvider(
                        seasonUid: _seasonUid,
                        builder: (BuildContext context,
                                SingleSeasonBloc seasonBloc) =>
                            BlocBuilder(
                          bloc: seasonBloc,
                          builder: (BuildContext context,
                              SingleSeasonState seasonState) {
                            return Column(
                                children: _buildPlayers(seasonState, state));
                          },
                        ),
                      ),
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
