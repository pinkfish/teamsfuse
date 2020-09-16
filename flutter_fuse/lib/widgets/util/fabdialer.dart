import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'fabminimenuitem.dart';

class FabDialer extends StatefulWidget {
  const FabDialer(
      {@required this.menu,
      @required this.color,
      @required this.icon,
      this.disabled = false});

  final List<FabMiniMenuItemWidget> menu;
  final Color color;
  final Icon icon;
  final bool disabled;

  @override
  FabDialerState createState() => FabDialerState();
}

class FabDialerState extends State<FabDialer> with TickerProviderStateMixin {
  FabDialerState();

  int _angle = 90;
  bool _isRotated = true;

  AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    controller.reverse();

    super.initState();
  }

  void closeDialer() {
    print("closing $_isRotated");
    if (!_isRotated) {
      setState(() {
        _isRotated = true;
        _angle = 90;
        controller.reverse();
      });
    }
  }

  void _rotateTo(bool rotate) {
    if (widget.disabled || rotate == _isRotated) {
      return;
    }
    setState(() {
      if (rotate) {
        _angle = 90;
        _isRotated = true;
        controller.reverse();
      } else {
        _angle = 45;
        _isRotated = false;
        controller.forward();
      }
      print('$_isRotated $rotate $_angle');
    });
  }

  void _rotate() {
    print("rotate $_isRotated");
    _rotateTo(!_isRotated);
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
      widget.details.dialer = this;
    });

    // Update all the menu items.
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: widget.menu,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation<double>(_angle / 360),
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
