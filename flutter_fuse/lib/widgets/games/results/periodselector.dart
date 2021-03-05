import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Selector to select the current game period.
///
class PeriodTypeSelector extends StatelessWidget {
  /// Constructor.
  PeriodTypeSelector(this.team, this.currentPeriod, this.onChanged);

  /// The team to show the period for.
  final Team team;

  /// Callback when things change.
  final ValueChanged<GamePeriod> onChanged;

  /// The current period selected.
  final GamePeriod currentPeriod;

  void _setPeriodType(GamePeriodType type) {
    var periodNumber = currentPeriod.periodNumber.toInt();
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
    var period = GamePeriod((b) => b
      ..type = type
      ..periodNumber = periodNumber);
    onChanged(period);
  }

  List<Widget> _buildNextPeriods() {
    // We use the current period as a guide to work out where we go next.
    if (currentPeriod == null) {
      return <Widget>[Text('')];
    }
    var ret = <Widget>[];
    ret.add(
      Container(
        padding: EdgeInsets.only(left: 3.0, right: 3.0),
        child: RaisedButton(
          disabledColor: Colors.blue,
          onPressed: (currentPeriod.type == GamePeriodType.Regulation ||
                  currentPeriod.type == GamePeriodType.Break)
              ? null
              : () => _setPeriodType(GamePeriodType.Regulation),
          disabledTextColor: Colors.white,
          child: Text('Regulation'),
        ),
      ),
    );
    ret.add(
      Container(
        padding: EdgeInsets.only(left: 3.0, right: 3.0),
        child: RaisedButton(
          disabledColor: Colors.blue,
          onPressed: (currentPeriod.type == GamePeriodType.Overtime ||
                  currentPeriod.type == GamePeriodType.OvertimeBreak)
              ? null
              : () => _setPeriodType(GamePeriodType.Overtime),
          child: Text('Overtime'),
        ),
      ),
    );
    if (team.sport == Sport.Soccer) {
      ret.add(
        Container(
          padding: EdgeInsets.only(left: 3.0, right: 3.0),
          child: RaisedButton(
            disabledColor: Colors.blue,
            onPressed: (currentPeriod.type == GamePeriodType.Penalty)
                ? null
                : () => _setPeriodType(GamePeriodType.Penalty),
            child: Text('Penalty'),
          ),
        ),
      );
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.tightFor(height: 40.0),
      padding: EdgeInsets.all(5.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: _buildNextPeriods(),
      ),
    );
  }
}

///
/// The period number to select, after the type is selected.
///
class PeriodNumberSelector extends StatelessWidget {
  /// Constructor.
  PeriodNumberSelector(
      this.currentPeriod, this.divisionsType, this.onChanged, this.controller);

  /// Called when the value changes.
  final ValueChanged<GamePeriod> onChanged;

  /// The current period for the game.
  final GamePeriod currentPeriod;

  /// The scroll controller to use to show where the selector is.
  final ScrollController controller;

  /// The type of game divisons.
  final GameDivisionsType divisionsType;

  final double _itemExtent = 150.0;

  void _setPeriodNumber(int periodNumber) {
    GamePeriod period;
    if (currentPeriod.type == GamePeriodType.OvertimeBreak) {
      period = GamePeriod((b) => b
        ..type = GamePeriodType.Overtime
        ..periodNumber = periodNumber);
    } else {
      period = GamePeriod((b) => b
        ..type = GamePeriodType.Regulation
        ..periodNumber = periodNumber);
    }
    onChanged(period);
  }

  void _endPeriod(int period) {
    GamePeriod period;

    if (currentPeriod.type == GamePeriodType.Overtime) {
      period = GamePeriod((b) => b
        ..type = GamePeriodType.OvertimeBreak
        ..periodNumber = currentPeriod.periodNumber);
    } else {
      period = GamePeriod((b) => b
        ..type = GamePeriodType.Break
        ..periodNumber = currentPeriod.periodNumber);
    }
    onChanged(period);
  }

