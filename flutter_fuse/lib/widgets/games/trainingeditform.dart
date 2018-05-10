import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/form/datetimeformfield.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:timezone/timezone.dart';
import 'editformbase.dart';

class TrainingEditForm extends StatefulWidget {
  final Game game;

  TrainingEditForm(
      {@required Game game, @required GlobalKey<TrainingEditFormState> key})
      : this.game = game,
        super(key: key);

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

  void save() {}

  @override
  void initState() {
    super.initState();
    _atDate = widget.game.tzTime;
    _atEnd = widget.game.tzEndTime;
  }

  void _updateTimes(Duration diff) {
    _endTimeKey.currentState
        .setValue(_endTimeKey.currentState.value.subtract(diff));
  }

  void _showPlacesPicker() async {
    LocationAndPlace place = await MapData.instance.getPlaceAndLocation();
    if (place != null) {
      // Yay!
      setState(() {
        widget.game.place.name = place.details.name;
        widget.game.place.address = place.details.address;
        widget.game.place.longitude = place.details.location.longitude;
        widget.game.place.latitude = place.details.location.latitude;
        place.loc.then((Location location) {
          widget.game.timezone = location.name;
        });
      });
    }
  }

  bool validate() {
    return _formState.currentState.validate();
  }

  Game get finalGameResult {
    _formState.currentState.save();
    // Add the date time and the time together.
    widget.game.time = new TZDateTime(
            getLocation(widget.game.timezone),
            _atDate.year,
            _atDate.month,
            _atDate.day,
            _atDate.hour,
            _atDate.minute)
        .millisecondsSinceEpoch;
    widget.game.arriveTime = widget.game.time;
    DateTime end = _atEnd;
    if (_atEnd.millisecondsSinceEpoch < _atDate.millisecondsSinceEpoch) {
      end.add(new Duration(days: 1));
    }
    widget.game.endTime = new TZDateTime(getLocation(widget.game.timezone),
            end.year, end.month, end.day, end.hour, end.minute)
        .millisecondsSinceEpoch;
    widget.game.endTime = _atEnd.millisecondsSinceEpoch;
    return widget.game;
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);
    print("${widget.game.toJSON()}");
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
                new SeasonFormField(
                  decoration: new InputDecoration(
                    icon: const Icon(CommunityIcons.calendarquestion),
                    labelText: messages.season,
                  ),
                  initialValue: widget.game.seasonUid,
                  teamUid: widget.game.teamUid,
                  onSaved: (String value) {
                    widget.game.seasonUid = value;
                  },
                ),
                new DateTimeFormField(
                  labelText: Messages.of(context).gametime,
                  decoration: new InputDecoration(
                    icon: const Icon(Icons.calendar_today),
                  ),
                  initialValue: _atDate,
                  hideDate: false,
                  onFieldChanged: _updateTimes,
                  onSaved: (TZDateTime value) {
                    _atDate = value;
                  },
                ),
                new DateTimeFormField(
                  labelText: Messages.of(context).trainingend,
                  key: _endTimeKey,
                  decoration: new InputDecoration(
                    icon: const Icon(CommunityIcons.calendarrange),
                  ),
                  initialValue: _atEnd,
                  hideDate: false,
                  onSaved: (TZDateTime value) {
                    _atEnd = value;
                  },
                ),
                new ListTile(
                  onTap: _showPlacesPicker,
                  leading: const Icon(Icons.place),
                  title: new Text(widget.game.place.name == null
                      ? messages.unknown
                      : widget.game.place.name),
                  subtitle: new Text(widget.game.place.address == null
                      ? messages.unknown
                      : widget.game.place.address),
                ),
                new TextFormField(
                  initialValue: widget.game.notes,
                  decoration: new InputDecoration(
                    hintText: messages.trainingnoteshint,
                    labelText: messages.trainingnotes,
                    icon: const Icon(Icons.note),
                  ),
                  onSaved: (String value) {
                    widget.game.notes = value;
                  },
                ),
                new TextFormField(
                  initialValue: widget.game.uniform,
                  decoration: new InputDecoration(
                      hintText: messages.uniformhint,
                      labelText: messages.uniform,
                      icon: const Icon(CommunityIcons.tshirtcrew)),
                  onSaved: (String value) {
                    widget.game.uniform = value;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
