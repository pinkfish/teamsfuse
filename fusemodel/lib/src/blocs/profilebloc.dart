import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';

abstract class ProfileEvent extends Equatable {}

class _ProfileUserLoaded extends ProfileEvent {
  final String uid;

  _ProfileUserLoaded({
    @required this.uid,
  });

  @override
  String toString() {
    return '_ProfileUserLoaded{}';
  }

  @override
  List<Object> get props => [uid];
}

class _ProfileNewProfile extends ProfileEvent {
  FusedUserProfile profile;

  _ProfileNewProfile({this.profile});

  @override
  List<Object> get props => [profile];
}

class _ProfileLoggedOut extends ProfileEvent {
  @override
  List<Object> get props => [];
}

///
/// Basic state for all the user states.
///
class ProfileState extends Equatable {
  final FusedUserProfile profile;

  ProfileState({@required this.profile});

  @override
  List<Object> get props => [profile];
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

  bool _loadedSql = false;

  ProfileBloc({
    @required this.coordinationBloc,
  }) : super(ProfileUninitialized()) {
    _authSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        _loadedSql = false;
        add(_ProfileLoggedOut());
      } else if (coordState is CoordinationStateLoadingSql) {
        if (_loadedSql) {
          _loadedSql = true;
          add(_ProfileUserLoaded(uid: coordState.uid));
        }
      }
    });
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
        add(_ProfileNewProfile(profile: profile));
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
