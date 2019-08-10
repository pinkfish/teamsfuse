import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleplayerprovider.dart';
import 'package:flutter_fuse/widgets/blocs/singleprofileprovider.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamseasonplayerprovider.dart';
import 'package:flutter_fuse/widgets/invites/deleteinvitedialog.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/playerimage.dart';
import 'package:flutter_fuse/widgets/util/playername.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:url_launcher/url_launcher.dart';

class _RoleInTeamAlertDialog extends StatefulWidget {
  _RoleInTeamAlertDialog(this.initialRole);

  final RoleInTeam initialRole;

  @override
  _RoleInTeamAlertDialogState createState() {
    return new _RoleInTeamAlertDialogState();
  }
}

class _RoleInTeamAlertDialogState extends State<_RoleInTeamAlertDialog> {
  RoleInTeam _myRole;

  @override
  void initState() {
    super.initState();
    _myRole = widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    List<DropdownMenuItem<RoleInTeam>> widgets =
        <DropdownMenuItem<RoleInTeam>>[];
    RoleInTeam.values.forEach((RoleInTeam role) {
      widgets.add(
        new DropdownMenuItem<RoleInTeam>(
          child: new Text(
            messages.roleingame(role),
          ),
          value: role,
        ),
      );
    });

    return new AlertDialog(
      title: new Text(messages.roleselect),
      content: new DropdownButton<RoleInTeam>(
        items: widgets,
        value: _myRole,
        onChanged: (RoleInTeam role) {
          print('changed $role');
          setState(() {
            _myRole = role;
          });
        },
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text(MaterialLocalizations.of(context).okButtonLabel),
          onPressed: () {
            // Do the delete.
            Navigator.of(context).pop(_myRole);
          },
        ),
        new FlatButton(
          child: new Text(MaterialLocalizations.of(context).cancelButtonLabel),
          onPressed: () {
            // Do the delete.
            Navigator.of(context).pop(null);
          },
        ),
      ],
    );
  }
}

class PlayerDetailsScreen extends StatelessWidget {
  PlayerDetailsScreen(this.teamUid, this.seasonUid, this.playerUid);

