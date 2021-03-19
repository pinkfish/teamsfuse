import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:flutter_fuse/widgets/teams/teamimage.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/util/coloredtabbar.dart';
import 'package:flutter_fuse/widgets/util/responsivewidget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../widgets/publicteamdetails.dart';
import '../widgets/publicseasonplayers.dart';

/// Which of the tabs in the public view are selected.
enum PublicTeamTab {
  /// The team tab.
  team,

  /// Players for the team
  players,

  /// The states for the team.
  stats,
}

extension PublicTeamTabExtension on PublicTeamTab {
  /// Turn the enum into a nice string with a name.
  String get name {
    switch (this) {
      case PublicTeamTab.team:
        return 'team';
      case PublicTeamTab.players:
        return 'players';
      case PublicTeamTab.stats:
        return 'stats';
      default:
        return null;
    }
  }

  /// Get the index of this enum in the enum.
  int get sortIndex {
    switch (this) {
      case PublicTeamTab.team:
        return 0;
      case PublicTeamTab.players:
        return 1;
      case PublicTeamTab.stats:
        return 2;
      default:
        return null;
    }
  }

  /// Find the indexof the string.
  static PublicTeamTab fromString(String str) {
    var check = str.toLowerCase();
    return PublicTeamTab.values.firstWhere(
      (v) => v.name == check,
      orElse: () => PublicTeamTab.team,
    );
  }

  /// Find the indexof the string.
  static PublicTeamTab fromIndex(int idx) {
    return PublicTeamTab.values.firstWhere(
      (v) => v.sortIndex == idx,
      orElse: () => PublicTeamTab.team,
    );
  }
}

///
/// Shows the public details of the team.
///
class PublicTeamDetailsScreen extends StatelessWidget {
  /// The tab to display.
  final PublicTeamTab tabSelected;

  /// The team uid to display
  final String teamUid;

  /// Create the team details for this team.
  PublicTeamDetailsScreen(String tab, this.teamUid)
      : tabSelected = PublicTeamTabExtension.fromString(tab);

  Widget _buildMediumBody(BuildContext context, SingleTeamBloc bloc) {
    return DefaultTabController(
      length: 3,
      initialIndex: tabSelected.sortIndex,
      child: Scaffold(
        appBar: _buildAppBar(context, bloc),
        body: BlocBuilder(
          cubit: bloc,
          builder: (context, singleTeamState) {
            if (singleTeamState is SingleTeamUninitialized) {
              return Text(Messages.of(context).loading);
            }
            if (singleTeamState is SingleTeamDeleted) {
              return Text(Messages.of(context).clubDeleted);
            }
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: _buildStuff(context, singleTeamState.team, bloc),
            );
          },
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String newRoute) {
    RepositoryProvider.of<fluro.FluroRouter>(context)
        .navigateTo(context, newRoute, transition: fluro.TransitionType.fadeIn);
  }

  Widget _buildStuff(
      BuildContext context, Team team, SingleTeamBloc singleTeamBloc) {
    switch (tabSelected) {
      case PublicTeamTab.team:
        return PublicTeamDetails(singleTeamBloc);
      case PublicTeamTab.players:
        return PublicSeasonPlayers(singleTeamBloc);
      case PublicTeamTab.stats:
        return SizedBox(height: 0);
    }
    return SizedBox(height: 0);
  }

  AppBar _buildAppBar(BuildContext context, SingleTeamBloc singleTeamBloc) {
    return AppBar(
      leading: TeamImage(teamUid: teamUid),
      title: BlocBuilder(
        cubit: singleTeamBloc,
        builder: (context, state) {
          if (state is SingleTeamUninitialized) {
            return Text(Messages.of(context).loading);
          }
          if (state is SingleTeamDeleted) {
            return Text(Messages.of(context).clubDeleted);
          }
          return Text(state.team.name);
        },
      ),
      bottom: ColoredTabBar(
        color: Colors.white,
        tabBar: TabBar(
          labelColor: Colors.black,
          indicatorColor: Colors.green,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 2.0, color: Colors.green),
          ),
          tabs: [
            Tab(
              icon: Icon(MdiIcons.basketball),
              text: Messages.of(context).about,
            ),
            Tab(
              icon: Icon(Icons.people),
              text: Messages.of(context).players,
            ),
            Tab(
              icon: Icon(MdiIcons.graph),
              text: Messages.of(context).stats,
            ),
          ],
          onTap: (idx) => _navigateTo(
              context,
              '/Team/'
              '${PublicTeamTab.values[idx].name}'
              '/$teamUid'),
        ),
      ),
    );
  }

  Widget _buildSmallBody(BuildContext context, SingleTeamBloc singleTeamBloc) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder(
          cubit: singleTeamBloc,
          builder: (context, state) {
            if (state is SingleTeamUninitialized) {
              return Text(Messages.of(context).loading);
            }
            if (state is SingleTeamDeleted) {
              return Text(Messages.of(context).clubDeleted);
            }
            return Row(
              children: [
                TeamImage(
                  teamUid: state.team.uid,
                  width: 30,
                  height: 30,
                ),
                Text(state.team.name,
                    style: Theme.of(context).textTheme.headline4),
              ],
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: BlocBuilder(
                  cubit: singleTeamBloc,
                  builder: (context, state) {
                    if (state is SingleTeamUninitialized) {
                      return Text(Messages.of(context).loading);
                    }
                    return Column(
                      children: [
                        TeamImage(teamUid: teamUid, width: 100, height: 100),
                        Text(
                          state.team.name,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    );
                  }),
            ),
            ListTile(
              leading: Icon(MdiIcons.basketball),
              title: Text(Messages.of(context).about),
              onTap: () => _navigateTo(
                  context,
                  '/Team/'
                  '${PublicTeamTab.team.name}'
                  '/$teamUid'),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text(Messages.of(context).players),
              onTap: () => _navigateTo(
                  context,
                  '/Team/${PublicTeamTab.players.name}'
                  '/$teamUid'),
            ),
            ListTile(
              leading: Icon(MdiIcons.graph),
              title: Text(Messages.of(context).stats),
              onTap: () => Navigator.popAndPushNamed(
                  context,
                  '/Team/'
                  '${PublicTeamTab.stats.name}'
                  '/$teamUid'),
            ),
          ],
        ),
      ),
      body: BlocBuilder(
        cubit: singleTeamBloc,
        builder: (context, singleTeamState) {
          if (singleTeamState is SingleTeamUninitialized) {
            return Text(Messages.of(context).loading);
          }
          if (singleTeamState is SingleTeamDeleted) {
            return Text(Messages.of(context).clubDeleted);
          }
          return _buildStuff(context, singleTeamState.team, singleTeamBloc);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: teamUid,
      builder: (context, singleTeamBloc) => ResponsiveWidget(
        largeScreen: (context) => _buildMediumBody(context, singleTeamBloc),
        mediumScreen: (context) => _buildMediumBody(context, singleTeamBloc),
        smallScreen: (context) => _buildSmallBody(context, singleTeamBloc),
      ),
    );
  }
}
