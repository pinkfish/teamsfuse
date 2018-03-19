import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/numberpickerformfield.dart';

enum RepeatPeriod { None, Weekly, Monthly }

class RepeatDetailsWidget extends StatefulWidget {
  final int repeatDay;
  RepeatDetailsWidget(this.repeatDay);

  @override
  RepeatDetailsState createState() {
    return new RepeatDetailsState();
  }
}

class RepeatDetailsState extends State<RepeatDetailsWidget> {
  ScrollController _scrollController = new ScrollController();
  bool autoValidate = false;
  GlobalKey<FormState> _formState = new GlobalKey<FormState>();

  RepeatPeriod period = RepeatPeriod.None;
  num repeatInterval = 1;
  List<bool> dayRepeats = [false, false, false, false, false, false, false];

  void initState() {
    dayRepeats[widget.repeatDay] = true;
  }

  List<DropdownMenuItem<RepeatPeriod>> _buildRepeatIntervalItems(
      BuildContext context) {
    List<DropdownMenuItem<RepeatPeriod>> ret = new List<DropdownMenuItem>();
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
        value: period,
        onChanged: (RepeatPeriod val) {
          setState(() {
            period = val;
          });
        },
      ),
    );
    switch (period) {
      case RepeatPeriod.Weekly:
        ret.add(
          new TextFormField(
            initialValue: "1",
            keyboardType: TextInputType.number,
            decoration: new InputDecoration(
              labelText: messages.every,
              icon: const Icon(Icons.repeat),
            ),
          ),
        );
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
                    dayRepeats[pos] = !dayRepeats[pos];
                  });
                },
                child: new Chip(
                  backgroundColor: dayRepeats[pos]
                      ? Theme.of(context).accentColor
                      : Theme.of(context).disabledColor,
                  label: new Text(days[pos]),
                ),
              ),
            ),
          );
        }
        print("$daysWidgets");
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
              labelText: messages.every,
              icon: const Icon(Icons.repeat),
            ),
            onSaved: (String val) { repeatInterval = int.parse(val); },
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
    return new SingleChildScrollView(
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
    );
  }
}
