import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'fabdialer.dart';

typedef void OnFabMiniMenuItemPressed();

class MenuDetails {
  int index;
  AnimationController controller;
  FabDialerState dialer;
}

class FabMiniMenuItemWidget extends StatelessWidget {
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
  final double elevation;
  final String text;
  final Icon icon;
  final Color fabColor;
  final OnFabMiniMenuItemPressed onPressed;
  final MenuDetails details = MenuDetails();

  final Color chipColor;
  final String tooltip;
  final Color textColor;

  void _doPress() {
    details.controller.animateTo(0.0);
    details.dialer.closeDialer();
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    Color chipColor = this.chipColor;
    if (chipColor == null) {
      chipColor = Theme.of(context).cardColor;
    }
    Color textColor = this.textColor;
    if (textColor == null) {
      textColor = Theme.of(context).textTheme.body1.color;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: details.controller,
                curve: Interval(
                  ((details.index + 1) / 10),
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
              parent: details.controller,
              curve: Interval(((details.index + 1) / 10), 1.0,
                  curve: Curves.linear),
            ),
            child: FloatingActionButton(
              elevation: elevation,
              mini: true,
              backgroundColor: fabColor,
              heroTag: "Inner fab " + details.index.toString(),
              tooltip: tooltip,
              child: icon,
              onPressed: _doPress,
            ),
          )
        ],
      ),
    );
  }
}
