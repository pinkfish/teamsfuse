import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/numberpicker.dart';
import 'package:flutter_fuse/util/debouncer.dart';
import 'package:flutter_fuse/widgets/util/statepicker.dart';

class EditResultDialog extends StatefulWidget {
  Game game;

  EditResultDialog(this.game);

  @override
  EditResultDialogState createState() {
    return new EditResultDialogState(this.game);
  }
}

class EditResultDialogState extends State<EditResultDialog> {
  Game _game;
  Team _team;
  Opponent _opponent;
  GameResultDetails _details;
  GlobalKey<FormState> _formKey;
  Debouncer<bool> debouncer;
  int _ptsFor;
  int _ptsAgainst;

  EditResultDialogState(this._game) {
    _details = new GameResultDetails.copy(_game.result);
    _ptsFor = _details.ptsFor;
    _ptsAgainst = _details.ptsAgainst;
    _team = UserDatabaseData.instance.teams[_game.teamUid];
    if (_team == null) {
      _team = new Team();
    }
    _opponent = _team.opponents[_game.opponentUid];
    if (_opponent == null) {
      _opponent = new Opponent();
    }
    debouncer = new Debouncer<bool>(new Duration(minutes: 1), _sendUpdate,
        resetOnAdd: false);
  }

  void _sendUpdate(List<bool> results) {
    print('updating values');
    _game.updateFirestoreGameResult(_details);
  }

