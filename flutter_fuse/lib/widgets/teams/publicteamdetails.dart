import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs/single/singleseasonbloc.dart';
import '../../services/messages.dart';
import '../blocs/singleseasonprovider.dart';
import '../blocs/singleteamprovider.dart';
import '../games/teamresults.dart';
import '../player/gendericon.dart';
import '../util/deleted.dart';
import '../util/loading.dart';
import 'stats/seasonplayerlist.dart';
import 'stats/teamstats.dart';
import 'teamimage.dart';

///
/// Shows the public details of the team and the current season (only showing
/// the one season).
///
class PublicTeamDetails extends StatelessWidget {
  /// Constructor.
  PublicTeamDetails(this.teamuid);

  /// The teamUid to show the details for.
  final String teamuid;

  Widget _buildCurrentSeason(BuildContext context, SingleTeamState team,
      SingleSeasonBloc singleSeasonBloc) {
    return BlocBuilder(
      cubit: singleSeasonBloc,
      builder: (context, seasonState) {
        if (seasonState is SingleSeasonDeleted) {
          return DeletedWidget();
        }
        if (seasonState is SingleSeasonUninitialized) {
          return LoadingWidget();
        }
        var season = seasonState.season;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${season.name} W:${season.record.win} L:${season.record.loss} T:${season.record.tie}",
              style: Theme.of(context).textTheme.headline5,
            ),
            // Show the list of players here.
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return DefaultTabController(
      length: 3,
      child: SingleTeamProvider(
        teamUid: teamuid,
        builder: (context, bloc) => BlocBuilder(
          cubit: bloc,
          builder: (context, teamState) {
            if (teamState is SingleTeamDeleted) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Image(
                      image:
                          ExactAssetImage("assets/images/hands_and_trophy.png"),
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

            var team = teamState.team;
            return SingleSeasonProvider(
              seasonUid: team.currentSeason,
              builder: (context, singleSeasonBloc) => Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: TeamImage(
                          teamUid: team.uid,
                          showIcon: false,
                          width: (screenSize.width < 500)
                              ? 120.0
                              : (screenSize.width / 4) + 12.0,
                          height: screenSize.height / 4 + 20,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(team.name,
                                  style: Theme.of(context).textTheme.headline4),
                              Text("${team.sport}(${team.league}, ) ",
                                  style: Theme.of(context).textTheme.headline5),
                              _buildCurrentSeason(
                                  context, teamState, singleSeasonBloc),
                            ],
                          ),
                        ),
                      ),
                      GenderIcon(team.gender),
                    ],
                  ),
                  Expanded(
                      child: Column(
                    children: [
                      _ColoredTabBar(
                        color: Colors.grey.shade200,
                        tabBar: TabBar(
                          labelColor: Colors.black,
                          tabs: [
                            Tab(
                              text: Messages.of(context).player,
                              icon: Icon(Icons.people),
                            ),
                            Tab(
                              text: Messages.of(context).games,
                              icon: Icon(MdiIcons.basketball),
                            ),
                            Tab(
                              text: Messages.of(context).stats,
                              icon: Icon(MdiIcons.graph),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            BlocBuilder(
                              cubit: singleSeasonBloc,
                              builder: (context, seasonState) {
                                if (seasonState is SingleSeasonDeleted) {
                                  return DeletedWidget();
                                }
                                if (seasonState is SingleSeasonUninitialized) {
                                  return LoadingWidget();
                                }
                                return SeasonPlayerList(
                                  season: seasonState.season,
                                  orientation: Orientation.landscape,
                                );
                              },
                            ),
                            SingleChildScrollView(
                              child: TeamResultsBySeason(
                                teamUid: team.uid,
                                seasonUid: team.currentSeason,
                              ),
                            ),
                            TeamStatsWidget(
                              teamUid: team.uid,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ))
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ColoredTabBar extends Container implements PreferredSizeWidget {
  _ColoredTabBar({this.color, this.tabBar});

  final Color color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
        color: color,
        child: tabBar,
      );
}
