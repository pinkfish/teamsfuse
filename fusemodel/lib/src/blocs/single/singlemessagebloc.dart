import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../messagesbloc.dart';

abstract class SingleMessageState extends Equatable {
  final Message message;
  final String body;

  SingleMessageState({@required this.message, @required this.body});

  @override
  List<Object> get props => [message, body];
}

///
/// We have a Message, default state.
///
class SingleMessageLoaded extends SingleMessageState {
  SingleMessageLoaded(
      {@required SingleMessageState state, Message message, String body})
      : super(message: message ?? state.message, body: body ?? state.body);

  @override
  String toString() {
    return 'SingleMessageLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleMessageSaving extends SingleMessageState {
  SingleMessageSaving({@required SingleMessageState state})
      : super(message: state.message, body: state.body);

  @override
  String toString() {
    return 'SingleMessageSaving{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleMessageSaveFailed extends SingleMessageState {
  final Error error;

  SingleMessageSaveFailed(
      {@required SingleMessageState state, @required this.error})
      : super(message: state.message, body: state.body);

  @override
  String toString() {
    return 'SingleMessageSaveFailed{}';
  }
}

///
/// Message got deleted.
///
class SingleMessageDeleted extends SingleMessageState {
  SingleMessageDeleted() : super(message: null, body: null);

  @override
  String toString() {
    return 'SingleMessageDeleted{}';
  }
}

abstract class SingleMessageEvent extends Equatable {}

///
/// Updates the Message (writes it out to firebase.
///
class SingleMessageUpdate extends SingleMessageEvent {
  final MessageBuilder message;

  SingleMessageUpdate({@required this.message});

  @override
  List<Object> get props => [message];
}

///
/// Updates the Message (writes it out to firebase.
///
class SingleMessageUpdateBody extends SingleMessageEvent {
  final String body;

  SingleMessageUpdateBody({@required this.body});

  @override
  List<Object> get props => [body];
}

///
/// Delete this Message from the world.
///
class SingleMessageDelete extends SingleMessageEvent {
  SingleMessageDelete();

  @override
  List<Object> get props => [];
}

class _SingleMessageNewMessage extends SingleMessageEvent {
  final Message newMessage;

  _SingleMessageNewMessage({@required this.newMessage});

  @override
  List<Object> get props => [newMessage];
}

class _SingleMessageNewBody extends SingleMessageEvent {
  final String newBody;

  _SingleMessageNewBody({@required this.newBody});

  @override
  List<Object> get props => [newBody];
}

class _SingleMessageSaveFailed extends SingleMessageEvent {
  final Error error;

  _SingleMessageSaveFailed({@required this.error});

  @override
  List<Object> get props => [error];
}

class _SingleMessageDeleted extends SingleMessageEvent {
  _SingleMessageDeleted();

  @override
  List<Object> get props => [];
}

///
/// Marks this message as read.
///
class SingleMessageRead extends SingleMessageEvent {
  @override
  List<Object> get props => [];
}

///
/// Marks this message as archived.
///
class SingleMessageArchive extends SingleMessageEvent {
  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific Message.
///
class SingleMessageBloc extends Bloc<SingleMessageEvent, SingleMessageState> {
  final MessagesBloc messageBloc;
  final String messageUid;

  StreamSubscription<MessagesState> _messageSub;
  StreamSubscription<String> _bodyState;

  SingleMessageBloc({@required this.messageBloc, @required this.messageUid})
      : super(messageBloc.state.getMessage(messageUid) != null
            ? SingleMessageLoaded(
                message: messageBloc.state.getMessage(messageUid),
                state: null,
                body: null)
            : SingleMessageDeleted()) {
    _messageSub = messageBloc.listen((MessagesState messageState) {
      Message message = messageState.getMessage(messageUid);
      if (message != null) {
        // Only send this if the Message is not the same.
        if (message != state.message) {
          add(_SingleMessageNewMessage(newMessage: message));
        }
      } else {
        add(_SingleMessageDeleted());
      }
    });
    Message message = messageBloc.state.getMessage(messageUid);
    if (message != null) {
      // Load the body.
      _bodyState = messageBloc.coordinationBloc.databaseUpdateModel
          .loadMessageBody(messageUid)
          .listen((String str) {
        add(_SingleMessageNewBody(newBody: str));
      });
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    _messageSub?.cancel();
    _bodyState?.cancel();
  }

  @override
  Stream<SingleMessageState> mapEventToState(SingleMessageEvent event) async* {
    if (event is _SingleMessageNewMessage) {
      yield SingleMessageLoaded(state: state, message: event.newMessage);
    }
    if (event is _SingleMessageNewBody) {
      yield SingleMessageLoaded(state: state, body: event.newBody);
    }

    // The Message is deleted.
    if (event is _SingleMessageDeleted) {
      yield SingleMessageDeleted();
    }

    // Save the Message.
    if (event is SingleMessageUpdate) {
      yield SingleMessageSaving(state: state);

      try {
        await messageBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreMessage(event.message);
      } catch (e) {
        yield SingleMessageSaveFailed(state: state, error: e);
      }
    }

    if (event is _SingleMessageSaveFailed) {
      yield SingleMessageSaveFailed(state: state, error: event.error);
    }

    if (event is SingleMessageRead) {
      String userUid =
          messageBloc.coordinationBloc.authenticationBloc.currentUser.uid;
      if (state.message.recipients.containsKey(userUid)) {
        if (state.message.recipients[userUid].state == MessageState.Unread) {
          yield SingleMessageSaving(state: state);
          messageBloc.coordinationBloc.databaseUpdateModel
              .updateMessageRecipientState(
                  state.message.recipients[userUid], MessageState.Read)
              .then((void c) {}, onError: (Error e) {
            add(_SingleMessageSaveFailed(error: e));
          });
        }
      }
    }

    if (event is SingleMessageArchive) {
      String userUid =
          messageBloc.coordinationBloc.authenticationBloc.currentUser.uid;
      if (state.message.recipients.containsKey(userUid)) {
        if (state.message.recipients[userUid].state != MessageState.Archived) {
          yield SingleMessageSaving(state: state);
          messageBloc.coordinationBloc.databaseUpdateModel
              .updateMessageRecipientState(
                  state.message.recipients[userUid], MessageState.Archived)
              .then((void c) {}, onError: (Error e) {
            add(_SingleMessageSaveFailed(error: e));
          });
        }
      }
    }

    if (event is SingleMessageDelete) {
      String userUid =
          messageBloc.coordinationBloc.authenticationBloc.currentUser.uid;
      if (state.message.recipients.containsKey(userUid)) {
        yield SingleMessageSaving(state: state);
        messageBloc.coordinationBloc.databaseUpdateModel
            .deleteRecipient(state.message.recipients[userUid])
            .then((void c) {}, onError: (Error e) {
          add(_SingleMessageSaveFailed(error: e));
        });
      }
    }

    // Save the message body
    if (event is SingleMessageUpdateBody) {
      yield SingleMessageSaving(state: state);

      messageBloc.coordinationBloc.databaseUpdateModel
          .updateFirestoreMessageBody(
              messageUid: state.message.uid, body: event.body)
          .then((void g) {}, onError: (Error error) {
        add(_SingleMessageSaveFailed(error: error));
      });
    }
  }
}
