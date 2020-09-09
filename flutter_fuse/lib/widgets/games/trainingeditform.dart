import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/datetimeformfield.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

import '../blocs/singleteamprovider.dart';
import 'editformbase.dart';

class TrainingEditForm extends StatefulWidget {
  TrainingEditForm(
      {@required this.game, @required GlobalKey<TrainingEditFormState> key})
      : super(key: key);

  final Game game;

  @override
  TrainingEditFormState createState() {
    return new TrainingEditFormState();
  }
}

class TrainingEditFormState extends State<TrainingEditForm> with EditFormBase {
  ScrollController _scrollController = new ScrollController();
  GlobalKey<DateTimeFormFieldState> _endTimeKey =
      new GlobalKey<DateTimeFormFieldState>();
  bool autoValidate = false;
  GlobalKey<FormState> _formState = new GlobalKey<FormState>();
  DateTime _atDate;
  DateTime _atEnd;
  FocusNode _focusNodePlaceNotes = new FocusNode();
  FocusNode _focusNodeNotes = new FocusNode();
  FocusNode _focusNodeUniform = new FocusNode();
  GameBuilder builder;

  @override
  void save() {
    _formState.currentState.save();
  }

  @override
  void initState() {
    super.initState();
    _atDate = widget.game.sharedData.tzTime;
    _atEnd = widget.game.sharedData.tzEndTime;
    builder = widget.game.toBuilder();
  }

  void _updateTimes(Duration diff) {
    _endTimeKey.currentState
        .updateValue(_endTimeKey.currentState.value.subtract(diff));
  }

  void _showPlacesPicker() async {
    LocationAndPlace place = await MapData.instance.getPlaceAndLocation();
    if (place != null) {
      // Yay!
      setState(() {
        builder.sharedData.place.name = place.details.name;
        builder.sharedData.place.address = place.details.address;
        builder.sharedData.place.longitude = place.details.location.longitude;
        builder.sharedData.place.latitude = place.details.location.latitude;
        place.loc.then((Location location) {
          builder.sharedData.timezone = location.name;
        });
      });
    }
  }

  @override
  bool validate() {
    return _formState.currentState.validate();
  }

  @override
  GameBuilder get finalGameResult {
    _formState.currentState.save();
    // Add the date time and the time together.
    builder.sharedData.time = new TZDateTime(
            getLocation(widget.game.sharedData.timezone),
            _atDate.year,
            _atDate.month,
            _atDate.day,
            _atDate.hour,
            _atDate.minute)
        .millisecondsSinceEpoch;
    builder.arriveTime = widget.game.sharedData.time;
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
    builder.sharedData.endTime = _atEnd.millisecondsSinceEpoch;
    return builder;
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);
    print("${widget.game.toMap()}");
    return new Scrollbar(
      child: new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: new Form(
          key: _formState,
          autovalidate: autoValidate,
          child: new DropdownButtonHideUnderline(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SingleTeamProvider(
                  teamUid: builder.teamUid,
                  builder: (BuildContext context, SingleTeamBloc teamBloc) =>
                      SeasonFormField(
                    decoration: new InputDecoration(
                      icon: const Icon(CommunityIcons.calendarQuestion),
                      labelText: messages.season,
                    ),
                    initialValue: widget.game.seasonUid,
                    teamBloc: teamBloc,
                    onSaved: (String value) {
                      builder.seasonUid = value;
                    },
                  ),
                ),
                new DateTimeFormField(
                  labelText: Messages.of(context).gametime,
                  decoration: new InputDecoration(
                    icon: const Icon(Icons.calendar_today),
                  ),
                  initialValue: _atDate,
                  hideDate: false,
                  onFieldChanged: _updateTimes,
                  onSaved: (DateTime value) {
                    _atDate = value;
                  },
                ),
                new DateTimeFormField(
                  labelText: Messages.of(context).trainingend,
                  key: _endTimeKey,
                  decoration: new InputDecoration(
                    icon: const Icon(CommunityIcons.calendarRange),
                  ),
                  initialValue: _atEnd,
                  hideDate: false,
                  onSaved: (DateTime value) {
                    _atEnd = value;
                  },
                ),
                new ListTile(
                  onTap: _showPlacesPicker,
                  leading: const Icon(Icons.place),
                  title: new Text(widget.game.sharedData.place.name == null
                      ? messages.unknown
                      : widget.game.sharedData.place.name),
                  subtitle: new Text(
                      widget.game.sharedData.place.address == null
                          ? messages.unknown
                          : widget.game.sharedData.place.address),
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
                    initialValue: widget.game.sharedData.place.notes,
                    onSaved: (String value) {
                      builder.sharedData.place.notes = value;
                    },
                  ),
                ),
                new EnsureVisibleWhenFocused(
                  focusNode: _focusNodeUniform,
                  child: new TextFormField(
                    initialValue: widget.game.uniform,
                    decoration: new InputDecoration(
                        hintText: messages.uniformhint,
                        labelText: messages.uniform,
                        icon: const Icon(CommunityIcons.tshirtCrew)),
                    onSaved: (String value) {
                      builder.uniform = value;
                    },
                    focusNode: _focusNodeUniform,
                  ),
                ),
                new EnsureVisibleWhenFocused(
                  focusNode: _focusNodeNotes,
                  child: new TextFormField(
                    initialValue: widget.game.notes,
                    decoration: new InputDecoration(
                      hintText: messages.trainingnoteshint,
                      labelText: messages.trainingnotes,
                      icon: const Icon(Icons.note),
                    ),
                    focusNode: _focusNodeNotes,
                    onSaved: (String value) {
                      builder.notes = value;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
