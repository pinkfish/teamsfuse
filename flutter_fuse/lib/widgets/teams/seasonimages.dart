import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                options: CarouselOptions(height: 400.0),
                items: singleSeasonState.media.map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: height,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(color: Colors.amber),
                        child: CachedNetworkImage(
                          imageUrl: singleSeasonState.media.url,
                          errorWidget: (c, str, e) => Icon(Icons.error),
                          placeholder: (c, str) => CircularProgressIndicator(),
                          width: height,
                          height: height,
                          fit: BoxFit.scaleDown,
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            }
          }

          return inner;
        },
      ),
    );
  }
}
