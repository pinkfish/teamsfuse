import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'fabminimenuitem.dart';

///
/// A dialer for the floating action bar, pulls up a menu when clicked.
///
class FabDialer extends StatefulWidget {
  /// constructor.
  const FabDialer(
      {@required this.menu,
      @required this.color,
      @required this.icon,
      this.disabled = false});

  /// The menu items to display.
  final List<FabMiniMenuItemWidget> menu;

  /// color of the button.
  final Color color;

  /// Icon for the button.
  final Icon icon;

  /// If the dialer is disabled.
  final bool disabled;

  @override
  FabDialerState createState() => FabDialerState();
}

///
/// The state for the dialer, dealing with openness and closedness.
///
class FabDialerState extends State<FabDialer> with TickerProviderStateMixin {
  int _angle = 90;
  bool _isRotated = true;

  /// The controller for the animation.
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

  /// Closes the dialer.
  void closeDialer() {
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

  @override
  Widget build(BuildContext context) {
    var index = 0;
    for (var widget in widget.menu) {
      widget.setDetails(index++, controller, this);
    }

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
