import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Created by Marcin Szałek, Mangled a lot by David Bennett

///NumberPicker is a widget designed to pick a number between #minValue and #maxValue
class NumberPicker extends StatefulWidget {
  ///height of every list element
  static const double defaultItemExtent = 50.0;

  ///width of list view
  static const double defaultListViewWidth = 100.0;

  ///constructor for integer number picker
  NumberPicker.integer({
    @required this.initialValue,
    @required this.minValue,
    @required this.maxValue,
    @required this.onChanged,
    Key key,
    this.disabled = false,
    this.itemExtent = defaultItemExtent,
    this.listViewWidth = defaultListViewWidth,
  })
      : assert(initialValue != null),
        assert(minValue != null),
        assert(maxValue != null),
        assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        selectedDecimalValue = -1,
        decimalPlaces = 0,
        intScrollController = new ScrollController(
          initialScrollOffset: (initialValue - minValue) * itemExtent,
        ),
        decimalScrollController = null,
        _listViewHeight = 3 * itemExtent,
        super(key: key);

  ///constructor for decimal number picker
  NumberPicker.decimal({
    @required this.initialValue,
    @required this.minValue,
    @required this.maxValue,
    @required this.onChanged,
    Key key,
    this.decimalPlaces = 1,
    this.disabled = false,
    this.itemExtent = defaultItemExtent,
    this.listViewWidth = defaultListViewWidth,
  })
      : assert(initialValue != null),
        assert(minValue != null),
        assert(maxValue != null),
        assert(decimalPlaces != null && decimalPlaces > 0),
        assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        selectedDecimalValue = ((initialValue - initialValue.floorToDouble()) *
            pow(10, decimalPlaces))
            .round(),
        intScrollController = new ScrollController(
          initialScrollOffset: (initialValue.floor() - minValue) * itemExtent,
        ),
        decimalScrollController = new ScrollController(
          initialScrollOffset: ((initialValue - initialValue.floorToDouble()) *
              pow(10, decimalPlaces))
              .roundToDouble() *
              itemExtent,
        ),
        _listViewHeight = 3 * itemExtent,
        super(key: key);

  //called when selected value changes
  final ValueChanged<num> onChanged;

  ///min value user can pick
  final int minValue;

  ///max value user can pick
  final int maxValue;

  /// If the widget is disabled.
  final bool disabled;

  ///inidcates how many decimal places to show
  /// e.g. 0=>[1,2,3...], 1=>[1.0, 1.1, 1.2...]  2=>[1.00, 1.01, 1.02...]
  final int decimalPlaces;

  ///height of every list element in pixels
  final double itemExtent;

  ///view will always contain only 3 elements of list in pixels
  final double _listViewHeight;

  ///width of list view in pixels
  final double listViewWidth;

  ///ScrollController used for integer list
  final ScrollController intScrollController;

  ///ScrollController used for decimal list
  final ScrollController decimalScrollController;

  ///Currently selected integer value
  final int initialValue;

  ///Currently selected decimal value
  final int selectedDecimalValue;

  @override
  NumberPickerState createState() {
    return new NumberPickerState();
  }
}

class NumberPickerState extends State<NumberPicker> {

  //
  //----------------------------- PUBLIC ------------------------------
  //

  void animateInt(int valueToSelect) {
    _animate(widget.intScrollController, (valueToSelect - widget.minValue) * widget.itemExtent);
  }

  void animateDecimal(int decimalValue) {
    _animate(widget.decimalScrollController, decimalValue * widget.itemExtent);
  }

  void animateDecimalAndInteger(double valueToSelect) {
    print(valueToSelect);
    animateInt(valueToSelect.floor());
    animateDecimal(((valueToSelect - valueToSelect.floorToDouble()) *
        pow(10, widget.decimalPlaces))
        .round());
  }

  //
  //----------------------------- VIEWS -----------------------------
  //

  ///main widget
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    if (widget.decimalPlaces == 0) {
      return _integerListView(themeData);
    } else {
      return new Row(
        children: <Widget>[
          _integerListView(themeData),
          _decimalListView(themeData),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    }
  }

  Widget _integerListView(ThemeData themeData) {
    TextStyle defaultStyle = themeData.textTheme.body1;
    TextStyle selectedStyle =
    themeData.textTheme.headline.copyWith(color: themeData.accentColor);
    if (widget.disabled) {
      defaultStyle = defaultStyle.copyWith(color: themeData.disabledColor);
      selectedStyle = defaultStyle;
    }

    int itemCount = widget.maxValue - widget.minValue + 3;

    return new NotificationListener(
      child: new Container(
        height: widget._listViewHeight,
        width: widget.listViewWidth,
        child: new ListView.builder(
          controller: widget.intScrollController,
          itemExtent: widget.itemExtent,
          itemCount: itemCount,
          physics: widget.disabled ? new NeverScrollableScrollPhysics() : new AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            final int value = widget.minValue + index - 1;

            //define special style for selected (middle) element
            final TextStyle itemStyle =
            value == widget.initialValue ? selectedStyle : defaultStyle;

            bool isExtra = index == 0 || index == itemCount - 1;

            return isExtra
                ? new Container() //empty first and last element
                : new Center(
              child: new Text(value.toString(), style: itemStyle),
            );
          },
        ),
      ),
      onNotification: _onIntegerNotification,
    );
  }

