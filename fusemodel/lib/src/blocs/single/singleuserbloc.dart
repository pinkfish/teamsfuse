import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../authenticationbloc.dart';

abstract class SingleUserState extends Equatable {
  final FusedUserProfile profile;

  SingleUserState({@required this.profile});
}

///
/// We have a User, default state.
///
class SingleUserUnitialized extends SingleUserState {
  SingleUserUnitialized() : super(profile: null);

  @override
  String toString() {
    return 'SingleUserLoaded{}';
  }
}

///
/// We have a User, default state.
///
class SingleUserLoaded extends SingleUserState {
  SingleUserLoaded({@required FusedUserProfile profile})
      : super(profile: profile);

  @override
  String toString() {
    return 'SingleUserLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleUserSaving extends SingleUserState {
  SingleUserSaving({@required FusedUserProfile profile})
      : super(profile: profile);

  @override
  String toString() {
    return 'SingleUserSaving{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleUserSaveFailed extends SingleUserState {
  final Error error;

  SingleUserSaveFailed(
      {@required FusedUserProfile profile, @required this.error})
      : super(profile: profile);

  @override
  String toString() {
    return 'SingleUserSaveFailed{}';
  }
}

///
/// User got deleted.
///
class SingleUserDeleted extends SingleUserState {
  SingleUserDeleted() : super(profile: null);

  @override
  String toString() {
    return 'SingleUserDeleted{}';
  }
}

abstract class SingleUserEvent extends Equatable {}

///
/// Updates the User (writes it out to firebase.
///
class SingleUserUpdate extends SingleUserEvent {
  final FusedUserProfile profile;

  SingleUserUpdate({@required this.profile});
}

class _SingleUserNewUser extends SingleUserEvent {
  final FusedUserProfile profile;

  _SingleUserNewUser({@required this.profile});
}

class _SingleUserDeleted extends SingleUserEvent {
  _SingleUserDeleted();
}

///
/// Bloc to handle updates and state of a specific User.
///
class SingleUserBloc extends Bloc<SingleUserEvent, SingleUserState> {
  final AuthenticationBloc authenticationBloc;
  final String userUid;

  SingleUserBloc({@required this.authenticationBloc, @required this.userUid}) {
    authenticationBloc.userAuth
        .getProfile(userUid)
        .then((FusedUserProfile profile) {
      dispatch(_SingleUserNewUser(profile: profile));
    }).catchError((Error e) {
      dispatch(_SingleUserDeleted());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  SingleUserState get initialState => SingleUserUnitialized();

  @override
  Stream<SingleUserState> mapEventToState(SingleUserEvent event) async* {
    if (event is _SingleUserNewUser) {
      yield SingleUserLoaded(profile: event.profile);
    }

    // The User is deleted.
    if (event is _SingleUserDeleted) {
      yield SingleUserDeleted();
    }
  }
}
