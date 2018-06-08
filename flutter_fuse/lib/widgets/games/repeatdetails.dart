import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/datetimeformfield.dart';
import 'package:timezone/timezone.dart';

enum RepeatPeriod { None, Weekly, Monthly }

class RepeatData {
  RepeatPeriod period;
  num repeatInterval = 1;
  bool repeatUntil = false;
  TZDateTime endRepeat;
  List<bool> dayRepeats = [false, false, false, false, false, false, false];
}

class RepeatDetailsWidget extends StatefulWidget {
  final TZDateTime startTime;
  final RepeatData repeat;

  RepeatDetailsWidget(this.startTime, this.repeat,
      {GlobalKey<RepeatDetailsState> key})
      : super(key: key);

  @override
  RepeatDetailsState createState() {
    return new RepeatDetailsState();
  }
}

class RepeatDetailsState extends State<RepeatDetailsWidget> {
  ScrollController _scrollController = new ScrollController();
  bool autoValidate = false;
  GlobalKey<FormState> _formState = new GlobalKey<FormState>();

  void initState() {
    widget.repeat.dayRepeats[widget.startTime.weekday - 1] = true;
    widget.repeat.endRepeat = widget.startTime.add(const Duration(days: 7));
    super.initState();
    print('initState $widget.repeat.endRepeat');
  }

  bool validate() {
    return _formState.currentState.validate();
  }

  void save() {
    _formState.currentState.save();
  }

  //// List of date times that are based around the start point
  //// given the current repeat stuff.
  List<TZDateTime> repeatTimes(final TZDateTime start) {
    List<TZDateTime> newDates = [];
    // Normalize to 0.
    TZDateTime startOfWeek = start.subtract(new Duration(days: start.weekday));
    if (widget.repeat.period != RepeatPeriod.None) {
      if (widget.repeat.repeatUntil ||
          widget.repeat.period == RepeatPeriod.Monthly) {
        print("Interval ${widget.repeat.repeatInterval}");
        for (int i = 0; i < widget.repeat.repeatInterval; i++) {
          if (widget.repeat.period == RepeatPeriod.Monthly) {
            newDates.add(new TZDateTime(start.location, start.year,
                start.month + i, start.day, start.hour, start.minute));
          } else {
            DateTime newWeek = startOfWeek.add(new Duration(days: i * 7));
            for (int dayNum = 0;
                dayNum < widget.repeat.dayRepeats.length;
                dayNum++) {
              if (widget.repeat.dayRepeats[dayNum]) {
                newDates.add(newWeek.add(new Duration(days: dayNum)));
              }
            }
          }
        }
      } else {
        int i = 0;
        TZDateTime end = new TZDateTime(
                widget.repeat.endRepeat.location,
                widget.repeat.endRepeat.year,
                widget.repeat.endRepeat.month,
                widget.repeat.endRepeat.day)
            .add(new Duration(days: 1));
        while (
            startOfWeek.millisecondsSinceEpoch < end.millisecondsSinceEpoch) {
          DateTime newWeek = startOfWeek.add(new Duration(days: i * 7));
          for (int dayNum = 0;
              dayNum < widget.repeat.dayRepeats.length;
              dayNum++) {
            if (widget.repeat.dayRepeats[dayNum]) {
              TZDateTime newTime = newWeek.add(new Duration(days: dayNum));
              if (newTime.millisecondsSinceEpoch < end.millisecondsSinceEpoch) {
                newDates.add(newTime);
              }
            }
          }
        }
      }
    } else {
      newDates.add(start);
    }
    return newDates;
  }

  List<DropdownMenuItem<RepeatPeriod>> _buildRepeatIntervalItems(
      BuildContext context) {
    List<DropdownMenuItem<RepeatPeriod>> ret = [];
    ret.add(new DropdownMenuItem<RepeatPeriod>(
      child: new Text(Messages.of(context).noneperiod),
      value: RepeatPeriod.None,
    ));

    ret.add(new DropdownMenuItem<RepeatPeriod>(
      child: new Text(Messages.of(context).weeklyperiod),
      value: RepeatPeriod.Weekly,
    ));

    ret.add(new DropdownMenuItem<RepeatPeriod>(
      child: new Text(Messages.of(context).monthlyperiod),
      value: RepeatPeriod.Monthly,
    ));

    return ret;
  }

  List<Widget> _buildItems() {
    Messages messages = Messages.of(context);
    List<Widget> ret = [];
    ret.add(
      new DropdownButton<RepeatPeriod>(
        hint: new Text(messages.repeat),
        items: _buildRepeatIntervalItems(context),
        value: widget.repeat.period,
        onChanged: (RepeatPeriod val) {
          setState(() {
            widget.repeat.period = val;
          });
        },
      ),
    );
    print('$widget.repeat.endRepeat');
    switch (widget.repeat.period) {
      case RepeatPeriod.Weekly:
        ret.add(new Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new DropdownButton<bool>(
              value: widget.repeat.repeatUntil,
              items: <DropdownMenuItem<bool>>[
                new DropdownMenuItem(
                  child: new Text(
                    messages.repeat,
                  ),
                  value: true,
                ),
                new DropdownMenuItem(
                  child: new Text(
                    messages.until,
                  ),
                  value: false,
                ),
              ],
              onChanged: (bool val) => widget.repeat.repeatUntil = val,
            ),
            widget.repeat.repeatUntil
                ? new Container(
                    constraints: new BoxConstraints.loose(
                      new Size.fromWidth(20.0),
                    ),
                    margin: new EdgeInsets.only(left: 10.0),
                    child: new TextFormField(
                      initialValue: "1",
                      keyboardType: TextInputType.number,
                      onSaved: (String val) {
                        widget.repeat.repeatInterval = int.parse(val);
                      },
                    ),
                  )
                : new Flexible(
                    flex: 1,
                    child: new DateTimeFormField(
                      initialValue: widget.repeat.endRepeat,
                      hideTime: true,
                      onSaved: (DateTime tim) {
                        widget.repeat.endRepeat = tim;
                      },
                    ),
                  ),
          ],
        ));
        List<String> days = MaterialLocalizations.of(context).narrowWeekdays;
        int first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
        List<Widget> daysWidgets = [];
        print("$days");
        daysWidgets.add(const Icon(Icons.calendar_today));
        for (int i = first; i < first + days.length; i++) {
          int pos = i % days.length;
          daysWidgets.add(
            new Container(
              margin: new EdgeInsets.only(left: 10.0),
              child: new GestureDetector(
                onTap: () {
                  setState(() {
                    widget.repeat.dayRepeats[pos] =
                        !widget.repeat.dayRepeats[pos];
                  });
                },
                child: new Chip(
                  backgroundColor: widget.repeat.dayRepeats[pos]
                      ? Theme.of(context).accentColor
                      : Theme.of(context).disabledColor,
                  label: new Text(days[pos]),
                ),
              ),
            ),
          );
        }
        ret.add(
          new Container(
            margin: new EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: new Row(
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
          new TextFormField(
            initialValue: "1",
            keyboardType: TextInputType.number,
            decoration: new InputDecoration(
              labelText: messages.repeat,
              icon: const Icon(Icons.repeat),
            ),
            onSaved: (String val) {
              widget.repeat.repeatInterval = int.parse(val);
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
              children: _buildItems(),
            ),
          ),
        ),
      ),
    );
  }
}
