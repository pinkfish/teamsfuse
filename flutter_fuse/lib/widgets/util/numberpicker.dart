import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Created by Marcin Szałek, Mangled a lot by David Bennett

///NumberPicker is a widget designed to pick a number between #minValue and #maxValue
class NumberPicker extends StatefulWidget {
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
  })  : assert(initialValue != null),
        assert(minValue != null),
        assert(maxValue != null),
        assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        selectedDecimalValue = -1,
        decimalPlaces = 0,
        intScrollController = ScrollController(
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
  })  : assert(initialValue != null),
        assert(minValue != null),
        assert(maxValue != null),
        assert(decimalPlaces != null && decimalPlaces > 0),
        assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        selectedDecimalValue = ((initialValue - initialValue.floorToDouble()) *
                pow(10, decimalPlaces))
            .round(),
        intScrollController = ScrollController(
          initialScrollOffset: (initialValue.floor() - minValue) * itemExtent,
        ),
        decimalScrollController = ScrollController(
          initialScrollOffset: ((initialValue - initialValue.floorToDouble()) *
                      pow(10, decimalPlaces))
                  .roundToDouble() *
              itemExtent,
        ),
        _listViewHeight = 3 * itemExtent,
        super(key: key);

  /// height of every list element
  static const double defaultItemExtent = 50.0;

  /// width of list view
  static const double defaultListViewWidth = 100.0;

  /// called when selected value changes
  final ValueChanged<num> onChanged;

  /// min value user can pick
  final int minValue;

  /// max value user can pick
  final int maxValue;

  /// If the widget is disabled.
  final bool disabled;

  /// inidcates how many decimal places to show
  /// e.g. 0=>[1,2,3...], 1=>[1.0, 1.1, 1.2...]  2=>[1.00, 1.01, 1.02...]
  final int decimalPlaces;

  /// height of every list element in pixels
  final double itemExtent;

  /// view will always contain only 3 elements of list in pixels
  final double _listViewHeight;

  /// width of list view in pixels
  final double listViewWidth;

  /// ScrollController used for integer list
  final ScrollController intScrollController;

  /// ScrollController used for decimal list
  final ScrollController decimalScrollController;

  /// Currently selected integer value
  final int initialValue;

  /// Currently selected decimal value
  final int selectedDecimalValue;

  @override
  NumberPickerState createState() {
    return NumberPickerState();
  }
}

///
/// State for the number picker.  Used to acces the current internal state
/// of the picker.
///
class NumberPickerState extends State<NumberPicker> {
  //
  //----------------------------- PUBLIC ------------------------------
  //

  /// Animate to the specific integer.
  void animateInt(int valueToSelect) {
    _animate(widget.intScrollController,
        (valueToSelect - widget.minValue) * widget.itemExtent);
  }

  /// Animate to the specific decimal.
  void animateDecimal(int decimalValue) {
    _animate(widget.decimalScrollController, decimalValue * widget.itemExtent);
  }

  /// Animate to the specific integer and decimal.
  void animateDecimalAndInteger(double valueToSelect) {
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
    var themeData = Theme.of(context);

    if (widget.decimalPlaces == 0) {
      return _integerListView(themeData);
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _integerListView(themeData),
          _decimalListView(themeData),
        ],
      );
    }
  }

  Widget _integerListView(ThemeData themeData) {
    var defaultStyle = themeData.textTheme.bodyText2;
    var selectedStyle =
        themeData.textTheme.headline5.copyWith(color: themeData.accentColor);
    if (widget.disabled) {
      defaultStyle = defaultStyle.copyWith(color: themeData.disabledColor);
      selectedStyle = defaultStyle;
    }

    var itemCount = widget.maxValue - widget.minValue + 3;

    return NotificationListener<Notification>(
      onNotification: _onIntegerNotification,
      child: Container(
        height: widget._listViewHeight,
        width: widget.listViewWidth,
        child: ListView.builder(
          controller: widget.intScrollController,
          itemExtent: widget.itemExtent,
          itemCount: itemCount,
          physics: widget.disabled
              ? NeverScrollableScrollPhysics()
              : AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            var value = widget.minValue + index - 1;

            //define special style for selected (middle) element
            var itemStyle =
                value == widget.initialValue ? selectedStyle : defaultStyle;

            var isExtra = index == 0 || index == itemCount - 1;

            return isExtra
                ? Container() //empty first and last element
                : Center(
                    child: Text(value.toString(), style: itemStyle),
                  );
          },
        ),
      ),
    );
  }

  Widget _decimalListView(ThemeData themeData) {
    var defaultStyle = themeData.textTheme.bodyText2;
    var selectedStyle =
        themeData.textTheme.headline5.copyWith(color: themeData.accentColor);

    var itemCount = widget.initialValue == widget.maxValue.toInt()
        ? 3
        : (pow(10, widget.decimalPlaces) + 2).toInt();

    return NotificationListener<Notification>(
      onNotification: _onDecimalNotification,
      child: Container(
        height: widget._listViewHeight,
        width: widget.listViewWidth,
        child: ListView.builder(
          controller: widget.decimalScrollController,
          itemExtent: widget.itemExtent,
          itemCount: itemCount,
          physics: widget.disabled
              ? NeverScrollableScrollPhysics()
              : AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            var value = index - 1;

            //define special style for selected (middle) element
            var itemStyle = value == widget.selectedDecimalValue
                ? selectedStyle
                : defaultStyle;

            var isExtra = index == 0 || index == itemCount - 1;

            return isExtra
                ? Container() //empty first and last element
                : Center(
                    child: Text(
                        value.toString().padLeft(widget.decimalPlaces, '0'),
                        style: itemStyle),
                  );
          },
        ),
      ),
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
      var intIndexOfMiddleElement =
          (notification.metrics.pixels + widget._listViewHeight / 2) ~/
              widget.itemExtent;
      var intValueInTheMiddle = widget.minValue + intIndexOfMiddleElement - 1;

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
            //if value is maxValue, then return that value and ignore decimal
            newValue = (intValueInTheMiddle.toDouble());
            animateDecimal(0);
          } else {
            //return integer+decimal
            var decimalPart = _toDecimal(widget.selectedDecimalValue);
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
      var indexOfMiddleElement =
          (notification.metrics.pixels + widget._listViewHeight / 2) ~/
              widget.itemExtent;
      var decimalValueInTheMiddle = indexOfMiddleElement - 1;

      if (_userStoppedScrolling(notification, widget.decimalScrollController)) {
        //center selected value
        animateDecimal(decimalValueInTheMiddle);
      }

      //update selection
      if (widget.initialValue != widget.maxValue &&
          decimalValueInTheMiddle != widget.selectedDecimalValue) {
        var decimalPart = _toDecimal(decimalValueInTheMiddle);
        var newValue = ((widget.initialValue + decimalPart).toDouble());
        widget.onChanged(newValue);
      }
    }
    return true;
  }

  ///indicates if user has stopped scrolling so we can center value in the middle
  bool _userStoppedScrolling(
      Notification notification, ScrollController scrollController) {
    return notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle &&
        // ignore: invalid_use_of_protected_member
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
        duration: Duration(seconds: 1), curve: ElasticOutCurve());
  }
}
