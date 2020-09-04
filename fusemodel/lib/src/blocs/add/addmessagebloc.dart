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
  // TODO: implement props
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
          event.recipients.length > 0 ||
          event.body != null ||
          event.subject != null) {
        yield AddItemInvalidArguments(error: ArgumentError("Invalid args"));
      } else {
        yield AddItemSaving();

        try {
          MessageBuilder builder = MessageBuilder()
            ..teamUid = event.teamUid
            ..subject = event.subject
            ..fromUid = coordinationBloc.authenticationBloc.currentUser.uid;
          for (String str in event.recipients) {
            builder.recipients[str] = MessageRecipient((b) => b
              ..state = MessageState.Unread
              ..playerId = str);
          }

          Message mess = await coordinationBloc.databaseUpdateModel
              .updateFirestoreMessage(builder);
          await coordinationBloc.databaseUpdateModel.updateFirestoreMessageBody(
              messageUid: mess.uid, body: event.body);
          yield AddItemDone(uid: mess.uid);
        } catch (e) {
          yield AddItemSaveFailed(error: e);
        }
      }
    }
  }
}
