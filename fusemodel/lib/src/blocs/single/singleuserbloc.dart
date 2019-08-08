import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../authenticationbloc.dart';

abstract class SingleProfileState extends Equatable {
  final FusedUserProfile profile;

  SingleProfileState({@required this.profile});
}

///
/// We have a Profile, default state.
///
class SingleProfileUnitialized extends SingleProfileState {
  SingleProfileUnitialized() : super(profile: null);

  @override
  String toString() {
    return 'SingleProfileLoaded{}';
  }
}

///
/// We have a Profile, default state.
///
class SingleProfileLoaded extends SingleProfileState {
  SingleProfileLoaded({@required FusedUserProfile profile})
      : super(profile: profile);

  @override
  String toString() {
    return 'SingleProfileLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleProfileSaving extends SingleProfileState {
  SingleProfileSaving({@required FusedUserProfile profile})
      : super(profile: profile);

  @override
  String toString() {
    return 'SingleProfileSaving{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleProfileSaveFailed extends SingleProfileState {
  final Error error;

  SingleProfileSaveFailed(
      {@required FusedUserProfile profile, @required this.error})
      : super(profile: profile);

  @override
  String toString() {
    return 'SingleProfileSaveFailed{}';
  }
}

///
/// Profile got deleted.
///
class SingleProfileDeleted extends SingleProfileState {
  SingleProfileDeleted() : super(profile: null);

  @override
  String toString() {
    return 'SingleProfileDeleted{}';
  }
}

abstract class SingleProfileEvent extends Equatable {}

///
/// Updates the Profile (writes it out to firebase.
///
class SingleProfileUpdate extends SingleProfileEvent {
  final FusedUserProfile profile;

  SingleProfileUpdate({@required this.profile});
}

class _SingleProfileNewProfile extends SingleProfileEvent {
  final FusedUserProfile profile;

  _SingleProfileNewProfile({@required this.profile});
}

class _SingleProfileDeleted extends SingleProfileEvent {
  _SingleProfileDeleted();
}

///
/// Bloc to handle updates and state of a specific Profile.
///
class SingleProfileBloc extends Bloc<SingleProfileEvent, SingleProfileState> {
  final AuthenticationBloc authenticationBloc;
  final String profileUid;

  StreamSubscription<FusedUserProfile> _profileSub;

  SingleProfileBloc(
      {@required this.authenticationBloc, @required this.profileUid}) {
    _profileSub = authenticationBloc.userAuth
        .getProfileStream(profileUid)
        .listen((FusedUserProfile profile) {
      if (profile == null) {
        dispatch(_SingleProfileDeleted());
      } else {
        dispatch(_SingleProfileNewProfile(profile: profile));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _profileSub?.cancel();
  }

  @override
  SingleProfileState get initialState => SingleProfileUnitialized();

  @override
  Stream<SingleProfileState> mapEventToState(SingleProfileEvent event) async* {
    if (event is _SingleProfileNewProfile) {
      yield SingleProfileLoaded(profile: event.profile);
    }

    // The Profile is deleted.
    if (event is _SingleProfileDeleted) {
      yield SingleProfileDeleted();
    }
  }
}
