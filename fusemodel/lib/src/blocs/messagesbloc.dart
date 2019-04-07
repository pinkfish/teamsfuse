import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'teambloc.dart';
import 'internal/blocstoload.dart';

///
/// Basic state for all the data in this system.
///
class MessagesState extends Equatable {
  final Map<String, Message> unreadMessages;
  final Map<String, Message> recentMessages;
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
}

///
/// No data at all yet.
///
class MessagesUninitialized extends MessagesState {
  MessagesUninitialized()
      : super(unreadMessages: {}, recentMessages: {}, onlySql: true);

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
      {@required Map<String, Message> unreadMessages,
      @required Map<String, Message> recentMessages,
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

class MessagesEvent extends Equatable {}

class _MessagesEventUserLoaded extends MessagesEvent {
  final String uid;

  _MessagesEventUserLoaded({@required this.uid});

  @override
  String toString() {
    return '_MessagesEventUserLoaded{}';
  }
}

class _MessagesEventLogout extends MessagesEvent {}

class _MessagesEventNewUnReadLoaded extends MessagesEvent {
  final Map<String, Message> unreadMessages;

  _MessagesEventNewUnReadLoaded({@required this.unreadMessages});
}

class _MessagesEventNewRecentLoaded extends MessagesEvent {
  final Map<String, Message> recentMessages;

  _MessagesEventNewRecentLoaded({@required this.recentMessages});
}

class _MessagesEventFirestore extends MessagesEvent {
  final String uid;

  _MessagesEventFirestore({@required this.uid});

  @override
  String toString() {
    return '_MessagesEventFirestore{}';
  }
}

///
/// Handles the work around the Messagess and Messages system inside of
/// the app.
///
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final CoordinationBloc coordinationBloc;
  final TeamBloc teamBloc;

  StreamSubscription<CoordinationState> _coordState;
  StreamSubscription<FirestoreChangedData> _messageSnapshot;
  StreamSubscription<FirestoreChangedData> _readMessageSnapshot;
  InitialSubscription _unreadMessageInitialData;
  InitialSubscription _messageInitialData;

  MessagesBloc({@required this.coordinationBloc, @required this.teamBloc}) {
    _coordState = coordinationBloc.state.listen((CoordinationState state) {
      if (state is CoordinationStateLoggedOut) {
        dispatch(_MessagesEventLogout());
      } else if (state is CoordinationStateStartLoadingSql) {
        _startLoading(state);
      } else if (state is CoordinationStateStartLoadingFirestore) {
        _startLoadingFirestore(state);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _cleanupStuff();
    _coordState?.cancel();
    _coordState = null;
  }

  void _cleanupStuff() {
    _messageInitialData?.dispose();
    _messageInitialData = null;
    _messageSnapshot?.cancel();
    _messageSnapshot = null;
    _readMessageSnapshot?.cancel();
    _readMessageSnapshot = null;
    _unreadMessageInitialData?.dispose();
    _unreadMessageInitialData = null;
  }

  void _startLoading(CoordinationStateStartLoadingSql state) {
    dispatch(_MessagesEventUserLoaded(uid: state.uid));
  }

  void _startLoadingFirestore(CoordinationStateStartLoadingFirestore state) {
    dispatch(_MessagesEventFirestore(uid: state.uid));
  }

  @override
  MessagesState get initialState => MessagesUninitialized();

  void _onUnreadMessagesUpdated(FirestoreChangedData data) async {
    Set<String> toRemove = Set.from(currentState.unreadMessages.keys);
    Map<String, Message> messages = {};

    // Fill in all the messages.
    for (FirestoreWrappedData doc in data.newList) {
      coordinationBloc.loadingTrace?.incrementCounter("message");
      MessageRecipient recipient;
      // Update in place to keep the fetched and seen times.
      recipient = new MessageRecipient.fromJSON(doc.id, doc.data);

      Message mess = currentState.getMessage(recipient.messageId);
      if (mess != null) {
        // Update just my recipient piece of this.
        mess.recipients[recipient.userId] = recipient;
        messages[mess.uid] = mess;
        toRemove.remove(mess.uid);
        coordinationBloc.persistentData.updateElement(
            PersistenData.messagesTable,
            doc.id,
            mess.toJSON(includeMessage: true, forSQL: true));
      } else {
        // Otherwise we need to load it.
        mess = await coordinationBloc.databaseUpdateModel
            .getMessage(recipient.messageId);
        if (mess != null) {
          messages[mess.uid] = mess;
          toRemove.remove(mess.uid);
          mess.recipients[recipient.userId] = recipient;
          coordinationBloc.persistentData.updateElement(
              PersistenData.messagesTable,
              doc.id,
              mess.toJSON(includeMessage: true, forSQL: true));
        }
      }
    }
    for (String change in toRemove) {
      coordinationBloc.loadingTrace?.incrementCounter("deletemessage");
      coordinationBloc.persistentData
          .deleteElement(PersistenData.messagesTable, change);
    }
    print('Loaded unread');
    dispatch(_MessagesEventNewUnReadLoaded(unreadMessages: messages));
  }

  void _onReadMessagesUpdated(FirestoreChangedData data) async {
    Map<String, Message> messages = {};
    Set<String> toRemove = Set.from(currentState.recentMessages.keys);

    for (FirestoreWrappedData doc in data.newList) {
      coordinationBloc.loadingTrace?.incrementCounter("message");
      MessageRecipient recipient;
      // Update in place to keep the fetched and seen times.
      recipient = new MessageRecipient.fromJSON(doc.id, doc.data);

      Message mess = currentState.getMessage(recipient.messageId);
      if (mess != null) {
        // Update just my recipient piece of this.
        mess.recipients[recipient.userId] = recipient;
        messages[mess.uid] = mess;
        toRemove.remove(mess.uid);
        coordinationBloc.persistentData.updateElement(
            PersistenData.messagesTable,
            doc.id,
            mess.toJSON(includeMessage: true, forSQL: true));
      } else {
        // Otherwise we need to load it.
        Message mess = await coordinationBloc.databaseUpdateModel
            .getMessage(recipient.messageId);
        if (mess != null) {
          mess.recipients[recipient.userId] = recipient;
          messages[mess.uid] = mess;
          toRemove.remove(mess.uid);
          coordinationBloc.persistentData.updateElement(
              PersistenData.messagesTable,
              doc.id,
              mess.toJSON(includeMessage: true, forSQL: true));
        }
      }
    }
    for (String remove in toRemove) {
      coordinationBloc.loadingTrace?.incrementCounter("deletemessage");
      coordinationBloc.persistentData
          .deleteElement(PersistenData.messagesTable, remove);
    }
    print('Loaded read');
    dispatch(_MessagesEventNewRecentLoaded(recentMessages: messages));
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
        Message mess = new Message.fromJSON(uid, input);
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
          recentMessages: newMessages,
          unreadMessages: unreadMessages,
          onlySql: true);
      coordinationBloc.dispatch(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Messages, sql: true));
    }

    // The fireatore atart up.
    if (event is _MessagesEventFirestore) {
      _unreadMessageInitialData =
          coordinationBloc.databaseUpdateModel.getMessages(event.uid, true);
      _unreadMessageInitialData.startData
          .then((List<FirestoreWrappedData> data) {
        coordinationBloc.loadingTrace?.incrementCounter("message");
        print("Got some messages $data");
        _onUnreadMessagesUpdated(
            new FirestoreChangedData(newList: data, removed: []));
      });
      _messageSnapshot =
          _unreadMessageInitialData.stream.listen(this._onReadMessagesUpdated);
      _messageInitialData =
          coordinationBloc.databaseUpdateModel.getMessages(event.uid, false);
      _messageInitialData.startData.then((List<FirestoreWrappedData> data) {
        coordinationBloc.loadingTrace?.incrementCounter("message");
        print("Got some messages $data");
        this._onUnreadMessagesUpdated(
            new FirestoreChangedData(newList: data, removed: []));
      });
      _readMessageSnapshot =
          _messageInitialData.stream.listen(this._onReadMessagesUpdated);
    }

    // New data from above.  Mark ourselves as done.
    if (event is _MessagesEventNewRecentLoaded) {
      coordinationBloc.dispatch(CoordinationEventLoadedData(
          loaded: BlocsToLoad.LeagueOrTournament, sql: false));

      yield MessagesLoaded(
          recentMessages: event.recentMessages,
          unreadMessages: currentState.unreadMessages,
          onlySql: false);
    }

    if (event is _MessagesEventNewUnReadLoaded) {
      yield MessagesLoaded(
          recentMessages: currentState.recentMessages,
          unreadMessages: event.unreadMessages,
          onlySql: false);
    }

    // Unload everything.
    if (event is _MessagesEventLogout) {
      yield MessagesUninitialized();
      _cleanupStuff();
    }
  }
}
