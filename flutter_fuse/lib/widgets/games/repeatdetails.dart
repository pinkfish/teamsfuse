import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

import '../../services/messages.dart';
import '../form/datetimeformfield.dart';

///
/// Widget to show the repating details for a summary.
///
class RepeatDetailsWidget extends StatefulWidget {
  /// Constructor.
  RepeatDetailsWidget(this.startTime, this.repeat,
      {GlobalKey<RepeatDetailsState> key})
      : super(key: key);

  /// Start time.
  final TZDateTime startTime;

  /// Repeat reasons.
  final RepeatData repeat;

  @override
  RepeatDetailsState createState() {
    return RepeatDetailsState();
  }
}

///
/// The state exposed to use with forms.
///
class RepeatDetailsState extends State<RepeatDetailsWidget> {
  final ScrollController _scrollController = ScrollController();

  /// If the values should be always validated or only if the data is saved.
  bool autoValidate = false;
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  RepeatData _updatedRepeat;

  @override
  void initState() {
    _updatedRepeat = widget.repeat.rebuild((b) => b
      ..endRepeat = widget.startTime.add(const Duration(days: 7))
      ..dayRepeats[widget.startTime.weekday - 1] = true);
    super.initState();
    print('initState $_updatedRepeat.endRepeat');
  }

  /// Validates the values in the form.
  bool validate() {
    return _formState.currentState.validate();
  }

  /// Saves the values in the form out.
  RepeatData save() {
    _formState.currentState.save();
    return _updatedRepeat;
  }

  List<DropdownMenuItem<RepeatPeriod>> _buildRepeatIntervalItems(
      BuildContext context) {
    var ret = <DropdownMenuItem<RepeatPeriod>>[];
    ret.add(DropdownMenuItem<RepeatPeriod>(
      child: Text(Messages.of(context).noneperiod),
      value: RepeatPeriod.None,
    ));

    ret.add(DropdownMenuItem<RepeatPeriod>(
      child: Text(Messages.of(context).weeklyperiod),
      value: RepeatPeriod.Weekly,
    ));

    ret.add(DropdownMenuItem<RepeatPeriod>(
      child: Text(Messages.of(context).monthlyperiod),
      value: RepeatPeriod.Monthly,
    ));

    return ret;
  }

  List<Widget> _buildItems() {
    var messages = Messages.of(context);
    var ret = <Widget>[];
    ret.add(
      DropdownButton<RepeatPeriod>(
        hint: Text(messages.repeat),
        items: _buildRepeatIntervalItems(context),
        value: _updatedRepeat.period,
        onChanged: (val) {
          setState(() {
            _updatedRepeat = _updatedRepeat.rebuild((b) => b..period = val);
          });
        },
      ),
    );
    print('$_updatedRepeat.endRepeat');
    switch (_updatedRepeat.period) {
      case RepeatPeriod.Weekly:
        ret.add(Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            DropdownButton<bool>(
              value: _updatedRepeat.repeatUntil,
              items: <DropdownMenuItem<bool>>[
                DropdownMenuItem<bool>(
                  child: Text(
                    messages.repeat,
                  ),
                  value: true,
                ),
                DropdownMenuItem<bool>(
                  child: Text(
                    messages.until,
                  ),
                  value: false,
                ),
              ],
              onChanged: (val) => _updatedRepeat =
                  _updatedRepeat.rebuild((b) => b.repeatUntil = val),
            ),
            _updatedRepeat.repeatUntil
                ? Container(
                    constraints: BoxConstraints.loose(
                      Size.fromWidth(20.0),
                    ),
                    margin: EdgeInsets.only(left: 10.0),
                    child: TextFormField(
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      onSaved: (val) {
                        _updatedRepeat = _updatedRepeat
                            .rebuild((b) => b.repeatInterval = int.parse(val));
                      },
                    ),
                  )
                : Flexible(
                    flex: 1,
                    child: DateTimeFormField(
                      initialValue: _updatedRepeat.endRepeat,
                      hideTime: true,
                      onSaved: (tim) {
                        _updatedRepeat =
                            _updatedRepeat.rebuild((b) => b.endRepeat = tim);
                      },
                    ),
                  ),
          ],
        ));
        var days = MaterialLocalizations.of(context).narrowWeekdays;
        var first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
        var daysWidgets = <Widget>[];
        print('$days');
        daysWidgets.add(const Icon(Icons.calendar_today));
        for (var i = first; i < first + days.length; i++) {
          var pos = i % days.length;
          daysWidgets.add(
            Container(
              margin: EdgeInsets.only(left: 10.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _updatedRepeat = _updatedRepeat.rebuild((b) =>
                        b..dayRepeats[pos] = !_updatedRepeat.dayRepeats[pos]);
                  });
                },
                child: Chip(
                  backgroundColor: _updatedRepeat.dayRepeats[pos]
                      ? Theme.of(context).accentColor
                      : Theme.of(context).disabledColor,
                  label: Text(days[pos]),
                ),
              ),
            ),
          );
        }
        ret.add(
          Container(
            margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: daysWidgets,
            ),
          ),
        );
        break;
      case RepeatPeriod.Monthly:
        ret.add(
          TextFormField(
            initialValue: '1',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: messages.repeat,
              icon: const Icon(Icons.repeat),
            ),
            onSaved: (val) {
              _updatedRepeat = _updatedRepeat
                  .rebuild((b) => b..repeatInterval = int.parse(val));
            },
          ),
        );
        break;
      case RepeatPeriod.None:
        break;
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
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
              children: _buildItems(),
            ),
          ),
        ),
      ),
    );
  }
}
