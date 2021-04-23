import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleseasonprovider.dart';
import '../blocs/singleteamprovider.dart';
import '../util/publicmark.dart';
import 'teamimage.dart';

///
/// The tile associated with the team, shows bonus details about the
/// team.
///
class TeamTile extends StatelessWidget {
  /// Constructor for the team tile.
  TeamTile(this.teamUid,
      {this.popBeforeNavigate = false,
      this.showIconForTeam = false,
      this.onTap,
      this.selectedTileColor,
      this.selected = false});

  /// If we shuold do something exciting with the background.
  final Color selectedTileColor;

  /// If this tile is seltected.
  final bool selected;

  /// If the team tile has been tapped.
  final GestureTapCallback onTap;

  /// The teamUid to display.
  final String teamUid;

  /// If we should show an icon for the team.
  final bool showIconForTeam;

  /// If we should pop bevbore we navigate away,
  final bool popBeforeNavigate;

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: teamUid,
      builder: (c, singleTeamBloc) => BlocBuilder(
        bloc: singleTeamBloc,
        builder: (context, teamState) {
          if (teamState is SingleTeamDeleted) {
            return ListTile(
                leading: Icon(Icons.delete),
                title: Text(Messages.of(context).teamDeleted));
          }
          if (teamState is SingleTeamUninitialized) {
            return ListTile(
                leading: Icon(Icons.circle),
                title: Text(Messages.of(context).loading));
          }

          return SingleSeasonProvider(
              seasonUid: teamState.team.currentSeason,
              builder: (c, seasonBloc) {
                return PublicMark(
                  isPublic: teamState.team.isPublic,
                  child: ListTile(
                    selected: selected,
                    selectedTileColor:
                        selectedTileColor ?? Theme.of(context).splashColor,
                    leading: TeamImage(
                      width: 40.0,
                      height: 40.0,
                      teamUid: teamState.team.uid,
                      alignment: Alignment.centerLeft,
                      showIcon: showIconForTeam,
                    ),
                    title: BlocBuilder(
                      bloc: seasonBloc,
                      builder: (context, seasonState) {
                        var seasonName = '';
                        if (seasonState is SingleSeasonLoaded) {
                          seasonName = seasonState.season.name;
                        }

                        return RichText(
                          text: TextSpan(
                            text: teamState.team.name,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17.0),
                            children: <TextSpan>[
                              TextSpan(text: '  '),
                              TextSpan(
                                text: seasonName,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 15.0),
                              ),
                              TextSpan(
                                text: teamState.isAdmin()
                                    ? '\n${Messages.of(context).administrator}'
                                    : '',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 10.0,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    isThreeLine: false,
                    dense: true,
                    subtitle: BlocBuilder(
                      bloc: seasonBloc,
                      builder: (context, seasonState) {
                        if (seasonState is SingleSeasonLoaded) {
                          return Text(seasonState.season.record != null
                              ? Messages.of(context)
                                  .winRecord(seasonState.season.record)
                              : '');
                        }
                        return Text(Messages.of(context).loading);
                      },
                    ),
                    onTap: onTap ??
                        () {
                          if (popBeforeNavigate) {
                            Navigator.pop(context);
                          }
                          RepositoryProvider.of<fluro.FluroRouter>(context)
                              .navigateTo(
                                  context, 'Team/View/${teamState.team.uid}',
                                  transition: fluro.TransitionType.inFromRight);
                        },
                  ),
                );
              });
        },
      ),
    );
  }
}
