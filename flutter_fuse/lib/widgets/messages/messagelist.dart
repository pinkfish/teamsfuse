import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singlemessageprovider.dart';
import 'package:flutter_fuse/widgets/util/username.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../teams/teamimage.dart';

///
/// Shows the list of the mssages for the user.
///
class MessageList extends StatelessWidget {
  Widget _buildMessage(BuildContext context, MessageRecipient mess,
      DateTime dayCutoff, AuthenticationBloc authenticationBloc) {
    String timeMess;
    var theme = Theme.of(context);

    if (mess.sentAt.isBefore(dayCutoff)) {
      timeMess = MaterialLocalizations.of(context)
          .formatTimeOfDay(TimeOfDay.fromDateTime(mess.sentAt));
    } else {
      timeMess =
          MaterialLocalizations.of(context).formatMediumDate(mess.sentAt);
    }

    var teamBloc = BlocProvider.of<TeamBloc>(context);

    return SingleMessageProvider(
      messageId: mess.messageId,
      builder: (context, singleMessageBloc) => BlocBuilder(
        cubit: singleMessageBloc,
        builder: (context, SingleMessageState singleMessageState) {
          if (singleMessageState is SingleMessageUninitialized) {
            return ListTile(
              onTap: () => Navigator.pushNamed(
                  context, "/ShowMessage/${mess.messageId}"),
              title: Text(Messages.of(context).loading),
            );
          }
          if (singleMessageState is SingleMessageDeleted) {
            return SizedBox(height: 0, width: 0);
          }
          return ListTile(
            onTap: () =>
                Navigator.pushNamed(context, "/ShowMessage/${mess.messageId}"),
            leading: TeamImage(
              team: teamBloc.state.getTeam(singleMessageState.message.teamUid),
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
                    child: UserName(
                      userId: singleMessageState.message.fromUid,
                      style: singleMessageState
                                  .message
                                  .recipients[
                                      authenticationBloc.currentUser.uid]
                                  .state ==
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
              singleMessageState.message.subject,
              overflow: TextOverflow.clip,
              style: singleMessageState
                          .message
                          .recipients[authenticationBloc.currentUser.uid]
                          .state ==
                      MessageReadState.Unread
                  ? theme.textTheme.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: theme.textTheme.subtitle1.fontSize * 1.25)
                  : theme.textTheme.subtitle1,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: BlocProvider.of<MessagesBloc>(context),
      builder: (context, MessagesBlocState state) {
        if (state.unreadMessages.length == 0 &&
            state.recentMessages.length == 0) {
          return Center(
            child: Text(Messages.of(context).nomessages),
          );
        }
        // Make a sorted list of the messages.
        var sortedList = [...state.unreadMessages, ...state.recentMessages];
        sortedList.sort((m1, m2) => m1.sentAt.compareTo(m2.sentAt));
        var messages = <Widget>[];
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
