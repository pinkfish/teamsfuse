import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/widgets/blocs/singlegameprovider.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:video_player/video_player.dart';

import 'gamestatusoverlay.dart';

///
/// Shows video for the specific game.
///
class GameMediaVideoPlayer extends StatefulWidget {
  /// The video to play.
  final MediaInfo video;

  /// Where to start
  final DateTime start;

  GameMediaVideoPlayer({@required this.video, this.start, Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MediaVideoPlayerState();
  }
}

class _MediaVideoPlayerState extends State<GameMediaVideoPlayer> {
  VideoPlayerController _controller;
  Uri _currentUrl;
  DateTime _lastStart;
  double _volume = 1.0;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  void _updateUrl(Uri newUrl) async {
    if (newUrl != _currentUrl) {
      _currentUrl = newUrl;
      var downloadUrl = newUrl.toString();
      if (newUrl.scheme == 'gs') {
        var ref = FirebaseStorage.instance.refFromURL(newUrl.toString());
        downloadUrl = await ref.getDownloadURL();
      }
      await _controller?.dispose();
      _controller = VideoPlayerController.network(downloadUrl);
      try {
        await _controller.initialize();
        // If the start point is set, go to there.
        if (widget.start != null) {
          seekTo(widget.start);
        }
        _lastStart = widget.start;
        setState(() {});
      } catch (e) {
        print('Error $e');
      }
    }
  }

  ///
  /// Seek to specific place in the video.
  ///
  void seekTo(DateTime timestamp) {
    var pos = timestamp
        .subtract(Duration(seconds: 5))
        .difference(widget.video.startAt);
    if (pos.inSeconds < 0) {
      pos = Duration(seconds: 0);
    }
    if (_controller != null) {
      _controller.seekTo(pos);
      _controller.play().then((v) => setState(() => true));
    }
  }

  @override
  Widget build(BuildContext context) {
    var newUrl = widget.video.url;
    _updateUrl(newUrl);

    // Seek if the time point changes.
    if (widget.start != null) {
      if (_lastStart == null || widget.start.compareTo(_lastStart) != 0) {
        seekTo(widget.start);
        _lastStart = widget.start;
      }
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: _controller != null && _controller.value.isInitialized
                ? Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      widget.video.gameUid != null
                          ? SingleGameProvider(
                              gameUid: widget.video.gameUid,
                              builder: (context, singleGameBloc) => BlocBuilder(
                                  bloc: singleGameBloc,
                                  builder: (context, gameState) {
                                    singleGameBloc.add(SingleGameLoadEvents());
                                    return GameStatusVideoPlayerOverlay(
                                        controller: _controller,
                                        state: gameState);
                                  }),
                            )
                          : SizedBox(
                              height: 0,
                            )
                    ],
                  )
                : CircularProgressIndicator(),
          ),
        ),
        _controller != null
            ? VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
              )
            : SizedBox(height: 10.0),
        ButtonBar(
          children: <Widget>[
            IconButton(
              icon: _isMuted ? Icon(Icons.volume_off) : Icon(Icons.volume_mute),
              onPressed: () => setState(() {
                _isMuted = !_isMuted;
                if (!_isMuted) {
                  _controller.setVolume(_volume);
                } else {
                  _controller.setVolume(0.0);
                }
              }),
            ),
            Slider(
              onChanged: _isMuted
                  ? null
                  : (double value) => setState(() {
                        _volume = value;
                        if (!_isMuted) {
                          _controller.setVolume(_volume);
                        } else {
                          _controller.setVolume(0.0);
                        }
                      }),
              value: _volume,
              max: 1.0,
              min: 0.0,
            ),
            _controller != null && _controller.value.isPlaying
                ? IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () =>
                        _controller.pause().then((v) => setState(() => true)),
                  )
                : IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () =>
                        _controller.play().then((v) => setState(() => true)),
                  ),
            SizedBox(width: 20.0),
          ],
        ),
        Text(
          widget.video.description,
          overflow: TextOverflow.fade,
        ),
      ],
    );
  }
}
