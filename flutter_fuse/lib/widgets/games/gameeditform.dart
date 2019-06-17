import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/screens/game/addopponent.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/datetimeformfield.dart';
import 'package:flutter_fuse/widgets/form/opponentformfield.dart';
import 'package:flutter_fuse/widgets/form/placesformfield.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

import '../blocs/singleteamprovider.dart';
import 'editformbase.dart';

// This form has all the stuff needed to edit the main parts
// of the game.  Does not have the add game step flow.
class GameEditForm extends StatefulWidget {
  GameEditForm(
      {@required this.game, @required GlobalKey<GameEditFormState> key})
      : super(key: key);

  final Game game;

  @override
  GameEditFormState createState() {
    return new GameEditFormState();
  }
}

class GameEditFormState extends State<GameEditForm> with EditFormBase {
  GameEditFormState();

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
  FocusNode _focusNodeNotes = new FocusNode();
  FocusNode _focusNodePlaceNotes = new FocusNode();
  FocusNode _focusNodeUniform = new FocusNode();
  DateTime _atDate;
  DateTime _atArrival;
  DateTime _atEnd;
  GameBuilder builder;

  @override
  void save() {
    _formKey.currentState.save();
  }

  @override
  void initState() {
    super.initState();
    builder = widget.game.toBuilder();
    _atArrival = widget.game.tzArriveTime;
    _atDate = widget.game.sharedData.tzTime;
    _atEnd = widget.game.sharedData.tzEndTime;
  }

  @override
  bool validate() {
    if (_formKey.currentState == null) {
      return false;
    }
    return _formKey.currentState.validate();
  }

