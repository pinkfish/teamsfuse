import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/playername.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

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
      new ListTile(
        leading: const Icon(Icons.subject),
        title: new Text(mess.subject),
      ),
    );

    TeamBloc teamBloc = BlocProvider.of<TeamBloc>(context);

    kids.add(
      new ListTile(
        leading: new TeamImage(
          teamUid: mess.teamUid,
          width: 30.0,
        ),
        title: new Text(
          teamBloc.state.getTeam(mess.teamUid).name,
        ),
      ),
    );

    List<Widget> players = <Widget>[];
    mess.recipients.forEach((String id, MessageRecipient rec) {
      players.add(
        new ListTile(
          leading: const Icon(Icons.person),
          title: new PlayerName(playerUid: rec.playerId),
        ),
      );
    });
    kids.add(
      new ExpansionTile(
        leading: const Icon(Icons.people),
        title: new Text(messages.players),
        children: players,
      ),
    );

    kids.add(
      new ListTile(
        leading: const Icon(Icons.calendar_today),
        title: new Text(
          MaterialLocalizations.of(context).formatMediumDate(mess.tzTimeSent) +
              " " +
              MaterialLocalizations.of(context).formatTimeOfDay(
                new TimeOfDay.fromDateTime(mess.tzTimeSent),
              ),
        ),
      ),
    );
    kids.add(
      new Row(
        children: <Widget>[
          new FlatButton(
            onPressed: () => _archiveMessage(context),
            child: new Text(messages.archivemessage),
            textColor: Theme.of(context).accentColor,
          ),
          new FlatButton(
            onPressed: () => _deleteMessage(context),
            child: new Text(messages.deletemessage),
            textColor: Theme.of(context).accentColor,
          ),
        ],
      ),
    );

    kids.add(
      new Divider(
        color: Colors.grey.shade700,
      ),
    );

    kids.add(
      new Container(
        alignment: Alignment.topLeft,
        margin: new EdgeInsets.only(left: 15.0),
        child: new Text(
            state.body == null ? Messages.of(context).loading : state.body),
      ),
    );

    return new Scrollbar(
      child: new SingleChildScrollView(
        child: new Column(
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
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(messages.message),
      ),
      body: BlocProvider(
        create: (BuildContext context) => bloc,
        child: BlocListener(
          bloc: bloc,
          listener: (BuildContext context, SingleMessageState state) {
            if (state is SingleMessageDeleted) {
              Navigator.pop(context);
            }

            if (state is SingleMessageSaveFailed) {}
          },
          child: BlocBuilder(
            bloc: bloc,
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
