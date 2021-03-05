import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

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
  final FusedUserProfile profile;

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
  final AuthenticationBloc authenticationBloc;
  final AnalyticsSubsystem crashes;

  StreamSubscription<AuthenticationState> _authSub;
  StreamSubscription<FusedUserProfile> _profileSub;

  ProfileBloc({
    @required this.authenticationBloc,
    @required this.crashes,
  }) : super(ProfileBlocUninitialized()) {
    _authSub = authenticationBloc.listen((state) {
      if (state is AuthenticationLoggedOut) {
        add(_ProfileLoggedOut());
      } else if (state is AuthenticationLoggedIn) {
        add(_ProfileUserLoaded(uid: state.user.uid));
      }
    });
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }

  @override
  Stream<ProfileBlocState> mapEventToState(ProfileEvent event) async* {
    if (event is _ProfileUserLoaded) {
      yield (ProfileBlocLoaded.fromState(state)..profile = null).build();
      // Load the current uswers profile.
      _profileSub = authenticationBloc.userAuth
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
      await _profileSub?.cancel();
      _profileSub = null;
    }
  }

  @override
  ProfileBlocState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey('type')) {
      return ProfileBlocUninitialized();
    }
    var type = ProfileBlocStateType.valueOf(json['type']);
    switch (type) {
      case ProfileBlocStateType.Uninitialized:
        return ProfileBlocUninitialized();
      case ProfileBlocStateType.Loaded:
        try {
          return ProfileBlocLoaded.fromMap(json);
        } catch (e, stacktrace) {
          if (e is Error) {
            crashes.recordError(e, stacktrace);
          } else {
            crashes.recordException(e, stacktrace);
          }
        }
        return ProfileBlocUninitialized();
      default:
        return ProfileBlocUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(ProfileBlocState state) {
    return state.toMap();
  }
}
