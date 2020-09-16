import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/playername.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class MessageList extends StatelessWidget {
  Widget _buildMessage(BuildContext context, Message mess, DateTime dayCutoff,
      AuthenticationBloc authenticationBloc) {
    String timeMess;
    ThemeData theme = Theme.of(context);

    if (mess.timeSent < dayCutoff.millisecondsSinceEpoch) {
      timeMess = MaterialLocalizations.of(context)
          .formatTimeOfDay(TimeOfDay.fromDateTime(mess.tzTimeSent));
    } else {
      timeMess =
          MaterialLocalizations.of(context).formatMediumDate(mess.tzTimeSent);
    }
    print('rec ${mess.recipients} ${mess.uid}');

    TeamBloc teamBloc = BlocProvider.of<TeamBloc>(context);

    return ListTile(
      onTap: () => Navigator.pushNamed(context, "/ShowMessage/" + mess.uid),
      leading: TeamImage(
        team: teamBloc.state.getTeam(mess.teamUid),
        width: 30.0,
      ),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 3.0),
              alignment: AlignmentDirectional.centerStart,
              child: PlayerName(
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
          Container(
            margin: EdgeInsets.only(top: 3.0),
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              timeMess,
            ),
          ),
        ],
      ),
      title: Text(
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
    return BlocBuilder(
      cubit: BlocProvider.of<MessagesBloc>(context),
      builder: (BuildContext context, MessagesState state) {
        if (state.unreadMessages.length == 0 &&
            state.recentMessages.length == 0) {
          return Center(
            child: Text(Messages.of(context).nomessages),
          );
        }
        // Make a sorted list of the messages.
        Map<String, Message> stuff = Map.from(state.unreadMessages.asMap());
        stuff.addEntries(state.recentMessages.entries);
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
        return SingleChildScrollView(
          child: Column(
            children: messages,
          ),
        );
      },
    );
  }
}
