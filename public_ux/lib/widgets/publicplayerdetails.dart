import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fuse/services/blocs/single/singleplayerbloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/player/playerimage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/teams/teamimage.dart';
import 'package:flutter_fuse/widgets/teams/stats/seasonplayerdetail.dart';
import 'package:flutter_fuse/widgets/teams/stats/seasonplayerheader.dart';
import 'package:flutter_fuse/widgets/teams/teamname.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:public_ux/screens/publicteam.dart';

///
/// The size of the widget.
enum PublicPlayerSize {
  small,
  medium,
  large,
}

///
/// Show the details for the specific player.
///
class PublicPlayerDetails extends StatelessWidget {
  /// The bloc to get the details from.
  final SinglePlayerBloc bloc;

  /// The size of this widget.
  final PublicPlayerSize size;

  /// Create the basic player page.
  PublicPlayerDetails(this.bloc, this.size);

  Widget _buildCurrentSeason(
      BuildContext context, Season season, String playerUid) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TeamImage(teamUid: season.teamUid, width: 50, height: 50),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TeamName(
                              teamUid: season.teamUid,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontWeight: FontWeight.w600)),
                          SizedBox(width: 15),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                '${season.name} W:${season.record.win} L:${season.record.loss} T:${season.record.tie}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      SeasonPlayerHeader(
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontWeight: FontWeight.w100),
                      ),
                      SeasonPlayerDetails(
                        uid: playerUid,
                        season: season,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ButtonBar(
              children: [
                TextButton(
                child: Text(Messages.of(context).teamButton),
                onPressed: () => Navigator.pushNamed(context,
                    '/Team/${PublicTeamTab.team.name}/${season.teamUid}'),
              ),

    ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: bloc,
      builder: (context, singlePlayerState) {
        final seasons = <Widget>[];
        if (!singlePlayerState.loadedSeasons) {
          bloc.add(SinglePlayerLoadSeasons());
          seasons.add(Text(Messages.of(context).loading));
        } else if (singlePlayerState.seasons.isEmpty) {
          seasons.add(Text(Messages.of(context).noGames));
        } else {
          for (final season in singlePlayerState.seasons) {
            seasons.add(_buildCurrentSeason(
                context, season, singlePlayerState.player.uid));
          }
        }
        if (!singlePlayerState.loadedMedia) {
          bloc.add(SinglePlayerLoadMedia());
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlayerImage(
                    playerUid: singlePlayerState.player.uid, radius: 100),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(singlePlayerState.player.name,
                          style: Theme.of(context).textTheme.headline2),
                      ...(size != PublicPlayerSize.small ? seasons : []),
                    ],
                  ),
                ),
              ],
            ),
            ...(size == PublicPlayerSize.small ? seasons : []),
            singlePlayerState.loadedMedia
                ? singlePlayerState.media.isNotEmpty
                    ? Expanded(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: singlePlayerState.media
                              .map<Widget>((i) => _createMedia(context, i))
                              .toList(),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          Messages.of(context).noMedia,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      )
                : SizedBox(height: 0),
          ],
        );
      },
    );
  }

  Widget _createMedia(BuildContext context, MediaInfo i) {
    return CachedNetworkImage(
      imageUrl: i.url.toString(),
      errorWidget: (context, _, error) => Icon(Icons.error),
    );
  }
}
