import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Shows the media type as a nice icon.
///
class MediaTypeIcon extends StatelessWidget {
  final MediaType type;

  MediaTypeIcon(this.type);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case MediaType.Image:
        return Icon(Icons.image);
      case MediaType.VideoOnDemand:
        return Icon(Icons.ondemand_video);
      case MediaType.VideoStreaming:
        return Icon(Icons.videocam);
    }
    return Icon(Icons.error);
  }
}
