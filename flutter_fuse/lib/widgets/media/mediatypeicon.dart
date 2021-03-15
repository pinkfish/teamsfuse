import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Shows the media type as a nice icon.
///
class MediaTypeIcon extends StatelessWidget {
  /// The type pf the media to display.
  final MediaType type;

  /// The type of the media to display the icon.
  MediaTypeIcon(this.type);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case MediaType.image:
        return Icon(Icons.image);
      case MediaType.videoOnDemand:
        return Icon(Icons.ondemand_video);
      case MediaType.videoStreaming:
        return Icon(Icons.videocam);
    }
    return Icon(Icons.error);
  }
}