  Widget _makePeriodButton(String text, int period) {
    return Container(
      padding: EdgeInsets.only(left: 3.0, right: 3.0),
      child: RaisedButton(
        disabledColor: Colors.blue,
        disabledTextColor: Colors.white,
        onPressed: (currentPeriod.type == GamePeriodType.Regulation ||
                    currentPeriod.type == GamePeriodType.Overtime) &&
                currentPeriod.periodNumber == period
            ? null
            : () => _setPeriodNumber(period),
        child: Text(text),
      ),
    );
  }

  Widget _makeBreakButton(String text, int period) {
    return Container(
      padding: EdgeInsets.only(left: 3.0, right: 3.0),
      child: RaisedButton(
        disabledColor: Colors.blue,
        disabledTextColor: Colors.white,
        onPressed: (currentPeriod.type == GamePeriodType.Break ||
                    currentPeriod.type == GamePeriodType.OvertimeBreak) &&
                currentPeriod.periodNumber == period
            ? null
            : () => _endPeriod(period),
        child: Text(text),
      ),
    );
  }

  List<Widget> _buildPeriods() {
    var ret = <Widget>[];

    switch (divisionsType) {
      case GameDivisionsType.Quarters:
        ret.add(_makePeriodButton('First', 1));
        ret.add(_makeBreakButton('Half time', 1));
        ret.add(_makePeriodButton('Second', 2));
        break;
      case GameDivisionsType.Thirds:
        ret.add(_makePeriodButton('First', 1));
        ret.add(_makeBreakButton('First break', 1));
        ret.add(_makePeriodButton('Second', 2));
        ret.add(_makeBreakButton('Second break', 2));
        ret.add(_makePeriodButton('Third', 3));
        break;
      case GameDivisionsType.Halves:
        ret.add(_makePeriodButton('1st', 1));
        ret.add(_makeBreakButton('1st break', 1));
        ret.add(_makePeriodButton('2nd', 2));
        ret.add(_makeBreakButton('Half', 2));
        ret.add(_makePeriodButton('3rd', 3));
        ret.add(_makeBreakButton('3rd break', 3));
        ret.add(_makePeriodButton('4th', 4));
        break;
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.tightFor(height: _itemExtent),
      padding: EdgeInsets.all(5.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        controller: controller,
        shrinkWrap: true,
        children: _buildPeriods(),
      ),
    );
  }
}

///
/// Selector for the period, selects both the type and the period number.
///
class PeriodSelector extends StatelessWidget {
  /// Constructor.
  PeriodSelector(
      {@required this.currentPeriod,
      @required this.divisionsType,
      @required this.team,
      @required this.onChanged});

  /// The currently selected game period.
  final GamePeriod currentPeriod;

  /// The types of devisions on the game (halves, quarters).
  final GameDivisionsType divisionsType;

  /// The team to show the periods for.
  final Team team;

  /// Called when the value changes.
  final ValueChanged<GamePeriod> onChanged;

  List<DropdownMenuItem<GamePeriodType>> _buildPeriodTypes(
      BuildContext context) {
    var ret = <DropdownMenuItem<GamePeriodType>>[
      DropdownMenuItem<GamePeriodType>(
        value: GamePeriodType.Regulation,
        child: Text('Regulation'),
      ),
      DropdownMenuItem<GamePeriodType>(
        value: GamePeriodType.Overtime,
        child: Text('Overtime'),
      ),
    ];
    if (team.sport == Sport.Soccer) {
      ret.add(
        DropdownMenuItem<GamePeriodType>(
          value: GamePeriodType.Penalty,
          child: Text('Penalty'),
        ),
      );
    }
    return ret;
  }

  DropdownMenuItem<int> _makePeriodButton(String text, int period) {
    return DropdownMenuItem<int>(
      value: period,
      child: Text(text, overflow: TextOverflow.clip),
    );
  }

