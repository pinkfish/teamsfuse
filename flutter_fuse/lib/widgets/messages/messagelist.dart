import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/playername.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/blocs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageList extends StatelessWidget {
  Widget _buildMessage(BuildContext context, Message mess, DateTime dayCutoff,
      AuthenticationBloc authenticationBloc) {
    String timeMess;
    ThemeData theme = Theme.of(context);

    if (mess.timeSent < dayCutoff.millisecondsSinceEpoch) {
      timeMess = MaterialLocalizations.of(context)
          .formatTimeOfDay(new TimeOfDay.fromDateTime(mess.tzTimeSent));
    } else {
      timeMess =
          MaterialLocalizations.of(context).formatMediumDate(mess.tzTimeSent);
    }
    print('rec ${mess.recipients} ${mess.uid}');

    return new ListTile(
      onTap: () => Navigator.pushNamed(context, "/ShowMessage/" + mess.uid),
      leading: new TeamImage(
        team: UserDatabaseData.instance.teams[mess.teamUid],
        width: 30.0,
      ),
      subtitle: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Expanded(
            child: new Container(
              margin: new EdgeInsets.only(top: 3.0),
              alignment: AlignmentDirectional.centerStart,
              child: new PlayerName(
                playerUid: mess.fromUid,
                style:
                    mess.recipients[authenticationBloc.currentUser.uid].state ==
                            MessageState.Unread
                        ? theme.textTheme.subhead
                            .copyWith(fontWeight: FontWeight.bold)
                        : theme.textTheme.subhead,
              ),
            ),
          ),
          new Container(
            margin: new EdgeInsets.only(top: 3.0),
            alignment: AlignmentDirectional.centerEnd,
            child: new Text(
              timeMess,
            ),
          ),
        ],
      ),
      title: new Text(
        mess.subject,
        overflow: TextOverflow.clip,
        style: mess.recipients[authenticationBloc.currentUser.uid].state ==
                MessageState.Unread
            ? theme.textTheme.subhead.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: theme.textTheme.subhead.fontSize * 1.25)
            : theme.textTheme.subhead,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesEvent, MessagesState>(
      bloc: BlocProvider.of<MessagesBloc>(context),
      builder: (BuildContext context, MessagesState state) {
        if (state.unreadMessages.length == 0 &&
            state.recentMessages.length == 0) {
          return new Center(
            child: new Text(Messages.of(context).nomessages),
          );
        }
        // Make a sorted list of the messages.
        Map<String, Message> stuff = Map.from(state.unreadMessages);
        stuff.addAll(state.recentMessages);
        List<Message> sortedList = stuff.values.toList();
        sortedList.sort((Message m1, Message m2) =>
            m1.timeSent.toInt() - m2.timeSent.toInt());
        List<Widget> messages = [];
        DateTime dayCutoff = DateTime.now().subtract(Duration(days: 1));
        AuthenticationBloc authenticationBloc =
            BlocProvider.of<AuthenticationBloc>(context);
        for (Message mess in sortedList) {
          messages
              .add(_buildMessage(context, mess, dayCutoff, authenticationBloc));
        }
        return new SingleChildScrollView(
          child: new Column(
            children: messages,
          ),
        );
      },
    );
  }
}
