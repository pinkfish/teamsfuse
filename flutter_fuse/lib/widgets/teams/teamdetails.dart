import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/teams/media/seasonimages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleteamprovider.dart';
import '../games/teamresults.dart';
import '../player/gendericon.dart';
import 'teamimage.dart';

///
/// Shows the details of the team.
///
class TeamDetails extends StatelessWidget {
  /// Constructor.
  TeamDetails(this.teamuid);

  /// The teamUid to show the details for.
  final String teamuid;

  Widget _buildSeasonExpansionTitle(
      BuildContext context, Team team, Season season, bool admin) {
    return ExpansionTile(
      key: PageStorageKey<Season>(season),
      title: Text(
        '${season.name} W:${season.record.win} L:${season.record.loss} '
        'T:${season.record.tie}',
      ),
      initiallyExpanded: season.uid == team.currentSeason,
      children: <Widget>[
        TeamResultsBySeason(
          teamUid: team.uid,
          seasonUid: season.uid,
        ),
        admin
            ? ButtonBar(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, '/Game/Add/${team.uid}/${season.uid}'),
                    child: Text(Messages.of(context).addGameButton),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/AddTraining'),
                    child: Text(Messages.of(context).addTrainingButton),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/AddEvent'),
                    child: Text(Messages.of(context).addEventButton),
                  ),
                ],
              )
            : SizedBox(height: 0),
      ],
    );
  }

  Widget _buildSeasons(BuildContext context, SingleTeamState team, Club club,
      Iterable<Season> seasons) {
    var ret = <Widget>[];

    if (team.isAdmin()) {
      ret.add(
        ButtonBar(
          children: [
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, 'AddSeason/${team.team.uid}'),
              child: Text(Messages.of(context).addSeasonButton),
            ),
          ],
        ),
      );
    }
    // Show all the seasons here, not just the ones we know.
    var happyData = <Widget>[];

    if (!team.loadedSeasons) {
      ret.add(Text(Messages.of(context).loading));
    } else {
      var seasons = team.fullSeason.where((s) => s.teamUid == team.team.uid);
      if (seasons.isEmpty) {
        ret.add(Text(Messages.of(context).noseasons));
      } else {
        for (var season in seasons) {
          happyData.add(_buildSeasonExpansionTitle(
              context, team.team, season, team.isAdmin()));
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

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return SingleTeamProvider(
      teamUid: teamuid,
      builder: (context, bloc) => BlocBuilder(
        bloc: bloc,
        builder: (context, teamState) {
          if (teamState is SingleTeamLoaded && !teamState.loadedSeasons) {
            bloc.add(SingleTeamLoadSeasons());
          }
          if (teamState is SingleTeamDeleted) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Image(
                    image: ExactAssetImage('assets/images/abstractsport.png'),
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

          var tags = <Widget>[];
          var team = teamState.team;
          if (team.clubUid != null) {
            Widget middle;
            if (teamState.club == null) {
              middle = Text(Messages.of(context).loading);
            } else {
              middle = Text(teamState.club.name);
            }
            tags.add(ActionChip(
              avatar: CircleAvatar(
                backgroundColor: Colors.white70,
                child: const Icon(MdiIcons.cardsClub),
              ),
              label: middle,
              onPressed: () => Navigator.pushNamed(
                  context, '/Club/${teamState.team.clubUid}'),
            ));
          }
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

          tags.add(
            Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.white70,
                child: const Icon(MdiIcons.trafficLight),
              ),
              label: teamState.club == null && teamState.team.clubUid != null
                  ? Text(Messages.of(context).loading)
                  : Text(
                      Messages.of(context).trackattendence(
                          team.trackAttendence(teamState.club)
                              ? Tristate.Yes
                              : Tristate.No),
                    ),
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Center(
                child: TeamImage(
                  team: team,
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
                subtitle: Text('${team.sport}(${team.league}) '),
                trailing: GenderIcon(team.gender),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 5.0),
                child: Wrap(
                  spacing: 5.0,
                  children: tags,
                ),
              ),
              /*
              ListTile(
                leading: const Icon(Icons.timer),
                title: teamState.club == null && teamState.team.clubUid != null
                    ? Text(Messages.of(context).loading)
                    : Text(
                        Messages.of(context).arrivebefore(
                          team.arriveEarly(teamState.club).toInt(),
                        ),
                      ),
              ),
              */

              _buildSeasons(
                  context, teamState, teamState.club, teamState.fullSeason)
            ],
          );
        },
      ),
    );
  }
}
