import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:video_player/video_player.dart';

import 'gamestatus.dart';

///
/// Show the current state of the game in the overlay on top of the
/// video (or beside the video)
///
class GameStatusOverlay extends StatelessWidget {
  /// The status of the game to display.
  final GameStatus status;

  /// If the overlay has been initialized.
  final bool initialized;

  /// The game status as an overlay.
  GameStatusOverlay({@required this.status, this.initialized = true});

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return Container();
    }
    var ptsTheme = Theme.of(context).textTheme.headline5;
    return Container(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
        padding: EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(status.ptsFor.toString(), style: ptsTheme),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text('-', style: ptsTheme),
            ),
            Text(status.ptsAgainst.toString(), style: ptsTheme),
          ],
        ),
      ),
    );
  }
}

///
/// Show the status for a specific video player overlay
///
class GameStatusVideoPlayerOverlay extends StatefulWidget {
  /// The current game state.
  final SingleGameState state;

  /// The controller to deal with.
  final VideoPlayerController controller;

  /// Show the status as an overlay.
  GameStatusVideoPlayerOverlay({@required this.state, this.controller});

  @override
  State<StatefulWidget> createState() {
    return _GameStatusVideoPlayerOverlayState();
  }
}

class _GameStatusVideoPlayerOverlayState
    extends State<GameStatusVideoPlayerOverlay> {
  VoidCallback _listener;
  GameStatus _status;

  @override
  void initState() {
    _status = GameStatus(
        state: widget.state, position: widget.controller.value.position);
    super.initState();
    _listener = () {
      if (!mounted) {
        return;
      }
      if (_status.nextEvent < widget.controller.value.position) {
        setState(() {});
      }
    };
    widget.controller.addListener(_listener);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return GameStatusOverlay(
      status: _status,
      initialized: widget.controller.value.isInitialized,
    );
  }
}

///
/// Shows an overlay for the specific position in the data
///
class GameStatusPositionOverlay extends StatelessWidget {
  /// The position in the game.
  final SingleGameState state;

  /// The current duration point.
  final Duration position;

  /// Showing the overlay on the video.
  GameStatusPositionOverlay({@required this.state, this.position});

  @override
  Widget build(BuildContext context) {
    var status = GameStatus(state: state, position: position);
    return GameStatusOverlay(
      status: status,
      initialized: true,
    );
  }
}
