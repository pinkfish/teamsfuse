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
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:map_view/map_view.dart';
import 'package:timezone/timezone.dart';

// This form has all the stuff needed to edit the main parts
// of the game.  Does not have the add game step flow.
class GamEditForm extends StatefulWidget {
  GamEditForm(this.game, GlobalKey<GameEditFormState> key) : super(key: key);

  final Game game;

  GameEditFormState createState() {
    return new GameEditFormState(game);
  }
}

class GameEditFormState extends State<GamEditForm> {
  Game game;
  final GlobalKey<DateTimeFormFieldState> _arriveByKey =
      new GlobalKey<DateTimeFormFieldState>();
  final GlobalKey<DateTimeFormFieldState> _atEndKEy =
      new GlobalKey<DateTimeFormFieldState>();
  final GlobalKey<OpponentFormFieldState> _opponentState =
      new GlobalKey<OpponentFormFieldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool autovalidate = false;
  Validations _validations = new Validations();
  ScrollController _scrollController = new ScrollController();
  FocusNode _focusNode = new FocusNode();
  DateTime _atDate;
  DateTime _atArrival;
  DateTime _atEnd;

  GameEditFormState(this.game);

  void save() {
    _formKey.currentState.save();
  }

  @override
  void initState() {
    super.initState();
    _atArrival = new DateTime.fromMillisecondsSinceEpoch(game.arriveTime);
    _atDate = new DateTime.fromMillisecondsSinceEpoch(game.time);
    _atEnd = new DateTime.fromMillisecondsSinceEpoch(game.endTime);
  }

  bool validate() {
    if (_formKey.currentState == null) {
      return false;
    }
    return _formKey.currentState.validate();
  }

  Future<bool> validateAndSaveToFirebase() async {
    if (!_formKey.currentState.validate()) {
      autovalidate = true;
      return false;
    } else {
      _formKey.currentState.save();
      // Add the date time and the time together.
      widget.game.time = new TZDateTime(
              getLocation(widget.game.timezone),
              _atDate.year,
              _atDate.month,
              _atDate.day,
              _atDate.hour,
              _atDate.minute)
          .millisecondsSinceEpoch;
      // Move forward a day so it is in the next day.
      DateTime arrival = _atArrival;
      if (_atArrival.millisecondsSinceEpoch < _atDate.millisecondsSinceEpoch) {
        arrival.add(new Duration(days: 1));
      }
      widget.game.arriveTime = new TZDateTime(
              getLocation(widget.game.timezone),
              arrival.year,
              arrival.month,
              arrival.day,
              arrival.hour,
              arrival.minute)
          .millisecondsSinceEpoch;
      DateTime end = _atEnd;
      if (_atEnd.millisecondsSinceEpoch < _atDate.millisecondsSinceEpoch) {
        end.add(new Duration(days: 1));
      }
      widget.game.endTime = new TZDateTime(getLocation(widget.game.timezone),
              end.year, end.month, end.day, end.hour, end.minute)
          .millisecondsSinceEpoch;
      game.arriveTime = _atArrival.millisecondsSinceEpoch;
      game.endTime = _atEnd.millisecondsSinceEpoch;
      await game.updateFirestore();
    }
    return true;
  }

  void _changeAtTime(Duration diff) {
    _arriveByKey.currentState
        .setValue(_arriveByKey.currentState.value.subtract(diff));
    _atEndKEy.currentState
        .setValue(_atEndKEy.currentState.value.subtract(diff));
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
                          onSaved: (String value) {
                            game.seasonUid = value;
                          },
                        ),
                      ),
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
                            return _validations.validateOpponent(context, str);
                          },
                          onFieldSubmitted: (String value) {
                            if (value == 'add') {
                              // Open up a picker to create an opponent.
                              _openAddOpponentDialog();
                            }
                          },
                          onSaved: (String value) {
                            game.opponentUid = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  new DateTimeFormField(
                    labelText: Messages.of(context).gametime,
                    initialValue: _atDate,
                    hideDate: false,
                    onSaved: (DateTime value) {
                      _atDate = value;
                    },
                    onFieldChanged: this._changeAtTime,
                  ),
                  new FlatButton(
                    onPressed: () {
                      MapView
                          .openPlacePickerModal()
                          .then((Map<String, dynamic> val) {
                        print('places ret $val');
                      }).catchError((Object err) {
                        print('$err Error!');
                      });
                    },
                    child: new Text('Place'),
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
                          initialValue: _atArrival,
                          hideDate: true,
                          onSaved: (DateTime val) {
                            _atArrival = val;
                          },
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      new Expanded(
                        flex: 4,
                        child: new DateTimeFormField(
                          key: _atEndKEy,
                          labelText: Messages.of(context).gameend,
                          initialValue: _atEnd,
                          hideDate: true,
                          onSaved: (DateTime val) {
                            _atEnd = val;
                          },
                        ),
                      ),
                    ],
                  ),
                  new EnsureVisibleWhenFocused(
                    focusNode: _focusNode,
                    child: new TextFormField(
                      decoration: new InputDecoration(
                        icon: const Icon(CommunityIcons.tshirtcrew),
                        hintText: Messages.of(context).uniformhint,
                        labelText: Messages.of(context).uniform,
                      ),
                      keyboardType: TextInputType.text,
                      obscureText: false,
                      initialValue: game.uniform,
                      onSaved: (String value) {
                        game.uniform = value;
                      },
                    ),
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
                      },
                    ),
                  ),
                  new Expanded(
                    flex: 1,
                    child: new SwitchFormField(
                      decoration: new InputDecoration(
                        icon: const Icon(CommunityIcons.home),
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
            ),
          )
        ],
      ),
    );
  }
}
