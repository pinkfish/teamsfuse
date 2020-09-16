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
    return RepeatDetailsState();
  }
}

class RepeatDetailsState extends State<RepeatDetailsWidget> {
  ScrollController _scrollController = ScrollController();
  bool autoValidate = false;
  GlobalKey<FormState> _formState = GlobalKey<FormState>();
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
    Messages messages = Messages.of(context);
    List<Widget> ret = <Widget>[];
    ret.add(
      DropdownButton<RepeatPeriod>(
        hint: Text(messages.repeat),
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
              onChanged: (bool val) => _updatedRepeat =
                  _updatedRepeat.rebuild((b) => b.repeatUntil = val),
            ),
            _updatedRepeat.repeatUntil
                ? Container(
                    constraints: BoxConstraints.loose(
                      Size.fromWidth(20.0),
                    ),
                    margin: EdgeInsets.only(left: 10.0),
                    child: TextFormField(
                      initialValue: "1",
                      keyboardType: TextInputType.number,
                      onSaved: (String val) {
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
            initialValue: "1",
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
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