  void _selectResult(GameInProgress result) async {
    if (_details.inProgress == GameInProgress.NotStarted &&
        result != GameInProgress.NotStarted) {
      // Ask if they are sure
      bool ret = await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text(Messages.of(context).startgame),
            content: new Text(Messages.of(context).startgamebody),
            actions: <Widget>[
              new FlatButton(
                  child: new Text(MaterialLocalizations.of(context).okButtonLabel),
                  onPressed: () {
                    Navigator.pop(context, true);
                  }),
              new FlatButton(
                  child: new Text(MaterialLocalizations.of(context).cancelButtonLabel),
                  onPressed: () {
                    Navigator.pop(context, false);
                  })
            ],
          ));
      if (ret != null && ret == true) {
        // Save the state update.
        setState(() {
          _details.inProgress = result;
          _details.result = GameResult.InProgress;
        });
        debouncer.debounce(true);
      }
    } else if (_details.inProgress != GameInProgress.Final &&
        result == GameInProgress.Final) {
      // Finalize game?
      GameResult gameResult;
      if (_details.ptsFor > _details.ptsAgainst) {
        gameResult = GameResult.Win;
      } else if (_details.ptsFor < _details.ptsAgainst) {
        gameResult = GameResult.Loss;
      } else {
        gameResult = GameResult.Tie;
      }
      bool ret = await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text(Messages.of(context).finalscore),
            content: new Text(Messages.of(context).finalscorebody(
                _details.ptsFor, _details.ptsAgainst, gameResult.toString())),
            actions: <Widget>[
              new FlatButton(
                  child: new Text(MaterialLocalizations.of(context).okButtonLabel),
                  onPressed: () {
                    Navigator.pop(context, true);
                  }),
              new FlatButton(
                  child: new Text(MaterialLocalizations.of(context).cancelButtonLabel),
                  onPressed: () {
                    Navigator.pop(context, false);
                  })
            ],
          ));
      if (ret != null && ret == true) {
        // Save the state update.
        setState(() {
          _details.inProgress = result;
          _details.result = gameResult;
        });
        debouncer.debounce(true);
      }
    } else {
      setState(() {
        _details.inProgress = result;
        if (result == GameInProgress.NotStarted){
          _details.result = GameResult.Unknown;
        } else {
          _details.result = GameResult.InProgress;
        }
      });
      debouncer.debounce(true);
    }
  }

  PopupMenuItem<GameInProgress> _makeItem(GameInProgress val) {
    return new PopupMenuItem<GameInProgress>(
        child: new Text(Messages.of(context).gameinprogress(val)), value: val);
  }

  void _updateScore() {
    setState(() {
      _details.ptsAgainst = _ptsAgainst;
      _details.ptsFor = _ptsFor;
    });
    debouncer.debounce(true);
  }

  Widget _buildResults(BuildContext context) {
    ThemeData theme = Theme.of(context);

    print(_details.toJSON());
    return new Form(
        key: _formKey,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new Expanded(
                    flex: 1,
                    child: new Container(
                      decoration: new BoxDecoration(),
                      margin: new EdgeInsets.only(bottom: 5.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          new Text("For",
                              style: theme.textTheme.subhead.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.accentColor)),
                          new Container(
                              decoration: new BoxDecoration(
                                  border: new Border.all(
                                      color: theme.dividerColor, width: 1.0),
                                  gradient: new LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.centerLeft,
                                      tileMode: TileMode.mirror,
                                      colors: [
                                        Colors.grey.shade300,
                                        Colors.white
                                      ])),
                              child: new NumberPicker.integer(
                                disabled: _details.inProgress ==
                                    GameInProgress.NotStarted,
                                initialValue: _details.ptsFor,
                                minValue: 0,
                                maxValue: 10000,
                                onChanged: (num val) {
                                  _ptsFor = val;
                                },
                              )),
                        ],
                      ),
                    )),
                new Expanded(
                    flex: 1,
                    child: new Container(
                      decoration: new BoxDecoration(),
                      margin: new EdgeInsets.only(bottom: 5.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          new Container(
                              decoration: new BoxDecoration(
                                  border: new Border.all(
                                      color: theme.dividerColor, width: 1.0),
                                  gradient: new LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.centerLeft,
                                      tileMode: TileMode.mirror,
                                      colors: [
                                        Colors.grey.shade300,
                                        Colors.white
                                      ])),
                              child: new InProgressGamePicker(
                                initialValue: _details.inProgress,
                                onChanged: (GameInProgress val) {
                                  _selectResult(val);
                                },
                              )),
                        ],
                      ),
                    )),
                new Expanded(
                    flex: 1,
                    child: new Container(
                      decoration: new BoxDecoration(),
                      margin: new EdgeInsets.only(bottom: 5.0),
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Text("Against",
                                style: theme.textTheme.subhead.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.accentColor)),
                            new Container(
                                decoration: new BoxDecoration(
                                    border: new Border.all(
                                        color: theme.dividerColor, width: 1.0),
                                    gradient: new LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.centerLeft,
                                        tileMode: TileMode.mirror,
                                        colors: [
                                          Colors.grey.shade300,
                                          Colors.white
                                        ])),
                                child: new NumberPicker.integer(
                                  disabled: _details.inProgress ==
                                      GameInProgress.NotStarted,
                                  initialValue: _details.ptsAgainst,
                                  minValue: 0,
                                  maxValue: 10000,
                                  onChanged: (num val) {
                                    _ptsAgainst = val;
                                  },
                                )),
                          ]),
                    )),
              ],
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Container(
                      margin: new EdgeInsets.all(5.0),
                      child: new RaisedButton(
                          onPressed: _updateScore,
                          color: theme.accentColor,
                          textColor: Colors.white,
                          child: new Text("Set Score'"))),
                )
              ],
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(Messages.of(context).gametitlevs(_opponent.name)),
        ),
        backgroundColor: Colors.grey.shade100,
        resizeToAvoidBottomPadding: true,
        body: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              new Expanded(
                  child: new Container(
                constraints: new BoxConstraints(),
                margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                decoration: new BoxDecoration(color: theme.cardColor),
                child: new SingleChildScrollView(child: new Text(Messages.of(context).nomessages)),
              )),
              new Container(
                margin: new EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0, top: 1.0),
                  child: new TextField(
                      decoration: new InputDecoration(
                        prefixIcon: const Icon(Icons.send),
                        labelText: Messages.of(context).message,
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      keyboardType: TextInputType.text)),
              new Flexible(
                  fit: FlexFit.tight,
                  flex: 0,
                  child: this._buildResults(context))
            ]));
  }
}
