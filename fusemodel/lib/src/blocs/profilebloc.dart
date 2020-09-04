import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'data/profileblocstate.dart';

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
/// User bloc handles the profile flow.  Loading  the profile from
/// firestore.
///
class ProfileBloc extends HydratedBloc<ProfileEvent, ProfileBlocState> {
  final CoordinationBloc coordinationBloc;

  StreamSubscription<CoordinationState> _authSub;
  StreamSubscription<FusedUserProfile> _profileSub;

  ProfileBloc({
    @required this.coordinationBloc,
  }) : super(ProfileBlocUninitialized()) {
    _authSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        add(_ProfileLoggedOut());
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
  }

  @override
  Stream<ProfileBlocState> mapEventToState(ProfileEvent event) async* {
    if (event is _ProfileUserLoaded) {
      yield (ProfileBlocLoaded.fromState(state)..profile = null).build();
      // Load the current uswers profile.
      _profileSub = coordinationBloc.authenticationBloc.userAuth
          .getProfileStream(event.uid)
          .listen((FusedUserProfile profile) {
        add(_ProfileNewProfile(profile: profile));
      });
    }

    if (event is _ProfileNewProfile) {
      yield (ProfileBlocLoaded.fromState(state)
            ..profile = event.profile.toBuilder())
          .build();
    }

    // Unload everything.
    if (event is _ProfileLoggedOut) {
      yield ProfileBlocUninitialized();
      _profileSub?.cancel();
      _profileSub = null;
    }
  }

  @override
  ProfileBlocState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return ProfileBlocUninitialized();
    }
    ProfileBlocStateType type = ProfileBlocStateType.valueOf(json["type"]);
    switch (type) {
      case ProfileBlocStateType.Uninitialized:
        return ProfileBlocUninitialized();
      case ProfileBlocStateType.Loaded:
        return ProfileBlocLoaded.fromMap(json);
      default:
        return ProfileBlocUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(ProfileBlocState state) {
    return state.toMap();
  }
}
