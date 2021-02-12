import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleclubprovider.dart';
import '../../widgets/clubs/clubimage.dart';
import '../../widgets/public/publicclub.dart';
import '../../widgets/public/publicclubteans.dart';
import '../../widgets/public/publiccoaches.dart';
import '../../widgets/teams/publicteamdetails.dart';
import '../../widgets/util/coloredtabbar.dart';
import '../../widgets/util/responsivewidget.dart';

/// Which of the tabs in the public view are selected.
enum PublicTab {
  /// The club tab.
  club,

  /// The team tab.
  team,

  /// The coaches tab.
  coaches,
}

///
/// The screen showing all the details of the club.
///
class PublicHomeScreen extends StatelessWidget {
  /// Constructor.
  PublicHomeScreen(String tab, this.clubUid, this.extraUid)
      : tabSelected = PublicTab.values.firstWhere(
            (v) => v.toString().endsWith(tab),
            orElse: () => PublicTab.club);

  /// Club id to show the details for.
  final String clubUid;

  /// Team/player id to show the details for.
  final String extraUid;

  /// The tab currently selected.
  final PublicTab tabSelected;

  Widget _buildMediumBody(BuildContext context, SingleClubBloc bloc) {
    return DefaultTabController(
      length: 3,
      initialIndex:
          PublicTab.values.indexWhere((element) => element == tabSelected),
      child: Scaffold(
        appBar: _buildAppBar(context, bloc),
        /*body: Column(
        children: [
          BlocBuilder(
            cubit: bloc,
            builder: (context, singleClubState) {
              if (singleClubState is SingleClubUninitialized) {
                return TabBarView(children: [
                  LoadingWidget(),
                  LoadingWidget(),
                  LoadingWidget(),
                ]);
              }
              var club = singleClubState.club;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TabBarView(
                    children: [
                      tabSelected == PublicTab.Club
                          ? PublicClub(club)
                          : SizedBox(width: 0),
                      tabSelected == PublicTab.Team
                          ? (extraUid != null
                              ? PublicTeamDetails(extraUid)
                              : PublicClubTeams(club,
                                  onlyPublic: true,
                                  onTap: (t) => Navigator.pushNamed(context,
                                      "/Public/${PublicTab.Team.toString()}/$clubUid/${t.uid}")))
                          : SizedBox(width: 0),
                      SizedBox(width: 0),
                    ],
                  ),
                ),
              );
            },
            */
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
              child: _buildStuff(context, singleClubState.club, bloc),
              duration: Duration(milliseconds: 500),
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
      case PublicTab.club:
        return PublicClub(club);
      case PublicTab.team:
        if (extraUid != null) {
          return PublicTeamDetails(extraUid);
        }
        return PublicClubTeams(club,
            onlyPublic: true,
            onTap: (t) => _navigateTo(context,
                "/Public/${PublicTab.team.toString()}/$clubUid/${t.uid}"));
      case PublicTab.coaches:
        return PublicCoachDetails(singleClubBloc);
    }
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
            Tab(icon: Icon(Icons.people), text: Messages.of(context).about),
            Tab(icon: Icon(Icons.people), text: Messages.of(context).teams),
            Tab(icon: Icon(Icons.people), text: Messages.of(context).coaches),
          ],
          onTap: (idx) => _navigateTo(
              context, "/Public/${PublicTab.values[idx].toString()}/$clubUid"),
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
                  context, "/Public/${PublicTab.club.toString()}/$clubUid"),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text(Messages.of(context).teams),
              onTap: () => _navigateTo(
                  context, "/Public/${PublicTab.team.toString()}/$clubUid"),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text(Messages.of(context).coaches),
              onTap: () => Navigator.popAndPushNamed(
                  context, "/Public/${PublicTab.coaches.toString()}/$clubUid"),
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
