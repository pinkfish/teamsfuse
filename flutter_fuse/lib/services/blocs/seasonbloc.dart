import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';

abstract class SeasonEvent extends Equatable {}

class _SeasonFirestoreStart extends SeasonEvent {
  _SeasonFirestoreStart();

  @override
  String toString() {
    return '_SeasonFirestoreStart{}';
  }

  @override
  List<Object> get props => [];
}

class _SeasonLoggedOut extends SeasonEvent {
  @override
  List<Object> get props => [];
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
  final AnalyticsSubsystem crashes;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<Iterable<Season>> _seasonSub;

  bool _loadingFirestore = false;

  SeasonBloc({
    @required this.coordinationBloc,
    @required this.crashes,
  }) : super(SeasonUninitialized()) {
    coordinationBloc
        .add(CoordinationEventTrackLoading(toLoad: BlocsToLoad.Season));
    _coordSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;
        add(_SeasonLoggedOut());
      } else if (coordState is CoordinationStateLoadingFirestore) {
        _startLoadingFirestore(coordState);
      }
    });
    if (coordinationBloc.state is CoordinationStateLoadingFirestore) {
      _startLoadingFirestore(coordinationBloc.state);
    }
  }

  void _startLoadingFirestore(CoordinationState state) {
    if (!_loadingFirestore) {
      _loadingFirestore = true;
      add(_SeasonFirestoreStart());
    }
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
  Stream<SeasonState> mapEventToState(SeasonEvent event) async* {
    // Start the firestore loading.
    if (event is _SeasonFirestoreStart) {
      // Do the admin Season loading thing.
      TraceProxy adminTrace =
          coordinationBloc.analytics.newTrace('adminSeasons');
      Stream<Iterable<Season>> initialState =
          coordinationBloc.databaseUpdateModel.getSeasons();
      Completer<Iterable<Season>> seasonData = Completer();
      _seasonSub = initialState.listen((Iterable<Season> data) {
        if (!seasonData.isCompleted) {
          seasonData.complete(data);
          coordinationBloc.loadingTrace?.incrementCounter('seasons');
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
    if (json == null || !json.containsKey('type')) {
      return SeasonUninitialized();
    }

    SeasonBlocStateType type = SeasonBlocStateType.valueOf(json['type']);
    switch (type) {
      case SeasonBlocStateType.Uninitialized:
        return SeasonUninitialized();
      case SeasonBlocStateType.Loaded:
        // Starting, nothing loaded yet.
        TraceProxy seasonsTrace =
            coordinationBloc.analytics.newTrace('SeasonData');
        seasonsTrace.start();
        try {
          var state = SeasonLoaded.fromMap(json);
          seasonsTrace.stop();
          return state;
        } catch (e, stacktrace) {
          if (e is Error) {
            crashes.recordError(e, stacktrace);
          } else {
            crashes.recordException(e, stacktrace);
          }
        }
        return SeasonUninitialized();
      default:
        return SeasonUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(SeasonState state) {
    return state.toMap();
  }
}
