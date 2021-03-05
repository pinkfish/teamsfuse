import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'fabdialer.dart';

/// Function callback for when an item is pressed.
typedef OnFabMiniMenuItemPressed = void Function();

/// The details of the menu.
class _MenuDetails {
  int index;
  AnimationController controller;
  FabDialerState dialer;
}

///
/// A menu item to display the fab mini popup.
///
class FabMiniMenuItemWidget extends StatelessWidget {
  /// Constructor.
  FabMiniMenuItemWidget(
      {@required this.icon,
      @required this.fabColor,
      @required this.onPressed,
      Key key,
      this.elevation = 1.0,
      this.textColor,
      this.tooltip,
      this.text,
      this.chipColor})
      : super(key: key);

  /// Elevation to show a shadow for.
  final double elevation;

  /// The text to display.
  final String text;

  /// The icon to display.
  final Icon icon;

  /// The color of the button.
  final Color fabColor;

  /// What to do when the button is pressed.
  final OnFabMiniMenuItemPressed onPressed;
  final _MenuDetails _details = _MenuDetails();

  /// Color of the chip to use.
  final Color chipColor;

  /// The tooltip to display.
  final String tooltip;

  /// The color of the text.
  final Color textColor;

  void _doPress() {
    _details.controller.animateTo(0.0);
    _details.dialer.closeDialer();
    onPressed();
  }

  /// Sets the details for the fab menu item so it can render properly.
  void setDetails(
      int index, AnimationController controller, FabDialerState dialer) {
    _details.index = index;
    _details.controller = controller;
    _details.dialer = dialer;
  }

  @override
  Widget build(BuildContext context) {
    var chipColor = this.chipColor;
    chipColor ??= Theme.of(context).cardColor;
    var textColor = this.textColor;
    textColor ??= Theme.of(context).textTheme.bodyText2.color;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _details.controller,
                curve: Interval(
                  ((_details.index + 1) / 10),
                  1.0,
                  curve: Curves.linear,
                ),
              ),
              child: text != null
                  ? Chip(
                      label: Text(
                        text,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: chipColor,
                    )
                  : null,
            ),
          ),
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _details.controller,
              curve: Interval(((_details.index + 1) / 10), 1.0,
                  curve: Curves.linear),
            ),
            child: FloatingActionButton(
              elevation: elevation,
              mini: true,
              backgroundColor: fabColor,
              heroTag: 'Inner fab ${_details.index}',
              tooltip: tooltip,
              onPressed: _doPress,
              child: icon,
            ),
          )
        ],
      ),
    );
  }
}
