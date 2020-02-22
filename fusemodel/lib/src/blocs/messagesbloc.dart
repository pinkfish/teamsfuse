import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';
import 'teambloc.dart';

///
/// Basic state for all the data in this system.
///
abstract class MessagesState extends Equatable {
  final BuiltMap<String, Message> unreadMessages;
  final BuiltMap<String, Message> recentMessages;
  final bool onlySql;

  MessagesState(
      {@required this.unreadMessages,
      @required this.recentMessages,
      @required this.onlySql});

  Message getMessage(String uid) {
    if (recentMessages.containsKey(uid)) {
      return recentMessages[uid];
    }
    if (unreadMessages.containsKey(uid)) {
      return unreadMessages[uid];
    }
    return null;
  }

  @override
  List<Object> get props => [unreadMessages, recentMessages, onlySql];
}

///
/// No data at all yet.
///
class MessagesUninitialized extends MessagesState {
  MessagesUninitialized()
      : super(
            unreadMessages: BuiltMap(),
            recentMessages: BuiltMap(),
            onlySql: true);

  @override
  String toString() {
    return 'MessagesUninitialized{}';
  }
}

///
/// Doing something.
///
class MessagesLoaded extends MessagesState {
  MessagesLoaded(
      {@required BuiltMap<String, Message> unreadMessages,
      @required BuiltMap<String, Message> recentMessages,
      @required bool onlySql})
      : super(
            unreadMessages: unreadMessages,
            recentMessages: recentMessages,
            onlySql: onlySql);

  @override
  String toString() {
    return 'MessagesLoaded{}';
  }
}

abstract class MessagesEvent extends Equatable {}

class _MessagesEventUserLoaded extends MessagesEvent {
  final String uid;

  _MessagesEventUserLoaded({@required this.uid});

  @override
  String toString() {
    return '_MessagesEventUserLoaded{}';
  }

  @override
  List<Object> get props => [uid];
}

class _MessagesEventLogout extends MessagesEvent {
  @override
  List<Object> get props => [];
}

class _MessagesEventNewUnReadLoaded extends MessagesEvent {
  final Map<String, Message> unreadMessages;

  _MessagesEventNewUnReadLoaded({@required this.unreadMessages});

  @override
  List<Object> get props => [unreadMessages];
}

class _MessagesEventNewRecentLoaded extends MessagesEvent {
  final Map<String, Message> recentMessages;

  _MessagesEventNewRecentLoaded({@required this.recentMessages});

  @override
  List<Object> get props => [recentMessages];
}

class _MessagesEventFirestore extends MessagesEvent {
  final String uid;

  _MessagesEventFirestore({@required this.uid});

  @override
  String toString() {
    return '_MessagesEventFirestore{}';
  }

  @override
  List<Object> get props => [uid];
}

