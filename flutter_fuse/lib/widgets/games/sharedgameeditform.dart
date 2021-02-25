import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timezone/timezone.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../form/datetimeformfield.dart';
import '../form/placesformfield.dart';
import '../util/ensurevisiblewhenfocused.dart';

///
/// This form has all the stuff needed to edit the main parts
/// of the game.  Does not have the add game step flow.
///
class SharedGameEditForm extends StatefulWidget {
  /// Constructor.
  SharedGameEditForm(
      {@required this.game, @required GlobalKey<SharedGameEditFormState> key})
      : super(key: key);

  /// The game data to edit.
  final GameSharedData game;

  @override
  SharedGameEditFormState createState() {
    return SharedGameEditFormState();
  }
}

///
/// The state associated with the shared game editing form.
///
class SharedGameEditFormState extends State<SharedGameEditForm> {
  final GlobalKey<DateTimeFormFieldState> _arriveByKey =
      GlobalKey<DateTimeFormFieldState>();
  final GlobalKey<DateTimeFormFieldState> _atEndKEy =
      GlobalKey<DateTimeFormFieldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Validations _validations = Validations();

  /// If the form should validate on every change, or only on a save.
  bool autovalidate = false;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNodePlaceNotes = FocusNode();
  DateTime _atDate;
  DateTime _atEnd;
  GameSharedDataBuilder _builder;

  /// Save the form, updating the builder.
  void save() {
    _formKey.currentState.save();
  }

  @override
  void initState() {
    super.initState();
    _builder = widget.game.toBuilder();
    _atDate = widget.game.tzTime;
    _atEnd = widget.game.tzEndTime;
  }

  /// Validates the form is all co0rrect.
  bool validate() {
    if (_formKey.currentState == null) {
      return false;
    }
    return _formKey.currentState.validate();
  }

  /// Gets the final game result based on the edits.
  GameSharedDataBuilder get finalGameResult {
    if (!_formKey.currentState.validate()) {
      autovalidate = true;
      return null;
    } else {
      _formKey.currentState.save();
      // Add the date time and the time together.
      _builder.time = TZDateTime(getLocation(_builder.timezone), _atDate.year,
              _atDate.month, _atDate.day, _atDate.hour, _atDate.minute)
          .toUtc();
      // Move forward a day so it is in the next day.
      var end = _atEnd;
      if (_atEnd.millisecondsSinceEpoch < _atDate.millisecondsSinceEpoch) {
        end.add(Duration(days: 1));
      }
      _builder.endTime = TZDateTime(getLocation(_builder.timezone), end.year,
              end.month, end.day, end.hour, end.minute)
          .toUtc();
    }
    return _builder;
  }

  void _changeAtTime(Duration diff) {
    _arriveByKey.currentState
        .updateValue(_arriveByKey.currentState.value.subtract(diff));
    _atEndKEy.currentState
        .updateValue(_atEndKEy.currentState.value.subtract(diff));
  }

  @override
  Widget build(BuildContext context) {
    var firstRow = <Widget>[];

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
                  initialValue:
                      PlaceAndTimezone(widget.game.place, widget.game.timezone),
                  labelText: Messages.of(context).selectplace,
                  decoration: const InputDecoration(icon: Icon(Icons.place)),
                  onSaved: (loc) {
                    _builder.place = loc.place.toBuilder();
                    _builder.timezone = loc.timeZone;
                  },
                  validator: (place) =>
                      _validations.validateGamePlace(context, place.place),
                ),
                EnsureVisibleWhenFocused(
                  focusNode: _focusNodePlaceNotes,
                  child: TextFormField(
                    decoration: InputDecoration(
                      icon: const Icon(MdiIcons.tshirtCrew),
                      hintText: Messages.of(context).placesnoteshint,
                      labelText: Messages.of(context).placesnotes,
                    ),
                    keyboardType: TextInputType.text,
                    focusNode: _focusNodePlaceNotes,
                    obscureText: false,
                    initialValue: _builder.place.notes,
                    onSaved: (value) {
                      _builder.place.notes = value;
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
