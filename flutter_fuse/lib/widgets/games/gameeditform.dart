import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/datetimeformfield.dart';
import 'package:flutter_fuse/widgets/form/opponentformfield.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/screens/game/addopponent.dart';
import 'package:flutter_fuse/services/approuter.dart';

// This form has all the stuff needed to edit the main parts
// of the game.  Does not have the add game step flow.
class EditGameForm extends StatefulWidget {
  EditGameForm(this.game, GlobalKey<EditGameFormState> key) : super(key: key);

  final Game game;

  EditGameFormState createState() {
    return new EditGameFormState(game);
  }
}

class EditGameFormState extends State<EditGameForm> {
  Game game;
  final GlobalKey<DateTimeFormFieldState> _arriveByKey =
      new GlobalKey<DateTimeFormFieldState>();
  final GlobalKey<OpponentFormFieldState> _opponentState =
      new GlobalKey<OpponentFormFieldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool autovalidate = false;
  Validations _validations = new Validations();
  ScrollController _scrollController = new ScrollController();
  DateTimeUnion _arriveAtDate = new DateTimeUnion(
      new DateTime.now(), const TimeOfDay(hour: 7, minute: 28));
  DateTimeUnion _atDate = new DateTimeUnion(
      new DateTime.now(), const TimeOfDay(hour: 7, minute: 28));
  FocusNode _focusNode = new FocusNode();

  EditGameFormState(this.game);

  void save() {
    _formKey.currentState.save();
  }

  bool validate() {
    return _formKey.currentState.validate();
  }

  Future<bool> validateAndSaveToFirebase() async {
    if (!_formKey.currentState.validate()) {
      autovalidate = true;
      return false;
    } else {
      _formKey.currentState.save();
      await game.updateFirestore();
    }
    return true;
  }

  void setTeam(String team) {
    Team teamData = UserDatabaseData.instance.teams[team];
    num hour = _atDate.item2.hour;
    num minute = _atDate.item2.minute - teamData.arriveEarly;
    if (minute < 0) {
      hour -= minute / 60;
      minute = 60 - (minute % 60);
    }
    _arriveAtDate = new DateTimeUnion(
        _atDate.item1, new TimeOfDay(hour: hour, minute: minute));
    game.teamUid = team;
    game.seasonUid = teamData.currentSeason;
    game.opponentUid = null;
  }

  void _changeAtTime(DateTimeUnion union) {
    TimeOfDay curTime = _arriveByKey.currentState.value.item2;
    // Get the diff with the arrive time and then make the same diff...
    num cur = union.item2.hour * 60 + union.item2.minute;
    num arriveAt = curTime.hour * 60 + curTime.minute;
    num diff = cur - arriveAt;

    num hour = union.item2.hour;
    num minute = union.item2.minute - diff;

    hour += ((minute / 60) % 24).toInt();
    if (minute < 0) {
      minute = 60 + (minute % 60);
    } else if (minute > 60) {
      minute = (minute % 60);
    }

    _arriveByKey.currentState.setValue(new DateTimeUnion(
        union.item1, new TimeOfDay(hour: hour, minute: minute)));
  }

  void _openAddOpponentDialog() async {
    String save =
        await Navigator.of(context).push(new MaterialPageRoute<String>(
            builder: (BuildContext context) {
              return new AddOpponent(this.game.teamUid);
            },
            fullscreenDialog: true,

        ));

    if (save != null) {
      _opponentState.currentState.setValue(save);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (game.teamUid == null ||
        !UserDatabaseData.instance.teams.containsKey(game.teamUid)) {
      return new Text('Invalid state');
    }
    return new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Form(
                  key: _formKey,
                  autovalidate: autovalidate,
                  child: new DropdownButtonHideUnderline(
                      child: new Column(
                    children: <Widget>[
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Expanded(
                              flex: 1,
                              child: new SeasonFormField(
                                  initialValue: game.seasonUid,
                                  teamUid: game.teamUid,
                                  onSaved: ((String value) {
                                    game.seasonUid = value;
                                  }))),
                          const SizedBox(width: 12.0),
                          new Expanded(
                            flex: 1,
                            child: new OpponentFormField(
                                teamUid: game.teamUid,
                                key: _opponentState,
                                initialValue: game.opponentUid == null
                                    ? 'none'
                                    : game.opponentUid,
                                validator: (String str) {
                                  print('validate ${str}');
                                  return _validations.validateOpponent(
                                      context, str);
                                },
                                onFieldSubmitted: (String value) {
                                  if (value == 'add') {
                                    // Open up a picker to create an opponent.
                                    _openAddOpponentDialog();
                                  }
                                },
                                onSaved: ((String value) {
                                  game.opponentUid = value;
                                })),
                          ),
                        ],
                      ),
                      new DateTimeFormField(
                        labelText: Messages.of(context).gametime,
                        initialValue: _atDate,
                        hideDate: false,
                        onSaved: (DateTimeUnion value) {
                          _atDate = value;
                        },
                        onFieldSubmitted: this._changeAtTime,
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Expanded(
                            flex: 4,
                            child: new DateTimeFormField(
                              key: _arriveByKey,
                              labelText: Messages.of(context).arriveat,
                              initialValue: _arriveAtDate,
                              hideDate: true,
                              onSaved: (DateTimeUnion val) {
                                _arriveAtDate = val;
                              },
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          new Expanded(
                            flex: 1,
                            child: new SwitchFormField(
                              decoration: new InputDecoration(
                                labelText: Messages.of(context).homeaway,
                              ),
                              initialValue: game.homegame,
                              onSaved: (bool value) {
                                game.homegame = value;
                              },
                            ),
                          ),
                        ],
                      ),
                      new EnsureVisibleWhenFocused(
                        focusNode: _focusNode,
                        child: new TextFormField(
                            decoration: new InputDecoration(
                              icon: const Icon(Icons.event_note),
                              hintText: Messages.of(context).uniformhint,
                              labelText: Messages.of(context).uniform,
                            ),
                            keyboardType: TextInputType.text,
                            obscureText: false,
                            initialValue: game.uniform,
                            onSaved: (String value) {
                              game.uniform = value;
                            }),
                      ),
                      new EnsureVisibleWhenFocused(
                        focusNode: _focusNode,
                        child: new TextFormField(
                            decoration: const InputDecoration(
                                icon: const Icon(Icons.note),
                                hintText: 'Game notes',
                                labelText: 'Game notes'),
                            keyboardType: TextInputType.text,
                            obscureText: false,
                            initialValue: game.notes,
                            onSaved: (String value) {
                              game.notes = value;
                            }),
                      ),
                    ],
                  )))
            ]));
  }
}
