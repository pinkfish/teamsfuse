import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:flutter_fuse/widgets/teams/teamimage.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/util/coloredtabbar.dart';
import 'package:flutter_fuse/widgets/util/responsivewidget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../services/messagespublic.dart';
import '../widgets/publicteamdetails.dart';
import '../widgets/publicteammedia.dart';
import '../widgets/publicteamstats.dart';
import '../widgets/searchdelegate.dart';

/// Which of the tabs in the public view are selected.
enum PublicTeamTab {
  /// The team tab.
  team,

  /// The states for the team.
  stats,

  /// The media for the team.
  media,
}

extension PublicTeamTabExtension on PublicTeamTab {
  /// Turn the enum into a nice string with a name.
  String get name {
    switch (this) {
      case PublicTeamTab.team:
        return 'team';
      case PublicTeamTab.media:
        return 'media';
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
      case PublicTeamTab.media:
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

  void _doSearch(BuildContext context) async {
    final result = await showSearch(
      context: context,
      delegate: TeamsFuseSearchDelegate(),
    );
    if (result != null) {
      await Navigator.pushNamed(context, result);
    }
  }

  Widget _buildMediumBody(BuildContext context, SingleTeamBloc bloc) {
    return DefaultTabController(
      length: 3,
      initialIndex: tabSelected.sortIndex,
      child: Scaffold(
        appBar: _buildAppBar(context, bloc),
        body: BlocBuilder(
          bloc: bloc,
          builder: (context, singleTeamState) {
            if (singleTeamState is SingleTeamUninitialized) {
              return Text(Messages.of(context).loading);
            }
            if (singleTeamState is SingleTeamDeleted) {
              return Center(
                child: Text(Messages.of(context).teamDeleted,
                    style: Theme.of(context).textTheme.subtitle1),
              );
            }
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: _buildStuff(context, singleTeamState.team, bloc, false),
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

  Widget _buildStuff(BuildContext context, Team team,
      SingleTeamBloc singleTeamBloc, bool smallDisplay) {
    switch (tabSelected) {
      case PublicTeamTab.team:
        return PublicTeamDetails(singleTeamBloc, smallDisplay: smallDisplay);
      case PublicTeamTab.media:
        return PublicTeamMedia(singleTeamBloc);
      case PublicTeamTab.stats:
        return PublicTeamStatsWidget(
            teamBloc: singleTeamBloc, smallDisplay: smallDisplay);
    }
    return SizedBox(height: 0);
  }

  AppBar _buildAppBar(BuildContext context, SingleTeamBloc singleTeamBloc) {
    return AppBar(
      leading: TeamImage(teamUid: teamUid),
      title: BlocBuilder(
        bloc: singleTeamBloc,
        builder: (context, state) {
          if (state is SingleTeamUninitialized) {
            return Text(Messages.of(context).loading);
          }
          if (state is SingleTeamDeleted) {
            return Text(Messages.of(context).teamDeleted);
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
              icon: Icon(Icons.image),
              text: MessagesPublic.of(context).media,
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
      actions: [
        TextButton.icon(
          icon: Icon(Icons.search),
          label: Text(MessagesPublic.of(context).search),
          onPressed: () => _doSearch(context),
          style: TextButton.styleFrom(
            primary: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallBody(BuildContext context, SingleTeamBloc singleTeamBloc) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder(
          bloc: singleTeamBloc,
          builder: (context, state) {
            if (state is SingleTeamUninitialized) {
              return Text(Messages.of(context).loading);
            }
            if (state is SingleTeamDeleted) {
              return Text(Messages.of(context).teamDeleted);
            }
            return Row(
              children: [
                TeamImage(
                  teamUid: state.team.uid,
                  width: 30,
                  height: 30,
                ),
                SizedBox(width: 10),
                Text(
                  state.team.name,
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _doSearch(context),
            color: Colors.white,
          ),
        ],
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
                  bloc: singleTeamBloc,
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
              leading: Icon(Icons.image),
              onTap: () => _navigateTo(
                  context,
                  '/Team/'
                  '${PublicTeamTab.media.name}/'
                  '$teamUid'),
              title: Text(
                MessagesPublic.of(context).media,
              ),
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
        bloc: singleTeamBloc,
        builder: (context, singleTeamState) {
          if (singleTeamState is SingleTeamUninitialized) {
            return Text(Messages.of(context).loading);
          }
          if (singleTeamState is SingleTeamDeleted) {
            return Center(
              child: Text(Messages.of(context).teamDeleted,
                  style: Theme.of(context).textTheme.subtitle1),
            );
          }
          return _buildStuff(
              context, singleTeamState.team, singleTeamBloc, true);
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
