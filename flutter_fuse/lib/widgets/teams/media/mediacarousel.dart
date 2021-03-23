import 'dart:async';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart' as intl;

import '../../../services/messages.dart';

///
/// Show the media in full screen.
///
class MediaCarousel extends StatefulWidget {
  /// The media to display
  final MediaInfo media;

  /// All the media we could display.
  final BuiltList<MediaInfo> allMedia;

  /// Create a media carousel.
  MediaCarousel(this.media, {this.allMedia});

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

  @override
  void initState() {
    super.initState();
    _currentMedia = widget.media;
    _index = widget.allMedia.indexOf(_currentMedia);
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
                      _direction = false;
                      _index++;
                      if (_index >= widget.allMedia.length) {
                        _index = 0;
                      }
                      _zoomLocation = Offset(0, 0);
                      setState(() => _currentMedia = widget.allMedia[_index]);
                    }
                    if (_panOffset.dx < -100) {
                      _direction = true;
                      _index--;
                      if (_index < 0) {
                        _index = widget.allMedia.length - 1;
                      }
                      _zoomLocation = Offset(0, 0);
                      setState(() => _currentMedia = widget.allMedia[_index]);
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
                            print('zoom loc $_zoomLocation $_scale');
                            final imageToDisplay = Image(
                              image: provider,
                              height: _size.height / _scale,
                              width: _size.width / _scale,
                              fit: BoxFit.fill,
                              alignment: Alignment.topLeft,
                            );

                            imageToDisplay.image
                                .resolve(ImageConfiguration())
                                .addListener(
                              ImageStreamListener(
                                (ImageInfo image, bool synchronousCall) {
                                  var myImage = image.image;
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

                                  print('got size $_size');
                                },
                              ),
                            );
                            return FittedBox(
                                fit: BoxFit.none,
                                alignment: Alignment.topLeft,
                                child: imageToDisplay);
                          },
                          alignment: Alignment.topLeft,
                          imageUrl: _currentMedia.url.toString(),
                          fit: BoxFit.none,
                          errorWidget: (c, str, e) => Icon(Icons.error),
                          placeholder: (c, str) => CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      width: constraints.maxWidth,
                      child: Card(
                        color: Colors.white38,
                        child: Padding(
                          padding: EdgeInsets.all(10),
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
