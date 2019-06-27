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

class EventEditForm extends StatefulWidget {
  EventEditForm(
      {@required this.game, @required GlobalKey<EventEditFormState> key})
      : super(key: key);

  final Game game;

  @override
  EventEditFormState createState() {
    return new EventEditFormState();
  }
}

class EventEditFormState extends State<EventEditForm> with EditFormBase {
  ScrollController _scrollController = new ScrollController();
  GlobalKey<DateTimeFormFieldState> _endTimeKey =
      new GlobalKey<DateTimeFormFieldState>();
  bool autoValidate = false;
  GlobalKey<FormState> _formState = new GlobalKey<FormState>();
  DateTime _atDate;
  DateTime _atEnd;
  GamePlaceBuilder _place;
  String _timezone;
  FocusNode _focusNodeNotes = new FocusNode();
  GameBuilder builder;

  @override
  void save() {}

  @override
  void initState() {
    super.initState();
    builder = widget.game.toBuilder();
    _atDate = widget.game.sharedData.tzTime;
    _atEnd = widget.game.sharedData.tzEndTime;
    _place = widget.game.sharedData.place.toBuilder();
    _timezone = local.name;
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
            getLocation(_timezone),
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
    builder.sharedData.endTime = new TZDateTime(getLocation(_timezone),
            end.year, end.month, end.day, end.hour, end.minute)
        .millisecondsSinceEpoch;
    builder.sharedData.endTime = _atEnd.millisecondsSinceEpoch;
    builder.sharedData.place = _place;
    builder.sharedData.timezone = _timezone;
    return builder;
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
        _place.name = place.details.name;
        _place.address = place.details.address;
        _place.longitude = place.details.location.longitude;
        _place.latitude = place.details.location.latitude;
        place.loc.then((Location location) {
          _timezone = location.name;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);
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
                  title: new Text(_place.name ?? messages.unknown),
                  subtitle: new Text(_place.address ?? messages.unknown),
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
