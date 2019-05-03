import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';

class UserEvent extends Equatable {}

class _UserUserLoaded extends UserEvent {
  final String uid;

  _UserUserLoaded({
    @required this.uid,
  });

  @override
  String toString() {
    return '_UserUserLoaded{}';
  }
}

class _UserLoggedOut extends UserEvent {}

///
/// Loads the profile of the specified user.
///
class UserLoadProfile extends UserEvent {
  final String userUid;

  UserLoadProfile({@required this.userUid});
}

///
/// Basic state for all the user states.
///
class UserState extends Equatable {
  final Map<String, FusedUserProfile> users;

  UserState({@required this.users});
}

///
/// No data at all, we are uninitialized.
///
class UserUninitialized extends UserState {
  UserUninitialized() : super(users: {});

  @override
  String toString() {
    return 'UserUninitialized{users: ${users.length}}';
  }
}

///
/// User data is loaded and everything is fluffy.
///
class UserLoaded extends UserState {
  UserLoaded({@required Map<String, FusedUserProfile> users})
      : super(users: users);

  @override
  String toString() {
    return 'UserData{users: ${users.length}}';
  }
}

///
/// User bloc handles the user flow.  Loading all the users from
/// firestore.
///
class UserBloc extends Bloc<UserEvent, UserState> {
  final CoordinationBloc coordinationBloc;

  StreamSubscription<CoordinationState> _authSub;

  UserBloc({
    @required this.coordinationBloc,
  }) {
    _authSub = coordinationBloc.state.listen((CoordinationState state) {
      if (state is CoordinationStateLoggedOut) {
        dispatch(_UserLoggedOut());
      } else if (state is CoordinationStateStartLoadingSql) {
        dispatch(_UserUserLoaded(uid: state.uid));
      }
    });
  }
  @override
  UserState get initialState {
    return new UserUninitialized();
  }

  @override
  void dispose() {
    _authSub?.cancel();
  }

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is _UserUserLoaded) {
      yield UserLoaded(users: {});
    }

    // Unload everything.
    if (event is _UserLoggedOut) {
      yield UserUninitialized();
    }

    if (event is UserLoadProfile) {
      FusedUserProfile profile = await coordinationBloc
          .authenticationBloc.userAuth
          .getProfile(event.userUid);
      Map<String, FusedUserProfile> users = Map.from(currentState.users);
      users[event.userUid] = profile;
      yield UserLoaded(users: users);
    }
  }
}
