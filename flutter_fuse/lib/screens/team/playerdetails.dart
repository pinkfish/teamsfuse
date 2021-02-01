import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singleplayerprovider.dart';
import '../../widgets/blocs/singleprofileprovider.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/blocs/singleteamseasonplayerprovider.dart';
import '../../widgets/invites/deleteinvitedialog.dart';
import '../../widgets/player/playerimage.dart';
import '../../widgets/player/playername.dart';
import '../../widgets/util/savingoverlay.dart';

class _RoleInTeamAlertDialog extends StatefulWidget {
  _RoleInTeamAlertDialog(this.initialRole);

  final RoleInTeam initialRole;

  @override
  _RoleInTeamAlertDialogState createState() {
    return _RoleInTeamAlertDialogState();
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
    var messages = Messages.of(context);

    var widgets = <DropdownMenuItem<RoleInTeam>>[];
    for (var role in RoleInTeam.values) {
      widgets.add(
        DropdownMenuItem<RoleInTeam>(
          child: Text(
            messages.roleingame(role),
          ),
          value: role,
        ),
      );
    }

    return AlertDialog(
      title: Text(messages.roleselect),
      content: DropdownButton<RoleInTeam>(
        items: widgets,
        value: _myRole,
        onChanged: (role) {
          print('changed $role');
          setState(() {
            _myRole = role;
          });
        },
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
          onPressed: () {
            // Do the delete.
            Navigator.of(context).pop(_myRole);
          },
        ),
        FlatButton(
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          onPressed: () {
            // Do the delete.
            Navigator.of(context).pop(null);
          },
        ),
      ],
    );
  }
}

///
/// Shows the details of the player.
///
class PlayerDetailsScreen extends StatelessWidget {
  /// Constrcutor.
  PlayerDetailsScreen(this.teamUid, this.seasonUid, this.playerUid);

  /// The teamUid to get the player details for.
  final String teamUid;

  /// The seasonUid for the player to show details.
  final String seasonUid;

  /// The player itself to open up and view.
  final String playerUid;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _changeRole(BuildContext context, SingleTeamSeasonPlayerBloc bloc,
      SingleTeamSeasonPlayerState state) async {
    var player = state.seasonPlayer;
    var role = await showDialog(
      context: context,
      builder: (context) {
        return _RoleInTeamAlertDialog(player.role);
      },
    );
    if (role != null) {
      bloc.add(SingleTeamSeasonPlayerUpdate(
          player: player.rebuild((b) => b..role = role)));
    }
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }

