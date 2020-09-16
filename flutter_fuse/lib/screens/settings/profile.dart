import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singleplayerprovider.dart';
import '../../widgets/invites/deleteinvitedialog.dart';
import '../../widgets/util/playerimage.dart';

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
          return AlertDialog(
            title: Text(mess.deleteplayer),
            content: Scrollbar(
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(mess.confirmdeleteplayer(player)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () {
                  // Do the delete.
                  Navigator.of(context).pop(true);
                },
              ),
              FlatButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
    if (result) {
      bloc.add(SinglePlayerDelete());
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

    var invites = player.invites;
    if (invites.length > 0) {
      ret.add(
        Column(
          children: invites.map((InviteToPlayer invite) {
            return ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(Messages.of(context).invitedemail(invite)),
              trailing: IconButton(
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
          profileUid: user.userUid,
          playerBloc: BlocProvider.of<PlayerBloc>(context));
      ret.add(
        // Use a provider to cleanup the bloc.
        BlocProvider(
          create: (BuildContext context) => bloc,
          child: BlocBuilder(
            cubit: bloc,
            builder: (BuildContext context, SingleProfileState userState) {
              if (userState is SingleProfileUninitialized ||
                  userState is SingleProfileDeleted) {
                return ListTile(
                  title: Text(Messages.of(context).displaynamerelationship(
                      Messages.of(context).loading, user.relationship)),
                );
              }
              FusedUserProfile profile = userState.profile;
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(Messages.of(context).displaynamerelationship(
                    profile.displayName, user.relationship)),
                subtitle: Text(profile.email),
              );
            },
          ),
        ),
      );
    }
    ret.add(
      FlatButton(
        onPressed: () => _onAddPlayerInvite(context, player.player),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.add,
              color: Colors.blueAccent,
            ),
            SizedBox(width: 10.0),
            Text(
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
      ret.add(Center(
        child: PlayerImage(
          playerUid: state.me != null ? state.me.uid : null,
          radius: width > height ? height / 2 : width / 2,
        ),
      ));
    }
    AuthenticationBloc authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);

    if (!onlyPlayer) {
      ret.add(Text(authenticationBloc.currentUser.profile.displayName,
          style: theme.textTheme.headline));
      ret.add(
        ListTile(
          leading: const Icon(Icons.email),
          title: Text(authenticationBloc.currentUser.email),
        ),
      );
      ret.add(
        ListTile(
          leading: const Icon(Icons.phone),
          title: Text(authenticationBloc.currentUser.profile.phoneNumber),
        ),
      );
      ret.add(Divider());
      ret.add(Text(messages.players,
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
              cubit: playerBloc,
              builder: (BuildContext context, SinglePlayerState playerState) {
                // List the teams they are in.
                List<Widget> teamNames = <Widget>[];
                ImageProvider leading;
                if (playerState.player.photoUrl != null &&
                    playerState.player.photoUrl.isNotEmpty) {
                  leading =
                      CachedNetworkImageProvider(playerState.player.photoUrl);
                } else {
                  leading =
                      const AssetImage("assets/images/defaultavatar2.png");
                }
                TeamBloc teamBloc = BlocProvider.of<TeamBloc>(context);
                if (teamBloc.state.playerTeams.containsKey(player.uid)) {
                  Iterable<Team> teams = teamBloc.state.playerTeams.values;
                  SeasonBloc seasonBloc = BlocProvider.of<SeasonBloc>(context);

                  for (Team team in teams) {
                    for (Season season in seasonBloc.state.seasons.values) {
                      int index = season.players.indexWhere((SeasonPlayer sp) {
                        return sp.playerUid == player.uid;
                      });
                      if (index != -1) {
                        teamNames.add(
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, "EditPlayer/" + player.uid),
                            child: ListTile(
                              leading: const Icon(Icons.people),
                              title: Text(team.name),
                              subtitle: Text(
                                messages.roleingame(season.players[index].role),
                              ),
                              trailing: IconButton(
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
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: CircleAvatar(backgroundImage: leading),
                        trailing: IconButton(
                          onPressed: () {
                            _editPlayer(context, player.uid);
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        title: Text(player.name),
                      ),
                      ExpansionTile(
                        title: Text(messages
                            .numberofuserforplayer(player.users.length)),
                        initiallyExpanded: false,
                        children: _buildUserList(context, playerState),
                      ),
                      ExpansionTile(
                        title: Text(
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
    Navigator.pushNamed(context,
        "EditProfile/" + BlocProvider.of<PlayerBloc>(context).state.me.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          onlyPlayer
              ? Messages.of(context).players
              : Messages.of(context).title,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editProfile(context),
        child: const Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Scrollbar(
        child: SingleChildScrollView(
          child: BlocBuilder(
            cubit: BlocProvider.of<PlayerBloc>(context),
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
