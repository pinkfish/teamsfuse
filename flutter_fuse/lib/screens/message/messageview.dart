import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/util/playername.dart';
import '../../widgets/util/savingoverlay.dart';
import '../../widgets/util/teamimage.dart';

class ShowMessageScreen extends StatelessWidget {
  ShowMessageScreen({this.messageUid});

  final String messageUid;

  void _archiveMessage(BuildContext context) {
    SingleMessageBloc bloc = BlocProvider.of<SingleMessageBloc>(context);
    bloc.add(SingleMessageArchive());
  }

  void _deleteMessage(BuildContext context) {
    SingleMessageBloc bloc = BlocProvider.of<SingleMessageBloc>(context);
    bloc.add(SingleMessageDelete());
  }

  void _readMessage(BuildContext context) {
    SingleMessageBloc bloc = BlocProvider.of<SingleMessageBloc>(context);
    bloc.add(SingleMessageRead());
  }

  Widget _showMessage(BuildContext context, SingleMessageState state) {
    Messages messages = Messages.of(context);
    Message mess = state.message;
    List<Widget> kids = <Widget>[];
    _readMessage(context);
    kids.add(
      ListTile(
        leading: const Icon(Icons.subject),
        title: Text(mess.subject),
      ),
    );

    TeamBloc teamBloc = BlocProvider.of<TeamBloc>(context);

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

    List<Widget> players = <Widget>[];
    mess.recipients.forEach((String id, MessageRecipient rec) {
      players.add(
        ListTile(
          leading: const Icon(Icons.person),
          title: PlayerName(playerUid: rec.playerId),
        ),
      );
    });
    kids.add(
      ExpansionTile(
        leading: const Icon(Icons.people),
        title: Text(messages.players),
        children: players,
      ),
    );

    kids.add(
      ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(
          MaterialLocalizations.of(context).formatMediumDate(mess.tzTimeSent) +
              " " +
              MaterialLocalizations.of(context).formatTimeOfDay(
                TimeOfDay.fromDateTime(mess.tzTimeSent),
              ),
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
    Messages messages = Messages.of(context);
    var bloc = SingleMessageBloc(
        messageUid: messageUid,
        messageBloc: BlocProvider.of<MessagesBloc>(context));
    return Scaffold(
      appBar: AppBar(
        title: Text(messages.message),
      ),
      body: BlocProvider(
        create: (BuildContext context) => bloc,
        child: BlocListener(
          cubit: bloc,
          listener: (BuildContext context, SingleMessageState state) {
            if (state is SingleMessageDeleted) {
              Navigator.pop(context);
            }

            if (state is SingleMessageSaveFailed) {}
          },
          child: BlocBuilder(
            cubit: bloc,
            builder: (BuildContext context, SingleMessageState state) =>
                SavingOverlay(
              saving: state is SingleMessageSaving,
              child: _showMessage(context, state),
            ),
          ),
        ),
      ),
    );
  }
}
