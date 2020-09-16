import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/datetimeformfield.dart';
import 'package:flutter_fuse/widgets/form/placesformfield.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

// This form has all the stuff needed to edit the main parts
// of the game.  Does not have the add game step flow.
class SharedGameEditForm extends StatefulWidget {
  SharedGameEditForm(
      {@required this.game, @required GlobalKey<SharedGameEditFormState> key})
      : super(key: key);

  final GameSharedData game;

  @override
  SharedGameEditFormState createState() {
    return SharedGameEditFormState();
  }
}

class SharedGameEditFormState extends State<SharedGameEditForm> {
  final GlobalKey<DateTimeFormFieldState> _arriveByKey =
      GlobalKey<DateTimeFormFieldState>();
  final GlobalKey<DateTimeFormFieldState> _atEndKEy =
      GlobalKey<DateTimeFormFieldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool autovalidate = false;
  ScrollController _scrollController = ScrollController();
  FocusNode _focusNodePlaceNotes = FocusNode();
  DateTime _atDate;
  DateTime _atEnd;
  GameSharedDataBuilder builder;

  void save() {
    _formKey.currentState.save();
  }

  @override
  void initState() {
    super.initState();
    builder = widget.game.toBuilder();
    _atDate = widget.game.tzTime;
    _atEnd = widget.game.tzEndTime;
  }

  bool validate() {
    if (_formKey.currentState == null) {
      return false;
    }
    return _formKey.currentState.validate();
  }

  GameSharedDataBuilder get finalGameResult {
    if (!_formKey.currentState.validate()) {
      autovalidate = true;
      return null;
    } else {
      _formKey.currentState.save();
      // Add the date time and the time together.
      builder.time = TZDateTime(getLocation(builder.timezone), _atDate.year,
              _atDate.month, _atDate.day, _atDate.hour, _atDate.minute)
          .millisecondsSinceEpoch;
      // Move forward a day so it is in the next day.
      DateTime end = _atEnd;
      if (_atEnd.millisecondsSinceEpoch < _atDate.millisecondsSinceEpoch) {
        end.add(Duration(days: 1));
      }
      builder.endTime = TZDateTime(getLocation(builder.timezone), end.year,
              end.month, end.day, end.hour, end.minute)
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

  @override
  Widget build(BuildContext context) {
    List<Widget> firstRow = <Widget>[];

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
                  onSaved: (DateTime value) {
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
                PlacesFormField(
                  initialValue: LocationAndPlace.fromGame(
                      builder.place.build(), builder.timezone),
                  labelText: Messages.of(context).selectplace,
                  decoration:
                      const InputDecoration(icon: const Icon(Icons.place)),
                  onSaved: (LocationAndPlace loc) {
                    print('Saved location $loc');
                    builder.place.name = loc.details.name;
                    builder.place.address = loc.details.address;
                    builder.place.placeId = loc.details.placeid;
                    builder.place.latitude = loc.details.location.latitude;
                    builder.place.longitude = loc.details.location.longitude;
                    loc.loc.then((Location location) {
                      builder.timezone = location.name;
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
                    initialValue: builder.place.notes,
                    onSaved: (String value) {
                      builder.place.notes = value;
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
