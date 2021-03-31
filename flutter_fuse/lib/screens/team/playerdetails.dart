import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleplayerprovider.dart';
import '../../widgets/blocs/singleprofileprovider.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/blocs/singleteamseasonplayerprovider.dart';
import '../../widgets/invites/deleteinvitedialog.dart';
import '../../widgets/player/playerimage.dart';
import '../../widgets/player/playername.dart';
import '../../widgets/util/loading.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Shows the details of the player.
///
class PlayerDetailsScreen extends StatelessWidget {
  /// Constructor.
  PlayerDetailsScreen(this.teamUid, this.seasonUid, this.playerUid);

  /// The teamUid to get the player details for.
  final String teamUid;

  /// The seasonUid for the player to show details.
  final String seasonUid;

  /// The player itself to open up and view.
  final String playerUid;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showInSnackBar(BuildContext context, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
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

    var bloc = SinglePlayerBloc(
      playerUid: playerBloc.playerUid,
      crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
    );
    var result = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (context) {
          return AlertDialog(
            title: Text(mess.removeFromTeamButton),
            content: Scrollbar(
              child: SingleChildScrollView(
                child: BlocBuilder(
                    bloc: bloc,
                    builder: (context, state) {
                      var arr = <Widget>[];

                      if (state is SinglePlayerLoaded) {
                        arr.add(Text(
                            mess.confirmRemoveFromTeam(state.player.name)));
                      } else {
                        arr.add(Text(mess.confirmRemoveFromTeam(mess.loading)));
                      }
                      return ListBody(
                        children: arr,
                      );
                    }),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Do the delete.
                  Navigator.of(context).pop(true);
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
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
          messages.roleInGame(playerState.seasonPlayer.role),
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
      if (singlePlayerState.player.users.isEmpty) {
        ret.add(
          Text(Messages.of(context).invitedToTeam),
        );
      } else {
        for (final userUid in singlePlayerState.player.users.keys) {
          final player = singlePlayerState.player.users[userUid];
          ret.add(
            SingleProfileProvider(
              userUid: userUid,
              builder: (context, singleUserBloc) => BlocBuilder(
                bloc: singleUserBloc,
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
                          messages.displayNameRelationship(
                              profile.displayName, player.relationship),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('${profile.phoneNumber}\n${profile.email}'),
                            Row(
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(Icons.sms),
                                  color: Theme.of(context).primaryColorDark,
                                  onPressed: () =>
                                      launch('sms:${profile.phoneNumber}'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.email),
                                  color: Theme.of(context).primaryColorDark,
                                  onPressed: () =>
                                      launch('mailto:${profile.email}'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.message),
                                  color: Theme.of(context).primaryColorDark,
                                  onPressed: () => Navigator.pushNamed(context,
                                      '/AddMessagePlayer/$teamUid/$seasonUid/$playerUid'),
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
                        subtitle: Text(messages.sendMessage),
                      );
                    }
                  }
                  return Text(messages.unknown);
                },
              ),
            ),
          );
        }
      }
      if (!singlePlayerState.loadedInvites &&
          singlePlayerState.invites.isNotEmpty) {
        ret.add(Column(
          children: singlePlayerState.invites.map((invite) {
            return ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(invite.email),
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
      SingleChildScrollView(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: ret),
              ),
            ),
            ButtonBar(
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                      context, '/Season/Player/$seasonUid/$playerUid'),
                  style: TextButton.styleFrom(
                    primary: theme.accentColor,
                  ),
                  child: Text(messages.changeRoleButton),
                ),
                TextButton(
                  onPressed: () =>
                      _removeFromTeam(context, playerState, playerBloc),
                  style: TextButton.styleFrom(
                    primary: theme.accentColor,
                  ),
                  child: Text(messages.removeFromTeamButton),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: ret,
      ),
    );
  }

  void _onInvite(BuildContext context, SingleTeamSeasonPlayerState state) {
    Navigator.pushNamed(
        context, 'AddInviteToPlayer/${state.seasonPlayer.playerUid}');
  }

  void _editPlayer(BuildContext context, String playerUid) {
    Navigator.pushNamed(context, 'EditPlayer/$playerUid');
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
            bloc: singleTeamBloc,
            builder: (context, teamState) => BlocConsumer(
              bloc: singlePlayerBloc,
              listener: (context, singlePlayerState) {
                if (singlePlayerState is SinglePlayerLoaded) {
                  singlePlayerBloc.add(SinglePlayerLoadInvites());
                }
                if (singlePlayerState is SingleTeamSeasonPlayerSaveFailed) {
                  _showInSnackBar(context, Messages.of(context).formError);
                }
              },
              builder: (context, singlePlayerState) => BlocConsumer(
                bloc: seasonPlayerBloc,
                listener: (context, playerState) {
                  if (playerState is SingleTeamSeasonPlayerDeleted) {
                    Navigator.pop(context);
                  }
                  if (playerState is SingleTeamSeasonPlayerSaveFailed) {
                    _showInSnackBar(context, Messages.of(context).formError);
                  }
                },
                builder: (context, seasonPlayerState) {
                  var messages = Messages.of(context);
                  if (teamState is SingleTeamLoaded) {
                    var actions = <Widget>[];
                    if (teamState.isAdmin()) {
                      actions.add(
                        TextButton(
                          onPressed: () {
                            _onInvite(context, seasonPlayerState);
                          },
                          child: Text(
                            messages.addInviteButton,
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
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editPlayer(
                            context, seasonPlayerState.seasonPlayer.playerUid),
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
                        child: _buildPlayerDetails(context, seasonPlayerState,
                            teamState, seasonPlayerBloc, singlePlayerState),
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
