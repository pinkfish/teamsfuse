import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import '../playerbloc.dart';

abstract class SingleProfileState extends Equatable {
  final FusedUserProfile profile;

  SingleProfileState({@required this.profile});

  @override
  List<Object> get props => [profile];
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
/// Saving operation done.
///
class SingleProfileSaveDone extends SingleProfileState {
  SingleProfileSaveDone({@required FusedUserProfile profile})
      : super(profile: profile);

  @override
  String toString() {
    return 'SingleProfileSaveDone{}';
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
  final File image;

  SingleProfileUpdate({@required this.profile, this.image});

  @override
  List<Object> get props => [profile, image];
}

class _SingleProfileNewProfile extends SingleProfileEvent {
  final FusedUserProfile profile;

  _SingleProfileNewProfile({@required this.profile});

  @override
  List<Object> get props => [profile];
}

class _SingleProfileDeleted extends SingleProfileEvent {
  _SingleProfileDeleted();

  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific Profile.
///
class SingleProfileBloc extends Bloc<SingleProfileEvent, SingleProfileState> {
  final CoordinationBloc coordinationBloc;
  final PlayerBloc playerBloc;
  final String profileUid;

  StreamSubscription<FusedUserProfile> _profileSub;

  SingleProfileBloc(
      {@required this.coordinationBloc,
      @required this.profileUid,
      @required this.playerBloc}) {
    _profileSub = coordinationBloc.authenticationBloc.userAuth
        .getProfileStream(profileUid)
        .listen((FusedUserProfile profile) {
      if (profile == null) {
        add(_SingleProfileDeleted());
      } else {
        add(_SingleProfileNewProfile(profile: profile));
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _profileSub?.cancel();
  }

  @override
  SingleProfileState get initialState => SingleProfileUnitialized();

  @override
  Stream<SingleProfileState> mapEventToState(SingleProfileEvent event) async* {
    if (event is _SingleProfileNewProfile) {
      if (event.profile != state.profile) {
        yield SingleProfileLoaded(profile: event.profile);
      }
    }

    // The Profile is deleted.
    if (event is _SingleProfileDeleted) {
      yield SingleProfileDeleted();
    }

    if (event is SingleProfileUpdate) {
      try {
        FusedUserProfile profile = event.profile;
        if (event.image != null) {
          var url = coordinationBloc.databaseUpdateModel
              .updatePlayerImage(playerBloc.state.me.uid, event.image);
          //profile = profile.rebuild((b) b..)
        }
        await coordinationBloc.authenticationBloc.userAuth
            .updateProfile(profileUid, profile);
        yield SingleProfileSaveDone(profile: profile);
        yield SingleProfileLoaded(profile: profile);
      } catch (e) {
        yield SingleProfileSaveFailed(profile: state.profile, error: e);
      }
    }
  }
}
