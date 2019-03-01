import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

class PeriodTypeSelector extends StatelessWidget {
  PeriodTypeSelector(this.team, this.currentPeriod, this.onChanged);

  final Team team;
  final ValueChanged<GamePeriod> onChanged;
  final GamePeriod currentPeriod;

  void _setPeriodType(GamePeriodType type) {
    int periodNumber = currentPeriod.periodNumber.toInt();
    switch (type) {
      case GamePeriodType.Regulation:
        break;
      case GamePeriodType.Overtime:
        periodNumber = 1;
        break;
      case GamePeriodType.Penalty:
        periodNumber = 1;
        break;
      default:
        periodNumber = 1;
        break;
    }
    GamePeriod period = new GamePeriod(type: type, periodNumber: periodNumber);
    onChanged(period);
  }

  List<Widget> _buildNextPeriods() {
    // We use the current period as a guide to work out where we go next.
    if (currentPeriod == null) {
      return <Widget>[new Text("")];
    }
    List<Widget> ret = <Widget>[];
    ret.add(
      new Container(
        padding: new EdgeInsets.only(left: 3.0, right: 3.0),
        child: new RaisedButton(
          disabledColor: Colors.blue,
          onPressed: (currentPeriod.type == GamePeriodType.Regulation ||
                  currentPeriod.type == GamePeriodType.Break)
              ? null
              : () => _setPeriodType(GamePeriodType.Regulation),
          disabledTextColor: Colors.white,
          child: new Text("Regulation"),
        ),
      ),
    );
    ret.add(
      new Container(
        padding: new EdgeInsets.only(left: 3.0, right: 3.0),
        child: new RaisedButton(
          disabledColor: Colors.blue,
          onPressed: (currentPeriod.type == GamePeriodType.Overtime ||
                  currentPeriod.type == GamePeriodType.OvertimeBreak)
              ? null
              : () => _setPeriodType(GamePeriodType.Overtime),
          child: new Text("Overtime"),
        ),
      ),
    );
    if (team.sport == Sport.Soccer) {
      ret.add(
        new Container(
          padding: new EdgeInsets.only(left: 3.0, right: 3.0),
          child: new RaisedButton(
            disabledColor: Colors.blue,
            onPressed: (currentPeriod.type == GamePeriodType.Penalty)
                ? null
                : () => _setPeriodType(GamePeriodType.Penalty),
            child: new Text("Penalty"),
          ),
        ),
      );
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      constraints: new BoxConstraints.tightFor(height: 40.0),
      padding: new EdgeInsets.all(5.0),
      child: new ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: _buildNextPeriods(),
      ),
    );
  }
}

class PeriodNumberSelector extends StatelessWidget {
  PeriodNumberSelector(
      this.currentPeriod, this.divisionsType, this.onChanged, this.controller);

  final ValueChanged<GamePeriod> onChanged;
  final GamePeriod currentPeriod;
  final ScrollController controller;
  final GameDivisionsType divisionsType;

  static double itemExtent = 150.0;

  void _setPeriodNumber(int periodNumber) {
    GamePeriod period;
    if (currentPeriod.type == GamePeriodType.OvertimeBreak) {
      period = new GamePeriod(
          type: GamePeriodType.Overtime, periodNumber: periodNumber);
    } else {
      period = new GamePeriod(
          type: GamePeriodType.Regulation, periodNumber: periodNumber);
    }
    onChanged(period);
  }

  void _endPeriod(int period) {
    GamePeriod period;

    if (currentPeriod.type == GamePeriodType.Overtime) {
      period = new GamePeriod(
          type: GamePeriodType.OvertimeBreak,
          periodNumber: currentPeriod.periodNumber);
    } else {
      period = new GamePeriod(
          type: GamePeriodType.Break, periodNumber: currentPeriod.periodNumber);
    }
    onChanged(period);
  }

