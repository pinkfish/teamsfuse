import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/teams/teamimage.dart';
import 'package:flutter_fuse/widgets/teams/teamname.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleplayerprovider.dart';
import '../../widgets/invites/deleteinvitedialog.dart';
import '../../widgets/player/playerimage.dart';

///
/// Displays the profile for the user.
///
class ProfileScreen extends StatelessWidget {
  /// Constructor.
  ProfileScreen({this.onlyPlayer = false});

  /// Only show the player.
  final bool onlyPlayer;

  void _editPlayer(BuildContext context, String uid) {
    Navigator.pushNamed(context, "EditPlayer/$uid");
  }

  void _deletePlayer(
      BuildContext context, Player player, SinglePlayerBloc bloc) async {
    var mess = Messages.of(context);
    // Show an alert dialog and stuff.
    var result = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (context) {
          return AlertDialog(
            title: Text(mess.deleteplayer),
            content: Scrollbar(
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(mess.confirmDeletePlayer(player)),
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
    Navigator.pushNamed(context, "AddInviteToPlayer/${player.uid}");
  }

  List<Widget> _buildUserList(BuildContext context, SinglePlayerState player) {
    var ret = <Widget>[];
    var theme = Theme.of(context);

    var invites = player.invites;
    if (invites.isNotEmpty) {
      ret.add(
        Column(
          children: invites.map((invite) {
            return ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(invite.email),
              trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteInvite(context, invite)),
            );
          }).toList(),
        ),
      );
    }

    for (var user in player.player.users.values) {
      var bloc = SingleProfileBloc(
          coordinationBloc: BlocProvider.of<CoordinationBloc>(context),
          profileUid: user.userUid,
          playerBloc: BlocProvider.of<PlayerBloc>(context));
      ret.add(
        // Use a provider to cleanup the bloc.
        BlocProvider(
          create: (context) => bloc,
          child: BlocBuilder(
            cubit: bloc,
            builder: (context, userState) {
              if (userState is SingleProfileUninitialized ||
                  userState is SingleProfileDeleted) {
                return ListTile(
                  title: Text(Messages.of(context).displayNameRelationship(
                      Messages.of(context).loading, user.relationship)),
                );
              }
              FusedUserProfile profile = userState.profile;
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(Messages.of(context).displayNameRelationship(
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
              Messages.of(context).addInvite,
              style: theme.textTheme.button.copyWith(color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
    return ret;
  }

  List<Widget> _buildPlayerData(BuildContext context, PlayerState state) {
    var screenSize = MediaQuery.of(context).size;
    var ret = <Widget>[];
    var theme = Theme.of(context);
    var messages = Messages.of(context);

    var width =
        (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0;
    var height = screenSize.height / 4 + 20;
    if (!onlyPlayer) {
      ret.add(Center(
        child: PlayerImage(
          playerUid: state.me != null ? state.me.uid : null,
          radius: width > height ? height / 2 : width / 2,
        ),
      ));
    }
    var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    if (!onlyPlayer) {
      ret.add(Text(authenticationBloc.currentUser.profile.displayName,
          style: theme.textTheme.headline5));
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
          style: theme.textTheme.subtitle1.copyWith(color: theme.accentColor)));
    }
    if (state.players.length > 0) {
      // We have some extra players!
      for (var key in state.players.keys) {
        var player = state.players[key];

        ret.add(
          SinglePlayerProvider(
            playerUid: player.uid,
            builder: (context, playerBloc) => BlocBuilder(
              cubit: playerBloc,
              builder: (context, playerState) {
                if (playerState is SinglePlayerUninitialized) {
                  return LoadingWidget();
                }
                // List the teams they are in.
                var teamNames = <Widget>[];
                ImageProvider leading;
                if (playerState.player.photoUrl != null &&
                    playerState.player.photoUrl.isNotEmpty) {
                  leading =
                      CachedNetworkImageProvider(playerState.player.photoUrl);
                } else {
                  leading =
                      const AssetImage("assets/images/defaultavatar2.png");
                }
                if (!playerState.seasonsLoaded) {
                  playerBloc.add(SinglePlayerLoadSeasons());
                }
                if (playerState.seasonsLoaded) {
                  var teams = Set<String>();
                  for (Season season in playerState.seasons) {
                    if (!teams.contains(season.teamUid)) {
                      teams.add(season.teamUid);
                      teamNames.add(
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, "EditPlayer/${player.uid}"),
                          child: ListTile(
                            tileColor: Theme.of(context).selectedRowColor,
                            minVerticalPadding: 10.0,
                            leading: TeamImage(
                                teamUid: season.teamUid, width: 40, height: 40),
                            title: TeamName(
                                teamUid: season.teamUid,
                                style: Theme.of(context).textTheme.headline5),
                            subtitle: Table(
                              children: [
                                TableRow(
                                  children: [
                                    Text(Messages.of(context).season,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                                fontWeight: FontWeight.bold)),
                                    Text(Messages.of(context).role,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                                fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                ...(playerState.seasons
                                    .where((s) => s.teamUid == season.teamUid)
                                    .map<TableRow>((s) {
                                  int index = s.players.indexWhere((p) =>
                                      p.playerUid == playerState.player.uid);
                                  return TableRow(
                                    children: [
                                      Text(s.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2),
                                      Text(
                                        messages
                                            .roleInGame(s.players[index].role),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      )
                                    ],
                                  );
                                }).toList()),
                              ],
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
                      teamNames.add(SizedBox(height:20));
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
                            .numberOfUserForPlayer(player.users.length)),
                        initiallyExpanded: false,
                        children: _buildUserList(context, playerState),
                      ),
                      ExpansionTile(
                        title: Text(
                            messages.numberOfTeamsForPlayer(teamNames.length)),
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
        "EditProfile/${BlocProvider.of<PlayerBloc>(context).state.me.uid}");
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
            builder: (context, state) {
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
