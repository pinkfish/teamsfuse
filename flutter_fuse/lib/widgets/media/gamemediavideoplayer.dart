import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Boolean callback to use for the playing state.
typedef BoolCallback = void Function(bool state);

///
/// Shows video for the specific game.
///
class GameMediaVideoPlayer extends StatefulWidget {
  /// The video to play.
  final MediaInfo video;

  /// Where to start
  final DateTime start;

  /// The controller and stream.
  final StreamController<Duration> positionController;

  /// The notifier to use when updating the playing state.
  final BoolCallback onPlayingStateChanged;

  /// The stream exposed that has all the events on it.
  Stream<Duration> get positionStream => positionController.stream;

  /// Create the video player with the right details.
  GameMediaVideoPlayer(
      {@required this.video, this.start, this.onPlayingStateChanged, Key key})
      : positionController = StreamController<Duration>.broadcast(),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MediaVideoPlayerState();
  }
}

class _MediaVideoPlayerState extends State<GameMediaVideoPlayer> {
  VideoPlayerController _controller;
  YoutubePlayerController _youtubeController;
  Uri _currentUrl;
  DateTime _lastStart;
  double _volume = 1.0;
  bool _isMuted = false;
  bool _currentlyPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.onPlayingStateChanged != null) {
      widget.onPlayingStateChanged(_currentlyPlaying);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _youtubeController?.dispose();
  }

  void _updateMedia(MediaInfo media) async {
    Uri newUrl;

    switch (media.type) {
      case MediaType.videoOnDemand:
        newUrl = media.url;
        break;
      case MediaType.youtubeID:
        newUrl =
            Uri.parse('https://wwww.youtube.com/watch?v=${media.youtubeID}');
        break;
      default:
        newUrl = Uri.file('');
        break;
    }
    if (newUrl != _currentUrl) {
      _currentUrl = newUrl;
      if (media.type == MediaType.videoOnDemand) {
        _youtubeController?.dispose();
        _youtubeController = null;
        var downloadUrl = newUrl.toString();
        if (newUrl.scheme == 'gs') {
          var ref = FirebaseStorage.instance.refFromURL(newUrl.toString());
          downloadUrl = await ref.getDownloadURL();
        }
        await _controller?.dispose();
        _controller = VideoPlayerController.network(downloadUrl);
        _controller.addListener(() {
          if (!mounted) {
            return;
          }
          var playing = false;
          if (_controller.value.isInitialized) {
            widget.positionController.add(_controller.value.position);
            playing = _controller.value.isPlaying;
          }
          if (playing != _currentlyPlaying) {
            _currentlyPlaying = playing;
            if (widget.onPlayingStateChanged != null) {
              widget.onPlayingStateChanged(_currentlyPlaying);
            }
          }
        });
        try {
          await _controller.initialize();
          // If the start point is set, go to there.
          if (widget.start != null) {
            seekTo(widget.start);
          }
          await _controller.pause();
          _lastStart = widget.start;
          setState(() {});
        } catch (e) {
          print('Error $e');
        }
      } else {
        await _controller?.dispose();
        _controller = null;
        if (_youtubeController == null) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: media.youtubeID,
            flags: YoutubePlayerFlags(
              autoPlay: false,
              controlsVisibleAtStart: true,
            ),
          );
          var loaded = false;
          _youtubeController.addListener(() {
            if (!mounted) {
              return;
            }
            var playing = false;
            if (_youtubeController.value.isReady) {
              // Pause it once it loads.
              if (!loaded) {
                loaded = true;
                _youtubeController.pause();
              }
              widget.positionController.add(_youtubeController.value.position);
              playing = _youtubeController.value.isPlaying;
            }
            if (playing != _currentlyPlaying) {
              _currentlyPlaying = playing;
              if (widget.onPlayingStateChanged != null) {
                widget.onPlayingStateChanged(_currentlyPlaying);
              }
            }
            if (_youtubeController.value.hasError) {
              print('youtube error ${_youtubeController.value.errorCode}');
            }
          });
        } else {
          _youtubeController.load(media.youtubeID);
        }
        print(
            'youtube ${media.youtubeID} ${_youtubeController.initialVideoId}');
        try {
          // If the start point is set, go to there.
          if (widget.start != null) {
            seekTo(widget.start);
          }
          //_youtubeController.pause();
          print('youtube ${media.youtubeID} pause');
          _lastStart = widget.start;
          setState(() {});
        } catch (e) {
          print('Error $e');
        }
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
    if (_youtubeController != null) {
      _youtubeController.seekTo(pos);
      _youtubeController.play();
    }
  }

  Widget _showVideoPlayer(BuildContext context) {
    Widget player;
    double aspectRatio;

    if (_controller != null && _controller.value.isInitialized) {
      player = VideoPlayer(_controller);
      aspectRatio = _controller.value.aspectRatio;
    } else if (_youtubeController != null) {
      print('Creating youtube player ${_youtubeController.value}');
      player = YoutubePlayer(
        controller: _youtubeController,
        showVideoProgressIndicator: true,
        progressColors: ProgressBarColors(
          playedColor: Colors.amber,
          handleColor: Colors.amberAccent,
        ),
        progressIndicatorColor: Colors.blueAccent,
      );
      aspectRatio = 16 / 9;
    } else {
      print('No youtube player ${_youtubeController?.value}');
      return CircularProgressIndicator();
    }
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: player,
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateMedia(widget.video);

    // Seek if the time point changes.
    if (widget.start != null) {
      if (_lastStart == null || widget.start.compareTo(_lastStart) != 0) {
        seekTo(widget.start);
        _lastStart = widget.start;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _showVideoPlayer(context),
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
            _youtubeController != null
                ? SizedBox(width: 0)
                : _controller != null && _controller.value.isPlaying
                    ? IconButton(
                        icon: const Icon(Icons.pause),
                        onPressed: () => _controller
                            .pause()
                            .then((v) => setState(() => true)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => _controller
                            .play()
                            .then((v) => setState(() => true)),
                      ),
          ],
        ),
      ],
    );
  }
}
