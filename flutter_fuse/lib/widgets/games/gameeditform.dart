import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

import '../../screens/game/addopponent.dart';
import '../../services/map.dart';
import '../../services/messages.dart';
import '../../services/validations.dart';
import '../blocs/singleteamprovider.dart';
import '../form/datetimeformfield.dart';
import '../form/opponentformfield.dart';
import '../form/placesformfield.dart';
import '../form/seasonformfield.dart';
import '../form/switchformfield.dart';
import '../util/communityicons.dart';
import '../util/ensurevisiblewhenfocused.dart';
import 'editformbase.dart';

///
/// This form has all the stuff needed to edit the main parts
/// of the game.  Does not have the add game step flow.
///
class GameEditForm extends StatefulWidget {
  /// Constructor.
  GameEditForm(
      {@required this.game, @required GlobalKey<GameEditFormState> key})
      : super(key: key);

  /// The game to edit.
  final Game game;

  @override
  GameEditFormState createState() {
    return GameEditFormState();
  }
}

///
/// The edit form for the game.  Lets us access the internal of the game
/// while being edited.
///
class GameEditFormState extends State<GameEditForm> with EditFormBase {
  final GlobalKey<DateTimeFormFieldState> _arriveByKey =
      GlobalKey<DateTimeFormFieldState>();
  final GlobalKey<DateTimeFormFieldState> _atEndKEy =
      GlobalKey<DateTimeFormFieldState>();
  final GlobalKey<OpponentFormFieldState> _opponentState =
      GlobalKey<OpponentFormFieldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// If we should autovalidate the fiels in the form, or only on save.
  bool autovalidate = false;
  final Validations _validations = Validations();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNodeNotes = FocusNode();
  final FocusNode _focusNodePlaceNotes = FocusNode();
  final FocusNode _focusNodeUniform = FocusNode();
  DateTime _atDate;
  DateTime _atArrival;
  DateTime _atEnd;

  /// The builder for the game to be used externally.
  GameBuilder _builder;

  @override
  void save() {
    _formKey.currentState.save();
  }

