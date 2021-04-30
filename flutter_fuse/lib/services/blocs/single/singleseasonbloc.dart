import 'dart:async';
import 'dart:isolate';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';
import '../seasonbloc.dart';

abstract class SingleSeasonEvent extends Equatable {}

///
/// Updates the team (writes it out to firebase.
///
class SingleSeasonUpdate extends SingleSeasonEvent {
  final Season season;

  SingleSeasonUpdate({@required this.season});

  @override
  List<Object> get props => [season];
}

///
/// Loads all the games for this season.
///
class SingleSeasonLoadGames extends SingleSeasonEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads all the media for this season.
///
class SingleSeasonLoadMedia extends SingleSeasonEvent {
  @override
  List<Object> get props => [];
}

class _SingleNewTeamSeason extends SingleSeasonEvent {
  final Season newSeason;

  _SingleNewTeamSeason({@required this.newSeason});

  @override
  List<Object> get props => [newSeason];
}

class _SingleSeasonDeleted extends SingleSeasonEvent {
  _SingleSeasonDeleted();

  @override
  List<Object> get props => [];
}

class _SingleSeasonLoadedGames extends SingleSeasonEvent {
  final BuiltList<Game> games;

  _SingleSeasonLoadedGames({@required this.games});

  @override
  List<Object> get props => [games];
}

class _SingleSeasonLoadedMedia extends SingleSeasonEvent {
  final BuiltList<MediaInfo> media;

  _SingleSeasonLoadedMedia({@required this.media});

  @override
  List<Object> get props => [media];
}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleSeasonBloc
    extends AsyncHydratedBloc<SingleSeasonEvent, SingleSeasonState> {
  final DatabaseUpdateModel db;
  final String seasonUid;
  final AnalyticsSubsystem crashes;
  bool _willLoadGames = false;

  StreamSubscription<Season> _seasonSub;
  StreamSubscription<BuiltList<Game>> _gameSub;
  StreamSubscription<BuiltList<MediaInfo>> _mediaSub;

  // Create the bloc and do exciting things with it.
  SingleSeasonBloc(
      {@required this.db,
      @required this.seasonUid,
      @required this.crashes,
      SeasonBloc seasonBloc})
      : super(_getInitialState(seasonUid, seasonBloc), seasonUid) {
    assert(seasonUid != null && seasonUid.isNotEmpty);
    _seasonSub = db.getSingleSeason(seasonUid).listen((season) {
      if (season != null) {
        // Only send this if the team is not the same.
        if (season != state.season) {
          add(_SingleNewTeamSeason(newSeason: season));
        }
      } else {
        add(_SingleSeasonDeleted());
      }
    });
    _seasonSub.onError((e, stack) {
      add(_SingleSeasonDeleted());
      crashes.recordException(e, stack);
    });
  }

  static SingleSeasonState _getInitialState(String uid, SeasonBloc seasonBloc) {
    final season = seasonBloc?.getSeason(uid);
    if (season == null) {
      return SingleSeasonUninitialized();
    }
    return SingleSeasonLoaded((b) => b..season = season.toBuilder());
  }

  @override
  Future<void> close() async {
    await super.close();
    await _seasonSub?.cancel();
    _seasonSub = null;
    await _gameSub?.cancel();
    _gameSub = null;
  }

  @override
  Stream<SingleSeasonState> mapEventToState(SingleSeasonEvent event) async* {
    if (event is _SingleNewTeamSeason) {
      yield (SingleSeasonLoaded.fromState(state)
            ..season = event.newSeason.toBuilder())
          .build();
      if (_willLoadGames) {
        _willLoadGames = false;
        add(SingleSeasonLoadGames());
      }
    }

    // The team is deleted.
    if (event is _SingleSeasonDeleted) {
      yield SingleSeasonDeleted();
    }

    // Save the team.
    if (event is SingleSeasonUpdate) {
      yield SingleSeasonSaving.fromState(state).build();
      try {
        await db.updateFirestoreSeason(event.season, false);
        yield SingleSeasonSaveDone.fromState(state).build();
        yield (SingleSeasonLoaded.fromState(state)
              ..season = event.season.toBuilder())
            .build();
      } catch (e, stack) {
        yield (SingleSeasonSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleSeasonLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleSeasonLoadGames) {
      if (state is SingleSeasonUninitialized) {
        _willLoadGames = true;
      } else {
        if (_gameSub == null) {
          _gameSub = db.getSeasonGames(state.season).listen((games) {
            add(_SingleSeasonLoadedGames(games: games));
          });
          _gameSub.onError(crashes.recordException);
        }
      }
    }

    if (event is SingleSeasonLoadMedia) {
      if (_mediaSub == null) {
        _mediaSub =
            db.getMediaForSeason(seasonUid: state.season.uid).listen((media) {
          add(_SingleSeasonLoadedMedia(media: media));
        });
        _gameSub.onError(crashes.recordException);
      }
    }

    if (event is _SingleSeasonLoadedMedia) {
      yield (SingleSeasonLoaded.fromState(state)
            ..media = event.media.toBuilder()
            ..loadedMedia = true)
          .build();
    }

    if (event is _SingleSeasonLoadedGames) {
      yield (SingleSeasonLoaded.fromState(state)
            ..games = event.games.toBuilder()
            ..loadedGames = true)
          .build();
    }
  }

  @override
  SingleSeasonState fromJson(Map<String, dynamic> json) {
    if (!(state is SingleSeasonUninitialized)) {
      return state;
    }

    if (json == null || !json.containsKey('type')) {
      return state;
    }

    try {
      var type = SingleSeasonBlocStateType.valueOf(json['type']);
      switch (type) {
        case SingleSeasonBlocStateType.Uninitialized:
          return SingleSeasonUninitialized();
        case SingleSeasonBlocStateType.Loaded:
          return SingleSeasonLoaded.fromMap(json);
        case SingleSeasonBlocStateType.Deleted:
          return SingleSeasonDeleted.fromMap(json);
        case SingleSeasonBlocStateType.SaveFailed:
          return SingleSeasonSaveFailed.fromMap(json);
        case SingleSeasonBlocStateType.Saving:
          return SingleSeasonSaving.fromMap(json);
        case SingleSeasonBlocStateType.SaveDone:
          return SingleSeasonSaveDone.fromMap(json);
      }
    } catch (e, stack) {
      if (e is Error) {
        crashes.recordError(e, stack);
      } else {
        crashes.recordException(e, stack);
      }
    }

    return SingleSeasonUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleSeasonState state) {
    return state.toMap();
  }
}
