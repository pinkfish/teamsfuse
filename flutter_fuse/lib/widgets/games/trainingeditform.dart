import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timezone/timezone.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../blocs/singleteamprovider.dart';
import '../form/datetimeformfield.dart';
import '../form/seasonformfield.dart';
import '../util/ensurevisiblewhenfocused.dart';
import 'editformbase.dart';
import '../form/placesformfield.dart';

///
/// Edit form to edit all the training stuff.
///
class TrainingEditForm extends StatefulWidget {
  /// Constructor.
  TrainingEditForm(
      {@required this.game, @required GlobalKey<TrainingEditFormState> key})
      : super(key: key);

  /// Game the training is for.
  final Game game;

  @override
  TrainingEditFormState createState() {
    return TrainingEditFormState();
  }
}

///
/// State of the traning data for the edit form.
///
class TrainingEditFormState extends State<TrainingEditForm> with EditFormBase {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<DateTimeFormFieldState> _endTimeKey =
      GlobalKey<DateTimeFormFieldState>();
  final Validations _validations = Validations();

  /// If the form should validate on every change or only a save.
  bool autoValidate = false;
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  DateTime _atDate;
  DateTime _atEnd;
  final FocusNode _focusNodePlaceNotes = FocusNode();
  final FocusNode _focusNodeNotes = FocusNode();
  final FocusNode _focusNodeUniform = FocusNode();
  GameBuilder _builder;

  @override
  void save() {
    _formState.currentState.save();
  }

  @override
  void initState() {
    super.initState();
    _atDate = widget.game.sharedData.tzTime;
    _atEnd = widget.game.sharedData.tzEndTime;
    _builder = widget.game.toBuilder();
  }

  void _updateTimes(Duration diff) {
    _endTimeKey.currentState
        .updateValue(_endTimeKey.currentState.value.subtract(diff));
  }

  @override
  bool validate() {
    if (_formState.currentState != null) {
      return _formState.currentState.validate();
    }
    return false;
  }

  @override
  GameBuilder get finalGameResult {
    _formState.currentState.save();
    // Add the date time and the time together.
    _builder.sharedData.time = TZDateTime(
            getLocation(widget.game.sharedData.timezone),
            _atDate.year,
            _atDate.month,
            _atDate.day,
            _atDate.hour,
            _atDate.minute)
        .toUtc();
    _builder.arrivalTime = widget.game.sharedData.time.toUtc();
    var end = _atEnd;
    if (_atEnd.millisecondsSinceEpoch < _atDate.millisecondsSinceEpoch) {
      end.add(Duration(days: 1));
    }
    _builder.sharedData.endTime = TZDateTime(
            getLocation(widget.game.sharedData.timezone),
            end.year,
            end.month,
            end.day,
            end.hour,
            end.minute)
        .toUtc();
    _builder.sharedData.endTime = _atEnd.toUtc();
    return _builder;
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
          autovalidateMode: autoValidate
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: DropdownButtonHideUnderline(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SingleTeamProvider(
                  teamUid: _builder.teamUid,
                  builder: (context, teamBloc) => SeasonFormField(
                    decoration: InputDecoration(
                      icon: const Icon(MdiIcons.calendarQuestion),
                      labelText: messages.season,
                    ),
                    initialValue: widget.game.seasonUid,
                    teamBloc: teamBloc,
                    onSaved: (value) {
                      _builder.seasonUid = value;
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
                    _builder.sharedData.place = loc.place.toBuilder();
                    _builder.sharedData.timezone = loc.timeZone;
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
                    initialValue: widget.game.sharedData.place.notes,
                    onSaved: (value) {
                      _builder.sharedData.place.notes = value;
                    },
                  ),
                ),
                EnsureVisibleWhenFocused(
                  focusNode: _focusNodeUniform,
                  child: TextFormField(
                    initialValue: widget.game.uniform,
                    decoration: InputDecoration(
                        hintText: messages.uniformhint,
                        labelText: messages.uniform,
                        icon: const Icon(MdiIcons.tshirtCrew)),
                    onSaved: (value) {
                      _builder.uniform = value;
                    },
                    focusNode: _focusNodeUniform,
                  ),
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
                    focusNode: _focusNodeNotes,
                    onSaved: (value) {
                      _builder.notes = value;
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
