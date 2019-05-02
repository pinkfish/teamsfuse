import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../playerbloc.dart';
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

  final List<String> recipients;

  AddMessageEventCommit(
      {@required this.teamUid,
      @required this.subject,
      @required this.body,
      @required this.recipients});
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddPlayerBloc extends Bloc<AddMessageEvent, AddItemState> {
  final PlayerBloc playerBloc;

  AddPlayerBloc({@required this.playerBloc}) {}

  @override
  AddItemState get initialState => new AddItemUninitialized();

  @override
  Stream<AddItemState> mapEventToState(AddMessageEvent event) async* {
    // Create a new Player.
    if (event is AddMessageEventCommit) {
      yield AddItemSaving();

      try {
        MessageBuilder builder = MessageBuilder()
          ..teamUid = event.teamUid
          ..subject = event.subject
          ..fromUid =
              playerBloc.coordinationBloc.authenticationBloc.currentUser.uid;
        for (String str in event.recipients) {
          builder.recipients[str] = MessageRecipient((b) => b
            ..state = MessageState.Unread
            ..userId =
                playerBloc.coordinationBloc.authenticationBloc.currentUser.uid
            ..playerId = str);
        }
        Message mess = await playerBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreMessage(builder);
        await playerBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreMessageBody(messageUid: mess.uid, body: event.body);
        yield AddItemDone(uid: mess.uid);
      } catch (e) {
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