  Widget _makePeriodButton(String text, int period) {
    return new Container(
      padding: new EdgeInsets.only(left: 3.0, right: 3.0),
      child: new RaisedButton(
        disabledColor: Colors.blue,
        disabledTextColor: Colors.white,
        onPressed: (currentPeriod.type == GamePeriodType.Regulation ||
                    currentPeriod.type == GamePeriodType.Overtime) &&
                currentPeriod.periodNumber == period
            ? null
            : () => _setPeriodNumber(period),
        child: new Text(text),
      ),
    );
  }

  Widget _makeBreakButton(String text, int period) {
    return new Container(
      padding: new EdgeInsets.only(left: 3.0, right: 3.0),
      child: new RaisedButton(
        disabledColor: Colors.blue,
        disabledTextColor: Colors.white,
        onPressed: (currentPeriod.type == GamePeriodType.Break ||
                    currentPeriod.type == GamePeriodType.OvertimeBreak) &&
                currentPeriod.periodNumber == period
            ? null
            : () => _endPeriod(period),
        child: new Text(text),
      ),
    );
  }

  List<Widget> _buildPeriods() {
    List<Widget> ret = <Widget>[];

    switch (divisionsType) {
      case GameDivisionsType.Quarters:
        ret.add(_makePeriodButton("First", 1));
        ret.add(_makeBreakButton("Half time", 1));
        ret.add(_makePeriodButton("Second", 2));
        break;
      case GameDivisionsType.Thirds:
        ret.add(_makePeriodButton("First", 1));
        ret.add(_makeBreakButton("First break", 1));
        ret.add(_makePeriodButton("Second", 2));
        ret.add(_makeBreakButton("Second break", 2));
        ret.add(_makePeriodButton("Third", 3));
        break;
      case GameDivisionsType.Halves:
        ret.add(_makePeriodButton("1st", 1));
        ret.add(_makeBreakButton("1st break", 1));
        ret.add(_makePeriodButton("2nd", 2));
        ret.add(_makeBreakButton("Half", 2));
        ret.add(_makePeriodButton("3rd", 3));
        ret.add(_makeBreakButton("3rd break", 3));
        ret.add(_makePeriodButton("4th", 4));
        break;
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      constraints: new BoxConstraints.tightFor(height: itemExtent),
      padding: new EdgeInsets.all(5.0),
      child: new ListView(
        scrollDirection: Axis.horizontal,
        controller: controller,
        shrinkWrap: true,
        children: _buildPeriods(),
      ),
    );
  }
}

class PeriodSelector extends StatelessWidget {
  PeriodSelector(
      {@required this.currentPeriod,
      @required this.divisionsType,
      @required this.team,
      @required this.onChanged});

  final GamePeriod currentPeriod;
  final GameDivisionsType divisionsType;
  final Team team;
  final ValueChanged<GamePeriod> onChanged;

  List<DropdownMenuItem<GamePeriodType>> _buildPeriodTypes(
      BuildContext context) {
    List<DropdownMenuItem<GamePeriodType>> ret =
        <DropdownMenuItem<GamePeriodType>>[
      new DropdownMenuItem<GamePeriodType>(
        child: new Text("Regulation"),
        value: GamePeriodType.Regulation,
      ),
      new DropdownMenuItem<GamePeriodType>(
        child: new Text("Overtime"),
        value: GamePeriodType.Overtime,
      ),
    ];
    if (team.sport == Sport.Soccer) {
      ret.add(
        new DropdownMenuItem<GamePeriodType>(
          child: new Text("Penalty"),
          value: GamePeriodType.Penalty,
        ),
      );
    }
    return ret;
  }

  DropdownMenuItem<int> _makePeriodButton(String text, int period) {
    return new DropdownMenuItem<int>(
      child: new Text(text, overflow: TextOverflow.clip),
      value: period,
    );
  }

  DropdownMenuItem<int> _makeBreakButton(String text, int period) {
    return new DropdownMenuItem<int>(
      child: new Text(
        text,
        overflow: TextOverflow.clip,
      ),
      value: period + 1000,
    );
  }

