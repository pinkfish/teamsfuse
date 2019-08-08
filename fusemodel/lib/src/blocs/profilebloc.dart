import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';

class ProfileEvent extends Equatable {}

class _ProfileUserLoaded extends ProfileEvent {
  final String uid;

  _ProfileUserLoaded({
    @required this.uid,
  });

  @override
  String toString() {
    return '_ProfileUserLoaded{}';
  }
}

class _ProfileNewProfile extends ProfileEvent {
  FusedUserProfile profile;

  _ProfileNewProfile({this.profile});
}

class _ProfileLoggedOut extends ProfileEvent {}

///
/// Basic state for all the user states.
///
class ProfileState extends Equatable {
  final FusedUserProfile profile;

  ProfileState({@required this.profile});
}

///
/// No data at all, we are uninitialized.
///
class ProfileUninitialized extends ProfileState {
  ProfileUninitialized() : super(profile: null);

  @override
  String toString() {
    return 'UserUninitialized{users: ${profile.uid}}';
  }
}

///
/// User data is loaded and everything is fluffy.
///
class ProfileLoaded extends ProfileState {
  ProfileLoaded({@required FusedUserProfile profile}) : super(profile: profile);

  @override
  String toString() {
    return 'UserData{users: ${profile.uid}}';
  }
}

///
/// User bloc handles the profile flow.  Loading  the profile from
/// firestore.
///
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final CoordinationBloc coordinationBloc;

  StreamSubscription<CoordinationState> _authSub;
  StreamSubscription<FusedUserProfile> _profileSub;

  ProfileBloc({
    @required this.coordinationBloc,
  }) {
    _authSub = coordinationBloc.state.listen((CoordinationState state) {
      if (state is CoordinationStateLoggedOut) {
        dispatch(_ProfileLoggedOut());
      } else if (state is CoordinationStateStartLoadingSql) {
        dispatch(_ProfileUserLoaded(uid: state.uid));
      }
    });
  }
  @override
  ProfileState get initialState {
    return new ProfileUninitialized();
  }

  @override
  void dispose() {
    _authSub?.cancel();
  }

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is _ProfileUserLoaded) {
      yield ProfileLoaded(profile: null);
      // Load the current uswers profile.
      _profileSub = coordinationBloc.authenticationBloc.userAuth
          .getProfileStream(event.uid)
          .listen((FusedUserProfile profile) {
        dispatch(_ProfileNewProfile(profile: profile));
      });
    }

    if (event is _ProfileNewProfile) {
      yield ProfileLoaded(profile: event.profile);
    }

    // Unload everything.
    if (event is _ProfileLoggedOut) {
      yield ProfileUninitialized();
      _profileSub?.cancel();
      _profileSub = null;
    }
  }
}
