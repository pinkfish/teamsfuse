import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/datetimeformfield.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

class RepeatDetailsWidget extends StatefulWidget {
  RepeatDetailsWidget(this.startTime, this.repeat,
      {GlobalKey<RepeatDetailsState> key})
      : super(key: key);

  final TZDateTime startTime;
  final RepeatData repeat;

  @override
  RepeatDetailsState createState() {
    return new RepeatDetailsState();
  }
}

class RepeatDetailsState extends State<RepeatDetailsWidget> {
  ScrollController _scrollController = new ScrollController();
  bool autoValidate = false;
  GlobalKey<FormState> _formState = new GlobalKey<FormState>();
  RepeatData _updatedRepeat;

  @override
  void initState() {
    _updatedRepeat = widget.repeat.rebuild((b) => b
      ..endRepeat = widget.startTime.add(const Duration(days: 7))
      ..dayRepeats[widget.startTime.weekday - 1] = true);
    super.initState();
    print('initState $_updatedRepeat.endRepeat');
  }

  bool validate() {
    return _formState.currentState.validate();
  }

  RepeatData save() {
    _formState.currentState.save();
    return _updatedRepeat;
  }

  List<DropdownMenuItem<RepeatPeriod>> _buildRepeatIntervalItems(
      BuildContext context) {
    List<DropdownMenuItem<RepeatPeriod>> ret =
        <DropdownMenuItem<RepeatPeriod>>[];
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
    List<Widget> ret = <Widget>[];
    ret.add(
      new DropdownButton<RepeatPeriod>(
        hint: new Text(messages.repeat),
        items: _buildRepeatIntervalItems(context),
        value: _updatedRepeat.period,
        onChanged: (RepeatPeriod val) {
          setState(() {
            _updatedRepeat = _updatedRepeat.rebuild((b) => b..period = val);
          });
        },
      ),
    );
    print('$_updatedRepeat.endRepeat');
    switch (_updatedRepeat.period) {
      case RepeatPeriod.Weekly:
        ret.add(new Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new DropdownButton<bool>(
              value: _updatedRepeat.repeatUntil,
              items: <DropdownMenuItem<bool>>[
                new DropdownMenuItem<bool>(
                  child: new Text(
                    messages.repeat,
                  ),
                  value: true,
                ),
                new DropdownMenuItem<bool>(
                  child: new Text(
                    messages.until,
                  ),
                  value: false,
                ),
              ],
              onChanged: (bool val) => _updatedRepeat =
                  _updatedRepeat.rebuild((b) => b.repeatUntil = val),
            ),
            _updatedRepeat.repeatUntil
                ? new Container(
                    constraints: new BoxConstraints.loose(
                      new Size.fromWidth(20.0),
                    ),
                    margin: new EdgeInsets.only(left: 10.0),
                    child: new TextFormField(
                      initialValue: "1",
                      keyboardType: TextInputType.number,
                      onSaved: (String val) {
                        _updatedRepeat = _updatedRepeat
                            .rebuild((b) => b.repeatInterval = int.parse(val));
                      },
                    ),
                  )
                : new Flexible(
                    flex: 1,
                    child: new DateTimeFormField(
                      initialValue: _updatedRepeat.endRepeat,
                      hideTime: true,
                      onSaved: (DateTime tim) {
                        _updatedRepeat =
                            _updatedRepeat.rebuild((b) => b.endRepeat = tim);
                      },
                    ),
                  ),
          ],
        ));
        List<String> days = MaterialLocalizations.of(context).narrowWeekdays;
        int first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
        List<Widget> daysWidgets = <Widget>[];
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
                    _updatedRepeat = _updatedRepeat.rebuild((b) =>
                        b..dayRepeats[pos] = !_updatedRepeat.dayRepeats[pos]);
                  });
                },
                child: new Chip(
                  backgroundColor: _updatedRepeat.dayRepeats[pos]
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
