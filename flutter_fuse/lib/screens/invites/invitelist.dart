import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/invites/deleteinvitedialog.dart';
import '../../widgets/util/savingoverlay.dart';

// Shows the current invites pending for this user.
class InviteListScreen extends StatefulWidget {
  static void deletePressed(BuildContext context, Invite invite) async {
    Messages mess = Messages.of(context);

    bool result = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(mess.deleteinvite),
            content: Scrollbar(
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(mess.confirmdelete(invite)),
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
      SingleInviteBloc singleInviteBloc = SingleInviteBloc(
          analytisSubsystem: RepositoryProvider.of<AnalyticsSubsystem>(context),
          inviteUid: invite.uid,
          teamBloc: BlocProvider.of<TeamBloc>(context),
          seasonBloc: BlocProvider.of<SeasonBloc>(context));
      try {
        singleInviteBloc
            .add(SingleInviteEventDeleteInvite(inviteUid: invite.uid));
      } finally {
        singleInviteBloc.close();
      }
    }
  }

  @override
  InviteListScreenState createState() {
    return InviteListScreenState();
  }
}

class InviteListScreenState extends State<InviteListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onInviteUpdate(UpdateReason reason) {
    setState(() {});
  }

  void _deleteInvite(Invite invite) async {
    bool result = await deleteInviteDialog(context, invite);
    if (result) {
      if (invite is InviteToTeam) {
        Navigator.pop(context);
      }
    }
  }

  void _addInviteToTeam(Invite invite) {
    Navigator.pushNamed(context, "AcceptInviteToTeam/" + invite.uid);
  }

  void _addInviteToPlayer(Invite invite) {
    Navigator.pushNamed(context, "AcceptInviteToPlayer/" + invite.uid);
  }

  void _addInviteAsAdmin(Invite invite) {
    Navigator.pushNamed(context, "AcceptInviteAsAdmin/" + invite.uid);
  }

  void _addInviteToLeague(Invite invite) {
    Navigator.pushNamed(context, "AcceptInviteToLeague/" + invite.uid);
  }

  void _addInviteToLeagueTeam(Invite invite) {
    Navigator.pushNamed(context, "AcceptInviteToLeagueTeam/" + invite.uid);
  }

  void _addInviteToClub(Invite invite) {
    Navigator.pushNamed(context, "AcceptInviteToClub/" + invite.uid);
  }

  Card _buildInviteToTeam(InviteToTeam invite) {
    Messages messages = Messages.of(context);
    ThemeData theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () {
            _addInviteToTeam(invite);
          },
        ),
        title: Text(
          messages.teamandseason(invite.teamName, invite.seasonName),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 5.0),
            Text(Messages.of(context).roleingame(invite.role)),
            const SizedBox(height: 5.0),
            Row(
              children: invite.playerName.map((String name) {
                return Chip(
                    backgroundColor: Colors.lightBlueAccent, label: Text(name));
              }).toList(),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _deleteInvite(invite);
          },
        ),
      ),
    );
  }

  Card _buildInviteAsAdmin(InviteAsAdmin invite) {
    ThemeData theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () {
            _addInviteAsAdmin(invite);
          },
        ),
        title: Text(invite.teamName),
        subtitle: Text(Messages.of(context).administrator),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _deleteInvite(invite);
          },
        ),
      ),
    );
  }

  Card _buildInviteToClub(InviteToClub invite) {
    ThemeData theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () {
            _addInviteToClub(invite);
          },
        ),
        title: Text(invite.clubName),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _deleteInvite(invite);
          },
        ),
      ),
    );
  }

  Card _buildInviteToPlayer(InviteToPlayer invite) {
    ThemeData theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () => _addInviteToPlayer(invite),
        ),
        onTap: () => _addInviteToPlayer(invite),
        title: Text(Messages.of(context).followplayer(invite.playerName)),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteInvite(invite),
        ),
      ),
    );
  }

  Card _buildInviteToLeague(InviteToLeagueAsAdmin invite) {
    ThemeData theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () {
            _addInviteToLeague(invite);
          },
        ),
        title: Text(invite.leagueName),
        subtitle: Text(Messages.of(context).leaguetournament),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _deleteInvite(invite);
          },
        ),
      ),
    );
  }

  Card _buildInviteToLeagueTeam(InviteToLeagueTeam invite) {
    ThemeData theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () {
            _addInviteToLeagueTeam(invite);
          },
        ),
        title: Text(invite.leagueTeamName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(invite.leagueName),
            Text(Messages.of(context).leaguetournament),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _deleteInvite(invite);
          },
        ),
      ),
    );
  }

  List<Widget> _buildInviteList(BuiltMap<String, Invite> invites) {
    List<Widget> inviteWidgets = <Widget>[];
    if (invites.length == 0) {
      inviteWidgets.add(SizedBox(height: 50.0));
      inviteWidgets.add(
        Center(
          child: Text(
            Messages.of(context).noinvites,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
      );
    } else {
      invites.forEach((String key, Invite invite) {
        if (invite is InviteToTeam) {
          inviteWidgets.add(_buildInviteToTeam(invite));
        }
        if (invite is InviteToPlayer) {
          inviteWidgets.add(_buildInviteToPlayer(invite));
        }
        if (invite is InviteAsAdmin) {
          inviteWidgets.add(_buildInviteAsAdmin(invite));
        }
        if (invite is InviteToClub) {
          inviteWidgets.add(_buildInviteToClub(invite));
        }
        if (invite is InviteToLeagueAsAdmin) {
          inviteWidgets.add(_buildInviteToLeague(invite));
        }
        if (invite is InviteToLeagueTeam) {
          inviteWidgets.add(_buildInviteToLeagueTeam(invite));
        }
      });
    }
    return inviteWidgets;
  }

  @override
  Widget build(BuildContext context) {
    InviteBloc inviteBloc = BlocProvider.of<InviteBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).invite),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: BlocListener(
            cubit: inviteBloc,
            listener: (BuildContext context, InviteState state) {
              if (state is SingleInviteDeleted) {
                Navigator.pop(context);
                return;
              }
              if (state is SingleInviteSaveFailed) {
                Navigator.pop(context);
                return;
              }
            },
            child: BlocBuilder(
                cubit: inviteBloc,
                builder: (BuildContext context, InviteState state) {
                  return SavingOverlay(
                    saving: state is SingleInviteSaving,
                    child: Column(
                      children: _buildInviteList(state.invites),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
