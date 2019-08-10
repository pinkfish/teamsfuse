import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/invites/deleteinvitedialog.dart';
import 'package:flutter_fuse/widgets/util/cachednetworkimage.dart';
import 'package:flutter_fuse/widgets/util/playerimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../widgets/blocs/singleplayerprovider.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({this.onlyPlayer = false});

  final bool onlyPlayer;

  void _editPlayer(BuildContext context, String uid) {
    Navigator.pushNamed(context, "EditPlayer/" + uid);
  }

  void _deletePlayer(
      BuildContext context, Player player, SinglePlayerBloc bloc) async {
    Messages mess = Messages.of(context);
    // Show an alert dialog and stuff.
    bool result = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(mess.deleteplayer),
            content: new Scrollbar(
              child: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(mess.confirmdeleteplayer(player)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child:
                    new Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () {
                  // Do the delete.
                  Navigator.of(context).pop(true);
                },
              ),
              new FlatButton(
                child: new Text(
                    MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
    if (result) {
      bloc.dispatch(SinglePlayerDelete());
    }
  }

  void _deleteInvite(BuildContext context, InviteToPlayer invite) async {
    await deleteInviteDialog(context, invite);
  }

  void _onAddPlayerInvite(BuildContext context, Player player) {
    Navigator.pushNamed(context, "AddInviteToPlayer/" + player.uid);
  }

  List<Widget> _buildUserList(BuildContext context, SinglePlayerState player) {
    List<Widget> ret = <Widget>[];
    ThemeData theme = Theme.of(context);

    List<InviteToPlayer> invites = player.invites;
    if (invites.length > 0) {
      ret.add(
        new Column(
          children: invites.map((InviteToPlayer invite) {
            return new ListTile(
              leading: const Icon(Icons.person_add),
              title: new Text(Messages.of(context).invitedemail(invite)),
              trailing: new IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteInvite(context, invite)),
            );
          }).toList(),
        ),
      );
    }

    for (PlayerUser user in player.player.users.values) {
      var bloc = SingleProfileBloc(
          coordinationBloc: BlocProvider.of<CoordinationBloc>(context),
          profileUid: user.userUid);
      ret.add(
        // Use a provider to cleanup the bloc.
        BlocProvider(
          builder: (BuildContext context) => bloc,
          child: BlocBuilder(
            bloc: bloc,
            builder: (BuildContext context, SingleProfileState userState) {
              if (userState is SingleProfileUnitialized ||
                  userState is SingleProfileDeleted) {
                return new ListTile(
                  title: new Text(Messages.of(context).displaynamerelationship(
                      Messages.of(context).loading, user.relationship)),
                );
              }
              FusedUserProfile profile = userState.profile;
              return new ListTile(
                leading: const Icon(Icons.person),
                title: new Text(Messages.of(context).displaynamerelationship(
                    profile.displayName, user.relationship)),
                subtitle: new Text(profile.email),
              );
            },
          ),
        ),
      );
    }
    ret.add(
      new FlatButton(
        onPressed: () => _onAddPlayerInvite(context, player.player),
        child: new Row(
          children: <Widget>[
            new Icon(
              Icons.add,
              color: Colors.blueAccent,
            ),
            new SizedBox(width: 10.0),
            new Text(
              Messages.of(context).addinvite,
              style: theme.textTheme.button.copyWith(color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
    return ret;
  }

  List<Widget> _buildPlayerData(BuildContext context, PlayerState state) {
    final Size screenSize = MediaQuery.of(context).size;
    List<Widget> ret = <Widget>[];
    ThemeData theme = Theme.of(context);
    Messages messages = Messages.of(context);

    double width =
        (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0;
    double height = screenSize.height / 4 + 20;
    if (!onlyPlayer) {
      ret.add(new Center(
        child: new PlayerImage(
          playerUid: state.me != null ? state.me.uid : null,
          radius: width > height ? height / 2 : width / 2,
        ),
      ));
    }
    AuthenticationBloc authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);

    if (!onlyPlayer) {
      ret.add(new Text(authenticationBloc.currentUser.profile.displayName,
          style: theme.textTheme.headline));
      ret.add(
        new ListTile(
          leading: const Icon(Icons.email),
          title: new Text(authenticationBloc.currentUser.email),
        ),
      );
      ret.add(
        new ListTile(
          leading: const Icon(Icons.phone),
          title: new Text(authenticationBloc.currentUser.profile.phoneNumber),
        ),
      );
      ret.add(new Divider());
      ret.add(new Text(messages.players,
          style: theme.textTheme.subhead.copyWith(color: theme.accentColor)));
    }
    if (state.players.length > 0) {
      // We have some extra players!
      for (String key in state.players.keys) {
        Player player = state.players[key];

        ret.add(
          SinglePlayerProvider(
            playerUid: player.uid,
            builder: (BuildContext context, SinglePlayerBloc playerBloc) =>
                BlocBuilder(
              bloc: playerBloc,
              builder: (BuildContext context, SinglePlayerState playerState) {
                // List the teams they are in.
                List<Widget> teamNames = <Widget>[];
                ImageProvider leading;
                if (playerState.player.photoUrl != null &&
                    playerState.player.photoUrl.isNotEmpty) {
                  leading = new CachedNetworkImageProvider(
                      urlNow: playerState.player.photoUrl);
                } else {
                  leading =
                      const AssetImage("assets/images/defaultavatar2.png");
                }
                TeamBloc teamBloc = BlocProvider.of<TeamBloc>(context);
                if (teamBloc.currentState.teamsByPlayer
                    .containsKey(player.uid)) {
                  Iterable<Team> teams =
                      teamBloc.currentState.teamsByPlayer.values;

                  for (Team team in teams) {
                    for (Season season in team.seasons.values) {
                      int index = season.players.indexWhere((SeasonPlayer sp) {
                        return sp.playerUid == player.uid;
                      });
                      if (index != -1) {
                        teamNames.add(
                          new GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, "EditPlayer/" + player.uid),
                            child: new ListTile(
                              leading: const Icon(Icons.people),
                              title: new Text(team.name),
                              subtitle: new Text(
                                messages.roleingame(season.players[index].role),
                              ),
                              trailing: new IconButton(
                                onPressed: () {
                                  _deletePlayer(context, player, playerBloc);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  }
                }

                return Card(
                  child: new Column(
                    children: <Widget>[
                      new ListTile(
                        leading: new CircleAvatar(backgroundImage: leading),
                        trailing: new IconButton(
                          onPressed: () {
                            _editPlayer(context, player.uid);
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        title: new Text(player.name),
                      ),
                      new ExpansionTile(
                        title: new Text(messages
                            .numberofuserforplayer(player.users.length)),
                        initiallyExpanded: false,
                        children: _buildUserList(context, playerState),
                      ),
                      ExpansionTile(
                        title: new Text(
                            messages.numberofteamsforplayer(teamNames.length)),
                        initiallyExpanded: false,
                        children: teamNames,
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }

    return ret;
  }

  void _editProfile(BuildContext context) {
    // Open up the edit profile dialog.
    Navigator.pushNamed(
        context,
        "EditProfile/" +
            BlocProvider.of<PlayerBloc>(context).currentState.me.uid);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          onlyPlayer
              ? Messages.of(context).players
              : Messages.of(context).title,
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _editProfile(context),
        child: const Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: new Scrollbar(
        child: new SingleChildScrollView(
          child: BlocBuilder<PlayerEvent, PlayerState>(
            bloc: BlocProvider.of<PlayerBloc>(context),
            builder: (BuildContext context, PlayerState state) {
              if (state is PlayerUninitialized) {
                return Text(Messages.of(context).formerror);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildPlayerData(context, state),
              );
            },
          ),
        ),
      ),
    );
  }
}
