import 'package:built_collection/built_collection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart';

import '../../player/playername.dart';
import '../../util/publicmark.dart';
import '../../../services/messages.dart';
import 'mediacarousel.dart';

///
/// The card to display the details of the media.
///
class MediaCard extends StatelessWidget {
  /// The media to display.
  final MediaInfo media;

  /// All the media we could display.
  final BuiltList<MediaInfo> allMedia;

  /// Create the card.
  MediaCard({@required this.media, this.allMedia});

  @override
  Widget build(BuildContext context) {
    final _dateFormat = DateFormat.yMMMMEEEEd(Messages.of(context).locale);
    final _timeFormat = DateFormat.jm(Messages.of(context).locale);
    return Card(
      child: PublicMark(
        isPublic: media.isPublic,
        child: Row(
          children: [
            Hero(
              tag: 'media${media.uid}',
              child: CachedNetworkImage(
                imageUrl: media.url.toString(),
                width: 75,
                height: 75,
                fit: BoxFit.contain,
                errorWidget: (c, str, e) => Icon(Icons.error),
                placeholder: (c, str) => CircularProgressIndicator(),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.description,
                    style: Theme.of(context).textTheme.bodyText1,
                    textScaleFactor: 1.5,
                  ),
                  SizedBox(height: 10),
                  media.gameUid.isNotEmpty
                      ? Text(
                          'Game set',
                          style: Theme.of(context).textTheme.bodyText2,
                        )
                      : Text(
                          Messages.of(context).noGames,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                  media.playerUid.isNotEmpty
                      ? PlayerName(
                          playerUid: media.playerUid,
                          style: Theme.of(context).textTheme.bodyText2,
                        )
                      : Text(
                          Messages.of(context).noPlayers,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                  Row(
                    children: [
                      Text(
                        _dateFormat.format(media.startAt),
                      ),
                      SizedBox(width: 20),
                      Text(
                        _timeFormat.format(media.startAt),
                      ),
                    ],
                  ),
                  ButtonBar(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context,
                            '/Season/Media/${media.seasonUid}/${media.uid}'),
                        child: Text(Messages.of(context).editButton),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MediaCarousel(
                              media,
                              allMedia: allMedia,
                            ),
                          ),
                        ),
                        child: Text(Messages.of(context).viewButton),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
