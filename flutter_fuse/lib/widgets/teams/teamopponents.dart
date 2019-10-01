import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleopponentprovider.dart';

///
/// Widget to show the opponents for this team.
///
class TeamOpponents extends StatefulWidget {
  TeamOpponents(this._teamBloc);

  final SingleTeamBloc _teamBloc;

  @override
  _TeamOpponentsState createState() {
    return new _TeamOpponentsState();
  }
}

class _TeamOpponentsState extends State<TeamOpponents> {
  String _seasonUid;

  void initState() {
    super.initState();
    widget._teamBloc.dispatch(SingleTeamLoadAllSeasons());
    widget._teamBloc.dispatch(SingleTeamLoadOpponents());
    _seasonUid = widget._teamBloc.currentState.team.currentSeason;
  }

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, SingleTeamState teamState) {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    for (Season s in teamState.fullSeason) {
      ret.add(
          new DropdownMenuItem<String>(child: new Text(s.name), value: s.uid));
    }

    return ret;
  }

  void _deleteOpponent(SingleOpponentBloc op) async {
    Messages mess = Messages.of(context);
    // Show an alert dialog first.
    bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(mess.deleteopponent),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(op.currentState.opponent.name),
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
      op.dispatch(SingleOpponentDeleteOpponent());
    }
  }

  List<Widget> _buildOpponents(Team team, SingleTeamState singleTeamState) {
    List<Widget> ret = <Widget>[];
    ThemeData theme = Theme.of(context);

    ret.add(
      new RichText(
        text: new TextSpan(
          text: Messages.of(context).opponentwithresult,
          style: theme.textTheme.title,
        ),
      ),
    );
    List<String> opponentKeys = singleTeamState.opponents.keys.toList();
    opponentKeys.sort((String uid1, String uid2) => singleTeamState
        .opponents[uid1].name
        .compareTo(singleTeamState.opponents[uid2].name));

    for (String uid in opponentKeys) {
      Opponent op = singleTeamState.opponents[uid];
      WinRecord record;
      if (!op.record.containsKey(_seasonUid)) {
        continue;
      }
      record = op.record[_seasonUid];

      ret.add(
        SingleOpponentProvider(
          opponentUid: op.uid,
          singleTeamBloc: widget._teamBloc,
          builder: (BuildContext context, SingleOpponentBloc opBloc) {
            return ExpansionTile(
              title: new RichText(
                text: new TextSpan(
                  style: theme.textTheme.subhead.copyWith(
                      color: record.win > record.loss
                          ? Colors.green
                          : record.win < record.loss
                              ? Colors.redAccent
                              : Colors.black),
                  text: op.name +
                      " W:" +
                      record.win.toString() +
                      " L:" +
                      record.loss.toString() +
                      " T:" +
                      record.tie.toString(),
                ),
              ),
              initiallyExpanded: false,
              children: <Widget>[
                new BlocBuilder(
                    bloc: opBloc,
                    builder: (BuildContext context, SingleOpponentState state) {
                      if (state is SingleOpponentDeleted) {
                        return new Center(
                          child: new Text(Messages.of(context).teamdeleted),
                        );
                      }
                      if (state.gamesLoaded) {
                        if (state.games.length == 0) {
                          return new Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Center(
                                child: new Text(
                                    Messages.of(context).unabletoloadgames),
                              ),
                            ],
                          );
                        } else {
                          List<Widget> newData = <Widget>[];
                          for (Game game in state.games) {
                            if (game.sharedData.type == EventType.Game &&
                                game.seasonUid == _seasonUid &&
                                game.opponentUids.contains(uid)) {
                              newData.add(
                                GameCard(gameUid: game.uid),
                              );
                            }
                          }
                          if (newData.length == 0) {
                            newData.add(new Text(Messages.of(context).nogames));
                          }
                          return new Column(
                            children: newData,
                          );
                        }
                      } else {
                        opBloc.dispatch(SingleOpponentLoadGames());
                        return new Center(
                          child: new Text(Messages.of(context).loading),
                        );
                      }
                    }),
              ],
            );
          },
        ),
      );
    }
    ret.add(
      new RichText(
        text: new TextSpan(
          text: Messages.of(context).opponentwithnoresult,
          style: theme.textTheme.title,
        ),
      ),
    );
    for (String uid in opponentKeys) {
      Opponent op = singleTeamState.opponents[uid];
      if (op.record.containsKey(_seasonUid)) {
        continue;
      }

      ret.add(
        SingleOpponentProvider(
          opponentUid: op.uid,
          singleTeamBloc: widget._teamBloc,
          builder: (BuildContext context, SingleOpponentBloc opBloc) =>
              ExpansionTile(
            title: new Text(op.name),
            initiallyExpanded: false,
            children: <Widget>[
              new BlocBuilder(
                bloc: opBloc,
                builder: (BuildContext context, SingleOpponentState state) {
                  if (state is SingleOpponentDeleted) {
                    return new Center(
                      child: new Text(Messages.of(context).loading),
                    );
                  }

                  if (state.games.length == 0) {
                    return new Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Center(
                          child: new Text(Messages.of(context).nogames),
                        ),
                        new IconButton(
                          onPressed: () => _deleteOpponent(opBloc),
                          icon: const Icon(Icons.delete),
                          color: Theme.of(context).primaryColorDark,
                        )
                      ],
                    );
                  } else {
                    List<Widget> newData = <Widget>[];
                    for (Game game in state.games) {
                      if (game.sharedData.type == EventType.Game &&
                          game.opponentUids.contains(uid)) {
                        if (game.seasonUid == _seasonUid) {
                          newData.add(
                            GameCard(
                              gameUid: game.uid,
                            ),
                          );
                        }
                      }
                    }
                    if (newData.length == 0) {
                      newData.add(
                          new Text(Messages.of(context).nogamesthisseason));
                    }
                    return new Column(
                      children: newData,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Messages messsages = Messages.of(context);

    return BlocListener(
      bloc: widget._teamBloc,
      listener: (BuildContext context, SingleTeamState state) {
        print("State is $state");
        if (state is SingleTeamLoaded) {
          _seasonUid = state.team.currentSeason;
        }
      },
      child: Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              BlocBuilder(
                bloc: widget._teamBloc,
                builder: (BuildContext context, SingleTeamState teamState) =>
                    DropdownButton<String>(
                  hint: new Text(messsages.seasonselect),
                  value: _seasonUid,
                  items: _buildItems(context, teamState),
                  onChanged: (String val) {
                    print('changed $val');
                    setState(() {
                      _seasonUid = val;
                    });
                  },
                ),
              ),
            ],
          ),
          new Expanded(
            child: new Container(
              constraints: new BoxConstraints(),
              margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
              decoration: new BoxDecoration(color: theme.cardColor),
              child: new SingleChildScrollView(
                child: BlocBuilder(
                  bloc: widget._teamBloc,
                  builder: (BuildContext context, SingleTeamState teamState) =>
                      Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildOpponents(teamState.team, teamState),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
