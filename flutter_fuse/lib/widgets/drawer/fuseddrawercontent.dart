import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import '../../services/blocs.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/messages.dart';
import '../teams/teamtile.dart';
import 'fuseddrawer.dart';
import 'fuseddrawerheader.dart';

///
/// The fused drawer content to display the details of the fused drawer.
///
class FusedDrawerContent extends StatelessWidget {
  /// Constructor.
  FusedDrawerContent({this.mode = DrawerMode.gameList});

  /// The mode to display the content with.
  final DrawerMode mode;

  Widget _buildClubSection(BuildContext context, ClubState state) {
    var data = <Widget>[];
    // If we are specifically in a club, list that here.
    for (var club in state.clubs.values) {
      if (club.isMember()) {
        data.add(
          ListTile(
            leading: const Icon(MdiIcons.cardsClub),
            title: RichText(
              text: TextSpan(
                text: club.name,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 17.0),
                children: <TextSpan>[
                  TextSpan(
                      text: club.isAdmin()
                          ? "\n${Messages.of(context).administrator}"
                          : "",
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 10.0,
                            color: Theme.of(context).primaryColorDark,
                          )),
                ],
              ),
            ),
            subtitle: BlocBuilder(
                cubit: BlocProvider.of<TeamBloc>(context),
                builder: (build, state) {
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
              RepositoryProvider.of<fluro.FluroRouter>(context).navigateTo(
                  context, "Club/${club.uid}",
                  transition: fluro.TransitionType.inFromRight);
            },
          ),
        );
      }
    }
    return Column(children: data);
  }

  Widget _buildTeamSection(BuildContext context, TeamState state) {
    var data = <Widget>[];

    var clubBloc = BlocProvider.of<ClubBloc>(context);

    for (var team in state.playerTeams.values) {
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
        leading: const Icon(MdiIcons.teamviewer),
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
    var children = <Widget>[
      FusedDrawerHeader(),
      BlocBuilder(
        cubit: BlocProvider.of<ClubBloc>(context),
        builder: (context, state) {
          return _buildClubSection(context, state);
        },
      ),
      BlocBuilder(
        cubit: BlocProvider.of<TeamBloc>(context),
        builder: (context, state) {
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
          var overlayState = Overlay.of(context);
          var overlayEntry = OverlayEntry(builder: (context) {
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
          var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
          authenticationBloc.add(AuthenticationLogOut());

          await overlayEntry.remove();

          Navigator.pushNamedAndRemoveUntil(
              context, "/Login/Home", (d) => false);
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
