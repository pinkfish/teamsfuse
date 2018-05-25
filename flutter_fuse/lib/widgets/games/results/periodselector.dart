import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/databasedetails.dart';

class PeriodTypeSelector extends StatelessWidget {
  final Team team;
  final ValueChanged<GamePeriod> onChanged;
  final GamePeriod currentPeriod;

  PeriodTypeSelector(this.team, this.currentPeriod, this.onChanged);

  void _setPeriodType(GamePeriodType type) {
    GamePeriod period =
        new GamePeriod(type: type, periodNumber: currentPeriod.periodNumber);
    switch (type) {
      case GamePeriodType.Regulation:
        break;
      case GamePeriodType.Overtime:
        period.periodNumber = 1;
        break;
      case GamePeriodType.Penalty:
        period.periodNumber = 1;
        break;
      default:
        period.periodNumber = 1;
        break;
    }
    onChanged(period);
  }

  List<Widget> _buildNextPeriods() {
    // We use the current period as a guide to work out where we go next.
    if (currentPeriod == null) {
      return [new Text("")];
    }
    List<Widget> ret = [];
    ret.add(
      new RaisedButton(
        disabledColor: Colors.blue,
        onPressed: (currentPeriod.type == GamePeriodType.Regulation)
            ? null
            : () => _setPeriodType(GamePeriodType.Regulation),
        disabledTextColor: Colors.white,
        child: new Text("Regulation"),
      ),
    );
    ret.add(
      new RaisedButton(
        disabledColor: Colors.blue,
        onPressed: (currentPeriod.type == GamePeriodType.Half)
            ? null
            : () => _setPeriodType(GamePeriodType.Half),
        child: new Text("Half"),
      ),
    );
    ret.add(
      new RaisedButton(
        disabledColor: Colors.blue,
        onPressed: (currentPeriod.type == GamePeriodType.Overtime)
            ? null
            : () => _setPeriodType(GamePeriodType.Overtime),
        child: new Text("Overtime"),
      ),
    );
    if (team.sport == Sport.Soccer) {
      ret.add(
        new RaisedButton(
          disabledColor: Colors.blue,
          onPressed: (currentPeriod.type == GamePeriodType.Penalty)
              ? null
              : () => _setPeriodType(GamePeriodType.Penalty),
          child: new Text("Penalty"),
        ),
      );
    }

    ret.add(new RaisedButton(
      onPressed: () => _setPeriodType(GamePeriodType.Regulation),
      child: new Text("Finish"),
    ));
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: _buildNextPeriods(),
    );
  }
}

class PeriodNumberSelector extends StatelessWidget {
  final ValueChanged<GamePeriod> onChanged;
  final GamePeriod currentPeriod;
  final ScrollController controller;

  PeriodNumberSelector(this.currentPeriod, this.onChanged, this.controller);

  static double ITEM_EXTENT = 40.0;

  void _setPeriodNumber(int period) {
    GamePeriod period = new GamePeriod(
        type: currentPeriod.type, periodNumber: currentPeriod.periodNumber + 1);
    onChanged(period);
  }

  Widget _buildItem(BuildContext contxt, int index) {
    return new SizedBox(
      height: ITEM_EXTENT - 5.0,
      width: ITEM_EXTENT - 5.0,
      child: new FlatButton(
        padding: EdgeInsets.zero,
        color: (index + 1) == currentPeriod.periodNumber
            ? Colors.blue
            : Colors.grey.shade200,
        textColor: (index + 1) == currentPeriod.periodNumber
            ? Colors.white
            : Colors.black,
        shape: new CircleBorder(),
        onPressed: () => _setPeriodNumber(index),
        child: new Center(
          child: new Text(
            (index + 1).toString(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      constraints: new BoxConstraints.tightFor(height: ITEM_EXTENT),
      padding: new EdgeInsets.all(5.0),
      child: new ListView.builder(
        itemBuilder: _buildItem,
        scrollDirection: Axis.horizontal,
        controller: controller,
        shrinkWrap: true,
        itemCount: 50,
        itemExtent: ITEM_EXTENT,
      ),
    );
  }
}