  void _removeFromTeam(
      BuildContext context,
      SingleTeamSeasonPlayerState playerState,
      SingleTeamSeasonPlayerBloc playerBloc) async {
    var mess = Messages.of(context);

    var bloc = SinglePlayerBloc(playerUid: playerBloc.playerUid);
    var result = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (context) {
          return AlertDialog(
            title: Text(mess.deleteplayer),
            content: Scrollbar(
              child: SingleChildScrollView(
                child: BlocBuilder(
                    cubit: bloc,
                    builder: (context, state) {
                      var arr = <Widget>[];

                      if (state is SinglePlayerLoaded) {
                        arr.add(Text(
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
      playerBloc.add(SingleTeamSeasonPlayerDelete());
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
    var ret = <Widget>[];
    var screenSize = MediaQuery.of(context).size;
    var messages = Messages.of(context);
    var theme = Theme.of(context);

    var width =
        (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0;
    var height = screenSize.height / 4 + 20;

    ret.add(
      PlayerImage(
        playerUid: playerState.seasonPlayer.playerUid,
        radius: width > height ? height / 2 : width / 2,
      ),
    );

    ret.add(
      ListTile(
        leading: const Icon(MdiIcons.bookOpenVariant),
        title: Text(
          messages.roleingame(playerState.seasonPlayer.role),
        ),
      ),
    );

    ret.add(
      ListTile(
        leading: const Icon(MdiIcons.tshirtCrew),
        title: Text(playerState.seasonPlayer.jerseyNumber.isEmpty
            ? Messages.of(context).unknown
            : playerState.seasonPlayer.jerseyNumber),
      ),
    );

    if (singlePlayerState.player != null &&
        singlePlayerState.player.users != null) {
      for (var userUid in singlePlayerState.player.users.keys) {
        var player = singlePlayerState.player.users[userUid];
        ret.add(
          SingleProfileProvider(
            userUid: userUid,
            builder: (context, singleUserBloc) => BlocBuilder(
              cubit: singleUserBloc,
              builder: (context, userState) {
                if (userState is SingleProfileUninitialized) {
                  return Text(messages.loading);
                }
                if (userState is SingleProfileLoaded) {
                  var profile = userState.profile;

                  if (profile.phoneNumber != null &&
                      profile.phoneNumber.isNotEmpty) {
                    return ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(
                        messages.displaynamerelationship(
                            profile.displayName, player.relationship),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("${profile.phoneNumber}\n${profile.email}"),
                          Row(
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.sms),
                                color: Theme.of(context).primaryColorDark,
                                onPressed: () =>
                                    launch("sms:${profile.phoneNumber}"),
                              ),
                              IconButton(
                                icon: const Icon(Icons.email),
                                color: Theme.of(context).primaryColorDark,
                                onPressed: () =>
                                    launch("mailto:${profile.email}"),
                              ),
                              IconButton(
                                icon: const Icon(Icons.message),
                                color: Theme.of(context).primaryColorDark,
                                onPressed: () => Navigator.pushNamed(context,
                                    "/AddMessagePlayer/$teamUid/$seasonUid/$playerUid"),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  } else {
                    return ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(profile.displayName),
                      subtitle: Text(messages.sendmessage),
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
          children: singlePlayerState.invites.map((invite) {
            return ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(Messages.of(context).invitedemail(invite)),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteInvite(context, invite),
              ),
            );
          }).toList(),
        ));
      }
    }

    // Find which seasons they are in.
    for (var season in teamState.fullSeason) {
      if (season.players.any(
          (player) => player.playerUid == playerState.seasonPlayer.playerUid)) {
        ret.add(
          ListTile(
            leading: const Icon(MdiIcons.tshirtCrew),
            title: Text(season.name),
          ),
        );
      }
    }

    if (!(teamState is SingleTeamUninitialized) && teamState.isAdmin()) {
      ret.add(
        Row(
          children: <Widget>[
            FlatButton(
              onPressed: () => _changeRole(context, playerBloc, playerState),
              child: Text(messages.changerole),
              textColor: theme.accentColor,
            ),
            FlatButton(
              onPressed: () =>
                  _removeFromTeam(context, playerState, playerBloc),
              child: Text(messages.deleteplayer),
              textColor: theme.accentColor,
            ),
          ],
        ),
      );
    }

    return Column(
      children: ret,
    );
  }

  void _onInvite(BuildContext context, SingleTeamSeasonPlayerState state) {
    Navigator.pushNamed(
        context, "AddInviteToPlayer/${state.seasonPlayer.playerUid}");
  }

  void _editPlayer(BuildContext context, String playrrUid) {
    Navigator.pushNamed(context, "EditPlayer/$playerUid");
  }

  @override
  Widget build(BuildContext context) {
    var userUid = BlocProvider.of<AuthenticationBloc>(context).currentUser.uid;

    return SingleTeamProvider(
      teamUid: teamUid,
      builder: (context, singleTeamBloc) => SinglePlayerProvider(
        playerUid: playerUid,
        builder: (context, singlePlayerBloc) => SingleTeamSeasonPlayerProvider(
          seasonUid: seasonUid,
          playerUid: playerUid,
          builder: (context, seasonPlayerBloc) => BlocBuilder(
            cubit: singleTeamBloc,
            builder: (context, teamState) => BlocConsumer(
              cubit: singlePlayerBloc,
              listener: (context, singlePlayerState) {
                if (singlePlayerState is SinglePlayerLoaded) {
                  singlePlayerBloc.add(SinglePlayerLoadInvites());
                }
                if (singlePlayerState is SingleTeamSeasonPlayerSaveFailed) {
                  _showInSnackBar(Messages.of(context).formerror);
                }
              },
              builder: (context, singlePlayerState) => BlocConsumer(
                cubit: seasonPlayerBloc,
                listener: (context, playerState) {
                  if (playerState is SingleTeamSeasonPlayerDeleted) {
                    Navigator.pop(context);
                  }
                  if (playerState is SingleTeamSeasonPlayerSaveFailed) {
                    _showInSnackBar(Messages.of(context).formerror);
                  }
                },
                builder: (context, seasonPlayerState) {
                  var messages = Messages.of(context);
                  if (teamState is SingleTeamLoaded) {
                    var actions = <Widget>[];
                    if (teamState.isAdmin()) {
                      actions.add(
                        FlatButton(
                          onPressed: () {
                            _onInvite(context, seasonPlayerState);
                          },
                          child: Text(
                            messages.addinvite,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  }

                  var actions = <Widget>[];
                  if (singlePlayerState is SinglePlayerLoaded &&
                      singlePlayerState.player.users.containsKey(userUid)) {
                    // I am a member of this player, can edit them!
                    actions.add(
                      PopupMenuButton<String>(
                        onSelected: (str) => _editPlayer(
                            context, seasonPlayerState.seasonPlayer.playerUid),
                        itemBuilder: (context) => <PopupMenuItem<String>>[
                          PopupMenuItem<String>(
                            value: "edit",
                            child: ListTile(
                              title: Text(Messages.of(context).editbuttontext),
                              leading: Icon(Icons.edit),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (seasonPlayerState
                      is SingleTeamSeasonPlayerUninitialized) {
                    return LoadingWidget();
                  }

                  return Scaffold(
                    appBar: AppBar(
                      title: PlayerName(
                          playerUid: seasonPlayerState.seasonPlayer.playerUid),
                      actions: actions,
                    ),
                    key: _scaffoldKey,
                    body: SavingOverlay(
                      saving:
                          seasonPlayerState is SingleTeamSeasonPlayerSaving ||
                              singlePlayerState is SinglePlayerSaving,
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: _buildPlayerDetails(context, seasonPlayerState,
                              teamState, seasonPlayerBloc, singlePlayerState),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
