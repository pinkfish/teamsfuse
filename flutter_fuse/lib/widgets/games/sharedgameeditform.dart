import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/form/datetimeformfield.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:flutter_fuse/widgets/form/placesformfield.dart';

// This form has all the stuff needed to edit the main parts
// of the game.  Does not have the add game step flow.
class SharedGameEditForm extends StatefulWidget {
  SharedGameEditForm(
      {@required this.game, @required GlobalKey<SharedGameEditFormState> key})
      : super(key: key);

  final GameSharedData game;

  @override
  SharedGameEditFormState createState() {
    return new SharedGameEditFormState();
  }
}

class SharedGameEditFormState extends State<SharedGameEditForm> {
  final GlobalKey<DateTimeFormFieldState> _arriveByKey =
      new GlobalKey<DateTimeFormFieldState>();
  final GlobalKey<DateTimeFormFieldState> _atEndKEy =
      new GlobalKey<DateTimeFormFieldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool autovalidate = false;
  ScrollController _scrollController = new ScrollController();
  FocusNode _focusNodePlaceNotes = new FocusNode();
  DateTime _atDate;
  DateTime _atEnd;

  void save() {
    _formKey.currentState.save();
  }

  @override
  void initState() {
    super.initState();
    _atDate = widget.game.tzTime;
    _atEnd = widget.game.tzEndTime;
  }

  bool validate() {
    if (_formKey.currentState == null) {
      return false;
    }
    return _formKey.currentState.validate();
  }

  GameSharedData get finalGameResult {
    if (!_formKey.currentState.validate()) {
      autovalidate = true;
      return null;
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
      DateTime end = _atEnd;
      if (_atEnd.millisecondsSinceEpoch < _atDate.millisecondsSinceEpoch) {
        end.add(new Duration(days: 1));
      }
      widget.game.endTime = new TZDateTime(getLocation(widget.game.timezone),
              end.year, end.month, end.day, end.hour, end.minute)
          .millisecondsSinceEpoch;
    }
    return widget.game;
  }

  void _changeAtTime(Duration diff) {
    _arriveByKey.currentState
        .updateValue(_arriveByKey.currentState.value.subtract(diff));
    _atEndKEy.currentState
        .updateValue(_atEndKEy.currentState.value.subtract(diff));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> firstRow = <Widget>[];

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
                      widget.game.place, widget.game.timezone),
                  labelText: Messages.of(context).selectplace,
                  decoration:
                      const InputDecoration(icon: const Icon(Icons.place)),
                  onSaved: (LocationAndPlace loc) {
                    print('Saved location $loc');
                    widget.game.place.name = loc.details.name;
                    widget.game.place.address = loc.details.address;
                    widget.game.place.placeId = loc.details.placeid;
                    widget.game.place.latitude = loc.details.location.latitude;
                    widget.game.place.longitude =
                        loc.details.location.longitude;
                    loc.loc.then((Location location) {
                      widget.game.timezone = location.name;
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
                    initialValue: widget.game.place.notes,
                    onSaved: (String value) {
                      widget.game.place.notes = value;
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
