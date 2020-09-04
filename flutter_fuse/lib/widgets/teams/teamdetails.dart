import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/teamresults.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/gendericon.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleteamprovider.dart';

///
/// Shows the details of the team.
///
class TeamDetails extends StatelessWidget {
  TeamDetails(this.teamuid);

  final String teamuid;

  Widget _buildSeasonExpansionTitle(Team team, Season season) {
    return new ExpansionTile(
      key: new PageStorageKey<Season>(season),
      title: new Text(
        season.name +
            " W:" +
            season.record.win.toString() +
            " L:" +
            season.record.loss.toString() +
            " T:" +
            season.record.tie.toString(),
      ),
      children: <Widget>[
        new TeamResultsBySeason(
          teamUid: team.uid,
          seasonUid: season.uid,
        ),
      ],
      initiallyExpanded: false,
    );
  }

  Widget _buildSeasons(BuildContext context, SingleTeamState team, Club club,
      Iterable<Season> seasons) {
    List<Widget> ret = <Widget>[];

    if (team.isAdmin()) {
      ret.add(
        new FlatButton(
          onPressed: () =>
              Navigator.pushNamed(context, "AddSeason/" + team.team.uid),
          child: new Text(Messages.of(context).addseason),
        ),
      );
    }
    // Show all the seasons here, not just the ones we know.
    List<Widget> happyData = <Widget>[];

    Iterable<Season> seasons =
        team.fullSeason.where((Season s) => s.teamUid == team.team.uid);
    if (seasons.length == 0) {
      ret.add(Text(Messages.of(context).noseasons));
    } else {
      for (Season season in seasons) {
        happyData.add(_buildSeasonExpansionTitle(team.team, season));
      }
    }
    ret.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: happyData,
      ),
    );

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ret,
    );
  }

  void _openClub(BuildContext context, Team team) {
    if (team.clubUid != null) {
      Navigator.pushNamed(context, "Club/" + team.clubUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return SingleTeamProvider(
      teamUid: teamuid,
      builder: (BuildContext context, SingleTeamBloc bloc) => BlocListener(
        cubit: bloc,
        listener: (BuildContext context, SingleTeamState state) {
          if (state is SingleTeamLoaded) {
            bloc.add(SingleTeamLoadAllSeasons());
          }
        },
        child: BlocBuilder(
          cubit: bloc,
          builder: (BuildContext context, SingleTeamState teamState) {
            if (teamState is SingleTeamDeleted) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Center(
                    child: new Image(
                      image: new ExactAssetImage(
                          "assets/images/abstractsport.png"),
                      width: (screenSize.width < 500)
                          ? 120.0
                          : (screenSize.width / 4) + 12.0,
                      height: screenSize.height / 4 + 20,
                    ),
                  ),
                  new ListTile(title: new Text(Messages.of(context).unknown)),
                  _buildSeasons(
                      context, teamState, teamState.club, teamState.fullSeason)
                ],
              );
            }

            Widget club;
            Team team = teamState.team;
            if (team.clubUid != null) {
              if (teamState.club == null) {
                club = new Text(Messages.of(context).loading);
              } else {
                club = new Text(teamState.club.name);
              }
            } else {
              club = new Text(Messages.of(context).noclub);
            }

            return new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Center(
                  child: new TeamImage(
                    team: team,
                    width: (screenSize.width < 500)
                        ? 120.0
                        : (screenSize.width / 4) + 12.0,
                    height: screenSize.height / 4 + 20,
                  ),
                ),
                new ListTile(
                  leading: const Icon(Icons.people),
                  title: new Text(team.name),
                  subtitle: new Text(
                      team.sport.toString() + "(" + team.league + ") "),
                  trailing: new GenderIcon(team.gender),
                ),
                new ListTile(
                  leading: const Icon(CommunityIcons.cardsClub),
                  title: club,
                  onTap: () => _openClub(context, team),
                ),
                new ListTile(
                  leading: const Icon(Icons.archive),
                  title: team.archived
                      ? Text(Messages.of(context).archived)
                      : Text(Messages.of(context).notarchived),
                ),
                new ListTile(
                  leading: const Icon(Icons.timer),
                  title:
                      teamState.club == null && teamState.team.clubUid != null
                          ? Text(Messages.of(context).loading)
                          : Text(
                              Messages.of(context).arrivebefore(
                                team.arriveEarly(teamState.club).toInt(),
                              ),
                            ),
                ),
                new ListTile(
                  leading: const Icon(CommunityIcons.trafficLight),
                  title:
                      teamState.club == null && teamState.team.clubUid != null
                          ? Text(Messages.of(context).loading)
                          : Text(
                              Messages.of(context).trackattendence(
                                  team.trackAttendence(teamState.club)
                                      ? Tristate.Yes
                                      : Tristate.No),
                            ),
                ),
                _buildSeasons(
                    context, teamState, teamState.club, teamState.fullSeason)
              ],
            );
          },
        ),
      ),
    );
  }
}
