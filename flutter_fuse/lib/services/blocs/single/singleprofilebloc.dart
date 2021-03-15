import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

abstract class SingleProfileEvent extends Equatable {}

///
/// Updates the Profile (writes it out to firebase.
///
class SingleProfileUpdate extends SingleProfileEvent {
  final FusedUserProfile profile;
  final Uint8List image;

  SingleProfileUpdate({@required this.profile, this.image});

  @override
  List<Object> get props => [profile, image];
}

///
/// Loads the me player for this user.
///
class SingleProfileLoadMePlayer extends SingleProfileEvent {
  @override
  List<Object> get props => [];
}

class _SingleProfileNewProfile extends SingleProfileEvent {
  final FusedUserProfile profile;

  _SingleProfileNewProfile({@required this.profile});

  @override
  List<Object> get props => [profile];
}

class _SingleProfileNewMePlayer extends SingleProfileEvent {
  final Player player;

  _SingleProfileNewMePlayer({@required this.player});

  @override
  List<Object> get props => [player];
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
  final UserAuthImpl userAuth;
  final DatabaseUpdateModel db;
  final String profileUid;
  final AnalyticsSubsystem crashes;

  StreamSubscription<FusedUserProfile> _profileSub;
  StreamSubscription<Player> _playerSub;

  SingleProfileBloc(
      {@required this.userAuth,
      @required this.db,
      @required this.profileUid,
      @required this.crashes})
      : super(SingleProfileUninitialized(), profileUid) {
    _profileSub = userAuth
        .getProfileStream(profileUid)
        .listen((FusedUserProfile profile) {
      if (profile == null) {
        add(_SingleProfileDeleted());
      } else {
        add(_SingleProfileNewProfile(profile: profile));
      }
    });
    _profileSub.onError(crashes.recordException);
  }

  @override
  Future<void> close() async {
    await super.close();
    await _profileSub?.cancel();
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

    if (event is SingleProfileLoadMePlayer) {
      _playerSub = db.getMePlayer(profileUid).listen((Player player) {
        if (player != null) {
          add(_SingleProfileNewMePlayer(player: player));
        }
      });
      _playerSub.onError(crashes.recordException);
    }

    // Setup the new players
    if (event is _SingleProfileNewMePlayer) {
      yield (SingleProfileLoaded.fromState(state)
            ..mePlayer = event.player.toBuilder()
            ..loadedMePlayer = true)
          .build();
    }

    // The Profile is deleted.
    if (event is _SingleProfileDeleted) {
      yield SingleProfileDeleted();
    }

    if (event is SingleProfileUpdate) {
      try {
        var profile = event.profile;
        if (event.image != null) {
          // Find the me player.
          final player = await db.getMePlayer(db.currentUser.uid).first;
          await db.updatePlayerImage(player.uid, event.image);
          //profile = profile.rebuild((b) b..)
        }
        await userAuth.updateProfile(profileUid, profile);
        yield (SingleProfileSaveDone.fromState(state)
              ..profile = profile.toBuilder())
            .build();
        yield (SingleProfileLoaded.fromState(state)
              ..profile = profile.toBuilder())
            .build();
      } catch (e, stack) {
        yield (SingleProfileSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleProfileLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }
  }

  @override
  SingleProfileState fromJson(Map<String, dynamic> json) {
    if (!(state is SingleProfileUninitialized)) {
      return state;
    }
    if (json == null || !json.containsKey('type')) {
      return SingleProfileUninitialized();
    }
    try {
      var type = SingleProfileBlocStateType.valueOf(json['type']);
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
    } catch (e, stack) {
      if (e is Error) {
        crashes.recordError(e, stack);
      } else {
        crashes.recordException(e, stack);
      }
    }

    return SingleProfileUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleProfileState state) {
    return state.toMap();
  }
}
