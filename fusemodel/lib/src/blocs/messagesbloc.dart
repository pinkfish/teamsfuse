import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'authenticationbloc.dart';
import 'playerbloc.dart';
import 'teambloc.dart';

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

///
/// Handles the work around the Messagess and Messages system inside of
/// the app.
///
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final AuthenticationBloc authenticationBloc;
  final PlayerBloc playerBloc;
  final TeamBloc teamBloc;

  StreamSubscription<AuthenticationState> _authSub;
  StreamSubscription<FirestoreChangedData> _messageSnapshot;
  StreamSubscription<FirestoreChangedData> _readMessageSnapshot;
  InitialSubscription _unreadMessageInitialData;
  InitialSubscription _messageInitialData;

  MessagesBloc(
      {@required this.authenticationBloc,
      @required this.playerBloc,
      @required this.teamBloc}) {
    _authSub = authenticationBloc.state.listen((AuthenticationState state) {
      if (state is AuthenticationLoggedIn) {
        _startLoading(state);
      } else {
        dispatch(_MessagesEventLogout());
      }
    });
    if (authenticationBloc.currentState is AuthenticationLoggedIn) {
      _startLoading(authenticationBloc.currentState);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cleanupStuff();
    _authSub?.cancel();
    _authSub = null;
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

  void _startLoading(AuthenticationLoggedIn state) {
    dispatch(_MessagesEventUserLoaded(uid: state.user.uid));
  }

  @override
  MessagesState get initialState => MessagesUninitialized();

  void _onUnreadMessagesUpdated(FirestoreChangedData data) async {
    Set<String> toRemove = Set.from(currentState.unreadMessages.keys);
    Map<String, Message> messages = {};

    // Fill in all the messages.
    for (FirestoreWrappedData doc in data.newList) {
      playerBloc.loadingTrace?.incrementCounter("message");
      MessageRecipient recipient;
      // Update in place to keep the fetched and seen times.
      recipient = new MessageRecipient.fromJSON(doc.id, doc.data);

      Message mess = currentState.getMessage(recipient.messageId);
      if (mess != null) {
        // Update just my recipient piece of this.
        mess.recipients[recipient.userId] = recipient;
        messages[mess.uid] = mess;
        toRemove.remove(mess.uid);
        playerBloc.persistentData.updateElement(PersistenData.messagesTable,
            doc.id, mess.toJSON(includeMessage: true, forSQL: true));
      } else {
        // Otherwise we need to load it.
        mess = await playerBloc.databaseUpdateModel
            .getMessage(recipient.messageId);
        if (mess != null) {
          messages[mess.uid] = mess;
          toRemove.remove(mess.uid);
          mess.recipients[recipient.userId] = recipient;
          playerBloc.persistentData.updateElement(PersistenData.messagesTable,
              doc.id, mess.toJSON(includeMessage: true, forSQL: true));
        }
      }
    }
    for (String change in toRemove) {
      playerBloc.loadingTrace?.incrementCounter("deletemessage");
      playerBloc.persistentData
          .deleteElement(PersistenData.messagesTable, change);
    }
    print('Loaded unread');
    dispatch(_MessagesEventNewUnReadLoaded(unreadMessages: messages));
  }

  void _onReadMessagesUpdated(FirestoreChangedData data) async {
    Map<String, Message> messages = {};
    Set<String> toRemove = Set.from(currentState.recentMessages.keys);

    for (FirestoreWrappedData doc in data.newList) {
      playerBloc.loadingTrace?.incrementCounter("message");
      MessageRecipient recipient;
      // Update in place to keep the fetched and seen times.
      recipient = new MessageRecipient.fromJSON(doc.id, doc.data);

      Message mess = currentState.getMessage(recipient.messageId);
      if (mess != null) {
        // Update just my recipient piece of this.
        mess.recipients[recipient.userId] = recipient;
        messages[mess.uid] = mess;
        toRemove.remove(mess.uid);
        playerBloc.persistentData.updateElement(PersistenData.messagesTable,
            doc.id, mess.toJSON(includeMessage: true, forSQL: true));
      } else {
        // Otherwise we need to load it.
        Message mess = await playerBloc.databaseUpdateModel
            .getMessage(recipient.messageId);
        if (mess != null) {
          mess.recipients[recipient.userId] = recipient;
          messages[mess.uid] = mess;
          toRemove.remove(mess.uid);
          playerBloc.persistentData.updateElement(PersistenData.messagesTable,
              doc.id, mess.toJSON(includeMessage: true, forSQL: true));
        }
      }
    }
    for (String remove in toRemove) {
      playerBloc.loadingTrace?.incrementCounter("deletemessage");
      playerBloc.persistentData
          .deleteElement(PersistenData.messagesTable, remove);
    }
    print('Loaded read');
    dispatch(_MessagesEventNewRecentLoaded(recentMessages: messages));
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    if (event is _MessagesEventUserLoaded) {
      TraceProxy messagesTrace =
          playerBloc.analyticsSubsystem.newTrace("messagesTrace");
      messagesTrace.start();
      Map<String, Map<String, dynamic>> data = await playerBloc.persistentData
          .getAllElements(PersistenData.messagesTable);
      Map<String, Message> newMessages = {};
      Map<String, Message> unreadMessages = {};
      data.forEach((String uid, Map<String, dynamic> input) {
        playerBloc.sqlTrace.incrementCounter("message");
        Message mess = new Message.fromJSON(uid, input);
        if (mess.recipients[event.uid].state == MessageState.Unread) {
          unreadMessages[uid] = mess;
        } else {
          newMessages[uid] = mess;
        }
      });
      print('End messages ${playerBloc.start.difference(new DateTime.now())}');
      messagesTrace.stop();
      yield MessagesLoaded(
          recentMessages: newMessages,
          unreadMessages: unreadMessages,
          onlySql: true);

      _unreadMessageInitialData =
          playerBloc.databaseUpdateModel.getMessages(event.uid, true);
      _unreadMessageInitialData.startData
          .then((List<FirestoreWrappedData> data) {
        playerBloc.loadingTrace?.incrementCounter("message");
        print("Got some messages $data");
        _onUnreadMessagesUpdated(
            new FirestoreChangedData(newList: data, removed: []));
      });
      _messageSnapshot =
          _unreadMessageInitialData.stream.listen(this._onReadMessagesUpdated);
      _messageInitialData =
          playerBloc.databaseUpdateModel.getMessages(event.uid, false);
      _messageInitialData.startData.then((List<FirestoreWrappedData> data) {
        playerBloc.loadingTrace?.incrementCounter("message");
        print("Got some messages $data");
        this._onUnreadMessagesUpdated(
            new FirestoreChangedData(newList: data, removed: []));
      });
      _readMessageSnapshot =
          _messageInitialData.stream.listen(this._onReadMessagesUpdated);
    }

    // New data from above.  Mark ourselves as done.
    if (event is _MessagesEventNewRecentLoaded) {
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
