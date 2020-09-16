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
    return _TeamOpponentsState();
  }
}

class _TeamOpponentsState extends State<TeamOpponents> {
  String _seasonUid;

  @override
  void initState() {
    super.initState();
    widget._teamBloc.add(SingleTeamLoadSeasons());
    widget._teamBloc.add(SingleTeamLoadOpponents());
    _seasonUid = widget._teamBloc.state.team.currentSeason;
  }

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, SingleTeamState teamState) {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    for (Season s in teamState.fullSeason) {
      ret.add(DropdownMenuItem<String>(child: Text(s.name), value: s.uid));
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
        return AlertDialog(
          title: Text(mess.deleteopponent),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(op.state.opponent.name),
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
      op.add(SingleOpponentDeleteOpponent());
    }
  }

  List<Widget> _buildOpponents(Team team, SingleTeamState singleTeamState) {
    List<Widget> ret = <Widget>[];
    ThemeData theme = Theme.of(context);

    ret.add(
      RichText(
        text: TextSpan(
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
              title: RichText(
                text: TextSpan(
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
                BlocBuilder(
                    cubit: opBloc,
                    builder: (BuildContext context, SingleOpponentState state) {
                      if (state is SingleOpponentDeleted) {
                        return Center(
                          child: Text(Messages.of(context).teamdeleted),
                        );
                      }
                      if (state.gamesLoaded) {
                        if (state.games.length == 0) {
                          return Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text(
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
                            newData.add(Text(Messages.of(context).nogames));
                          }
                          return Column(
                            children: newData,
                          );
                        }
                      } else {
                        opBloc.add(SingleOpponentLoadGames());
                        return Center(
                          child: Text(Messages.of(context).loading),
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
      RichText(
        text: TextSpan(
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
            title: Text(op.name),
            initiallyExpanded: false,
            children: <Widget>[
              BlocBuilder(
                cubit: opBloc,
                builder: (BuildContext context, SingleOpponentState state) {
                  if (state is SingleOpponentDeleted) {
                    return Center(
                      child: Text(Messages.of(context).loading),
                    );
                  }

                  if (state.games.length == 0) {
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Text(Messages.of(context).nogames),
                        ),
                        IconButton(
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
                      newData.add(Text(Messages.of(context).nogamesthisseason));
                    }
                    return Column(
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
      cubit: widget._teamBloc,
      listener: (BuildContext context, SingleTeamState state) {
        print("State is $state");
        if (state is SingleTeamLoaded) {
          _seasonUid = state.team.currentSeason;
        }
      },
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              BlocBuilder(
                cubit: widget._teamBloc,
                builder: (BuildContext context, SingleTeamState teamState) =>
                    DropdownButton<String>(
                  hint: Text(messsages.seasonselect),
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
          Expanded(
            child: Container(
              constraints: BoxConstraints(),
              margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
              decoration: BoxDecoration(color: theme.cardColor),
              child: SingleChildScrollView(
                child: BlocBuilder(
                  cubit: widget._teamBloc,
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
