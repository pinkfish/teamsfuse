import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/invites/deleteinvitedialog.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Shows the current invites pending for this user.
///
class InviteListScreen extends StatefulWidget {
  @override
  _InviteListScreenState createState() {
    return _InviteListScreenState();
  }
}

class _InviteListScreenState extends State<InviteListScreen> {
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
    await deleteInviteDialog(context, invite);
  }

  void _addInviteToPlayer(Invite invite) {
    Navigator.pushNamed(context, 'AcceptInviteToPlayer/${invite.uid}');
  }

  void _addInviteAsAdmin(Invite invite) {
    Navigator.pushNamed(context, 'AcceptInviteAsAdmin/${invite.uid}');
  }

  void _addInviteToLeague(Invite invite) {
    Navigator.pushNamed(context, 'AcceptInviteToLeague/${invite.uid}');
  }

  void _addInviteToLeagueTeam(Invite invite) {
    Navigator.pushNamed(context, 'AcceptInviteToLeagueTeam/${invite.uid}');
  }

  void _addInviteToClub(Invite invite) {
    Navigator.pushNamed(context, 'AcceptInviteToClub/${invite.uid}');
  }

  Card _buildInviteAsAdmin(InviteAsAdmin invite) {
    var theme = Theme.of(context);
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
    var theme = Theme.of(context);
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
    var theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () => _addInviteToPlayer(invite),
        ),
        onTap: () => _addInviteToPlayer(invite),
        title: Text(Messages.of(context).followPlayer(invite.playerName)),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteInvite(invite),
        ),
      ),
    );
  }

  Card _buildInviteToLeague(InviteToLeagueAsAdmin invite) {
    var theme = Theme.of(context);
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
    var theme = Theme.of(context);
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
    var inviteWidgets = <Widget>[];
    if (invites.length == 0) {
      inviteWidgets.add(SizedBox(height: 50.0));
      inviteWidgets.add(
        Center(
          child: Text(
            Messages.of(context).noinvites,
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
      );
    } else {
      invites.forEach((key, invite) {
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
    var inviteBloc = BlocProvider.of<InviteBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).invite),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: BlocListener(
            cubit: inviteBloc,
            listener: (context, state) {
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
                builder: (context, state) {
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
