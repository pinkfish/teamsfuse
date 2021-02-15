import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import 'additemstate.dart';

abstract class AddMessageEvent extends Equatable {}

///
/// Adds this player into the set of players.
///
class AddMessageEventCommit extends AddMessageEvent {
  final String teamUid;
  // Need a rich text section for the message itself.
  final String subject;
  final String body;
  final Set<String> recipients;

  AddMessageEventCommit(
      {@required this.teamUid,
      @required this.subject,
      @required this.body,
      @required this.recipients});

  @override
  List<Object> get props => [teamUid, subject, body, recipients];
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddMessageBloc extends Bloc<AddMessageEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;

  AddMessageBloc({@required this.coordinationBloc})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddMessageEvent event) async* {
    // Create a new Player.
    if (event is AddMessageEventCommit) {
      if (event.teamUid == null ||
          event.recipients.length == 0 ||
          event.body == null ||
          event.subject == null) {
        yield AddItemInvalidArguments(error: ArgumentError("Invalid args"));
      } else {
        yield AddItemSaving();

        try {
          MessageBuilder builder = MessageBuilder()
            ..teamUid = event.teamUid
            ..subject = event.subject
            ..timeSent = Timestamp.now().toUtc()
            ..fromUid = coordinationBloc.authenticationBloc.currentUser.uid;
          for (String str in event.recipients) {
            // Get all the users for the player.
            var player = await coordinationBloc.databaseUpdateModel
                .getPlayerDetails(str.trim())
                .first;
            if (player != null) {
              for (var userId in player.users.keys) {
                // Do this by user, so only one email for more than one player.
                builder.recipients[userId] = MessageRecipient((b) => b
                  ..state = MessageReadState.Unread
                  ..userId = userId
                  ..sentAt = Timestamp.now().toUtc()
                  ..fromUid = coordinationBloc.authenticationBloc.currentUser.uid
                  ..playerId = str.trim());
              }
            } else {
              print("Cannot find player '$str'");
            }
          }
          var newMess = builder.build();
          if (newMess.recipients.isEmpty) {
            yield AddItemInvalidArguments(
                error: ArgumentError("No users to message"));
            return;
          }

          var mess = await coordinationBloc.databaseUpdateModel
              .addMessage(newMess, event.body);
          yield AddItemDone(uid: mess.uid);
        } catch (e, stack) {
          coordinationBloc.analytics.recordException(e, stack);

          yield AddItemSaveFailed(error: e);
        }
      }
    }
  }
}
