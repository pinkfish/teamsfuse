import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:flutter_fuse/widgets/clubs/clubteams.dart';
import 'package:flutter_fuse/widgets/teams/publicteamdetails.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/messages.dart';

///
/// Shows the public details of the team.
///
class PublicTeamDetailsScreen extends StatelessWidget {
  final String teamUid;

  PublicTeamDetailsScreen(this.teamUid);

  Widget _buildBody(BuildContext context, Team team, BoxConstraints layout) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          child: Column(
            children: [
              TextButton.icon(
                icon: Icon(Icons.arrow_back),
                label: Text(
                  MaterialLocalizations.of(context).backButtonTooltip,
                ),
                onPressed: () => Navigator.pushNamed(
                    context, "/Public/Club/" + team.clubUid),
              ),
              Expanded(
                child: ClubTeams(
                  team.clubUid,
                  onlyPublic: true,
                  selected: team,
                  onTap: (t) =>
                      Navigator.pushNamed(context, "/Public/Team/" + t.uid),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PublicTeamDetails(team.uid),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: teamUid,
      builder: (context, singleTeamBloc) => BlocConsumer(
        cubit: singleTeamBloc,
        listener: (context, state) {
          if (state is SingleTeamDeleted) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          String title;
          if (state is SingleTeamDeleted || state is SingleTeamUninitialized) {
            title = Messages.of(context).loading;
          } else {
            title = state.club.name;
          }
          Widget theBody;
          if (state is SingleTeamDeleted) {
            theBody = Center(
              child: Text(Messages.of(context).clubDeleted,
                  style: Theme.of(context).textTheme.headline3),
            );
          } else if (state is SingleTeamUninitialized) {
            theBody = Center(
              child: LoadingWidget(),
            );
          } else {
            theBody = LayoutBuilder(
              builder: (context, layout) =>
                  _buildBody(context, state.team, layout),
            );
          }

          // Setup the navigation items.
          var navItems = <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.gamepad),
              label: Messages.of(context).clubdetails,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: Messages.of(context).teams,
            ),
          ];

          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              leading: Icon(MdiIcons.cardsClub),
            ),
            body: theBody,
          );
        },
      ),
    );
  }
}