///
/// Handles the work around the Messagess and Messages system inside of
/// the app.
///
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final CoordinationBloc coordinationBloc;
  final TeamBloc teamBloc;

  StreamSubscription<CoordinationState> _coordState;
  StreamSubscription<Iterable<MessageRecipient>> _messageSnapshot;
  StreamSubscription<Iterable<MessageRecipient>> _readMessageSnapshot;

  MessagesBloc({@required this.coordinationBloc, @required this.teamBloc}) {
    _coordState = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        add(_MessagesEventLogout());
      } else if (coordState is CoordinationStateStartLoadingSql) {
        _startLoading(coordState);
      } else if (coordState is CoordinationStateStartLoadingFirestore) {
        _startLoadingFirestore(coordState);
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanupStuff();
    _coordState?.cancel();
    _coordState = null;
  }

  void _cleanupStuff() {
    _messageSnapshot?.cancel();
    _messageSnapshot = null;
    _readMessageSnapshot?.cancel();
    _readMessageSnapshot = null;
  }

  void _startLoading(CoordinationStateStartLoadingSql state) {
    add(_MessagesEventUserLoaded(uid: state.uid));
  }

  void _startLoadingFirestore(CoordinationStateStartLoadingFirestore state) {
    add(_MessagesEventFirestore(uid: state.uid));
  }

  @override
  MessagesState get initialState => MessagesUninitialized();

  void _onUnreadMessagesUpdated(Iterable<MessageRecipient> data) async {
    Set<String> toRemove = Set.from(state.unreadMessages.keys);
    Map<String, Message> messages = {};

    // Fill in all the messages.
    for (MessageRecipient recipient in data) {
      coordinationBloc.loadingTrace?.incrementCounter("message");

      Message mess = state.getMessage(recipient.messageId);
      if (mess != null) {
        // Update just my recipient piece of this.
        MessageBuilder builder = mess.toBuilder();

        builder.recipients[recipient.userId] = recipient;
        messages[mess.uid] = builder.build();
        toRemove.remove(mess.uid);
        mess = builder.build();
        coordinationBloc.persistentData.updateElement(
            PersistenData.messagesTable, mess.uid, mess.toJSON(forSQL: true));
      } else {
        // Otherwise we need to load it.
        mess = await coordinationBloc.databaseUpdateModel
            .getMessage(recipient.messageId);
        if (mess != null) {
          messages[mess.uid] = mess;
          toRemove.remove(mess.uid);
          MessageBuilder builder = mess.toBuilder();
          builder.recipients[recipient.userId] = recipient;
          mess = builder.build();
          coordinationBloc.persistentData.updateElement(
              PersistenData.messagesTable, mess.uid, mess.toJSON(forSQL: true));
        }
      }
    }
    for (String change in toRemove) {
      coordinationBloc.loadingTrace?.incrementCounter("deletemessage");
      coordinationBloc.persistentData
          .deleteElement(PersistenData.messagesTable, change);
    }
    print('Loaded unread');
    add(_MessagesEventNewUnReadLoaded(unreadMessages: messages));
    coordinationBloc.add(
        CoordinationEventLoadedData(loaded: BlocsToLoad.Messages, sql: false));
  }

  void _onReadMessagesUpdated(Iterable<MessageRecipient> data) async {
    Map<String, Message> messages = {};
    Set<String> toRemove = Set.from(state.recentMessages.keys);

    for (MessageRecipient recipient in data) {
      coordinationBloc.loadingTrace?.incrementCounter("message");

      Message mess = state.getMessage(recipient.messageId);
      if (mess != null) {
        // Update just my recipient piece of this.
        MessageBuilder builder = mess.toBuilder();
        builder.recipients[recipient.userId] = recipient;
        messages[mess.uid] = builder.build();
        toRemove.remove(mess.uid);
        coordinationBloc.persistentData.updateElement(
            PersistenData.messagesTable, mess.uid, mess.toJSON(forSQL: true));
      } else {
        // Otherwise we need to load it.
        Message mess = await coordinationBloc.databaseUpdateModel
            .getMessage(recipient.messageId);
        if (mess != null) {
          MessageBuilder builder = mess.toBuilder();
          builder.recipients[recipient.userId] = recipient;
          messages[mess.uid] = builder.build();
          toRemove.remove(mess.uid);
          coordinationBloc.persistentData.updateElement(
              PersistenData.messagesTable, mess.uid, mess.toJSON(forSQL: true));
        }
      }
    }
    for (String remove in toRemove) {
      coordinationBloc.loadingTrace?.incrementCounter("deletemessage");
      coordinationBloc.persistentData
          .deleteElement(PersistenData.messagesTable, remove);
    }
    print('Loaded read');
    add(_MessagesEventNewRecentLoaded(recentMessages: messages));
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    if (event is _MessagesEventUserLoaded) {
      TraceProxy messagesTrace =
          coordinationBloc.analyticsSubsystem.newTrace("messagesTrace");
      messagesTrace.start();
      Map<String, Map<String, dynamic>> data = await coordinationBloc
          .persistentData
          .getAllElements(PersistenData.messagesTable);
      Map<String, Message> newMessages = {};
      Map<String, Message> unreadMessages = {};
      data.forEach((String uid, Map<String, dynamic> input) {
        coordinationBloc.sqlTrace.incrementCounter("message");

        Message mess = Message.fromJSON(uid, input).build();
        if (mess.recipients[event.uid].state == MessageState.Unread) {
          unreadMessages[uid] = mess;
        } else {
          newMessages[uid] = mess;
        }
      });
      print(
          'End messages ${coordinationBloc.start.difference(new DateTime.now())}');
      messagesTrace.stop();
      yield MessagesLoaded(
          recentMessages: BuiltMap.from(newMessages),
          unreadMessages: BuiltMap.from(unreadMessages),
          onlySql: true);
      coordinationBloc.add(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Messages, sql: true));
    }

    // The fireatore atart up.
    if (event is _MessagesEventFirestore) {
      _messageSnapshot = coordinationBloc.databaseUpdateModel
          .getMessages(event.uid, true)
          .listen((Iterable<MessageRecipient> messages) {
        coordinationBloc.loadingTrace?.incrementCounter("message");
        _onUnreadMessagesUpdated(messages);
      });
      _readMessageSnapshot = coordinationBloc.databaseUpdateModel
          .getMessages(event.uid, false)
          .listen((Iterable<MessageRecipient> messages) {
        coordinationBloc.loadingTrace?.incrementCounter("message");
        this._onReadMessagesUpdated(messages);
      });
    }

    // New data from above.  Mark ourselves as done.
    if (event is _MessagesEventNewRecentLoaded) {
      coordinationBloc.add(CoordinationEventLoadedData(
          loaded: BlocsToLoad.LeagueOrTournament, sql: false));

      yield MessagesLoaded(
          recentMessages: BuiltMap.from(event.recentMessages),
          unreadMessages: state.unreadMessages,
          onlySql: false);
    }

    if (event is _MessagesEventNewUnReadLoaded) {
      yield MessagesLoaded(
          recentMessages: state.recentMessages,
          unreadMessages: BuiltMap.from(event.unreadMessages),
          onlySql: false);
    }

    // Unload everything.
    if (event is _MessagesEventLogout) {
      yield MessagesUninitialized();
      _cleanupStuff();
    }
  }
}
