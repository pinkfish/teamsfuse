import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs/single/singleseasonbloc.dart';
import 'package:flutter_fuse/services/blocs/single/singleteambloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleseasonprovider.dart';
import 'package:flutter_fuse/widgets/clubs/clubimage.dart';
import 'package:flutter_fuse/widgets/clubs/clubname.dart';
import 'package:flutter_fuse/widgets/games/teamresults.dart';
import 'package:flutter_fuse/widgets/player/gendericon.dart';
import 'package:flutter_fuse/widgets/teams/seasonimages.dart';
import 'package:flutter_fuse/widgets/teams/teamimage.dart';
import 'package:flutter_fuse/widgets/util/deleted.dart';
import 'package:flutter_fuse/widgets/util/handsandtrophy.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

///
/// Shows the public details of the team and the current season (only showing
/// the one season).
///
class PublicTeamDetails extends StatelessWidget {
  /// Constructor.
  PublicTeamDetails(this.singleTeamBloc);

  /// The teamUid to show the details for.
  final SingleTeamBloc singleTeamBloc;

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
      cubit: singleTeamBloc,
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
                              Text(team.name,
                                  style: Theme.of(context).textTheme.headline4),
                              SizedBox(width:5),
                              Expanded(child:Align(
                                alignment: Alignment.centerRight,
                                child: GenderIcon(team.gender, size:30,),
                              ),),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
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
                                        .copyWith(fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ),
                            ],
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
              SingleChildScrollView(
                child: TeamResultsBySeason(
                  teamUid: team.uid,
                  seasonUid: team.currentSeason,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
