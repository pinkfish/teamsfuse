import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'authenticationbloc.dart';
import 'internal/blocstoload.dart';

///
/// The base state for the bloc.
///
abstract class CoordinationState extends Equatable {
  final BuiltSet<BlocsToLoad> loaded;
  final String uid;

  CoordinationState({@required this.uid, @required this.loaded})
      : super([loaded, uid]);
}

///
/// Start loading the bits from sql.
///
class CoordinationStateStartLoadingSql extends CoordinationState {
  CoordinationStateStartLoadingSql({@required String uid})
      : super(loaded: BuiltSet<BlocsToLoad>(), uid: uid);
}

///
/// Yay, we are loading from sql and having fun.
///
class CoordinatiomnStateLoadingSql extends CoordinationState {
  CoordinatiomnStateLoadingSql(
      {@required String uid, BuiltSet<BlocsToLoad> loaded})
      : super(loaded: loaded, uid: uid);

  @override
  String toString() {
    return 'CoordinatiomnStateLoadingSql{loaded: $loaded}';
  }
}

///
/// Now we are off to load from firestore.
///
class CoordinationStateStartLoadingFirestore extends CoordinationState {
  CoordinationStateStartLoadingFirestore({@required String uid})
      : super(loaded: BuiltSet(), uid: uid);

  @override
  String toString() {
    return 'CoordinationStateStartLoadingFirestore{loaded: $loaded}';
  }
}

///
/// Yay, we are loading from firestore and yayness.
///
class CoordinationStateLoadingFirestore extends CoordinationState {
  CoordinationStateLoadingFirestore(
      {@required String uid, BuiltSet<BlocsToLoad> loaded})
      : super(loaded: loaded, uid: uid);

  @override
  String toString() {
    return 'CoordinationStateLoadingFirestore{loaded: $loaded}';
  }
}

///
/// We are now fully loaded.
///
class CoordinationStateLoaded extends CoordinationState {
  CoordinationStateLoaded({@required String uid})
      : super(uid: uid, loaded: BuiltSet.from(BlocsToLoad.values));
}

///
/// Logged out amd not doing any loading.
///
class CoordinationStateLoggedOut extends CoordinationState {
  CoordinationStateLoggedOut() : super(loaded: BuiltSet(), uid: '');
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
  final bool sql;

  CoordinationEventLoadedData({this.loaded, this.sql});
}

///
/// called when the system logs out at the auth level.
///
class _CoordintationStateLoggedOut extends CoordinationEvent {}

///
/// Starts the whole process by logging in.
///
class _CoordintationStateStart extends CoordinationEvent {
  final String uid;
  _CoordintationStateStart({this.uid});
}

///
/// The bloc that co-ordinates all the loading from the various databases/
///
class CoordinationBloc extends Bloc<CoordinationEvent, CoordinationState> {
  final AuthenticationBloc authenticationBloc;
  final AnalyticsSubsystem analytics;
  final PersistenData persistentData;
  final DatabaseUpdateModel databaseUpdateModel;
  final AnalyticsSubsystem analyticsSubsystem;

  TraceProxy loadingTrace;
  TraceProxy sqlTrace;
  DateTime start;

  CoordinationBloc(
      {@required this.persistentData,
      @required this.authenticationBloc,
      @required this.analytics,
      @required this.databaseUpdateModel,
      @required this.analyticsSubsystem}) {
    authenticationBloc.state.listen((AuthenticationState state) {
      if (state is AuthenticationLoggedIn) {
        sqlTrace = analytics.newTrace("sqlTrace");
        loadingTrace = analytics.newTrace("fullLoadTrace");
        start = DateTime.now();
        assert(state.user.uid != null);
        dispatch(_CoordintationStateStart(uid: state.user.uid));
      } else {
        dispatch(_CoordintationStateLoggedOut());
      }
    });
  }

  @override
  CoordinationState get initialState {
    return CoordinationStateLoggedOut();
  }

  @override
  Stream<CoordinationState> mapEventToState(CoordinationEvent event) async* {
    if (event is _CoordintationStateStart) {
      yield CoordinationStateStartLoadingSql(uid: event.uid);
    }

    if (event is _CoordintationStateLoggedOut) {
      yield CoordinationStateLoggedOut();
    }

    if (event is CoordinationEventLoadedData) {
      // In the sql loading state.
      if (currentState is CoordinationStateStartLoadingSql ||
          currentState is CoordinatiomnStateLoadingSql) {
        BuiltSet<BlocsToLoad> loaded =
            currentState.loaded.rebuild((b) => b..add(event.loaded));
        print("Update loaded ${event.loaded} $loaded");
        if (loaded.length == BlocsToLoad.values.length) {
          // Close the sql trace part.
          sqlTrace.stop();
          sqlTrace = null;
          yield CoordinationStateStartLoadingFirestore(uid: currentState.uid);
        } else {
          yield CoordinatiomnStateLoadingSql(
              loaded: BuiltSet.from(loaded), uid: currentState.uid);
        }
      }
      if (currentState is CoordinationStateStartLoadingFirestore ||
          currentState is CoordinationStateLoadingFirestore) {
        if (!currentState.loaded.contains(currentState.loaded)) {
          BuiltSet<BlocsToLoad> loaded =
              currentState.loaded.rebuild((b) => b..add(event.loaded));
          if (loaded.length == BlocsToLoad.values.length) {
            loadingTrace.stop();
            loadingTrace = null;
            yield CoordinationStateLoaded(uid: currentState.uid);
          } else {
            yield CoordinationStateLoadingFirestore(
                loaded: loaded, uid: currentState.uid);
          }
        }
      }
    }
  }
}
