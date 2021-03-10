import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleclubprovider.dart';
import 'package:flutter_fuse/widgets/clubs/clubimage.dart';
import 'package:flutter_fuse/widgets/util/coloredtabbar.dart';
import 'package:flutter_fuse/widgets/util/responsivewidget.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../widgets/publicclub.dart';
import '../widgets/publicclubnews.dart';
import '../widgets/publicclubteams.dart';
import '../widgets/publiccoaches.dart';
import '../widgets/publicteamdetails.dart';

/// Which of the tabs in the public view are selected.
enum PublicClubTab {
  /// The club tab.
  club,

  /// The team tab.
  team,

  /// The coaches tab.
  coaches,

  /// The news tab.
  news,
}

extension PublicClubTabExtension on PublicClubTab {
  /// Turn the enum into a nice string with a name.
  String get name {
    switch (this) {
      case PublicClubTab.club:
        return 'club';
      case PublicClubTab.team:
        return 'team';
      case PublicClubTab.coaches:
        return 'coaches';
      case PublicClubTab.news:
        return 'news';
      default:
        return null;
    }
  }

  /// Get the index of this enum in the enum.
  int get sortIndex {
    switch (this) {
      case PublicClubTab.club:
        return 0;
      case PublicClubTab.team:
        return 1;
      case PublicClubTab.coaches:
        return 2;
      case PublicClubTab.news:
        return 3;
      default:
        return null;
    }
  }

  /// Find the indexof the string.
  static PublicClubTab fromString(String str) {
    var check = str.toLowerCase();
    return PublicClubTab.values.firstWhere(
      (v) => v.name == check,
      orElse: () => PublicClubTab.club,
    );
  }

  /// Find the indexof the string.
  static PublicClubTab fromIndex(int idx) {
    return PublicClubTab.values.firstWhere(
      (v) => v.sortIndex == idx,
      orElse: () => PublicClubTab.club,
    );
  }
}

///
/// The screen showing all the details of the club.
///
class PublicClubHomeScreen extends StatelessWidget {
  /// Constructor.
  PublicClubHomeScreen(String tab, this.clubUid, this.extraUid)
      : tabSelected = PublicClubTabExtension.fromString(tab);

  /// Club id to show the details for.
  final String clubUid;

  /// Team/player id to show the details for.
  final String extraUid;

  /// The tab currently selected.
  final PublicClubTab tabSelected;

  Widget _buildMediumBody(BuildContext context, SingleClubBloc bloc) {
    return DefaultTabController(
      length: 3,
      initialIndex: tabSelected.sortIndex,
      child: Scaffold(
        appBar: _buildAppBar(context, bloc),
        body: BlocBuilder(
          cubit: bloc,
          builder: (context, singleClubState) {
            if (singleClubState is SingleClubUninitialized) {
              return Text(Messages.of(context).loading);
            }
            if (singleClubState is SingleClubDeleted) {
              return Text(Messages.of(context).clubDeleted);
            }
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: _buildStuff(context, singleClubState.club, bloc),
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
      BuildContext context, Club club, SingleClubBloc singleClubBloc) {
    switch (tabSelected) {
      case PublicClubTab.club:
        return PublicClub(club);
      case PublicClubTab.team:
        if (extraUid != null) {
          return PublicTeamDetails(extraUid);
        }
        return PublicClubTeams(singleClubBloc,
            onlyPublic: true,
            onTap: (t) => _navigateTo(
                context, '/Club/${PublicClubTab.team.name}/$clubUid/${t.uid}'));
      case PublicClubTab.coaches:
        return PublicCoachDetails(singleClubBloc);
      case PublicClubTab.news:
        return PublicClubNews(singleClubBloc);
    }
    return SizedBox(height: 0);
  }

  AppBar _buildAppBar(BuildContext context, SingleClubBloc singleClubBloc) {
    return AppBar(
      leading: ClubImage(clubUid: clubUid),
      title: BlocBuilder(
        cubit: singleClubBloc,
        builder: (context, state) {
          if (state is SingleClubUninitialized) {
            return Text(Messages.of(context).loading);
          }
          if (state is SingleClubDeleted) {
            return Text(Messages.of(context).clubDeleted);
          }
          return Text(state.club.name);
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
                text: Messages.of(context).about),
            Tab(icon: Icon(Icons.people), text: Messages.of(context).teams),
            Tab(icon: Icon(Icons.people), text: Messages.of(context).coaches),
            Tab(
                icon: Icon(MdiIcons.newspaper),
                text: Messages.of(context).news),
          ],
          onTap: (idx) => _navigateTo(
              context,
              '/Public/'
              '${PublicClubTab.values[idx].name}'
              '/$clubUid'),
        ),
      ),
    );
  }

  Widget _buildSmallBody(BuildContext context, SingleClubBloc singleClubBloc) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder(
          cubit: singleClubBloc,
          builder: (context, state) {
            if (state is SingleClubUninitialized) {
              return Text(Messages.of(context).loading);
            }
            if (state is SingleClubDeleted) {
              return Text(Messages.of(context).clubDeleted);
            }
            return Text(state.club.name,
                style: Theme.of(context).textTheme.headline4);
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
                  cubit: singleClubBloc,
                  builder: (context, state) {
                    if (state is SingleClubUninitialized) {
                      return Text(Messages.of(context).loading);
                    }
                    return Column(
                      children: [
                        ClubImage(clubUid: clubUid, width: 100, height: 100),
                        Text(
                          state.club.name,
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
                  '/Public/'
                  '${PublicClubTab.club.name}'
                  '/$clubUid'),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text(Messages.of(context).teams),
              onTap: () => _navigateTo(
                  context,
                  '/Club/${PublicClubTab.team.name}'
                  '/$clubUid'),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text(Messages.of(context).coaches),
              onTap: () => Navigator.popAndPushNamed(
                  context,
                  '/Club/'
                  '${PublicClubTab.coaches.name}'
                  '/$clubUid'),
            ),
            ListTile(
              leading: Icon(MdiIcons.newspaper),
              title: Text(Messages.of(context).news),
              onTap: () => Navigator.popAndPushNamed(
                  context,
                  '/Club/'
                  '${PublicClubTab.news.name}'
                  '/$clubUid'),
            ),
          ],
        ),
      ),
      body: BlocBuilder(
        cubit: singleClubBloc,
        builder: (context, singleClubState) {
          if (singleClubState is SingleClubUninitialized) {
            return Text(Messages.of(context).loading);
          }
          if (singleClubState is SingleClubDeleted) {
            return Text(Messages.of(context).clubDeleted);
          }
          return _buildStuff(context, singleClubState.club, singleClubBloc);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: clubUid,
      builder: (context, singleClubBloc) => Scaffold(
        body: ResponsiveWidget(
          largeScreen: (context) => _buildMediumBody(context, singleClubBloc),
          mediumScreen: (context) => _buildMediumBody(context, singleClubBloc),
          smallScreen: (context) => _buildSmallBody(context, singleClubBloc),
        ),
      ),
    );
  }
}
