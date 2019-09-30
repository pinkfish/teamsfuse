import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/approuter.dart';
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
          new ListTile(
            leading: const Icon(CommunityIcons.cardsClub),
            title: new RichText(
              text: new TextSpan(
                text: club.name,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 17.0),
                children: <TextSpan>[
                  new TextSpan(
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
                bloc: BlocProvider.of<TeamBloc>(context),
                builder: (BuildContext build, TeamState state) {
                  //if (snap.hasData) {
                  return new Text(
                    Messages.of(context).teamnumbers(state.playerTeams.length),
                  );
                  /*}
                  //if (club.cachedTeams != null) {
                    return new Text(
                      Messages.of(context).teamnumbers(state.clubTeams.length),
                    );
                  //}
                  return new Text(Messages.of(context).loading);
                  */
                }),
            onTap: () {
              Navigator.pop(context);
              AppRouter.instance.navigateTo(context, "Club/" + club.uid,
                  transition: TransitionType.inFromRight);
            },
          ),
        );
      }
    }
    return new Column(children: data);
  }

  Widget _buildTeamSection(BuildContext context, TeamState state) {
    List<Widget> data = <Widget>[];

    ClubBloc clubBloc = BlocProvider.of<ClubBloc>(context);

    for (Team team in state.playerTeams.values) {
      if (!team.archived) {
        if (team.clubUid == null ||
            !clubBloc.currentState.clubs.containsKey(team.clubUid)) {
          data.add(
            new TeamTile(
              team.uid,
              popBeforeNavigate: true,
              showIconForTeam: true,
            ),
          );
        }
      }
    }
    data.add(
      new ListTile(
        leading: const Icon(CommunityIcons.teamviewer),
        title: new Text(
          Messages.of(context).allteamsbbutton,
          style: Theme.of(context).textTheme.button,
        ),
        onTap: () => Navigator.popAndPushNamed(context, "AllTeams"),
      ),
    );
    return new Column(children: data);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      new FusedDrawerHeader(),
      new BlocBuilder(
        bloc: BlocProvider.of<ClubBloc>(context),
        builder: (BuildContext context, ClubState state) {
          return _buildClubSection(context, state);
        },
      ),
      new BlocBuilder(
        bloc: BlocProvider.of<TeamBloc>(context),
        builder: (BuildContext context, TeamState state) {
          return _buildTeamSection(context, state);
        },
      ),
      new Divider(),
      mode == DrawerMode.gameList
          ? new ListTile(
              leading: const Icon(Icons.people_outline),
              title: new Text(Messages.of(context).leaguetournament),
              onTap: () {
                Navigator.popAndPushNamed(context, "/League/Home");
              },
            )
          : new ListTile(
              leading: const Icon(Icons.list),
              title: new Text(Messages.of(context).allgames),
              onTap: () {
                Navigator.popAndPushNamed(context, "/Home");
              },
            ),
      new Divider(),
      new ListTile(
        leading: const Icon(Icons.people_outline),
        title: new Text(Messages.of(context).players),
        onTap: () {
          Navigator.popAndPushNamed(context, "/Players");
        },
      ),
      new ListTile(
        leading: const Icon(Icons.exit_to_app),
        title: new Text(Messages.of(context).signout),
        onTap: () async {
          OverlayState overlayState = Overlay.of(context);
          OverlayEntry overlayEntry =
              new OverlayEntry(builder: (BuildContext context) {
            return new Positioned(
              top: 50.0,
              left: 50.0,
              child: new Material(
                color: Colors.transparent,
                child: new Icon(Icons.warning, color: Colors.purple),
              ),
            );
          });

          overlayState.insert(overlayEntry);

          // Do the logout dance.
          AuthenticationBloc authenticationBloc =
              BlocProvider.of<AuthenticationBloc>(context);
          authenticationBloc.dispatch(AuthenticationLogOut());

          await overlayEntry.remove();

          Navigator.pushNamedAndRemoveUntil(
              context, "/Login/Home", (Route<dynamic> d) => false);
        },
      ),
      new ListTile(
        leading: const Icon(Icons.settings),
        title: new Text(Messages.of(context).settings),
        onTap: () {
          Navigator.popAndPushNamed(context, "/Settings");
        },
      ),
      new ListTile(
        leading: const Icon(Icons.help),
        title: new Text(Messages.of(context).about),
        onTap: () {
          Navigator.popAndPushNamed(context, "/About");
        },
      ),
    ];
    return new ListView(children: children);
  }
}
