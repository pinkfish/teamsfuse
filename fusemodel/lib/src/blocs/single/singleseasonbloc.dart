import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/async_hydrated_bloc/asynchydratedbloc.dart';
import 'package:meta/meta.dart';

import 'data/singleseasonbloc.dart';

abstract class SingleSeasonEvent extends Equatable {}

///
/// Updates the team (writes it out to firebase.
///
class SingleSeasonUpdate extends SingleSeasonEvent {
  final SeasonBuilder season;

  SingleSeasonUpdate({@required this.season});

  @override
  List<Object> get props => [season];
}

///
/// Loads all the invites for this season.
///
class SingleSeasonLoadInvites extends SingleSeasonEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads all the games for this season.
///
class SingleSeasonLoadGames extends SingleSeasonEvent {
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

class _SingleSeasonLoadedInvites extends SingleSeasonEvent {
  final BuiltList<InviteToTeam> invites;

  _SingleSeasonLoadedInvites({this.invites});

  @override
  List<Object> get props => [invites];
}

class _SingleSeasonLoadedGames extends SingleSeasonEvent {
  final BuiltList<Game> games;

  _SingleSeasonLoadedGames({@required this.games});

  @override
  List<Object> get props => [games];
}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleSeasonBloc
    extends AsyncHydratedBloc<SingleSeasonEvent, SingleSeasonState> {
  final DatabaseUpdateModel db;
  final String seasonUid;

  StreamSubscription<Season> _seasonSub;
  StreamSubscription<Iterable<InviteToTeam>> _inviteSub;
  StreamSubscription<GameSnapshotEvent> _gameSub;

  // Create the bloc and do exciting things with it.
  SingleSeasonBloc({@required this.db, @required this.seasonUid})
      : super(SingleSeasonUninitialized(), seasonUid) {
    _seasonSub = db.getSingleSeason(seasonUid).listen((season) {
      if (season != null) {
        // Only send this if the team is not the same.
        if (season != state.season) {
          add(_SingleNewTeamSeason(newSeason: season));
        }
      } else {
        print('SingleSeasonBLoc: lost $seasonUid}');
        add(_SingleSeasonDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _seasonSub?.cancel();
    _seasonSub = null;
    _inviteSub?.cancel();
    _inviteSub = null;
    _gameSub?.cancel();
    _gameSub = null;
  }

  @override
  SingleSeasonState get initialState {}

  @override
  Stream<SingleSeasonState> mapEventToState(SingleSeasonEvent event) async* {
    if (event is _SingleNewTeamSeason) {
      yield (SingleSeasonLoaded.fromState(state)
            ..season = event.newSeason.toBuilder())
          .build();
    }

    // The team is deleted.
    if (event is _SingleSeasonDeleted) {
      yield SingleSeasonDeleted();
    }

    // Save the team.
    if (event is SingleSeasonUpdate) {
      yield SingleSeasonSaving.fromState(state).build();
      try {
        await db.updateFirestoreSeason(event.season.build(), false);
        yield SingleSeasonSaveDone.fromState(state).build();
        yield (SingleSeasonLoaded.fromState(state)..season = event.season)
            .build();
      } catch (e) {
        yield (SingleSeasonSaveFailed.fromState(state)..error = e).build();
      }
    }

    if (event is SingleSeasonLoadInvites) {
      if (_inviteSub == null) {
        _inviteSub = db
            .getInviteForSeasonStream(
                seasonUid: seasonUid, teamUid: state.season.teamUid)
            .listen((Iterable<InviteToTeam> invites) {
          add(_SingleSeasonLoadedInvites(invites: invites));
        });
      }
    }

    if (event is SingleSeasonLoadGames) {
      print('Loading games');
      if (_gameSub == null) {
        _gameSub =
            db.getSeasonGames(state.season).listen((GameSnapshotEvent games) {
          add(_SingleSeasonLoadedGames(games: BuiltList.of(games.newGames)));
        });
      }
    }

    if (event is _SingleSeasonLoadedGames) {
      print('Loaded games');
      yield (SingleSeasonLoaded.fromState(state)
            ..games = event.games.toBuilder()
            ..loadedGames = true)
          .build();
    }

    if (event is _SingleSeasonLoadedInvites) {
      yield (SingleSeasonLoaded.fromState(state)
            ..invites = event.invites.toBuilder()
            ..loadedInvites = true)
          .build();
    }
  }

  @override
  SingleSeasonState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return SingleSeasonUninitialized();
    }

    SingleSeasonBlocStateType type =
        SingleSeasonBlocStateType.valueOf(json["type"]);
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
  }

  @override
  Map<String, dynamic> toJson(SingleSeasonState state) {
    return state.toMap();
  }
}
