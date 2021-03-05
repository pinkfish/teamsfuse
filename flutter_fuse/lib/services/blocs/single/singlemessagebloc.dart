import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asynchydratedbloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

abstract class SingleMessageEvent extends Equatable {}

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
class SingleMessageBloc
    extends AsyncHydratedBloc<SingleMessageEvent, SingleMessageState> {
  final DatabaseUpdateModel db;
  final AnalyticsSubsystem crashes;
  final String messageUid;

  StreamSubscription<Message> _messageSub;
  StreamSubscription<String> _bodyState;

  SingleMessageBloc(
      {@required this.db, @required this.messageUid, @required this.crashes})
      : super(SingleMessageUninitialized(), messageUid) {
    _messageSub = db.getMessage(messageUid).listen((message) {
      if (message != null) {
        // Only send this if the Message is not the same.
        if (message != state.message) {
          add(_SingleMessageNewMessage(newMessage: message));
          _bodyState?.cancel();
          _bodyState = db.loadMessageBody(messageUid).listen((String str) {
            add(_SingleMessageNewBody(newBody: str));
          });
          _bodyState.onError((e, stack) => crashes.recordException(e, stack));
        }
      } else {
        add(_SingleMessageDeleted());
      }
    });
    _messageSub.onError((e, stack) => crashes.recordException(e, stack));
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
      yield (SingleMessageLoaded.fromState(state)
            ..message = event.newMessage.toBuilder())
          .build();
    }
    if (event is _SingleMessageNewBody) {
      yield (SingleMessageLoaded.fromState(state)
            ..body = event.newBody
            ..loadedBody = true)
          .build();
    }

    // The Message is deleted.
    if (event is _SingleMessageDeleted) {
      yield SingleMessageDeleted();
    }

    if (event is SingleMessageRead) {
      String userUid = db.currentUser.uid;
      if (state.message.recipients.containsKey(userUid)) {
        if (state.message.recipients[userUid].state ==
                MessageReadState.Unread &&
            state.message.recipients[userUid].uid != null) {
          yield SingleMessageSaving.fromState(state).build();
          try {
            await db.updateMessageRecipientState(
                state.message.recipients[userUid], MessageReadState.Read);
            yield SingleMessageLoaded.fromState(state).build();
          } catch (e, stack) {
            yield (SingleMessageSaveFailed.fromState(state)..error = e).build();
            yield SingleMessageLoaded.fromState(state).build();
            crashes.recordException(e, stack);
          }
        }
      }
    }

    if (event is SingleMessageArchive) {
      String userUid = db.currentUser.uid;
      if (state.message.recipients.containsKey(userUid)) {
        if (state.message.recipients[userUid].state !=
            MessageReadState.Archived) {
          yield SingleMessageSaving.fromState(state).build();
          try {
            await db.updateMessageRecipientState(
                state.message.recipients[userUid], MessageReadState.Archived);
            yield SingleMessageLoaded.fromState(state).build();
          } catch (e, stack) {
            yield (SingleMessageSaveFailed.fromState(state)..error = e).build();
            yield SingleMessageLoaded.fromState(state).build();
            crashes.recordException(e, stack);
          }
        }
      }
    }

    if (event is SingleMessageDelete) {
      String userUid = db.currentUser.uid;
      if (state.message.recipients.containsKey(userUid)) {
        yield SingleMessageSaving.fromState(state).build();
        try {
          await db.deleteRecipient(state.message.recipients[userUid]);
          yield SingleMessageLoaded.fromState(state).build();
        } catch (e, stack) {
          yield (SingleMessageSaveFailed.fromState(state)..error = e).build();
          yield SingleMessageLoaded.fromState(state).build();
          crashes.recordException(e, stack);
        }
      }
    }
  }

  @override
  SingleMessageState fromJson(Map<String, dynamic> json) {
    if (!(state is SingleMessageUninitialized)) {
      return state;
    }
    if (json == null || !json.containsKey('type')) {
      return SingleMessageUninitialized();
    }

    try {
      SingleMessageBlocStateType type =
          SingleMessageBlocStateType.valueOf(json['type']);
      switch (type) {
        case SingleMessageBlocStateType.Uninitialized:
          return SingleMessageUninitialized();
        case SingleMessageBlocStateType.Loaded:
          return SingleMessageLoaded.fromMap(json);
        case SingleMessageBlocStateType.Deleted:
          return SingleMessageDeleted.fromMap(json);
        case SingleMessageBlocStateType.SaveFailed:
          return SingleMessageSaveFailed.fromMap(json);
        case SingleMessageBlocStateType.Saving:
          return SingleMessageSaving.fromMap(json);
        case SingleMessageBlocStateType.SaveDone:
          return SingleMessageSaveDone.fromMap(json);
      }
    } catch (e, stack) {
      if (e is Error) {
        crashes.recordError(e, stack);
      } else {
        crashes.recordException(e, stack);
      }
    }

    return SingleMessageUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleMessageState state) {
    return state.toMap();
  }
}
