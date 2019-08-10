import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

abstract class SingleUserState extends Equatable {
  final Iterable<Player> players;

  SingleUserState({@required this.players});
}

///
/// We have a Profile, default state.
///
class SingleUserUnitialized extends SingleUserState {
  SingleUserUnitialized() : super(players: []);

  @override
  String toString() {
    return 'SingleUserUnitialized{}';
  }
}

///
/// We have a Profile, default state.
///
class SingleUserLoaded extends SingleUserState {
  SingleUserLoaded({@required Iterable<Player> players})
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
  SingleUserDeleted() : super(players: []);

  @override
  String toString() {
    return 'SingleUserLoaded{}';
  }
}

abstract class SingleUserEvent extends Equatable {}

class _SingleUserNewProfile extends SingleUserEvent {
  final Iterable<Player> players;

  _SingleUserNewProfile({@required this.players});
}

class _SingleUserDeleted extends SingleUserEvent {
  _SingleUserDeleted();
}

///
/// Bloc to handle updates and state of a specific Profile.
///
class SingleUserBloc extends Bloc<SingleUserEvent, SingleUserState> {
  final DatabaseUpdateModel databaseUpdateModel;
  final String userUid;

  StreamSubscription<Iterable<Player>> _playerSub;

  SingleUserBloc({@required this.databaseUpdateModel, @required this.userUid}) {
    _playerSub = databaseUpdateModel.getPlayers(userUid).listen(
        (Iterable<Player> players) {
      if (players.length == 0) {
        dispatch(_SingleUserDeleted());
      } else {
        dispatch(_SingleUserNewProfile(players: players));
      }
    }, onError: (Error e) => dispatch(_SingleUserDeleted()));
  }

  @override
  void dispose() {
    super.dispose();
    _playerSub?.cancel();
  }

  @override
  SingleUserState get initialState => SingleUserUnitialized();

  @override
  Stream<SingleUserState> mapEventToState(SingleUserEvent event) async* {
    if (event is _SingleUserNewProfile) {
      yield SingleUserLoaded(players: event.players);
    }

    // The Profile is deleted.
    if (event is _SingleUserDeleted) {
      yield SingleUserDeleted();
    }
  }
}
