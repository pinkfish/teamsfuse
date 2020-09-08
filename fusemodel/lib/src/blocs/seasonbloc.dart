import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'data/seasonblocstate.dart';
import 'internal/blocstoload.dart';

abstract class SeasonEvent extends Equatable {}

class _SeasonUserLoaded extends SeasonEvent {
  final String uid;

  _SeasonUserLoaded({@required this.uid});

  @override
  String toString() {
    return '_SeasonUserLoaded{}';
  }

  @override
  List<Object> get props => [uid];
}

class _SeasonFirestoreStart extends SeasonEvent {
  final String uid;

  _SeasonFirestoreStart({@required this.uid});

  @override
  String toString() {
    return '_SeasonFirestoreStart{}';
  }

  @override
  List<Object> get props => [uid];
}

class _SeasonLoggedOut extends SeasonEvent {
  @override
  List<Object> get props => [];
}

class _SeasonAdminUpdated extends SeasonEvent {
  final Map<String, Season> adminSeasons;

  _SeasonAdminUpdated({@required this.adminSeasons});

  @override
  List<Object> get props => [adminSeasons];
}

class _SeasonUpdate extends SeasonEvent {
  final BuiltMap<String, Season> newSeasons;

  _SeasonUpdate({@required this.newSeasons});

  @override
  List<Object> get props => [newSeasons];
}

///
/// Season bloc handles the Seasons flow.  Loading all the Seasons from
/// firestore.
///
class SeasonBloc extends HydratedBloc<SeasonEvent, SeasonState> {
  final CoordinationBloc coordinationBloc;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<Iterable<Season>> _seasonSub;

  bool _loadingFirestore = false;

  SeasonBloc({@required this.coordinationBloc}) : super(SeasonUninitialized()) {
    _coordSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;
        add(_SeasonLoggedOut());
      } else if (coordState is CoordinationStateLoadingFirestore) {
        if (!_loadingFirestore) {
          _loadingFirestore = true;
          _startLoadingFirestore(coordState);
        }
      }
    });
  }

  void _startLoading(CoordinationState state) {
    add(_SeasonUserLoaded(uid: state.uid));
  }

  void _startLoadingFirestore(CoordinationState state) {
    add(_SeasonFirestoreStart(uid: state.uid));
  }

  void _cleanupSnaps() {
    _seasonSub?.cancel();
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanupSnaps();
    _coordSub?.cancel();
  }

  @override
  void onClubUpdated(FirestoreWrappedData data) {}

  @override
  Stream<SeasonState> mapEventToState(SeasonEvent event) async* {
    // Start the firestore loading.
    if (event is _SeasonFirestoreStart) {
      // Do the admin Season loading thing.
      TraceProxy adminTrace =
          coordinationBloc.analytics.newTrace('adminSeasons');
      Stream<Iterable<Season>> initialState =
          coordinationBloc.databaseUpdateModel.getSeasons(event.uid);
      Completer<Iterable<Season>> seasonData = Completer();
      _seasonSub = initialState.listen((Iterable<Season> data) {
        if (!seasonData.isCompleted) {
          seasonData.complete(data);
        }
        if (!state.loadedFirestore) {
          coordinationBloc.loadingTrace?.incrementCounter("seasons");
          coordinationBloc
              .add(CoordinationEventLoadedData(loaded: BlocsToLoad.Season));
          adminTrace.stop();
        }
        add(_SeasonUpdate(
            newSeasons: BuiltMap.from(
                Map.fromIterable(data, key: (t) => t.uid, value: (t) => t))));
      });
    }

    // Unload everything.
    if (event is _SeasonLoggedOut) {
      yield SeasonUninitialized();
      _cleanupSnaps();
    }

    // Update just the seasons.
    if (event is _SeasonUpdate) {
      yield (SeasonLoaded.fromState(state)
            ..seasons = event.newSeasons.toBuilder()
            ..loadedFirestore = true)
          .build();
      coordinationBloc
          .add(CoordinationEventLoadedData(loaded: BlocsToLoad.Season));
    }
  }

  @override
  SeasonState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return SeasonUninitialized();
    }

    SeasonBlocStateType type = SeasonBlocStateType.valueOf(json["type"]);
    switch (type) {
      case SeasonBlocStateType.Uninitialized:
        return SeasonUninitialized();
      case SeasonBlocStateType.Loaded:
        // Starting, nothing loaded yet.
        TraceProxy SeasonsTrace =
            coordinationBloc.analyticsSubsystem.newTrace("SeasonData");
        SeasonsTrace.start();
        var loaded = SeasonLoaded.fromMap(json);
        print(
            'Start Seasons ${coordinationBloc.start.difference(new DateTime.now())}');
        SeasonsTrace.stop();
        return loaded;
      default:
        return SeasonUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(SeasonState state) {
    return state.toMap();
  }
}
