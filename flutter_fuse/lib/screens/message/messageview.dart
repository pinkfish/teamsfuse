import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../../widgets/util/playername.dart';
import '../../widgets/util/savingoverlay.dart';
import '../../widgets/util/teamimage.dart';

///
/// Show a specific message.
///
class ShowMessageScreen extends StatelessWidget {
  /// Constructor.
  ShowMessageScreen({this.messageUid});

  /// The message to display.
  final String messageUid;

  void _archiveMessage(context) {
    var bloc = BlocProvider.of<SingleMessageBloc>(context);
    bloc.add(SingleMessageArchive());
  }

  void _deleteMessage(context) {
    var bloc = BlocProvider.of<SingleMessageBloc>(context);
    bloc.add(SingleMessageDelete());
  }

  void _readMessage(context) {
    var bloc = BlocProvider.of<SingleMessageBloc>(context);
    bloc.add(SingleMessageRead());
  }

  Widget _showMessage(BuildContext context, SingleMessageState state) {
    var messages = Messages.of(context);
    var mess = state.message;
    var kids = <Widget>[];
    _readMessage(context);
    kids.add(
      ListTile(
        leading: const Icon(Icons.subject),
        title: Text(mess.subject),
      ),
    );

    var teamBloc = BlocProvider.of<TeamBloc>(context);

    kids.add(
      ListTile(
        leading: TeamImage(
          teamUid: mess.teamUid,
          width: 30.0,
        ),
        title: Text(
          teamBloc.state.getTeam(mess.teamUid).name,
        ),
      ),
    );

    var players = <Widget>[];
    for (var entry in mess.recipients.entries) {
      players.add(
        ListTile(
          leading: const Icon(Icons.person),
          title: PlayerName(playerUid: entry.value.playerId),
        ),
      );
    }
    kids.add(
      ExpansionTile(
        leading: const Icon(Icons.people),
        title: Text(messages.players),
        children: players,
      ),
    );

    var start =
        MaterialLocalizations.of(context).formatMediumDate(mess.tzTimeSent);
    var end = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(mess.tzTimeSent),
    );
    kids.add(
      ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(
          "$start $end",
        ),
      ),
    );
    kids.add(
      Row(
        children: <Widget>[
          FlatButton(
            onPressed: () => _archiveMessage(context),
            child: Text(messages.archivemessage),
            textColor: Theme.of(context).accentColor,
          ),
          FlatButton(
            onPressed: () => _deleteMessage(context),
            child: Text(messages.deletemessage),
            textColor: Theme.of(context).accentColor,
          ),
        ],
      ),
    );

    kids.add(
      Divider(
        color: Colors.grey.shade700,
      ),
    );

    kids.add(
      Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(left: 15.0),
        child: Text(
            state.body == null ? Messages.of(context).loading : state.body),
      ),
    );

    return Scrollbar(
      child: SingleChildScrollView(
        child: Column(
          children: kids,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var messages = Messages.of(context);
    var bloc = SingleMessageBloc(
        messageUid: messageUid,
        messageBloc: BlocProvider.of<MessagesBloc>(context));
    return Scaffold(
      appBar: AppBar(
        title: Text(messages.message),
      ),
      body: BlocProvider(
        create: (context) => bloc,
        child: BlocListener(
          cubit: bloc,
          listener: (context, state) {
            if (state is SingleMessageDeleted) {
              Navigator.pop(context);
            }

            if (state is SingleMessageSaveFailed) {}
          },
          child: BlocBuilder(
            cubit: bloc,
            builder: (context, state) => SavingOverlay(
              saving: state is SingleMessageSaving,
              child: _showMessage(context, state),
            ),
          ),
        ),
      ),
    );
  }
}
