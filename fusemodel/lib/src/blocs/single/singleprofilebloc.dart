import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/async_hydrated_bloc/asynchydratedbloc.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import '../playerbloc.dart';
import 'data/singleprofilebloc.dart';

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
class SingleProfileBloc
    extends AsyncHydratedBloc<SingleProfileEvent, SingleProfileState> {
  final CoordinationBloc coordinationBloc;
  final PlayerBloc playerBloc;
  final String profileUid;

  StreamSubscription<FusedUserProfile> _profileSub;

  SingleProfileBloc(
      {@required this.coordinationBloc,
      @required this.profileUid,
      @required this.playerBloc})
      : super(SingleProfileUninitialized(), profileUid) {
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
  Stream<SingleProfileState> mapEventToState(SingleProfileEvent event) async* {
    if (event is _SingleProfileNewProfile) {
      if (event.profile != state.profile) {
        yield (SingleProfileLoaded.fromState(state)
              ..profile = event.profile.toBuilder())
            .build();
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
          coordinationBloc.databaseUpdateModel
              .updatePlayerImage(playerBloc.state.me.uid, event.image);
          //profile = profile.rebuild((b) b..)
        }
        await coordinationBloc.authenticationBloc.userAuth
            .updateProfile(profileUid, profile);
        yield (SingleProfileSaveDone.fromState(state)
              ..profile = profile.toBuilder())
            .build();
        yield (SingleProfileLoaded.fromState(state)
              ..profile = profile.toBuilder())
            .build();
      } catch (e) {
        yield (SingleProfileSaveFailed.fromState(state)..error = e).build();
      }
    }
  }

  @override
  SingleProfileState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return SingleProfileUninitialized();
    }

    SingleProfileBlocStateType type =
        SingleProfileBlocStateType.valueOf(json["type"]);
    switch (type) {
      case SingleProfileBlocStateType.Uninitialized:
        return SingleProfileUninitialized();
      case SingleProfileBlocStateType.Loaded:
        return SingleProfileLoaded.fromMap(json);
      case SingleProfileBlocStateType.Deleted:
        return SingleProfileDeleted.fromMap(json);
      case SingleProfileBlocStateType.SaveFailed:
        return SingleProfileSaveFailed.fromMap(json);
      case SingleProfileBlocStateType.Saving:
        return SingleProfileSaving.fromMap(json);
      case SingleProfileBlocStateType.SaveDone:
        return SingleProfileSaveDone.fromMap(json);
    }
    return SingleProfileUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleProfileState state) {
    return state.toMap();
  }
}
