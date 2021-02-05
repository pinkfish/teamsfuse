import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs/single/singleseasonbloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleseasonprovider.dart';
import 'package:flutter_fuse/widgets/games/teamresults.dart';
import 'package:flutter_fuse/widgets/util/deleted.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/messages.dart';
import '../blocs/singleteamprovider.dart';
import '../player/gendericon.dart';
import 'stats/seasonplayerlist.dart';
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
              ),
              // Show the list of players here.
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return DefaultTabController(
      // The number of tabs / content sections to display.
      length: 2,
      child: // Complete this code in the next step.
          SingleTeamProvider(
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
                      image: ExactAssetImage("assets/images/abstractsport.png"),
                      width: (screenSize.width < 500)
                          ? 120.0
                          : (screenSize.width / 4) + 12.0,
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

            var tags = <Widget>[];
            var team = teamState.team;
            if (team.archived) {
              tags.add(
                Chip(
                  avatar: CircleAvatar(
                    backgroundColor: Colors.white70,
                    child: const Icon(Icons.archive),
                  ),
                  label: Text(Messages.of(context).archived),
                ),
              );
            }

            return SingleSeasonProvider(
              seasonUid: team.currentSeason,
              builder: (context, singleSeasonBloc) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: TeamImage(
                      teamUid: team.uid,
                      showIcon: false,
                      width: (screenSize.width < 500)
                          ? 120.0
                          : (screenSize.width / 4) + 12.0,
                      height: screenSize.height / 4 + 20,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: Text(team.name),
                    subtitle: Text("${team.sport}(${team.league}) "),
                    trailing: GenderIcon(team.gender),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 5.0),
                    child: Wrap(
                      spacing: 5.0,
                      children: tags,
                    ),
                  ),
                  _buildCurrentSeason(context, teamState, singleSeasonBloc),
                  TabBar(
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
                    ],
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
                        TeamResultsBySeason(
                          teamUid: team.uid,
                          seasonUid: team.currentSeason,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
