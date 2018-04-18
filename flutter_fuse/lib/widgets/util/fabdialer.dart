import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'fabminimenuitem.dart';

class FabDialer extends StatefulWidget {
  const FabDialer(
      {@required this.menu, @required this.color, @required this.icon});

  final List<FabMiniMenuItemWidget> menu;
  final Color color;
  final Icon icon;

  @override
  FabDialerState createState() => new FabDialerState();
}

class FabDialerState extends State<FabDialer> with TickerProviderStateMixin {
  FabDialerState();

  int _angle = 90;
  bool _isRotated = true;

  AnimationController controller;

  @override
  void deactivate() {
    //closeDialer();
    super.deactivate();
  }

  @override
  void initState() {
    controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    controller.reverse();

    super.initState();
  }

  void closeDialer() {
    if (_isRotated) {
      setState(() {
        _isRotated = false;
      });
    }
  }

  void _rotate() {
    setState(() {
      if (_isRotated) {
        _angle = 45;
        _isRotated = false;
        controller.forward();
      } else {
        _angle = 90;
        _isRotated = true;
        controller.reverse();
      }
    });
  }

  int getIndex(FabMiniMenuItemWidget fabwidget) {
    return widget.menu.indexOf(fabwidget);
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
    widget.menu.forEach((FabMiniMenuItemWidget widget) {
      widget.details.controller = controller;
      widget.details.index = index++;
    });
    // Update all the menu items.
    return new Container(
      margin: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: widget.menu,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new FloatingActionButton(
                child: new RotationTransition(
                  turns: new AlwaysStoppedAnimation(_angle / 360),
                  child: widget.icon,
                ),
                backgroundColor: widget.color,
                onPressed: _rotate,
              )
            ],
          ),
        ],
      ),
    );
  }
}
