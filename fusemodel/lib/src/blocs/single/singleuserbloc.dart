import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

abstract class SingleUserState extends Equatable {
  final BuiltList<Player> players;

  SingleUserState({@required this.players});

  @override
  List<Object> get props => [players];
}

///
/// We have a Profile, default state.
///
class SingleUserUnitialized extends SingleUserState {
  SingleUserUnitialized() : super(players: BuiltList());

  @override
  String toString() {
    return 'SingleUserUnitialized{}';
  }
}

///
/// We have a Profile, default state.
///
class SingleUserLoaded extends SingleUserState {
  SingleUserLoaded({@required BuiltList<Player> players})
      : super(players: players);

  @override
  String toString() {
    return 'SingleUserLoaded{}';
  }
}

///
/// We have a Profile, default state.
///
class SingleUserDeleted extends SingleUserState {
  SingleUserDeleted() : super(players: BuiltList());

  @override
  String toString() {
    return 'SingleUserLoaded{}';
  }
}

abstract class SingleUserEvent extends Equatable {}

class _SingleUserNewProfile extends SingleUserEvent {
  final Iterable<Player> players;

  _SingleUserNewProfile({@required this.players});

  @override
  List<Object> get props => [players];
}

class _SingleUserDeleted extends SingleUserEvent {
  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific Profile.
///
class SingleUserBloc extends Bloc<SingleUserEvent, SingleUserState> {
  final DatabaseUpdateModel databaseUpdateModel;
  final String userUid;

  StreamSubscription<Iterable<Player>> _playerSub;

  SingleUserBloc({@required this.databaseUpdateModel, @required this.userUid})
      : super(SingleUserUnitialized()) {
    _playerSub =
        databaseUpdateModel.getPlayers().listen((Iterable<Player> players) {
      if (players.length == 0) {
        add(_SingleUserDeleted());
      } else {
        add(_SingleUserNewProfile(players: players));
      }
    }, onError: (Error e) => add(_SingleUserDeleted()));
  }

  @override
  Future<void> close() async {
    await super.close();
    _playerSub?.cancel();
  }

  @override
  Stream<SingleUserState> mapEventToState(SingleUserEvent event) async* {
    if (event is _SingleUserNewProfile) {
      yield SingleUserLoaded(players: BuiltList.from(event.players));
    }

    // The Profile is deleted.
    if (event is _SingleUserDeleted) {
      yield SingleUserDeleted();
    }
  }
}
