import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// Picker to show the inprogess game and select the current state
///
class InProgressGamePicker extends StatelessWidget {
  /// constructor for in progress game picker
  InProgressGamePicker({
    @required this.initialValue,
    @required this.onChanged,
    Key key,
    this.disabled = false,
    this.itemExtent = defaultItemExtent,
    this.listViewWidth = defaultListViewWidth,
  })  : assert(initialValue != null),
        scrollController = ScrollController(
          initialScrollOffset:
              ((GameInProgress.getIndex(initialValue)) * itemExtent).toDouble(),
        ),
        _listViewHeight = 3 * itemExtent,
        super(key: key);

  /// height of every list element
  static const double defaultItemExtent = 50.0;

  /// width of list view
  static const double defaultListViewWidth = 100.0;

  /// called when selected value changes
  final ValueChanged<GameInProgress> onChanged;

  /// If the widget is disabled.
  final bool disabled;

  /// height of every list element in pixels
  final double itemExtent;

  /// view will always contain only 3 elements of list in pixels
  final double _listViewHeight;

  /// width of list view in pixels
  final double listViewWidth;

  /// ScrollController used for integer list
  final ScrollController scrollController;

  /// Currently selected integer value
  final GameInProgress initialValue;

  //
  //----------------------------- PUBLIC ------------------------------
  //

  ///
  /// Animates a move to the specific inprogess value
  ///
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
    var themeData = Theme.of(context);

    return _inProgressListView(themeData);
  }

  Widget _inProgressListView(ThemeData themeData) {
    var defaultStyle = themeData.textTheme.bodyText2;
    var selectedStyle =
        themeData.textTheme.bodyText2.copyWith(color: themeData.accentColor);
    if (disabled) {
      defaultStyle = defaultStyle.copyWith(color: themeData.disabledColor);
      selectedStyle = defaultStyle.copyWith(color: themeData.accentColor);
    }

    var itemCount = GameInProgress.values.length + 2;

    return NotificationListener<Notification>(
      onNotification: _onScrollNotification,
      child: Container(
        height: _listViewHeight,
        width: listViewWidth,
        child: ListView.builder(
          controller: scrollController,
          itemExtent: itemExtent,
          itemCount: itemCount,
          physics: disabled
              ? NeverScrollableScrollPhysics()
              : AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            var isExtra = index == 0 || index == itemCount - 1;
            if (isExtra) {
              return Container();
            }
            //define special style for selected (middle) element
            var value = GameInProgress.valuesByIndex[index];
            var itemStyle =
                value == initialValue ? selectedStyle : defaultStyle;

            return Center(
              child: Text(Messages.of(context).gameInProgress(value),
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

  bool _onScrollNotification(Notification notification) {
    if (disabled) {
      return false;
    }
    if (notification is ScrollNotification && !disabled) {
      //calculate
      var intIndexOfMiddleElement =
          (notification.metrics.pixels + _listViewHeight / 2) ~/ itemExtent;
      var intValueInTheMiddle = intIndexOfMiddleElement - 1;

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

  /// indicates if user has stopped scrolling so we can center value in the middle
  bool _userStoppedScrolling(
      Notification notification, ScrollController scrollController) {
    return notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle &&
        // ignore: invalid_use_of_protected_member
        scrollController.position.activity is! HoldScrollActivity;
  }

  /// scroll to selected value
  void _animate(ScrollController scrollController, double value) {
    scrollController.animateTo(value,
        duration: Duration(seconds: 1), curve: ElasticOutCurve());
  }
}
