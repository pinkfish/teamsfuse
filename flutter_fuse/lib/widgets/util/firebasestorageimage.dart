import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

///
/// Download the firebase storage image and show a placeholder
/// till it is downloaded.
///
class FirebaseStorageImage extends StatelessWidget {
  /// The storageId in firebase to download the image for.
  final String storageId;

  /// The place holder widget to display.
  final PlaceholderWidgetBuilder placeholder;

  /// The loading error widget to display.
  final LoadingErrorWidgetBuilder errorWidget;

  /// Constructore the firbasebase storage image.
  FirebaseStorageImage(
      {@required this.storageId, this.placeholder, this.errorWidget});

  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: FutureBuilder<Uint8List>(
          future:
              FirebaseStorage.instance.refFromURL(storageId).getData(100000),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              if (errorWidget != null) {
                return errorWidget(context, storageId, snapshot.error);
              }
              return Icon(Icons.error);
            }
            if (snapshot.hasData) {
              return Image.memory(snapshot.data);
            }
            if (placeholder != null) {
              return placeholder(context, storageId);
            }
            return Icon(Icons.image);
          },
        ));
  }
}
