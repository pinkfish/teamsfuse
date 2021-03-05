import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:flutter_fuse/widgets/teams/seasondropdown.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleopponentprovider.dart';
import '../games/gamecard.dart';

///
/// Widget to show the opponents for this team.
///
class TeamOpponents extends StatefulWidget {
  final String teamUid;

  /// Constructor.
  TeamOpponents(this.teamUid);

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
  }

  void _deleteOpponent(SingleOpponentBloc op) async {
    var mess = Messages.of(context);
    // Show an alert dialog first.
    var result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
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
            TextButton(
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
          ],
        );
      },
    );
    if (result) {
      op.add(SingleOpponentDeleteOpponent());
    }
  }

  List<Widget> _buildOpponents(
      Team team, SingleTeamBloc teamBloc, SingleTeamState singleTeamState) {
    var ret = <Widget>[];
    var theme = Theme.of(context);

    ret.add(
      RichText(
        text: TextSpan(
          text: Messages.of(context).opponentwithresult,
          style: theme.textTheme.headline6,
        ),
      ),
    );
    if (!singleTeamState.loadedOpponents) {
      ret.add(Text(Messages.of(context).loading));
    } else {
      var opponentKeys = singleTeamState.opponents.keys.toList();
      opponentKeys.sort((uid1, uid2) => singleTeamState.opponents[uid1].name
          .compareTo(singleTeamState.opponents[uid2].name));

      for (var uid in opponentKeys) {
        var op = singleTeamState.opponents[uid];
        WinRecord record;
        if (!op.record.containsKey(_seasonUid)) {
          continue;
        }
        record = op.record[_seasonUid];

        ret.add(
          SingleOpponentProvider(
            opponentUid: op.uid,
            teamUid: teamBloc.teamUid,
            builder: (context, opBloc) {
              return ExpansionTile(
                title: RichText(
                  text: TextSpan(
                    style: theme.textTheme.subtitle1.copyWith(
                        color: record.win > record.loss
                            ? Colors.green
                            : record.win < record.loss
                                ? Colors.redAccent
                                : Colors.black),
                    text: '${op.name} W:${record.win} L:${record.loss} '
                        'T:${record.tie}',
                  ),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  BlocBuilder(
                      cubit: opBloc,
                      builder: (context, state) {
                        if (!state.loadedGames) {
                          opBloc.add(SingleOpponentLoadGames());
                        }
                        if (state is SingleOpponentUninitialized) {
                          return Center(
                            child: Text(Messages.of(context).loading),
                          );
                        }
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
                            var newData = <Widget>[];
                            for (Game game in state.games) {
                              if (game.sharedData.type == EventType.Game &&
                                  game.seasonUid == _seasonUid &&
                                  game.opponentUid == uid) {
                                newData.add(
                                  GameCard(gameUid: game.uid),
                                );
                              }
                            }
                            if (newData.isEmpty) {
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
            style: theme.textTheme.headline6,
          ),
        ),
      );
      for (var uid in opponentKeys) {
        var op = singleTeamState.opponents[uid];
        if (op.record.containsKey(_seasonUid)) {
          continue;
        }

        ret.add(
          SingleOpponentProvider(
            opponentUid: op.uid,
            teamUid: teamBloc.teamUid,
            builder: (context, opBloc) => ExpansionTile(
              title: Text(op.name),
              initiallyExpanded: false,
              children: <Widget>[
                BlocBuilder(
                  cubit: opBloc,
                  builder: (context, state) {
                    if (state is SingleOpponentDeleted) {
                      return Center(
                        child: Text(Messages.of(context).teamdeleted),
                      );
                    }
                    if (state is SingleOpponentUninitialized) {
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
                      var newData = <Widget>[];
                      for (Game game in state.games) {
                        if (game.sharedData.type == EventType.Game &&
                            game.opponentUid == uid) {
                          if (game.seasonUid == _seasonUid) {
                            newData.add(
                              GameCard(
                                gameUid: game.uid,
                              ),
                            );
                          }
                        }
                      }
                      if (newData.isEmpty) {
                        newData
                            .add(Text(Messages.of(context).nogamesthisseason));
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
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return SingleTeamProvider(
      teamUid: widget.teamUid,
      builder: (context, teamBloc) => BlocConsumer(
        cubit: teamBloc,
        listener: (context, state) {
          if (state is SingleTeamLoaded) {
            _seasonUid = state.team.currentSeason;
          }
          if (state is SingleTeamDeleted) {
            Navigator.pop(context);
          }
        },
        builder: (context, singleTeamState) {
          if (singleTeamState is SingleTeamUninitialized ||
              singleTeamState is SingleTeamDeleted) {
            return LoadingWidget();
          }

          _seasonUid ??= singleTeamState.team.currentSeason;

          if (!singleTeamState.loadedSeasons) {
            teamBloc.add(SingleTeamLoadSeasons());
          }
          if (!singleTeamState.loadedOpponents) {
            teamBloc.add(SingleTeamLoadOpponents());
          }

          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SeasonDropDown(
                    teamUid: widget.teamUid,
                    value: _seasonUid,
                    onChanged: (val) => setState(() => _seasonUid = val),
                  )
                ],
              ),
              Expanded(
                child: Container(
                  constraints: BoxConstraints(),
                  margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                  decoration: BoxDecoration(color: theme.cardColor),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildOpponents(
                          singleTeamState.team, teamBloc, singleTeamState),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
