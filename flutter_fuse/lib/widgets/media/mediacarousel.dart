import 'dart:async';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart' as intl;
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../services/messages.dart';

///
/// Show the media in full screen.
///
class MediaCarousel extends StatefulWidget {
  /// The media to display
  final MediaInfo media;

  /// All the media we could display.
  final BuiltList<MediaInfo> allMedia;

  /// Called when the player button is clicked.
  final ValueSetter<String> onPlayerPressed;

  /// Called when the team button is clicked.
  final ValueSetter<String> onTeamPressed;

  /// Create a media carousel.
  MediaCarousel(this.media,
      {this.allMedia, this.onPlayerPressed, this.onTeamPressed});

  @override
  State<StatefulWidget> createState() {
    return _MediaCarouselState();
  }
}

class _MediaCarouselState extends State<MediaCarousel> {
  MediaInfo _currentMedia;
  int _index;

  Offset _panOffset = Offset(0, 0);
  Offset _startOffset = Offset(0, 0);
  bool _direction = true;

  double _scale = 1.0;
  double _imageScale = 1.0;
  Offset _zoomLocation = Offset(0, 0);

  Size _size = Size(0, 0);
  bool _zoomed = false;

  final sizeController = StreamController<bool>.broadcast();

  VideoPlayerController _videoController;
  YoutubePlayerController _youtubeController;
  String _loadedVideo = '';

  @override
  void initState() {
    super.initState();
    _currentMedia = widget.media;
    _index = widget.allMedia.indexOf(_currentMedia);
  }

  @override
  void dispose() {
    super.dispose();
    _videoController?.dispose();
    _youtubeController?.dispose();
  }

  double _realPixelToImage(double pos) {
    return pos * _scale;
  }

  double _imagePixelToReal(double pos) {
    return pos / _scale;
  }

  Offset _normalizeZoomLocation(Offset loc, BoxConstraints constraints) {
    final imageX = _realPixelToImage(loc.dx);
    final imageY = _realPixelToImage(loc.dy);
    final endX = imageX + _realPixelToImage(constraints.maxWidth);
    final endY = imageY + _realPixelToImage(constraints.maxHeight);

    if (endX > _size.width) {
      final maxX = _size.width - _realPixelToImage(constraints.maxWidth);
      loc = Offset(_imagePixelToReal(maxX), loc.dy);
    }
    if (endY > _size.height) {
      final maxY = _size.height - _realPixelToImage(constraints.maxHeight);
      loc = Offset(loc.dx, _imagePixelToReal(maxY));
    }
    if (loc.dx < 0) {
      loc = Offset(0, loc.dy);
    }
    if (loc.dy < 0) {
      loc = Offset(loc.dx, 0);
    }
    return loc;
  }

  void _nextImage() {
    _direction = false;
    _index++;
    if (_index >= widget.allMedia.length) {
      _index = 0;
    }
    _zoomLocation = Offset(0, 0);
    setState(() => _currentMedia = widget.allMedia[_index]);
  }

  void _prevImage() {
    _direction = true;
    _index--;
    if (_index < 0) {
      _index = widget.allMedia.length - 1;
    }
    _zoomLocation = Offset(0, 0);
    setState(() => _currentMedia = widget.allMedia[_index]);
  }