  List<DropdownMenuItem<int>> _buildDurationTypes(BuildContext context) {
    List<DropdownMenuItem<int>> ret = <DropdownMenuItem<int>>[];

    if (currentPeriod.type == GamePeriodType.Penalty) {
      ret.add(_makePeriodButton("None", 1));
      return ret;
    }

    switch (divisionsType) {
      case GameDivisionsType.Halves:
        ret.add(_makePeriodButton("First", 1));
        ret.add(_makeBreakButton("Half time", 1));
        ret.add(_makePeriodButton("Second", 2));
        break;
      case GameDivisionsType.Thirds:
        ret.add(_makePeriodButton("First", 1));
        ret.add(_makeBreakButton("First break", 1));
        ret.add(_makePeriodButton("Second", 2));
        ret.add(_makeBreakButton("Second break", 2));
        ret.add(_makePeriodButton("Third", 3));
        break;
      case GameDivisionsType.Quarters:
        ret.add(_makePeriodButton("1st Quarter", 1));
        ret.add(_makeBreakButton("End of 1st Quarter", 1));
        ret.add(_makePeriodButton("2nd Quarter", 2));
        ret.add(_makeBreakButton("Half", 2));
        ret.add(_makePeriodButton("3rd Quarter", 3));
        ret.add(_makeBreakButton("End of 3rd Quarter", 3));
        ret.add(_makePeriodButton("4th Quarter", 4));
        break;
    }
    return ret;
  }

  void _setPeriodType(GamePeriodType type) {
    if (type == currentPeriod.type) {
      return;
    }
    int periodNumber = currentPeriod.periodNumber.toInt();
    switch (type) {
      case GamePeriodType.Regulation:
        break;
      case GamePeriodType.Overtime:
        periodNumber = 1;
        break;
      case GamePeriodType.Penalty:
        periodNumber = 1;
        break;
      default:
        periodNumber = 1;
        break;
    }
    GamePeriod period = new GamePeriod(type: type, periodNumber: periodNumber);
    onChanged(period);
  }

  void _setPeriodNumber(int periodNumber) {
    if (periodNumber == currentPeriod.periodNumber) {
      return;
    }
    GamePeriod period;
    if (currentPeriod.type == GamePeriodType.OvertimeBreak) {
      period = new GamePeriod(
          type: GamePeriodType.Overtime, periodNumber: periodNumber);
    } else {
      period = new GamePeriod(
          type: GamePeriodType.Regulation, periodNumber: periodNumber);
    }
    onChanged(period);
  }

  void _endPeriod(int periodNumber) {
    GamePeriod period;

    if (currentPeriod.type == GamePeriodType.Overtime) {
      period = new GamePeriod(
          type: GamePeriodType.OvertimeBreak, periodNumber: periodNumber);
    } else {
      period = new GamePeriod(
          type: GamePeriodType.Break, periodNumber: periodNumber);
    }
    onChanged(period);
  }

  void _setPeriodVal(int val) {
    if (val > 1000) {
      _endPeriod(val - 1000);
    } else {
      _setPeriodNumber(val);
    }
  }

  @override
  Widget build(BuildContext context) {
    GamePeriodType selected = currentPeriod.type;
    int selectedPeriod = currentPeriod.periodNumber.toInt();
    if (selected == GamePeriodType.Break) {
      selected = GamePeriodType.Regulation;
      selectedPeriod += 1000;
    } else if (selected == GamePeriodType.OvertimeBreak) {
      selected = GamePeriodType.Overtime;
      selectedPeriod += 1000;
    }
    return new Container(
      padding: new EdgeInsets.only(left: 5.0, right: 5.0),
      decoration: new BoxDecoration(color: Colors.lightBlue.shade50),
      child: new DropdownButtonHideUnderline(
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              flex: 1,
              child: new DropdownButton<int>(
                items: _buildDurationTypes(context),
                value: selectedPeriod,
                onChanged: (int val) => _setPeriodVal(val),
              ),
            ),
            new SizedBox(
              width: 10.0,
            ),
            new DropdownButton<GamePeriodType>(
              value: selected,
              items: _buildPeriodTypes(context),
              onChanged: (GamePeriodType ty) => _setPeriodType(ty),
            ),
          ],
        ),
      ),
    );
  }
}