  final String teamUid;
  final String seasonUid;
  final String playerUid;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _changeRole(BuildContext context, SingleTeamSeasonPlayerBloc bloc,
      SingleTeamSeasonPlayerState state) async {
    SeasonPlayer player = state.seasonPlayer;
    RoleInTeam role = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return new _RoleInTeamAlertDialog(player.role);
      },
    );
    if (role != null) {
      bloc.dispatch(SingleTeamSeasonPlayerUpdate(
          player: player.rebuild((b) => b..role = role)));
    }
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(value),
      ),
    );
  }

  void _removeFromTeam(
      BuildContext context,
      SingleTeamSeasonPlayerState playerState,
      SingleTeamSeasonPlayerBloc playerBloc) async {
    Messages mess = Messages.of(context);

    var bloc = SinglePlayerBloc(
        playerBloc: playerBloc.playerBloc, playerUid: playerBloc.playerUid);
    bool result = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(mess.deleteplayer),
            content: new Scrollbar(
              child: new SingleChildScrollView(
                child: BlocBuilder(
                    bloc: bloc,
                    builder: (BuildContext context, SinglePlayerState state) {
                      var arr = <Widget>[];

                      if (state is SinglePlayerLoaded) {
                        arr.add(new Text(
                            mess.confirmremovefromteam(state.player.name)));
                      } else {
                        arr.add(Text(mess.confirmremovefromteam(mess.loading)));
                      }
                      return ListBody(
                        children: arr,
                      );
                    }),
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
      playerBloc.dispatch(SingleTeamSeasonPlayerDelete());
    }
  }

  void _deleteInvite(BuildContext context, InviteToPlayer invite) {
    deleteInviteDialog(context, invite);
  }

  Widget _buildPlayerDetails(
      BuildContext context,
      SingleTeamSeasonPlayerState playerState,
      SingleTeamState teamState,
      SingleTeamSeasonPlayerBloc playerBloc,
      SinglePlayerState singlePlayerState) {
    List<Widget> ret = <Widget>[];
    final Size screenSize = MediaQuery.of(context).size;
    Messages messages = Messages.of(context);
    ThemeData theme = Theme.of(context);

    double width =
        (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0;
    double height = screenSize.height / 4 + 20;

    ret.add(
      new PlayerImage(
        playerUid: playerState.seasonPlayer.playerUid,
        radius: width > height ? height / 2 : width / 2,
      ),
    );

    ret.add(
      new ListTile(
        leading: const Icon(CommunityIcons.bookOpenVariant),
        title: new Text(
          messages.roleingame(playerState.seasonPlayer.role),
        ),
      ),
    );

    if (singlePlayerState.player != null &&
        singlePlayerState.player.users != null) {
      for (String userUid in singlePlayerState.player.users.keys) {
        PlayerUser player = singlePlayerState.player.users[userUid];
        ret.add(
          SingleProfileProvider(
            userUid: userUid,
            builder: (BuildContext context, SingleProfileBloc singleUserBloc) =>
                BlocBuilder(
              bloc: singleUserBloc,
              builder: (BuildContext context, SingleProfileState userState) {
                if (userState is SingleProfileUnitialized) {
                  return new Text(messages.loading);
                }
                if (userState is SingleProfileLoaded) {
                  FusedUserProfile profile = userState.profile;

                  if (profile.phoneNumber != null &&
                      profile.phoneNumber.isNotEmpty) {
                    return new ListTile(
                      leading: const Icon(Icons.phone),
                      title: new Text(
                        messages.displaynamerelationship(
                            profile.displayName, player.relationship),
                      ),
                      subtitle: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text("${profile.phoneNumber}\n${profile.email}"),
                          new Row(
                            children: <Widget>[
                              new IconButton(
                                icon: const Icon(Icons.sms),
                                color: Theme.of(context).primaryColorDark,
                                onPressed: () =>
                                    launch("sms:" + profile.phoneNumber),
                              ),
                              new IconButton(
                                icon: const Icon(Icons.email),
                                color: Theme.of(context).primaryColorDark,
                                onPressed: () =>
                                    launch("mailto:" + profile.email),
                              ),
                              new IconButton(
                                icon: const Icon(Icons.message),
                                color: Theme.of(context).primaryColorDark,
                                onPressed: () => Navigator.pushNamed(
                                    context,
                                    "/AddMessagePlayer/" +
                                        teamUid +
                                        "/" +
                                        seasonUid +
                                        "/" +
                                        playerUid),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  } else {
                    return new ListTile(
                      leading: const Icon(Icons.email),
                      title: new Text(profile.displayName),
                      subtitle: new Text(messages.sendmessage),
                    );
                  }
                }
                return Text(messages.unknown);
              },
            ),
          ),
        );
      }
      if (!singlePlayerState.invitesLoaded &&
          singlePlayerState.invites.length != 0) {
        ret.add(Column(
          children: singlePlayerState.invites.map((InviteToPlayer invite) {
            return new ListTile(
              leading: const Icon(Icons.person_add),
              title: new Text(Messages.of(context).invitedemail(invite)),
              trailing: new IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteInvite(context, invite),
              ),
            );
          }).toList(),
        ));
      }
    }

    // Find which seasons they are in.
    for (Season season in teamState.team.seasons.values) {
      if (season.players.any((SeasonPlayer player) =>
          player.playerUid == playerState.seasonPlayer.playerUid)) {
        ret.add(
          new ListTile(
            leading: const Icon(CommunityIcons.tshirtCrew),
            title: new Text(season.name),
          ),
        );
      }
    }

    if (teamState.isAdmin()) {
      ret.add(
        new Row(
          children: <Widget>[
            new FlatButton(
              onPressed: () => _changeRole(context, playerBloc, playerState),
              child: new Text(messages.changerole),
              textColor: theme.accentColor,
            ),
            new FlatButton(
              onPressed: () =>
                  _removeFromTeam(context, playerState, playerBloc),
              child: new Text(messages.deleteplayer),
              textColor: theme.accentColor,
            ),
          ],
        ),
      );
    }

    return new Column(
      children: ret,
    );
  }

  void _onInvite(BuildContext context, SingleTeamSeasonPlayerState state) {
    Navigator.pushNamed(
        context, "AddInviteToPlayer/" + state.seasonPlayer.playerUid);
  }

  void _editPlayer(BuildContext context, SinglePlayerState state) {
    Navigator.pushNamed(context, "EditPlayer/" + state.player.uid);
  }

  @override
  Widget build(BuildContext context) {
    String userUid =
        BlocProvider.of<AuthenticationBloc>(context).currentUser.uid;

    return SingleTeamProvider(
      teamUid: teamUid,
      builder: (BuildContext context, SingleTeamBloc teamBloc) =>
          SinglePlayerProvider(
        playerUid: playerUid,
        builder: (BuildContext context, SinglePlayerBloc singlePlayerBloc) =>
            SingleTeamSeasonPlayerProvider(
          teamUid: teamUid,
          seasonUid: seasonUid,
          playerUid: playerUid,
          builder: (BuildContext context,
                  SingleTeamSeasonPlayerBloc seasonPlayerBloc) =>
              BlocBuilder(
            bloc: teamBloc,
            builder: (BuildContext context, SingleTeamState teamState) =>
                BlocListener(
              bloc: seasonPlayerBloc,
              listener: (BuildContext context,
                  SingleTeamSeasonPlayerState playerState) {
                if (playerState is SingleTeamSeasonPlayerDeleted) {
                  Navigator.pop(context);
                }
                if (playerState is SingleTeamSeasonPlayerSaveFailed) {
                  _showInSnackBar(Messages.of(context).formerror);
                }
              },
              child: BlocListener(
                bloc: singlePlayerBloc,
                listener: (BuildContext context,
                    SinglePlayerState singlePlayerState) {
                  if (singlePlayerState is SinglePlayerLoaded) {
                    singlePlayerBloc.dispatch(SinglePlayerLoadInvites());
                  }
                  if (singlePlayerState is SingleTeamSeasonPlayerSaveFailed) {
                    _showInSnackBar(Messages.of(context).formerror);
                  }
                },
                child: BlocBuilder(
                  bloc: seasonPlayerBloc,
                  builder: (BuildContext context,
                          SingleTeamSeasonPlayerState seasonPlayerState) =>
                      BlocBuilder(
                    bloc: singlePlayerBloc,
                    builder: (BuildContext context,
                        SinglePlayerState singlePlayerState) {
                      Messages messages = Messages.of(context);
                      if (teamState is SingleTeamLoaded) {
                        List<Widget> actions = <Widget>[];
                        if (teamState.isAdmin()) {
                          actions.add(
                            new FlatButton(
                              onPressed: () {
                                _onInvite(context, seasonPlayerState);
                              },
                              child: new Text(
                                messages.addinvite,
                                style: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          );
                        }
                      }

                      FloatingActionButton fab;
                      if (singlePlayerState is SinglePlayerLoaded &&
                          singlePlayerState.player.users.containsKey(userUid)) {
                        // I am a member of this player, can edit them!
                        fab = new FloatingActionButton(
                          onPressed: () =>
                              _editPlayer(context, singlePlayerState),
                          child: const Icon(Icons.edit),
                        );
                      }

                      return new Scaffold(
                        appBar: new AppBar(
                          title: new PlayerName(
                              playerUid:
                                  seasonPlayerState.seasonPlayer.playerUid),
                        ),
                        key: _scaffoldKey,
                        body: SavingOverlay(
                          saving: seasonPlayerState
                                  is SingleTeamSeasonPlayerSaving ||
                              singlePlayerState is SinglePlayerSaving,
                          child: Scrollbar(
                            child: new SingleChildScrollView(
                              child: _buildPlayerDetails(
                                  context,
                                  seasonPlayerState,
                                  teamState,
                                  seasonPlayerBloc,
                                  singlePlayerState),
                            ),
                          ),
                        ),
                        floatingActionButton: fab,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