  @override
  Widget build(BuildContext context) {
    final _dateFormat = intl.DateFormat.yMMMMEEEEd(Messages.of(context).locale);
    final _timeFormat = intl.DateFormat.jm(Messages.of(context).locale);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onScaleUpdate: (scale) {
              _panOffset = scale.focalPoint - _startOffset;
              if (_zoomed) {
                if (scale.pointerCount == 2) {
                  final zoomScale = min(
                    constraints.maxWidth / _size.width,
                    constraints.maxHeight / _size.height,
                  );
                  print('$zoomScale $_imageScale -- $_scale ${scale.scale}');
                  final oldScale = _scale;
                  setState(() {
                    // Scale the top corner.
                    _scale =
                        (_scale / scale.scale).clamp(zoomScale, _imageScale);
                    final diffScale = oldScale / _scale;
                    _zoomLocation = _normalizeZoomLocation(
                        Offset(_zoomLocation.dx * diffScale,
                            _zoomLocation.dy * diffScale),
                        constraints);
                  });
                  print('$_scale');
                } else {
                  setState(() {
                    _zoomLocation -= _panOffset;
                    _zoomLocation =
                        _normalizeZoomLocation(_zoomLocation, constraints);
                  });
                }
              }
            },
            onScaleStart: (pan) {
              _panOffset = Offset(0, 0);
              _startOffset = pan.focalPoint;
            },
            onScaleEnd: (pan) {
              // If zoomed out, mark as not zoomed.
              if (_scale == _imageScale && _zoomed) {
                _zoomed = false;
              }
              // we are zoomed
              if (pan.pointerCount == 1 || pan.pointerCount == 0) {
                if (!_zoomed) {
                  if (_panOffset.dy < 60 && _panOffset.dy > -60) {
                    if (_panOffset.dx > 100) {
                      _nextImage();
                    }
                    if (_panOffset.dx < -100) {
                      _prevImage();
                    }
                  }
                }
              }
            },
            onDoubleTap: () {
              _zoomed = !_zoomed;
              if (_zoomed) {
                final zoomScale = min(
                  constraints.maxWidth / _size.width,
                  constraints.maxHeight / _size.height,
                );

                setState(() => _scale = zoomScale);
              } else {
                _zoomLocation = Offset(0, 0);
                setState(() => _scale = _imageScale);
              }
              print('double $_zoomed $_scale');
            },
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                final inAnimation = Tween<Offset>(
                        begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                    .animate(animation);
                final outAnimation = Tween<Offset>(
                        begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0))
                    .animate(animation);

                if (child.key == ValueKey(_currentMedia)) {
                  return ClipRect(
                    child: SlideTransition(
                      position: _direction ? inAnimation : outAnimation,
                      child: child,
                    ),
                  );
                } else {
                  return ClipRect(
                    child: SlideTransition(
                      position: _direction ? outAnimation : inAnimation,
                      child: child,
                    ),
                  );
                }
              },
              child: StreamBuilder(
                key: ValueKey(_currentMedia),
                stream: sizeController.stream,
                builder: (context, snapshot) => Stack(
                  alignment: Alignment.topLeft,
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: -_zoomLocation.dy,
                      left: -_zoomLocation.dx,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: Hero(
                        tag: 'media${_currentMedia.uid}',
                        child: CachedNetworkImage(
                          imageBuilder: (context, provider) {
                            Widget imageToDisplay;

                            switch (_currentMedia.type) {
                              case MediaType.image:
                                var myImage = Image(
                                  image: provider,
                                  height: _size.height / _scale,
                                  width: _size.width / _scale,
                                  fit: BoxFit.fill,
                                  alignment: Alignment.topLeft,
                                );

                                myImage.image
                                    .resolve(ImageConfiguration())
                                    .addListener(
                                  ImageStreamListener(
                                    (ImageInfo image, bool synchronousCall) {
                                      var myImage = image.image;
                                      if (myImage.width != _size.width ||
                                          myImage.height != _size.height ||
                                          _imageScale !=
                                              max(
                                                _size.width /
                                                    constraints.maxWidth,
                                                _size.height /
                                                    constraints.maxHeight,
                                              )) {
                                        _size = Size(myImage.width.toDouble(),
                                            myImage.height.toDouble());
                                        _imageScale = max(
                                          _size.width / constraints.maxWidth,
                                          _size.height / constraints.maxHeight,
                                        );
                                        if (!_zoomed) {
                                          _scale = _imageScale;
                                        }
                                        // Refresh the page,
                                        sizeController.add(true);
                                      }
                                    },
                                  ),
                                );
                                imageToDisplay = myImage;
                                break;
                              case MediaType.videoOnDemand:
                                if (_videoController == null ||
                                    _videoController.dataSource !=
                                        _currentMedia.url.toString()) {
                                  _videoController?.dispose();
                                  _videoController =
                                      VideoPlayerController.network(
                                          _currentMedia.url.toString());
                                  _videoController
                                      .initialize()
                                      .then((_) => setState(() {}));
                                }
                                imageToDisplay = VideoPlayer(_videoController);
                                break;
                              case MediaType.videoStreaming:
                                break;
                              case MediaType.youtubeID:
                                if (_loadedVideo == null ||
                                    _loadedVideo != _currentMedia.youtubeID) {
                                  if (_videoController != null) {
                                    _youtubeController =
                                        YoutubePlayerController(
                                            initialVideoId:
                                                _currentMedia.youtubeID);
                                  } else {
                                    _youtubeController
                                        .load(_currentMedia.youtubeID);
                                  }
                                  _loadedVideo = _currentMedia.youtubeID;
                                }
                                imageToDisplay = YoutubePlayer(
                                    controller: _youtubeController);
                                break;
                            }
                            return FittedBox(
                                fit: BoxFit.none,
                                alignment: Alignment.topLeft,
                                child: imageToDisplay);
                          },
                          alignment: Alignment.topLeft,
                          imageUrl: _currentMedia.url.toString(),
                          fit: BoxFit.none,
                          errorWidget: (c, str, e) => Icon(Icons.error),
                          placeholder: (c, str) => Center(
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      width: constraints.maxWidth,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.white38,
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                _currentMedia.description,
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
                                    _dateFormat.format(_currentMedia.startAt),
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    _timeFormat.format(_currentMedia.startAt),
                                  ),
                                ],
                              ),
                              ButtonBar(
                                children: [
                                  _currentMedia.playerUid.isNotEmpty &&
                                          widget.onPlayerPressed != null
                                      ? TextButton(
                                          onPressed: () =>
                                              widget.onPlayerPressed(
                                                  _currentMedia.playerUid),
                                          child: Text(Messages.of(context)
                                              .playerButton),
                                        )
                                      : SizedBox(width: 0),
                                  _currentMedia.teamUid.isNotEmpty &&
                                          widget.onTeamPressed != null
                                      ? TextButton(
                                          onPressed: () => widget.onTeamPressed(
                                              _currentMedia.teamUid),
                                          child: Text(
                                              Messages.of(context).teamButton),
                                        )
                                      : SizedBox(width: 0),
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/Season/Media/'
                                        '${widget.media.seasonUid}/'
                                        '${widget.media.uid}'),
                                    child:
                                        Text(Messages.of(context).editButton),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      top: (constraints.maxHeight - 50) / 2,
                      left: 3,
                      child: Ink(
                        decoration: ShapeDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                          onPressed: _nextImage,
                        ),
                      ),
                    ),
                    Positioned(
                      top: (constraints.maxHeight - 50) / 2,
                      left: constraints.maxWidth - 50,
                      child: Ink(
                        decoration: ShapeDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                          onPressed: _prevImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
