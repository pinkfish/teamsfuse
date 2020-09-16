import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/teamtile.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'fuseddrawer.dart';
import 'fuseddrawerheader.dart';

class FusedDrawerContent extends StatelessWidget {
  FusedDrawerContent({this.mode = DrawerMode.gameList});

  final DrawerMode mode;

  Widget _buildClubSection(BuildContext context, ClubState state) {
    List<Widget> data = <Widget>[];
    // If we are specifically in a club, list that here.
    for (Club club in state.clubs.values) {
      if (club.isMember()) {
        data.add(
          ListTile(
            leading: const Icon(CommunityIcons.cardsClub),
            title: RichText(
              text: TextSpan(
                text: club.name,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 17.0),
                children: <TextSpan>[
                  TextSpan(
                      text: club.isAdmin()
                          ? "\n" + Messages.of(context).administrator
                          : "",
                      style: Theme.of(context).textTheme.subhead.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 10.0,
                            color: Theme.of(context).primaryColorDark,
                          )),
                ],
              ),
            ),
            subtitle: BlocBuilder(
                cubit: BlocProvider.of<TeamBloc>(context),
                builder: (BuildContext build, TeamState state) {
                  //if (snap.hasData) {
                  return Text(
                    Messages.of(context).teamnumbers(state.playerTeams.length),
                  );
                  /*}
                  //if (club.cachedTeams != null) {
                    return Text(
                      Messages.of(context).teamnumbers(state.clubTeams.length),
                    );
                  //}
                  return Text(Messages.of(context).loading);
                  */
                }),
            onTap: () {
              Navigator.pop(context);
              RepositoryProvider.of<fluro.Router>(context).navigateTo(
                  context, "Club/" + club.uid,
                  transition: fluro.TransitionType.inFromRight);
            },
          ),
        );
      }
    }
    return Column(children: data);
  }

  Widget _buildTeamSection(BuildContext context, TeamState state) {
    List<Widget> data = <Widget>[];

    ClubBloc clubBloc = BlocProvider.of<ClubBloc>(context);

    for (Team team in state.playerTeams.values) {
      if (!team.archived) {
        if (team.clubUid == null ||
            !clubBloc.state.clubs.containsKey(team.clubUid)) {
          data.add(
            TeamTile(
              team.uid,
              popBeforeNavigate: true,
              showIconForTeam: true,
            ),
          );
        }
      }
    }
    data.add(
      ListTile(
        leading: const Icon(CommunityIcons.teamviewer),
        title: Text(
          Messages.of(context).allteamsbbutton,
          style: Theme.of(context).textTheme.button,
        ),
        onTap: () => Navigator.popAndPushNamed(context, "AllTeams"),
      ),
    );
    return Column(children: data);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      FusedDrawerHeader(),
      BlocBuilder(
        cubit: BlocProvider.of<ClubBloc>(context),
        builder: (BuildContext context, ClubState state) {
          return _buildClubSection(context, state);
        },
      ),
      BlocBuilder(
        cubit: BlocProvider.of<TeamBloc>(context),
        builder: (BuildContext context, TeamState state) {
          return _buildTeamSection(context, state);
        },
      ),
      Divider(),
      mode == DrawerMode.gameList
          ? ListTile(
              leading: const Icon(Icons.people_outline),
              title: Text(Messages.of(context).leaguetournament),
              onTap: () {
                Navigator.popAndPushNamed(context, "/League/Home");
              },
            )
          : ListTile(
              leading: const Icon(Icons.list),
              title: Text(Messages.of(context).allgames),
              onTap: () {
                Navigator.popAndPushNamed(context, "/Home");
              },
            ),
      Divider(),
      ListTile(
        leading: const Icon(Icons.people_outline),
        title: Text(Messages.of(context).players),
        onTap: () {
          Navigator.popAndPushNamed(context, "/Players");
        },
      ),
      ListTile(
        leading: const Icon(Icons.exit_to_app),
        title: Text(Messages.of(context).signout),
        onTap: () async {
          OverlayState overlayState = Overlay.of(context);
          OverlayEntry overlayEntry =
              OverlayEntry(builder: (BuildContext context) {
            return Positioned(
              top: 50.0,
              left: 50.0,
              child: Material(
                color: Colors.transparent,
                child: Icon(Icons.warning, color: Colors.purple),
              ),
            );
          });

          overlayState.insert(overlayEntry);

          // Do the logout dance.
          AuthenticationBloc authenticationBloc =
              BlocProvider.of<AuthenticationBloc>(context);
          authenticationBloc.add(AuthenticationLogOut());

          await overlayEntry.remove();

          Navigator.pushNamedAndRemoveUntil(
              context, "/Login/Home", (Route<dynamic> d) => false);
        },
      ),
      ListTile(
        leading: const Icon(Icons.settings),
        title: Text(Messages.of(context).settings),
        onTap: () {
          Navigator.popAndPushNamed(context, "/Settings");
        },
      ),
      ListTile(
        leading: const Icon(Icons.help),
        title: Text(Messages.of(context).about),
        onTap: () {
          Navigator.popAndPushNamed(context, "/About");
        },
      ),
    ];
    return ListView(children: children);
  }
}
