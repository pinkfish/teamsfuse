import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleteamprovider.dart';
import '../games/teamresults.dart';
import '../util/communityicons.dart';
import '../util/gendericon.dart';
import '../util/teamimage.dart';

///
/// Shows the details of the team.
///
class TeamDetails extends StatelessWidget {
  /// Constructor.
  TeamDetails(this.teamuid);

  /// The teamUid to show the details for.
  final String teamuid;

  Widget _buildSeasonExpansionTitle(Team team, Season season) {
    return ExpansionTile(
      key: PageStorageKey<Season>(season),
      title: Text(
        "${season.name} W:${season.record.win} L:${season.record.loss} T:${season.record.tie}",
      ),
      children: <Widget>[
        TeamResultsBySeason(
          teamUid: team.uid,
          seasonUid: season.uid,
        ),
      ],
      initiallyExpanded: false,
    );
  }

  Widget _buildSeasons(BuildContext context, SingleTeamState team, Club club,
      Iterable<Season> seasons) {
    var ret = <Widget>[];

    if (team.isAdmin()) {
      ret.add(
        FlatButton(
          onPressed: () =>
              Navigator.pushNamed(context, "AddSeason/${team.team.uid}"),
          child: Text(Messages.of(context).addseason),
        ),
      );
    }
    // Show all the seasons here, not just the ones we know.
    var happyData = <Widget>[];

    if (!team.loadedSeasons) {
      ret.add(Text(Messages.of(context).loading));
    } else {
      var seasons = team.fullSeason.where((s) => s.teamUid == team.team.uid);
      if (seasons.length == 0) {
        ret.add(Text(Messages.of(context).noseasons));
      } else {
        for (var season in seasons) {
          happyData.add(_buildSeasonExpansionTitle(team.team, season));
        }
      }
      ret.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: happyData,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ret,
    );
  }

  void _openClub(BuildContext context, Team team) {
    if (team.clubUid != null) {
      Navigator.pushNamed(context, "Club/${team.clubUid}");
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return SingleTeamProvider(
      teamUid: teamuid,
      builder: (context, bloc) => BlocListener(
        cubit: bloc,
        listener: (context, state) {
          if (state is SingleTeamLoaded) {
            bloc.add(SingleTeamLoadSeasons());
          }
        },
        child: BlocBuilder(
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
                  _buildSeasons(
                      context, teamState, teamState.club, teamState.fullSeason)
                ],
              );
            }

            Widget club;
            var team = teamState.team;
            if (team.clubUid != null) {
              if (teamState.club == null) {
                club = Text(Messages.of(context).loading);
              } else {
                club = Text(teamState.club.name);
              }
            } else {
              club = Text(Messages.of(context).noclub);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: TeamImage(
                    team: team,
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
                ListTile(
                  leading: const Icon(CommunityIcons.cardsClub),
                  title: club,
                  onTap: () => _openClub(context, team),
                ),
                ListTile(
                  leading: const Icon(Icons.archive),
                  title: team.archived
                      ? Text(Messages.of(context).archived)
                      : Text(Messages.of(context).notarchived),
                ),
                ListTile(
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
                ListTile(
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
