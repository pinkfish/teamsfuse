import 'package:flutter/material.dart';
import 'fabminimenuitem.dart';

class FabDialer extends StatefulWidget {
  const FabDialer({this.menu, this.color, this.icon});

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

  AnimationController _controller;

  @override
  void initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _controller.reverse();

    super.initState();
  }

  void _rotate() {
    setState(() {
      if (_isRotated) {
        _angle = 45;
        _isRotated = false;
        _controller.forward();
      } else {
        _angle = 90;
        _isRotated = true;
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Update all the menu items.
    int index = 0;
    widget.menu.forEach((FabMiniMenuItemWidget widget) {
      widget.index = index++;
      widget.updateAnimationController(_controller);
    });
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
