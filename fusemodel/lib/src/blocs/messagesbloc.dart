import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/blocs/data/messagesblocstate.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';
import 'teambloc.dart';

abstract class MessagesEvent extends Equatable {}

class _MessagesEventLogout extends MessagesEvent {
  @override
  List<Object> get props => [];
}

class _MessagesEventNewUnReadLoaded extends MessagesEvent {
  final MapBuilder<String, Message> unreadMessages;

  _MessagesEventNewUnReadLoaded({@required this.unreadMessages});

  @override
  List<Object> get props => [unreadMessages];
}

class _MessagesEventNewRecentLoaded extends MessagesEvent {
  final MapBuilder<String, Message> recentMessages;

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
class MessagesBloc extends HydratedBloc<MessagesEvent, MessagesState> {
  final CoordinationBloc coordinationBloc;
  final TeamBloc teamBloc;

  StreamSubscription<CoordinationState> _coordState;
  StreamSubscription<Iterable<MessageRecipient>> _messageSnapshot;
  StreamSubscription<Iterable<MessageRecipient>> _readMessageSnapshot;

  bool _loadingFirestore = false;

  MessagesBloc({@required this.coordinationBloc, @required this.teamBloc})
      : super(MessagesUninitialized()) {
    coordinationBloc
        .add(CoordinationEventTrackLoading(toLoad: BlocsToLoad.Messages));

    _coordState = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;
        add(_MessagesEventLogout());
      } else if (coordState is CoordinationStateLoadingFirestore) {
        _startLoadingFirestore(coordState);
      }
    });
    if (coordinationBloc.state is CoordinationStateLoadingFirestore) {
      _startLoadingFirestore(coordinationBloc.state);
    }
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

  void _startLoadingFirestore(CoordinationStateLoadingFirestore state) {
    if (!_loadingFirestore) {
      _loadingFirestore = true;
      add(_MessagesEventFirestore(uid: state.uid));
    }
  }

  void _onUnreadMessagesUpdated(Iterable<MessageRecipient> data) async {
    Set<String> toRemove = Set.from(state.unreadMessages.keys);
    MapBuilder<String, Message> messages = MapBuilder<String, Message>();

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
        }
      }
    }
    for (String change in toRemove) {
      coordinationBloc.loadingTrace?.incrementCounter("deletemessage");
    }
    print('Loaded unread');
    add(_MessagesEventNewUnReadLoaded(unreadMessages: messages));
    coordinationBloc
        .add(CoordinationEventLoadedData(loaded: BlocsToLoad.Messages));
  }

  void _onReadMessagesUpdated(Iterable<MessageRecipient> data) async {
    MapBuilder<String, Message> messages = MapBuilder<String, Message>();
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
      } else {
        // Otherwise we need to load it.
        Message mess = await coordinationBloc.databaseUpdateModel
            .getMessage(recipient.messageId);
        if (mess != null) {
          MessageBuilder builder = mess.toBuilder();
          builder.recipients[recipient.userId] = recipient;
          messages[mess.uid] = builder.build();
          toRemove.remove(mess.uid);
        }
      }
    }
    for (String remove in toRemove) {
      coordinationBloc.loadingTrace?.incrementCounter("deletemessage");
    }
    print('Loaded read');
    add(_MessagesEventNewRecentLoaded(recentMessages: messages));
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    // The fireatore atart up.
    if (event is _MessagesEventFirestore) {
      _messageSnapshot = coordinationBloc.databaseUpdateModel
          .getMessages(true)
          .listen((Iterable<MessageRecipient> messages) {
        coordinationBloc.loadingTrace?.incrementCounter("message");
        _onUnreadMessagesUpdated(messages);
      });
      _readMessageSnapshot = coordinationBloc.databaseUpdateModel
          .getMessages(false)
          .listen((Iterable<MessageRecipient> messages) {
        coordinationBloc.loadingTrace?.incrementCounter("message");
        this._onReadMessagesUpdated(messages);
      });
    }

    // New data from above.  Mark ourselves as done.
    if (event is _MessagesEventNewRecentLoaded) {
      coordinationBloc.add(
          CoordinationEventLoadedData(loaded: BlocsToLoad.LeagueOrTournament));

      yield (MessagesLoaded.fromState(state)
            ..recentMessages = event.recentMessages
            ..loadedFirestore = true)
          .build();
    }

    if (event is _MessagesEventNewUnReadLoaded) {
      yield (MessagesLoaded.fromState(state)
            ..unreadMessages = event.unreadMessages
            ..loadedFirestore = true)
          .build();
    }

    // Unload everything.
    if (event is _MessagesEventLogout) {
      yield MessagesUninitialized();
      _cleanupStuff();
    }
  }

  @override
  fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return MessagesUninitialized();
    }

    MessagesBlocStateType type = MessagesBlocStateType.valueOf(json["type"]);
    switch (type) {
      case MessagesBlocStateType.Uninitialized:
        return MessagesUninitialized();
      case MessagesBlocStateType.Loaded:
        TraceProxy messagesTrace =
            coordinationBloc.analyticsSubsystem.newTrace("messagesTrace");
        messagesTrace.start();
        var loaded = MessagesLoaded.fromMap(json);
        print('End messages ');
        messagesTrace.stop();
        return loaded;
      default:
        return MessagesUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(state) {
    return state.toMap();
  }
}
