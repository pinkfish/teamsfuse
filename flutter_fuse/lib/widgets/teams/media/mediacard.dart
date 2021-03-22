import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/player/playername.dart';
import 'package:flutter_fuse/widgets/util/publicmark.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/messages.dart';

///
/// The card to display the details of the media.
///
class MediaCard extends StatelessWidget {
  /// The media to display.
  final MediaInfo media;

  /// Create the card.
  MediaCard({@required this.media});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: PublicMark(
        isPublic: media.isPublic,
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: media.url.toString(),
              width: 75,
              height: 75,
              fit: BoxFit.contain,
              errorWidget: (c, str, e) => Icon(Icons.error),
              placeholder: (c, str) => CircularProgressIndicator(),
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
                          Messages.of(context).noplayers,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                  ButtonBar(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context,
                            '/Season/Media/${media.seasonUid}/${media.uid}'),
                        child: Text(Messages.of(context).editbuttontext),
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
