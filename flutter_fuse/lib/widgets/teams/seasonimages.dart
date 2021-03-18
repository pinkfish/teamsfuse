import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleseasonprovider.dart';

///
/// Create a nice carosoul of images.
///
class SeasonImages extends StatelessWidget {
  /// The season uid to load.
  final String seasonUid;

  /// The height of the carousel.
  final double height;

  /// The carousel of images.
  SeasonImages({@required this.seasonUid, this.height = 100.0});

  @override
  Widget build(BuildContext context) {
    return SingleSeasonProvider(
      seasonUid: seasonUid,
      builder: (c, singleSeasonBloc) => BlocBuilder(
        cubit: singleSeasonBloc,
        builder: (c, singleSeasonState) {
          Widget inner;

          if (!singleSeasonState.loadedMedia) {
            singleSeasonBloc.add(SingleSeasonLoadMedia());
            inner = Text(Messages.of(context).loading);
          } else {
            if (singleSeasonState.media.isEmpty) {
              inner = Text(Messages.of(context).noMedia);
            } else {
              inner = CarouselSlider(
                options: CarouselOptions(
                  autoPlay: false,
                  height: height,
                  enlargeCenterPage: false,
                  aspectRatio: 1.0,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                ),
                items: singleSeasonState.media
                    .map<Widget>(
                      (MediaInfo info) => Container(
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: info.url.toString(),
                            errorWidget: (c, str, e) => Icon(Icons.error),
                            placeholder: (c, str) =>
                                CircularProgressIndicator(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }
          }

          return inner;
        },
      ),
    );
  }
}