  Widget _decimalListView(ThemeData themeData) {
    TextStyle defaultStyle = themeData.textTheme.body1;
    TextStyle selectedStyle =
    themeData.textTheme.headline.copyWith(color: themeData.accentColor);

    int itemCount =
    widget.initialValue == widget.maxValue ? 3 : pow(10, widget.decimalPlaces) + 2;

    return new NotificationListener(
      child: new Container(
        height: widget._listViewHeight,
        width: widget.listViewWidth,
        child: new ListView.builder(
          controller: widget.decimalScrollController,
          itemExtent: widget.itemExtent,
          itemCount: itemCount,
          physics: widget.disabled ? new NeverScrollableScrollPhysics() : new AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            final int value = index - 1;

            //define special style for selected (middle) element
            final TextStyle itemStyle =
            value == widget.selectedDecimalValue ? selectedStyle : defaultStyle;

            bool isExtra = index == 0 || index == itemCount - 1;

            return isExtra
                ? new Container() //empty first and last element
                : new Center(
              child: new Text(
                  value.toString().padLeft(widget.decimalPlaces, '0'),
                  style: itemStyle),
            );
          },
        ),
      ),
      onNotification: _onDecimalNotification,
    );
  }

  //
  // ----------------------------- LOGIC -----------------------------
  //

  bool _onIntegerNotification(Notification notification) {
    if (widget.disabled) {
      return false;
    }
    if (notification is ScrollNotification && !widget.disabled) {
      //calculate
      int intIndexOfMiddleElement =
          (notification.metrics.pixels + widget._listViewHeight / 2) ~/ widget.itemExtent;
      int intValueInTheMiddle = widget.minValue + intIndexOfMiddleElement - 1;

      if (_userStoppedScrolling(notification, widget.intScrollController)) {
        //center selected value
        animateInt(intValueInTheMiddle);
      }

      //update selection
      if (intValueInTheMiddle != widget.initialValue) {
        num newValue;
        if (widget.decimalPlaces == 0) {
          //return integer value
          newValue = (intValueInTheMiddle);
        } else {
          if (intValueInTheMiddle == widget.maxValue) {
            //if new value is maxValue, then return that value and ignore decimal
            newValue = (intValueInTheMiddle.toDouble());
            animateDecimal(0);
          } else {
            //return integer+decimal
            double decimalPart = _toDecimal(widget.selectedDecimalValue);
            newValue = ((intValueInTheMiddle + decimalPart).toDouble());
          }
        }
        widget.onChanged(newValue);
      }
    }
    return true;
  }

  bool _onDecimalNotification(Notification notification) {
    if (widget.disabled) {
      return false;
    }
    if (notification is ScrollNotification && !widget.disabled) {
      //calculate middle value
      int indexOfMiddleElement =
          (notification.metrics.pixels + widget._listViewHeight / 2) ~/ widget.itemExtent;
      int decimalValueInTheMiddle = indexOfMiddleElement - 1;

      if (_userStoppedScrolling(notification, widget.decimalScrollController)) {
        //center selected value
        animateDecimal(decimalValueInTheMiddle);
      }

      //update selection
      if (widget.initialValue != widget.maxValue &&
          decimalValueInTheMiddle != widget.selectedDecimalValue) {
        double decimalPart = _toDecimal(decimalValueInTheMiddle);
        double newValue = ((widget.initialValue + decimalPart).toDouble());
        widget.onChanged(newValue);
      }
    }
    return true;
  }

  ///indicates if user has stopped scrolling so we can center value in the middle
  bool _userStoppedScrolling(Notification notification,
      ScrollController scrollController) {
    return notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle &&
        scrollController.position.activity is! HoldScrollActivity;
  }

  ///converts integer indicator of decimal value to double
  ///e.g. decimalPlaces = 1, value = 4  >>> result = 0.4
  ///     decimalPlaces = 2, value = 12 >>> result = 0.12
  double _toDecimal(int decimalValueAsInteger) {
    return double.parse((decimalValueAsInteger * pow(10, -widget.decimalPlaces))
        .toStringAsFixed(widget.decimalPlaces));
  }

  ///scroll to selected value
  void _animate(ScrollController scrollController, double value) {
    scrollController.animateTo(value,
        duration: new Duration(seconds: 1), curve: new ElasticOutCurve());
  }
}
