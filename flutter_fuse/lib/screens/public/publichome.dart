import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/clubs/clubimage.dart';
import 'package:flutter_fuse/widgets/public/publicclub.dart';
import 'package:flutter_fuse/widgets/teams/publicteamdetails.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:flutter_fuse/widgets/util/responsivewidget.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleclubprovider.dart';
import '../../widgets/public/publicclubteans.dart';

/// WHich of the tabs in the public view are selected.
enum PublicTab {
  Club,
  Team,
  Coaches,
}

///
/// The screen showing all the details of the club.
///
class PublicHomeScreen extends StatelessWidget {
  /// Constructor.
  PublicHomeScreen(String tab, this.clubUid, this.extraUid)
      : tabSelected = PublicTab.values.firstWhere(
            (v) => v.toString().endsWith(tab),
            orElse: () => PublicTab.Club);

  /// Club id to show the details for.
  final String clubUid;

  /// Team/player id to show the details for.
  final String extraUid;

  /// The tab currently selected.
  final PublicTab tabSelected;

  Widget _buildMediumBody(BuildContext context, SingleClubBloc bloc) {
    return Scaffold(
      appBar: _buildAppBar(context, bloc),
      body: Column(
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
          ),
        ],
      ),
    );
  }

  Widget _buildStuff(BuildContext context, Club club) {
    switch (tabSelected) {
      case PublicTab.Club:
        return PublicClub(club);
      case PublicTab.Team:
        if (extraUid != null) {
          return PublicTeamDetails(extraUid);
        }
        return PublicClubTeams(club,
            onlyPublic: true,
            onTap: (t) => Navigator.pushNamed(context,
                "/Public/${PublicTab.Team.toString()}/$clubUid/${t.uid}"));
      case PublicTab.Coaches:
        return Text("Coaches");
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
      bottom: _ColoredTabBar(
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
          onTap: (idx) => Navigator.popAndPushNamed(
              context, "/Public/${PublicTab.values[idx].toString()}/$clubUid"),
        ),
      ),
    );
  }

  Widget _buildSmallBody(BuildContext context, SingleClubBloc singleClubBloc) {
    return DefaultTabController(
      length: 3,
      initialIndex:
          PublicTab.values.indexWhere((element) => element == tabSelected),
      child: Scaffold(
        appBar: _buildAppBar(context, singleClubBloc),
        body: BlocBuilder(
          cubit: singleClubBloc,
          builder: (context, singleClubState) {
            if (singleClubState is SingleClubUninitialized) {
              return Text(Messages.of(context).loading);
            }
            if (singleClubState is SingleClubDeleted) {
              return Text(Messages.of(context).clubDeleted);
            }
            return _buildStuff(context, singleClubState.club);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: clubUid,
      builder: (context, singleClubBloc) => Scaffold(
        body: ResponsiveWidget(
          mediumScreen: (context) => _buildMediumBody(context, singleClubBloc),
          smallScreen: (context) => _buildSmallBody(context, singleClubBloc),
        ),
      ),
    );
  }
}

class _ColoredTabBar extends Container implements PreferredSizeWidget {
  _ColoredTabBar({this.color, this.tabBar});

  final Color color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
        color: color,
        child: tabBar,
      );
}
