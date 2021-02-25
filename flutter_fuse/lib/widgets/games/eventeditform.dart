import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timezone/timezone.dart';

import '../form/placesformfield.dart';
import '../../services/messages.dart';
import '../blocs/singleteamprovider.dart';
import '../form/datetimeformfield.dart';
import '../form/seasonformfield.dart';
import '../util/ensurevisiblewhenfocused.dart';
import 'editformbase.dart';

///
/// The edit form to let you edit the event.
///
class EventEditForm extends StatefulWidget {
  /// Constrcutor.
  EventEditForm(
      {@required this.game, @required GlobalKey<EventEditFormState> key})
      : super(key: key);

  /// The game to edit.
  final Game game;

  @override
  EventEditFormState createState() {
    return EventEditFormState();
  }
}

///
/// The state for the form allowing editing.
///
class EventEditFormState extends State<EventEditForm> with EditFormBase {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<DateTimeFormFieldState> _endTimeKey =
      GlobalKey<DateTimeFormFieldState>();

  /// If we should automatically validate the form fields, or only when saved.
  bool autoValidate = false;
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  DateTime _atDate;
  DateTime _atEnd;
  String _timezone;
  final FocusNode _focusNodeNotes = FocusNode();

  /// The builder for the game created as part of the save process.
  GameBuilder builder;

  @override
  void save() {}

  @override
  void initState() {
    super.initState();
    builder = widget.game.toBuilder();
    _atDate = widget.game.sharedData.tzTime;
    _atEnd = widget.game.sharedData.tzEndTime;
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
    builder.sharedData.time = TZDateTime(getLocation(_timezone), _atDate.year,
            _atDate.month, _atDate.day, _atDate.hour, _atDate.minute)
        .toUtc();
    builder.arrivalTime = widget.game.sharedData.time;
    var end = _atEnd.toUtc();
    if (_atEnd.millisecondsSinceEpoch < _atDate.millisecondsSinceEpoch) {
      end.add(Duration(days: 1));
    }
    builder.sharedData.endTime = TZDateTime(getLocation(_timezone), end.year,
            end.month, end.day, end.hour, end.minute)
        .toUtc();
    builder.sharedData.endTime = _atEnd.toUtc();
    builder.sharedData.timezone = _timezone;
    return builder;
  }

  void _updateTimes(Duration diff) {
    _endTimeKey.currentState
        .updateValue(_endTimeKey.currentState.value.subtract(diff));
  }

  @override
  Widget build(BuildContext context) {
    var messages = Messages.of(context);
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: Form(
          key: _formState,
          autovalidate: autoValidate,
          child: DropdownButtonHideUnderline(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SingleTeamProvider(
                  teamUid: builder.teamUid,
                  builder: (context, teamBloc) => SeasonFormField(
                    decoration: InputDecoration(
                      icon: const Icon(MdiIcons.calendarQuestion),
                      labelText: messages.season,
                    ),
                    initialValue: widget.game.seasonUid,
                    teamBloc: teamBloc,
                    onSaved: (value) {
                      builder.seasonUid = value;
                    },
                  ),
                ),
                DateTimeFormField(
                  labelText: Messages.of(context).gametime,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.calendar_today),
                  ),
                  initialValue: _atDate,
                  hideDate: false,
                  onFieldChanged: _updateTimes,
                  onSaved: (value) {
                    _atDate = value;
                  },
                ),
                DateTimeFormField(
                  labelText: Messages.of(context).trainingend,
                  key: _endTimeKey,
                  decoration: InputDecoration(
                    icon: const Icon(MdiIcons.calendarRange),
                  ),
                  initialValue: _atEnd,
                  hideDate: false,
                  onSaved: (value) {
                    _atEnd = value;
                  },
                ),
                PlacesFormField(
                  initialValue: PlaceAndTimezone(widget.game.sharedData.place,
                      widget.game.sharedData.timezone),
                  labelText: Messages.of(context).selectplace,
                  decoration: const InputDecoration(icon: Icon(Icons.place)),
                  onSaved: (loc) {
                    builder.sharedData.place = loc.place.toBuilder();
                    builder.sharedData.timezone = loc.timeZone;
                  },
                ),
                EnsureVisibleWhenFocused(
                  focusNode: _focusNodeNotes,
                  child: TextFormField(
                    initialValue: widget.game.notes,
                    decoration: InputDecoration(
                      hintText: messages.trainingnoteshint,
                      labelText: messages.trainingnotes,
                      icon: const Icon(Icons.note),
                    ),
                    onSaved: (value) {
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