  @override
  void initState() {
    super.initState();
    _builder = widget.game.toBuilder();
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
      _builder.sharedData.time = TZDateTime(
              getLocation(widget.game.sharedData.timezone),
              _atDate.year,
              _atDate.month,
              _atDate.day,
              _atDate.hour,
              _atDate.minute)
          .millisecondsSinceEpoch;
      // Move forward a day so it is in the next day.
      var arrival = _atArrival;
      if (_atArrival.millisecondsSinceEpoch < _atDate.millisecondsSinceEpoch) {
        arrival.add(Duration(days: 1));
      }
      _builder.arrivalTime = TZDateTime(
              getLocation(widget.game.sharedData.timezone),
              arrival.year,
              arrival.month,
              arrival.day,
              arrival.hour,
              arrival.minute)
          .toUtc();
      var end = _atEnd;
      if (_atEnd.millisecondsSinceEpoch < _atDate.millisecondsSinceEpoch) {
        end.add(Duration(days: 1));
      }
      var time = TZDateTime(getLocation(widget.game.sharedData.timezone),
              end.year, end.month, end.day, end.hour, end.minute)
          .toUtc();
      _builder.sharedData.endTime = time;
    }
    return _builder;
  }

  void _changeAtTime(Duration diff) {
    _arriveByKey.currentState
        .updateValue(_arriveByKey.currentState.value.subtract(diff));
    _atEndKEy.currentState
        .updateValue(_atEndKEy.currentState.value.subtract(diff));
  }

  void _openAddOpponentDialog() async {
    var save = await Navigator.of(context).push(MaterialPageRoute<String>(
      builder: (context) {
        return AddOpponent(widget.game.teamUid);
      },
      fullscreenDialog: true,
    ));

    if (save != null) {
      _opponentState.currentState.updateValue(save);
    }
  }

  @override
  Widget build(BuildContext context) {
    var teamBloc = BlocProvider.of<TeamBloc>(context);
    if (widget.game.teamUid == null ||
        teamBloc.state.getTeam(widget.game.teamUid) == null) {
      return Text('Invalid state');
    }
    var firstRow = <Widget>[];
    firstRow.add(
      Expanded(
        flex: 1,
        child: SingleTeamProvider(
          teamUid: _builder.teamUid,
          builder: (context, teambloc) => SeasonFormField(
            initialValue: widget.game.seasonUid,
            teamBloc: teambloc,
            onSaved: (value) {
              _builder.seasonUid = value;
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
        Expanded(
          flex: 1,
          child: SingleTeamProvider(
            teamUid: _builder.teamUid,
            builder: (context, teambloc) => OpponentFormField(
              teamBloc: teambloc,
              key: _opponentState,
              initialValue: _builder.opponentUid.isNotEmpty
                  ? OpponentFormField.none
                  : _builder.opponentUid,
              validator: (str) {
                return _validations.validateOpponent(context, str);
              },
              onFieldSubmitted: (value) {
                if (value == 'add') {
                  // Open up a picker to create an opponent.
                  _openAddOpponentDialog();
                }
              },
              onSaved: (value) {
                _builder.opponentUid = value;
              },
            ),
          ),
        ),
      );
    }

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: Form(
          key: _formKey,
          autovalidate: autovalidate,
          child: DropdownButtonHideUnderline(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: firstRow,
                ),
                DateTimeFormField(
                  labelText: Messages.of(context).gametime,
                  initialValue: _atDate,
                  hideDate: false,
                  onSaved: (value) {
                    _atDate = value;
                  },
                  onFieldChanged: _changeAtTime,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: DateTimeFormField(
                        key: _arriveByKey,
                        labelText: Messages.of(context).arriveat,
                        initialValue: _atArrival,
                        hideDate: true,
                        onSaved: (val) {
                          _atArrival = val;
                        },
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      flex: 4,
                      child: DateTimeFormField(
                        key: _atEndKEy,
                        labelText: Messages.of(context).gameend,
                        initialValue: _atEnd,
                        hideDate: true,
                        onSaved: (val) {
                          _atEnd = val;
                        },
                      ),
                    ),
                  ],
                ),
                PlacesFormField(
                  initialValue: LocationAndPlace.fromGame(
                      _builder.sharedData.place.build(),
                      _builder.sharedData.timezone),
                  labelText: Messages.of(context).selectplace,
                  decoration: const InputDecoration(icon: Icon(Icons.place)),
                  onSaved: (loc) {
                    print('Saved location $loc');
                    _builder.sharedData.place.name = loc.details.name;
                    _builder.sharedData.place.address = loc.details.address;
                    _builder.sharedData.place.placeId = loc.details.placeid;
                    _builder.sharedData.place.latitude =
                        loc.details.location.latitude;
                    _builder.sharedData.place.longitude =
                        loc.details.location.longitude;
                    loc.loc.then((location) {
                      _builder.sharedData.timezone = location.name;
                    });
                  },
                ),
                EnsureVisibleWhenFocused(
                  focusNode: _focusNodePlaceNotes,
                  child: TextFormField(
                    decoration: InputDecoration(
                      icon: const Icon(CommunityIcons.tshirtCrew),
                      hintText: Messages.of(context).placesnoteshint,
                      labelText: Messages.of(context).placesnotes,
                    ),
                    keyboardType: TextInputType.text,
                    focusNode: _focusNodePlaceNotes,
                    obscureText: false,
                    initialValue: _builder.sharedData.place.notes,
                    onSaved: (value) {
                      _builder.sharedData.place.notes = value;
                    },
                  ),
                ),
                EnsureVisibleWhenFocused(
                  focusNode: _focusNodeUniform,
                  child: TextFormField(
                    decoration: InputDecoration(
                      icon: const Icon(CommunityIcons.tshirtCrew),
                      hintText: Messages.of(context).uniformhint,
                      labelText: Messages.of(context).uniform,
                    ),
                    focusNode: _focusNodeUniform,
                    keyboardType: TextInputType.text,
                    obscureText: false,
                    initialValue: widget.game.uniform,
                    onSaved: (value) {
                      _builder.uniform = value;
                    },
                  ),
                ),
                EnsureVisibleWhenFocused(
                  focusNode: _focusNodeNotes,
                  child: TextFormField(
                    decoration: const InputDecoration(
                        icon: Icon(Icons.note),
                        hintText: 'Game notes',
                        labelText: 'Game notes'),
                    keyboardType: TextInputType.text,
                    focusNode: _focusNodeNotes,
                    obscureText: false,
                    initialValue: widget.game.notes,
                    onSaved: (value) {
                      _builder.notes = value;
                    },
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SwitchFormField(
                        icon: CommunityIcons.home,
                        label: Messages.of(context).homeaway,
                        initialValue: widget.game.homegame,
                        onSaved: (value) {
                          if (value) {
                            _builder.sharedData.officialResult
                                .homeTeamLeagueUid = _builder.teamUid;
                            _builder.sharedData.officialResult
                                .awayTeamLeagueUid = _builder.opponentUid;
                          } else {
                            _builder.sharedData.officialResult
                                .homeTeamLeagueUid = _builder.opponentUid;
                            _builder.sharedData.officialResult
                                .awayTeamLeagueUid = _builder.teamUid;
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
