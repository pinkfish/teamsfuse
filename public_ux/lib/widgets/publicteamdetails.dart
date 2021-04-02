import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs/single/singleseasonbloc.dart';
import 'package:flutter_fuse/services/blocs/single/singleteambloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleseasonprovider.dart';
import 'package:flutter_fuse/widgets/clubs/clubimage.dart';
import 'package:flutter_fuse/widgets/clubs/clubname.dart';
import 'package:flutter_fuse/widgets/player/gendericon.dart';
import 'package:flutter_fuse/widgets/teams/teamimage.dart';
import 'package:flutter_fuse/widgets/util/deleted.dart';
import 'package:flutter_fuse/widgets/util/handsandtrophy.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';

import '../screens/publicclubhome.dart';
import '../screens/publicteam.dart';
import '../services/messagespublic.dart';
import '../widgets/publicseasonplayers.dart';

///
/// Shows the public details of the team and the current season (only showing
/// the one season).
///
class PublicTeamDetails extends StatelessWidget {
  final bool smallDisplay;

  /// Constructor.
  PublicTeamDetails(
    this.singleTeamBloc, {
    this.smallDisplay = false,
  });

  /// The teamUid to show the details for.
  final SingleTeamBloc singleTeamBloc;

  Widget _buildCurrentSeason(BuildContext context, SingleTeamState team,
      SingleSeasonBloc singleSeasonBloc) {
    return BlocBuilder(
      bloc: singleSeasonBloc,
      builder: (context, seasonState) {
        if (seasonState is SingleSeasonDeleted) {
          return DeletedWidget();
        }
        if (seasonState is SingleSeasonUninitialized) {
          return LoadingWidget();
        }
        final season = seasonState.season;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              '${season.name} W:${season.record.win} L:${season.record.loss} T:${season.record.tie}',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(fontStyle: FontStyle.italic),
              overflow: TextOverflow.fade,
            ),
            // Show the list of players here.
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BlocBuilder(
      bloc: singleTeamBloc,
      builder: (context, teamState) {
        if (teamState is SingleTeamDeleted) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Center(
                child: HandsAndTrophy(
                  width: DefaultTabController.of(context).index == 0
                      ? (screenSize.width < 500)
                          ? 120.0
                          : (screenSize.width / 4) + 12.0
                      : 0.0,
                  height: screenSize.height / 4 + 20,
                ),
              ),
              ListTile(title: Text(Messages.of(context).unknown)),
              DeletedWidget(),
            ],
          );
        }

        if (teamState is SingleTeamUninitialized) {
          return LoadingWidget();
        }

        final team = teamState.team;
        return SingleSeasonProvider(
          seasonUid: team.currentSeason,
          builder: (context, singleSeasonBloc) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Hero(
                      tag: 'team${singleTeamBloc.teamUid}',
                      child: TeamImage(
                        teamUid: team.uid,
                        showIcon: false,
                        width: (screenSize.width < 500)
                            ? 120.0
                            : (screenSize.width / 4) + 12.0,
                        height: screenSize.height / 4 + 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  team.name,
                                  style: Theme.of(context).textTheme.headline4,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              SizedBox(width: 5),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GenderIcon(
                                  team.gender,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context,
                                '/Club/${PublicClubTab.club}/${team.clubUid}'),
                            child: Row(
                              children: [
                                ...(team.clubUid != null
                                    ? <Widget>[
                                        ClubImage(
                                          clubUid: team.clubUid,
                                          width: 30,
                                          height: 30,
                                        ),
                                        ClubName(
                                          clubUid: team.clubUid,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5,
                                        ),
                                      ]
                                    : <Widget>[
                                        SizedBox(width: 0),
                                      ]),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${team.sport}(${team.league}) ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                              fontStyle: FontStyle.italic),
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          _buildCurrentSeason(
                              context, teamState, singleSeasonBloc),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: PublicSeasonPlayers(
                    singleTeamBloc,
                  ),
                ),
              ),
              smallDisplay
                  ? ButtonBar(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context,
                              '/Club/'
                              '${PublicClubTab.club.name}/'
                              '${teamState.team.clubUid}'),
                          child: Text(Messages.of(context).clubButton),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context,
                              '/Team/'
                              '${PublicTeamTab.media.name}/'
                              '${teamState.team.uid}'),
                          child: Text(MessagesPublic.of(context).mediaButton),
                        ),
                        smallDisplay
                            ? TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context,
                                    '/Team/'
                                    '${PublicTeamTab.stats.name}/'
                                    '${teamState.team.uid}'),
                                child: Text(Messages.of(context).statsButton),
                              )
                            : SizedBox(width: 0),
                      ],
                    )
                  : SizedBox(
                      height: 0,
                    ),
            ],
          ),
        );
      },
    );
  }
}
