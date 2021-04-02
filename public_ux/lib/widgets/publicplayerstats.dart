import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs/single/singleplayerbloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/player/playerimage.dart';
import 'package:flutter_fuse/widgets/teams/stats/playerdetailrow.dart';
import 'package:flutter_fuse/widgets/teams/stats/seasonplayerdetail.dart';
import 'package:flutter_fuse/widgets/teams/stats/seasonplayerheader.dart';
import 'package:flutter_fuse/widgets/teams/teamimage.dart';
import 'package:flutter_fuse/widgets/teams/teamname.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:public_ux/services/publicgames.dart';
import 'package:public_ux/widgets/publicplayerdetails.dart';
import 'package:built_collection/built_collection.dart';

///
/// Show the stats for the player for public team/seasons.
///
class PublicPlayerStats extends StatelessWidget {
  /// The bloc to get the details from.
  final SinglePlayerBloc bloc;

  /// The size of this widget.
  final PublicPlayerSize size;

  /// Create the basic player stats page.
  PublicPlayerStats(this.bloc, this.size);

  Widget _buildCurrentSeason(BuildContext context, Season season) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TeamImage(teamUid: season.teamUid, width: 20, height: 20),
            SizedBox(width: 5),
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
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            '${season.name} W:${season.record.win} L:${season.record.loss} T:${season.record.tie}',
                            style:
                                Theme.of(context).textTheme.bodyText1.copyWith(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 15,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
          showName: false,
        ),
        _gamesList(season),
      ],
    );
  }

  Widget _gamesList(Season season) {
    final public = PublicGames(season.uid, bloc.playerUid);

    return FutureBuilder<BuiltList<Game>>(
        future: public.getGames(),
        builder: (context, state) {
          if (state.hasData) {
            // Show all the games.
            if (state.data.isEmpty) {
              return Text(Messages.of(context).noGames,
                  style: Theme.of(context).textTheme.subtitle1);
            }
            final seasonPlayer = season.playersData[bloc.playerUid];
            return LayoutBuilder(
                builder: (context, constraints) => Column(
                    children: state.data
                        .map((g) => PlayerDetailRow(
                              constraints,
                              Orientation.portrait,
                              bloc.playerUid,
                              seasonPlayer,
                              g.getPlayerSummary(bloc.playerUid).fullData,
                              showName: false,
                            ))
                        .toList()));
          }
          return LoadingWidget();
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: bloc,
      builder: (context, singlePlayerState) {
        final seasons = <Widget>[];

        if (singlePlayerState is SinglePlayerUninitialized) {
          return LoadingWidget();
        }

        if (!singlePlayerState.loadedSeasons) {
          bloc.add(SinglePlayerLoadSeasons());
          seasons.add(Text(Messages.of(context).loading));
        } else if (singlePlayerState.seasons.isEmpty) {
          seasons.add(Text(Messages.of(context).noGames));
        } else {
          for (final season in singlePlayerState.seasons) {
            seasons.add(_buildCurrentSeason(context, season));
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: PlayerImage(
                      playerUid: singlePlayerState.player.uid, radius: 75),
                ),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(singlePlayerState.player.name,
                            style: Theme.of(context).textTheme.headline4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ...seasons,
          ],
        );
      },
    );
  }
}