  DropdownMenuItem<int> _makeBreakButton(String text, int period) {
    return DropdownMenuItem<int>(
      value: period + 1000,
      child: Text(
        text,
        overflow: TextOverflow.clip,
      ),
    );
  }

  List<DropdownMenuItem<int>> _buildDurationTypes(BuildContext context) {
    var ret = <DropdownMenuItem<int>>[];

    if (currentPeriod.type == GamePeriodType.Penalty) {
      ret.add(_makePeriodButton('None', 1));
      return ret;
    }

    switch (divisionsType) {
      case GameDivisionsType.Halves:
        ret.add(_makePeriodButton('First', 1));
        ret.add(_makeBreakButton('Half time', 1));
        ret.add(_makePeriodButton('Second', 2));
        break;
      case GameDivisionsType.Thirds:
        ret.add(_makePeriodButton('First', 1));
        ret.add(_makeBreakButton('First break', 1));
        ret.add(_makePeriodButton('Second', 2));
        ret.add(_makeBreakButton('Second break', 2));
        ret.add(_makePeriodButton('Third', 3));
        break;
      case GameDivisionsType.Quarters:
        ret.add(_makePeriodButton('1st Quarter', 1));
        ret.add(_makeBreakButton('End of 1st Quarter', 1));
        ret.add(_makePeriodButton('2nd Quarter', 2));
        ret.add(_makeBreakButton('Half', 2));
        ret.add(_makePeriodButton('3rd Quarter', 3));
        ret.add(_makeBreakButton('End of 3rd Quarter', 3));
        ret.add(_makePeriodButton('4th Quarter', 4));
        break;
    }
    return ret;
  }

  void _setPeriodType(GamePeriodType type) {
    if (type == currentPeriod.type) {
      return;
    }
    var periodNumber = currentPeriod.periodNumber.toInt();
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
    var period = GamePeriod((b) => b
      ..type = type
      ..periodNumber = periodNumber);
    onChanged(period);
  }

  void _setPeriodNumber(int periodNumber) {
    if (periodNumber == currentPeriod.periodNumber) {
      return;
    }
    GamePeriod period;
    if (currentPeriod.type == GamePeriodType.OvertimeBreak) {
      period = GamePeriod((b) => b
        ..type = GamePeriodType.Overtime
        ..periodNumber = periodNumber);
    } else {
      period = GamePeriod((b) => b
        ..type = GamePeriodType.Regulation
        ..periodNumber
        ..periodNumber);
    }
    onChanged(period);
  }

  void _endPeriod(int periodNumber) {
    GamePeriod period;

    if (currentPeriod.type == GamePeriodType.Overtime) {
      period = GamePeriod((b) => b
        ..type = GamePeriodType.OvertimeBreak
        ..periodNumber = periodNumber);
    } else {
      period = GamePeriod((b) => b
        ..type = GamePeriodType.Break
        ..periodNumber = periodNumber);
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
    var selected = currentPeriod.type;
    var selectedPeriod = currentPeriod.periodNumber.toInt();
    if (selected == GamePeriodType.Break) {
      selected = GamePeriodType.Regulation;
      selectedPeriod += 1000;
    } else if (selected == GamePeriodType.OvertimeBreak) {
      selected = GamePeriodType.Overtime;
      selectedPeriod += 1000;
    }
    return Container(
      padding: EdgeInsets.only(left: 5.0, right: 5.0),
      decoration: BoxDecoration(color: Colors.lightBlue.shade50),
      child: DropdownButtonHideUnderline(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: DropdownButton<int>(
                items: _buildDurationTypes(context),
                value: selectedPeriod,
                onChanged: _setPeriodVal,
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            DropdownButton<GamePeriodType>(
              value: selected,
              items: _buildPeriodTypes(context),
              onChanged: _setPeriodType,
            ),
          ],
        ),
      ),
    );
  }
}
