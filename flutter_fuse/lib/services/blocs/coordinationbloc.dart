import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'internal/blocstoload.dart';

///
/// The base state for the bloc.
///
abstract class CoordinationState extends Equatable {
  final BuiltSet<BlocsToLoad> loaded;
  final BuiltSet<BlocsToLoad> toLoad;
  final String uid;

  CoordinationState(
      {@required this.uid, @required this.loaded, @required this.toLoad});

  CoordinationState update(BuiltSet<BlocsToLoad> toLoad);

  @override
  List<Object> get props => [loaded, uid, toLoad];
}

///
/// Yay, we are loading from firestore and yayness.
///
class CoordinationStateLoadingFirestore extends CoordinationState {
  CoordinationStateLoadingFirestore(
      {@required String uid,
      @required BuiltSet<BlocsToLoad> loaded,
      @required BuiltSet<BlocsToLoad> toLoad})
      : super(loaded: loaded, uid: uid, toLoad: toLoad);

  CoordinationState update(BuiltSet<BlocsToLoad> toLoad) {
    return CoordinationStateLoadingFirestore(
        uid: uid, loaded: loaded, toLoad: toLoad);
  }

  @override
  String toString() {
    return 'CoordinationStateLoadingFirestore{loaded: $loaded}';
  }
}

///
/// We are now fully loaded.
///
class CoordinationStateLoaded extends CoordinationState {
  CoordinationState update(BuiltSet<BlocsToLoad> toLoad) {
    return CoordinationStateLoaded(uid: uid, toLoad: toLoad);
  }

  CoordinationStateLoaded(
      {@required String uid, @required BuiltSet<BlocsToLoad> toLoad})
      : super(uid: uid, loaded: BuiltSet(), toLoad: toLoad);
}

///
/// Logged out amd not doing any loading.
///
class CoordinationStateLoggedOut extends CoordinationState {
  CoordinationStateLoggedOut(BuiltSet<BlocsToLoad> newToLoad)
      : super(loaded: BuiltSet(), uid: '', toLoad: newToLoad);

  CoordinationState update(BuiltSet<BlocsToLoad> newToLoad) {
    return CoordinationStateLoggedOut(newToLoad);
  }
}

///
/// Before we have worked out if we are logged in or logged out.
///
class CoordinationStateUninitialized extends CoordinationState {
  CoordinationStateUninitialized(BuiltSet<BlocsToLoad> newToLoad)
      : super(loaded: BuiltSet(), uid: '', toLoad: newToLoad);

  CoordinationState update(BuiltSet<BlocsToLoad> newToLoad) {
    return CoordinationStateUninitialized(newToLoad);
  }
}

///
/// The base event for the bloc.
///
abstract class CoordinationEvent extends Equatable {}

///
/// The blocs dispatch this to sau they have loaded stuff.
///
class CoordinationEventLoadedData extends CoordinationEvent {
  final BlocsToLoad loaded;

  CoordinationEventLoadedData({this.loaded});

  @override
  List<Object> get props => [loaded];
}

///
/// The blocs dispatch this to sau they want to be loaded.
///
class CoordinationEventTrackLoading extends CoordinationEvent {
  final BlocsToLoad toLoad;

  CoordinationEventTrackLoading({this.toLoad});

  @override
  List<Object> get props => [toLoad];
}

///
/// called when the system logs out at the auth level.
///
class _CoordintationStateLoggedOut extends CoordinationEvent {
  @override
  List<Object> get props => [];
}

///
/// Starts the whole process by logging in.
///
class _CoordintationStateStart extends CoordinationEvent {
  final String uid;
  _CoordintationStateStart({this.uid});

  @override
  List<Object> get props => [uid];
}

///
/// The bloc that co-ordinates all the loading from the various databases/
///
class CoordinationBloc extends Bloc<CoordinationEvent, CoordinationState> {
  final AuthenticationBloc authenticationBloc;
  final AnalyticsSubsystem analytics;
  final DatabaseUpdateModel databaseUpdateModel;

  TraceProxy loadingTrace;
  DateTime start;

  CoordinationBloc(
      {@required this.authenticationBloc,
      @required this.analytics,
      @required this.databaseUpdateModel})
      : super(CoordinationStateUninitialized(BuiltSet())) {
    authenticationBloc.listen((AuthenticationState authState) {
      if (authState is AuthenticationLoggedIn) {
        loadingTrace = analytics.newTrace('fullLoadTrace');
        start = clock.now();
        assert(authState.user.uid != null);
        add(_CoordintationStateStart(uid: authState.user.uid));
      } else {
        add(_CoordintationStateLoggedOut());
      }
    });
  }

  @override
  Stream<CoordinationState> mapEventToState(CoordinationEvent event) async* {
    if (event is _CoordintationStateStart) {
      yield CoordinationStateLoadingFirestore(
          uid: event.uid, toLoad: state.toLoad, loaded: BuiltSet());
    }

    if (event is _CoordintationStateLoggedOut) {
      yield CoordinationStateLoggedOut(state.toLoad);
    }

    if (event is CoordinationEventTrackLoading) {
      BuiltSet<BlocsToLoad> toLoad =
          state.toLoad.rebuild((b) => b..add(event.toLoad));
      yield state.update(toLoad);
    }

    if (event is CoordinationEventLoadedData) {
      // In the sql loading state.
      if (state is CoordinationStateLoadingFirestore) {
        if (!state.loaded.contains(state.loaded)) {
          BuiltSet<BlocsToLoad> loaded =
              state.loaded.rebuild((b) => b..add(event.loaded));
          var loadedLeft = Set.from(state.toLoad);
          loadedLeft.removeAll(loaded);
          if (loaded.containsAll(state.toLoad)) {
            loadingTrace.stop();
            loadingTrace = null;
            yield CoordinationStateLoaded(uid: state.uid, toLoad: state.toLoad);
          } else {
            yield CoordinationStateLoadingFirestore(
                loaded: loaded, uid: state.uid, toLoad: state.toLoad);
          }
        }
      }
    }
  }
}
