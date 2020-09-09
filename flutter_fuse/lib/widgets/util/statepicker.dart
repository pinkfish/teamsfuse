import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

class InProgressGamePicker extends StatelessWidget {
  ///constructor for integer number picker
  InProgressGamePicker({
    @required this.initialValue,
    @required this.onChanged,
    Key key,
    this.disabled = false,
    this.itemExtent = defaultItemExtent,
    this.listViewWidth = defaultListViewWidth,
  })  : assert(initialValue != null),
        scrollController = new ScrollController(
          initialScrollOffset:
              ((GameInProgress.getIndex(initialValue)) * itemExtent).toDouble(),
        ),
        _listViewHeight = 3 * itemExtent,
        super(key: key);

  ///height of every list element
  static const double defaultItemExtent = 50.0;

  ///width of list view
  static const double defaultListViewWidth = 100.0;

  ///called when selected value changes
  final ValueChanged<GameInProgress> onChanged;

  /// If the widget is disabled.
  final bool disabled;

  ///height of every list element in pixels
  final double itemExtent;

  ///view will always contain only 3 elements of list in pixels
  final double _listViewHeight;

  ///width of list view in pixels
  final double listViewWidth;

  ///ScrollController used for integer list
  final ScrollController scrollController;

  ///Currently selected integer value
  final GameInProgress initialValue;

  //
  //----------------------------- PUBLIC ------------------------------
  //

  void animateMove(GameInProgress valueToSelect) {
    _animate(
        scrollController, GameInProgress.getIndex(valueToSelect) * itemExtent);
  }

  //
  //----------------------------- VIEWS -----------------------------
  //

  ///main widget
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return _inProgressListView(themeData);
  }

  Widget _inProgressListView(ThemeData themeData) {
    TextStyle defaultStyle = themeData.textTheme.body1;
    TextStyle selectedStyle =
        themeData.textTheme.body1.copyWith(color: themeData.accentColor);
    if (disabled) {
      defaultStyle = defaultStyle.copyWith(color: themeData.disabledColor);
      selectedStyle = defaultStyle.copyWith(color: themeData.accentColor);
    }

    int itemCount = GameInProgress.values.length + 2;

    return new NotificationListener<Notification>(
      child: new Container(
        height: _listViewHeight,
        width: listViewWidth,
        child: new ListView.builder(
          controller: scrollController,
          itemExtent: itemExtent,
          itemCount: itemCount,
          physics: disabled
              ? new NeverScrollableScrollPhysics()
              : new AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            bool isExtra = index == 0 || index == itemCount - 1;
            if (isExtra) {
              return new Container();
            }
            //define special style for selected (middle) element
            GameInProgress value = GameInProgress.valuesByIndex[index];
            final TextStyle itemStyle =
                value == initialValue ? selectedStyle : defaultStyle;

            return new Center(
              child: new Text(Messages.of(context).gameinprogress(value),
                  style: itemStyle),
            );
          },
        ),
      ),
      onNotification: _onScrollNotification,
    );
  }

  //
  // ----------------------------- LOGIC -----------------------------
  //

  bool _onScrollNotification(Notification notification) {
    if (disabled) {
      return false;
    }
    if (notification is ScrollNotification && !disabled) {
      //calculate
      int intIndexOfMiddleElement =
          (notification.metrics.pixels + _listViewHeight / 2) ~/ itemExtent;
      int intValueInTheMiddle = intIndexOfMiddleElement - 1;

      if (_userStoppedScrolling(notification, scrollController)) {
        //center selected value
        animateMove(GameInProgress.valuesByIndex[intValueInTheMiddle]);
      }

      //update selection
      GameInProgress newValue;

      //return integer value
      if (intValueInTheMiddle < 0) {
        intValueInTheMiddle = 0;
      } else if (intValueInTheMiddle >= GameInProgress.values.length) {
        intValueInTheMiddle = GameInProgress.values.length - 1;
      }
      newValue = GameInProgress.valuesByIndex[intValueInTheMiddle];

      onChanged(newValue);
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

  ///scroll to selected value
  void _animate(ScrollController scrollController, double value) {
    scrollController.animateTo(value,
        duration: new Duration(seconds: 1), curve: new ElasticOutCurve());
  }
}
