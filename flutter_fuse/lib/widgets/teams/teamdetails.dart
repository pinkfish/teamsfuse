import 'dart:math';

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
import '../util/publicmark.dart';
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '${season.name} W:${season.record.win} L:${season.record.loss} '
            'T:${season.record.tie}',
          ),
          season.isPublic
              ? Expanded(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      Messages.of(context).public,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontStyle: FontStyle.italic, color: Colors.blue),
                    ),
                  ),
                )
              : SizedBox(width: 0),
        ],
      ),
      initiallyExpanded: season.uid == team.currentSeason,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        admin
            ? ButtonBar(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, '/Game/Add/${team.uid}/${season.uid}'),
                    child: Text(Messages.of(context).addGameButton),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, '/Game/AddTraining/${team.uid}/${season.uid}'),
                    child: Text(Messages.of(context).addTrainingButton),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, '/Game/AddEvent/${team.uid}/${season.uid}'),
                    child: Text(Messages.of(context).addEventButton),
                  ),
                ],
              )
            : SizedBox(height: 0),
        Padding(
          padding: EdgeInsets.all(10),
          child: TeamResultsBySeason(
            teamUid: team.uid,
            seasonUid: season.uid,
          ),
        ),
      ],
    );
  }

  Widget _buildSeasons(BuildContext context, SingleTeamState team, Club club,
      Iterable<Season> seasons) {
    final ret = <Widget>[];

    // Show all the seasons here, not just the ones we know.
    final happyData = <Widget>[];

    if (!team.loadedSeasons) {
      ret.add(Text(Messages.of(context).loading));
    } else {
      final seasons =
          team.fullSeason.where((s) => s.teamUid == team.team.uid).toList();
      seasons.sort((a, b) => a.uid == team.team.currentSeason
          ? -1
          : b.uid == team.team.currentSeason
              ? 1
              : a.name.compareTo(b.name));
      if (seasons.isEmpty) {
        ret.add(Text(Messages.of(context).noSeasons));
      } else {
        for (final season in seasons) {
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
                PublicMark(
                  isPublic: false,
                  child: Center(
                    child: Image(
                      image: ExactAssetImage('assets/images/abstractsport.png'),
                      width: (screenSize.width < 500)
                          ? 120.0
                          : (screenSize.width / 4) + 12.0,
                      height: screenSize.height / 4 + 20,
                    ),
                  ),
                ),
                ListTile(title: Text(Messages.of(context).unknown)),
                _buildSeasons(
                    context, teamState, teamState.club, teamState.fullSeason)
              ],
            );
          }

          final tags = <Widget>[];
          final team = teamState.team;
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
                      Messages.of(context).trackAttendance(
                          team.trackAttendance(teamState.club)
                              ? Tristate.Yes
                              : Tristate.No),
                    ),
            ),
          );

          final imgSize = max(150.0,
              min((screenSize.width / 4) + 12.0, screenSize.height / 4 + 20));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              PublicMark(
                isPublic: team.isPublic,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: TeamImage(
                      team: team,
                      showIcon: false,
                      circleBox: false,
                      width: screenSize.width - 20,
                      fit: BoxFit.fitHeight,
                      height: imgSize,
                    ),
                  ),
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
              _buildSeasons(
                  context, teamState, teamState.club, teamState.fullSeason)
            ],
          );
        },
      ),
    );
  }
}
