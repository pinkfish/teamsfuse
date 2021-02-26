import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Shows the game duration and keeps it updated while the clock is running
///
class GameDuration extends StatefulWidget {
  final TextStyle style;
  final double textScaleFactor;
  final Game game;

  GameDuration({this.game, this.textScaleFactor, this.style});

  @override
  State<StatefulWidget> createState() {
    return _GameDurationState();
  }
}

class _GameDurationState extends State<GameDuration> {
  Timer _timer;

  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.game == null) {
      return SizedBox(
        height: 0,
      );
    }
    if (widget.game.runningFrom != null) {
      if (_timer == null) {
        _timer = Timer.periodic(Duration(seconds: 1), (t) => setState(() {}));
      }
    } else if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }

    int diff = 0;
    if (widget.game.runningFrom != null) {
      diff += DateTime.now().difference(widget.game.runningFrom).inSeconds;
    }
    diff += widget.game.gameTime.inSeconds;

    return Text(
      twoDigits(diff ~/ 60) + ":" + twoDigits(diff % 60),
      style: widget.style,
      textScaleFactor: widget.textScaleFactor,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
