import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../player/playername.dart';
import '../teams/teamimage.dart';

///
/// Shows the list of the mssages for the user.
///
class MessageList extends StatelessWidget {
  Widget _buildMessage(BuildContext context, Message mess, DateTime dayCutoff,
      AuthenticationBloc authenticationBloc) {
    String timeMess;
    var theme = Theme.of(context);

    if (mess.timeSent < dayCutoff.millisecondsSinceEpoch) {
      timeMess = MaterialLocalizations.of(context)
          .formatTimeOfDay(TimeOfDay.fromDateTime(mess.tzTimeSent));
    } else {
      timeMess =
          MaterialLocalizations.of(context).formatMediumDate(mess.tzTimeSent);
    }

    var teamBloc = BlocProvider.of<TeamBloc>(context);

    return ListTile(
      onTap: () => Navigator.pushNamed(context, "/ShowMessage/${mess.uid}"),
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
                            MessageReadState.Unread
                        ? theme.textTheme.subtitle1
                            .copyWith(fontWeight: FontWeight.bold)
                        : theme.textTheme.subtitle1,
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
                MessageReadState.Unread
            ? theme.textTheme.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: theme.textTheme.subtitle1.fontSize * 1.25)
            : theme.textTheme.subtitle1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: BlocProvider.of<MessagesBloc>(context),
      builder: (context, state) {
        if (state.unreadMessages.length == 0 &&
            state.recentMessages.length == 0) {
          return Center(
            child: Text(Messages.of(context).nomessages),
          );
        }
        // Make a sorted list of the messages.
        var stuff = Map<String, Message>.from(state.unreadMessages.asMap());
        stuff.addEntries(state.recentMessages.entries);
        var sortedList = stuff.values.toList();
        sortedList.sort((m1, m2) => m1.timeSent.toInt() - m2.timeSent.toInt());
        var messages = [];
        var dayCutoff = DateTime.now().subtract(Duration(days: 1));
        var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
        for (var mess in sortedList) {
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
