import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart' as intl;

import 'gamestatus.dart';
import '../../services/messages.dart';

///
/// Show the current state of the game in the overlay on top of the
/// video (or beside the video)
///
class MediaStatusOverlay extends StatelessWidget {
  /// The status of the game to display.
  final GameStatus status;

  /// The game status as an overlay.
  MediaStatusOverlay({@required this.status});

  @override
  Widget build(BuildContext context) {
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
class MediaStatusVideoPlayerOverlay extends StatefulWidget {
  /// The media to show the overlay for.
  final MediaInfo media;

  /// The position to start at.
  final Duration initialPosition;

  /// The stream to use for the position.
  final Stream<Duration> positionStream;

  /// Called when the player button is clicked.
  final ValueSetter<String> onPlayerPressed;

  /// Called when the team button is clicked.
  final ValueSetter<String> onTeamPressed;

  /// Show the status as an overlay.
  MediaStatusVideoPlayerOverlay(
      {@required this.media,
      this.positionStream,
      this.initialPosition,
      this.onPlayerPressed,
      this.onTeamPressed});

  @override
  State<StatefulWidget> createState() {
    return _MediaStatusVideoPlayerOverlayState();
  }
}

class _MediaStatusVideoPlayerOverlayState
    extends State<MediaStatusVideoPlayerOverlay> {
  GameStatus _status;
  StreamSubscription<Duration> _streamSub;

  @override
  void initState() {
    super.initState();
    _status = GameStatus.empty();
    _streamSub = widget.positionStream?.listen((event) {
      if (!mounted) {
        return;
      }
      if (_status.nextEvent < widget.initialPosition) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSub?.cancel();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final _dateFormat = intl.DateFormat.yMMMMEEEEd(Messages.of(context).locale);
    final _timeFormat = intl.DateFormat.jm(Messages.of(context).locale);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.white38,
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.media.description,
              style: Theme.of(context).textTheme.bodyText1,
              textScaleFactor: 1.5,
              maxLines: 5,
              overflow: TextOverflow.fade,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  _dateFormat.format(widget.media.startAt),
                ),
                SizedBox(width: 20),
                Text(
                  _timeFormat.format(widget.media.startAt),
                ),
              ],
            ),
            ButtonBar(
              children: [
                widget.media.playerUid.isNotEmpty &&
                        widget.onPlayerPressed != null
                    ? TextButton(
                        onPressed: () =>
                            widget.onPlayerPressed(widget.media.playerUid),
                        child: Text(Messages.of(context).playerButton),
                      )
                    : SizedBox(width: 0),
                widget.media.teamUid.isNotEmpty && widget.onTeamPressed != null
                    ? TextButton(
                        onPressed: () =>
                            widget.onTeamPressed(widget.media.teamUid),
                        child: Text(Messages.of(context).teamButton),
                      )
                    : SizedBox(width: 0),
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                      context,
                      '/Season/Media/'
                      '${widget.media.seasonUid}/'
                      '${widget.media.uid}'),
                  child: Text(Messages.of(context).editButton),
                ),
              ],
            )
          ],
        ),
      ),
    );
    return MediaStatusOverlay(
      status: _status,
    );
  }
}