  @override
  GameBuilder get finalGameResult {
    if (!_formKey.currentState.validate()) {
      autovalidate = true;
      return null;
    } else {
      _formKey.currentState.save();
      // Add the date time and the time together.
      builder.sharedData.time = new TZDateTime(
              getLocation(widget.game.sharedData.timezone),
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
      builder.arriveTime = new TZDateTime(
              getLocation(widget.game.sharedData.timezone),
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
      builder.sharedData.endTime = new TZDateTime(
              getLocation(widget.game.sharedData.timezone),
              end.year,
              end.month,
              end.day,
              end.hour,
              end.minute)
          .millisecondsSinceEpoch;
    }
    return builder;
  }

  void _changeAtTime(Duration diff) {
    _arriveByKey.currentState
        .updateValue(_arriveByKey.currentState.value.subtract(diff));
    _atEndKEy.currentState
        .updateValue(_atEndKEy.currentState.value.subtract(diff));
  }

  void _openAddOpponentDialog() async {
    String save =
        await Navigator.of(context).push(new MaterialPageRoute<String>(
      builder: (BuildContext context) {
        return new AddOpponent(widget.game.teamUid);
      },
      fullscreenDialog: true,
    ));

    if (save != null) {
      _opponentState.currentState.updateValue(save);
    }
  }

  @override
  Widget build(BuildContext context) {
    TeamBloc teamBloc = BlocProvider.of<TeamBloc>(context);
    if (widget.game.teamUid == null ||
        teamBloc.currentState.getTeam(widget.game.teamUid) == null) {
      return new Text('Invalid state');
    }
    List<Widget> firstRow = <Widget>[];
    firstRow.add(
      new Expanded(
        flex: 1,
        child: SingleTeamProvider(
          teamUid: builder.teamUid,
          builder: (BuildContext context, SingleTeamBloc teambloc) =>
              SeasonFormField(
                initialValue: widget.game.seasonUid,
                teamBloc: teambloc,
                onSaved: (String value) {
                  builder.seasonUid = value;
                },
              ),
        ),
      ),
    );
    if (widget.game.sharedData.type == EventType.Game) {
      firstRow.add(
        const SizedBox(width: 12.0),
      );
      firstRow.add(
        new Expanded(
          flex: 1,
          child: SingleTeamProvider(
            teamUid: builder.teamUid,
            builder: (BuildContext context, SingleTeamBloc teambloc) =>
                OpponentFormField(
                  teamBloc: teambloc,
                  key: _opponentState,
                  initialValue: builder.opponentUids.length == 0
                      ? 'none'
                      : builder.opponentUids[0],
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
                    builder.opponentUids.addAll(<String>[value]);
                  },
                ),
          ),
        ),
      );
    }

    return new Scrollbar(
      child: new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: new Form(
          key: _formKey,
          autovalidate: autovalidate,
          child: new DropdownButtonHideUnderline(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: firstRow,
                ),
                new DateTimeFormField(
                  labelText: Messages.of(context).gametime,
                  initialValue: _atDate,
                  hideDate: false,
                  onSaved: (DateTime value) {
                    _atDate = value;
                  },
                  onFieldChanged: _changeAtTime,
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
                new PlacesFormField(
                  initialValue: new LocationAndPlace.fromGame(
                      builder.sharedData.place.build(),
                      builder.sharedData.timezone),
                  labelText: Messages.of(context).selectplace,
                  decoration:
                      const InputDecoration(icon: const Icon(Icons.place)),
                  onSaved: (LocationAndPlace loc) {
                    print('Saved location $loc');
                    builder.sharedData.place.name = loc.details.name;
                    builder.sharedData.place.address = loc.details.address;
                    builder.sharedData.place.placeId = loc.details.placeid;
                    builder.sharedData.place.latitude =
                        loc.details.location.latitude;
                    builder.sharedData.place.longitude =
                        loc.details.location.longitude;
                    loc.loc.then((Location location) {
                      builder.sharedData.timezone = location.name;
                    });
                  },
                ),
                new EnsureVisibleWhenFocused(
                  focusNode: _focusNodePlaceNotes,
                  child: new TextFormField(
                    decoration: new InputDecoration(
                      icon: const Icon(CommunityIcons.tshirtCrew),
                      hintText: Messages.of(context).placesnoteshint,
                      labelText: Messages.of(context).placesnotes,
                    ),
                    keyboardType: TextInputType.text,
                    focusNode: _focusNodePlaceNotes,
                    obscureText: false,
                    initialValue: builder.sharedData.place.notes,
                    onSaved: (String value) {
                      builder.sharedData.place.notes = value;
                    },
                  ),
                ),
                new EnsureVisibleWhenFocused(
                  focusNode: _focusNodeUniform,
                  child: new TextFormField(
                    decoration: new InputDecoration(
                      icon: const Icon(CommunityIcons.tshirtCrew),
                      hintText: Messages.of(context).uniformhint,
                      labelText: Messages.of(context).uniform,
                    ),
                    focusNode: _focusNodeUniform,
                    keyboardType: TextInputType.text,
                    obscureText: false,
                    initialValue: widget.game.uniform,
                    onSaved: (String value) {
                      builder.uniform = value;
                    },
                  ),
                ),
                new EnsureVisibleWhenFocused(
                  focusNode: _focusNodeNotes,
                  child: new TextFormField(
                    decoration: const InputDecoration(
                        icon: const Icon(Icons.note),
                        hintText: 'Game notes',
                        labelText: 'Game notes'),
                    keyboardType: TextInputType.text,
                    focusNode: _focusNodeNotes,
                    obscureText: false,
                    initialValue: widget.game.notes,
                    onSaved: (String value) {
                      builder.notes = value;
                    },
                  ),
                ),
                new Row(
                  children: <Widget>[
                    new Expanded(
                      flex: 1,
                      child: new SwitchFormField(
                        icon: CommunityIcons.home,
                        label: Messages.of(context).homeaway,
                        initialValue: widget.game.homegame,
                        onSaved: (bool value) {
                          if (value) {
                            builder.sharedData.officialResults
                                .homeTeamLeagueUid = builder.teamUid;
                            builder.sharedData.officialResults
                                .awayTeamLeagueUid = builder.opponentUids[0];
                          } else {
                            builder.sharedData.officialResults
                                .homeTeamLeagueUid = builder.opponentUids[0];
                            builder.sharedData.officialResults
                                .awayTeamLeagueUid = builder.teamUid;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
