import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/blocs/data/messagesblocstate.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';

abstract class MessagesEvent extends Equatable {}

class _MessagesEventLogout extends MessagesEvent {
  @override
  List<Object> get props => [];
}

class _MessagesEventNewUnReadLoaded extends MessagesEvent {
  final ListBuilder<MessageRecipient> unreadMessages;

  _MessagesEventNewUnReadLoaded({@required this.unreadMessages});

  @override
  List<Object> get props => [unreadMessages];
}

class _MessagesEventNewRecentLoaded extends MessagesEvent {
  final ListBuilder<MessageRecipient> recentMessages;

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
class MessagesBloc extends HydratedBloc<MessagesEvent, MessagesBlocState> {
  final CoordinationBloc coordinationBloc;
  final AnalyticsSubsystem crashes;

  StreamSubscription<CoordinationState> _coordState;
  StreamSubscription<Iterable<MessageRecipient>> _messageSnapshot;
  StreamSubscription<Iterable<MessageRecipient>> _readMessageSnapshot;

  bool _loadingFirestore = false;

  MessagesBloc({@required this.coordinationBloc, @required this.crashes})
      : super(MessagesUninitialized()) {
    coordinationBloc
        .add(CoordinationEventTrackLoading(toLoad: BlocsToLoad.Messages));

    _coordState =
        coordinationBloc.stream.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;
        add(_MessagesEventLogout());
      } else if (coordState is CoordinationStateLoadingFirestore) {
        _startLoadingFirestore(coordState);
      }
    });
    _coordState.onError((e, stack) {
      crashes.recordException(e, stack);
    });
    if (coordinationBloc.state is CoordinationStateLoadingFirestore) {
      _startLoadingFirestore(coordinationBloc.state);
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanupStuff();
    await _coordState?.cancel();
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
    // Fill in all the messages.
    for (var _ in data) {
      coordinationBloc.loadingTrace?.incrementCounter('message');
    }

    add(_MessagesEventNewUnReadLoaded(unreadMessages: ListBuilder(data)));
    coordinationBloc
        .add(CoordinationEventLoadedData(loaded: BlocsToLoad.Messages));
  }

  void _onReadMessagesUpdated(Iterable<MessageRecipient> data) async {
    add(_MessagesEventNewRecentLoaded(recentMessages: ListBuilder(data)));
  }

  @override
  Stream<MessagesBlocState> mapEventToState(MessagesEvent event) async* {
    // The fireatore atart up.
    if (event is _MessagesEventFirestore) {
      _messageSnapshot = coordinationBloc.databaseUpdateModel
          .getMessages(true)
          .listen((Iterable<MessageRecipient> messages) {
        coordinationBloc.loadingTrace?.incrementCounter('message');
        _onUnreadMessagesUpdated(messages);
      });
      _messageSnapshot.onError((e, stack) => crashes.recordException(e, stack));
      _readMessageSnapshot = coordinationBloc.databaseUpdateModel
          .getMessages(false)
          .listen((Iterable<MessageRecipient> messages) {
        coordinationBloc.loadingTrace?.incrementCounter('message');
        _onReadMessagesUpdated(messages);
      });
      _readMessageSnapshot
          .onError((e, stack) => crashes.recordException(e, stack));
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
  MessagesBlocState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey('type')) {
      return MessagesUninitialized();
    }

    var type = MessagesBlocStateType.valueOf(json['type']);
    switch (type) {
      case MessagesBlocStateType.Uninitialized:
        return MessagesUninitialized();
      case MessagesBlocStateType.Loaded:
        try {
          var messagesTrace =
              coordinationBloc.analytics.newTrace('messagesTrace');
          messagesTrace.start();
          var loaded = MessagesLoaded.fromMap(json);
          messagesTrace.stop();
          return loaded;
        } catch (e, stack) {
          if (e is Error) {
            crashes.recordError(e, stack);
          } else {
            crashes.recordException(e, stack);
          }
        }
        return MessagesUninitialized();
      default:
        return MessagesUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(state) {
    return state.toMap();
  }
}
