import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef void OnFabMiniMenuItemPressed();

class FabMiniMenuItemWidget extends StatelessWidget {
  FabMiniMenuItemWidget(
      {Key key,
      this.elevation = 1.0,
      this.textColor,
      this.tooltip,
      this.text,
      this.icon,
      this.index,
      this.fabColor,
      this.chipColor,
      this.controller,
      this.onPressed})
      : super(key: key);
  final double elevation;
  final String text;
  @required
  final Icon icon;
  int index;
  @required
  final Color fabColor;
  @required
  final OnFabMiniMenuItemPressed onPressed;
  AnimationController controller;

  final Color chipColor;
  final String tooltip;
  final Color textColor;

  void updateAnimationController(AnimationController controller) {
    if (this.controller == null) {
      this.controller = controller;
    }
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
    return new Container(
      margin: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 8.0),
            child: new ScaleTransition(
              scale: new CurvedAnimation(
                parent: controller,
                curve: new Interval(
                  ((index + 1) / 10),
                  1.0,
                  curve: Curves.linear,
                ),
              ),
              child: text != null
                  ? new Chip(
                      label: new Text(
                        text,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: new TextStyle(
                            color: textColor, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: chipColor,
                    )
                  : null,
            ),
          ),
          new ScaleTransition(
            scale: new CurvedAnimation(
              parent: controller,
              curve:
                  new Interval(((index + 1) / 10), 1.0, curve: Curves.linear),
            ),
            child: new FloatingActionButton(
              elevation: elevation,
              mini: true,
              backgroundColor: fabColor,
              heroTag: "Inner fab " + index.toString(),
              tooltip: tooltip,
              child: icon,
              onPressed: onPressed,
            ),
          )
        ],
      ),
    );
  }
}
