import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../seasonbloc.dart';

///
/// The basic state for all the bits of the single team bloc.
///
abstract class SingleSeasonState extends Equatable {
  final Season season;
  final BuiltList<InviteToTeam> invites;
  final BuiltList<Game> games;
  final bool loadedInvites;
  final bool loadedGames;

  SingleSeasonState(
      {@required this.season,
      @required this.invites,
      this.games,
      this.loadedGames,
      this.loadedInvites})
      : super([season, invites, games, loadedGames, loadedInvites]);
}

///
/// We have a team, default state.
///
class SingleSeasonLoaded extends SingleSeasonState {
  SingleSeasonLoaded(
      {@required SingleSeasonState state,
      @required Season season,
      @required BuiltList<InviteToTeam> invites,
      @required BuiltList<Game> games,
      bool loadedInvites,
      bool loadedGames})
      : super(
            season: season ?? state.season,
            invites: invites ?? state.invites,
            games: games ?? state.games,
            loadedInvites: loadedInvites ?? false,
            loadedGames: loadedGames ?? false);

  @override
  String toString() {
    return 'SingleSeasonLoaded{season: ${season.name}, team: ${season.teamUid}, games: ${games.length}, invites: ${invites.length}, loadedGames: $loadedGames, loadedInvites: $loadedInvites}';
  }
}

///
/// Saving operation in progress.
///
class SingleSeasonSaving extends SingleSeasonState {
  SingleSeasonSaving({@required SingleSeasonState state})
      : super(
            season: state.season,
            invites: state.invites,
            loadedGames: state.loadedGames,
            loadedInvites: state.loadedInvites,
            games: state.games);

  @override
  String toString() {
    return 'SingleSeasonSaving{season: $season}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleSeasonSaveFailed extends SingleSeasonState {
  final Error error;

  SingleSeasonSaveFailed({@required SingleSeasonState state, this.error})
      : super(
            season: state.season,
            invites: state.invites,
            loadedInvites: state.loadedInvites,
            loadedGames: state.loadedGames,
            games: state.games);

  @override
  String toString() {
    return 'SingleSeasonSaveFailed{season: $season}';
  }
}

///
/// Team got deleted.
///
class SingleSeasonDeleted extends SingleSeasonState {
  SingleSeasonDeleted()
      : super(
            season: null,
            invites: BuiltList(),
            games: BuiltList(),
            loadedGames: false,
            loadedInvites: false);

  @override
  String toString() {
    return 'SingleSeasonDeleted{season: $season}';
  }
}

abstract class SingleSeasonEvent extends Equatable {}

///
/// Updates the team (writes it out to firebase.
///
class SingleSeasonUpdate extends SingleSeasonEvent {
  final SeasonBuilder season;

  SingleSeasonUpdate({@required this.season});
}

///
/// Loads all the invites for this season.
///
class SingleSeasonLoadInvites extends SingleSeasonEvent {}

///
/// Loads all the games for this season.
///
class SingleSeasonLoadGames extends SingleSeasonEvent {}

class _SingleNewTeamSeason extends SingleSeasonEvent {
  final Season newSeason;

  _SingleNewTeamSeason({@required this.newSeason});
}

class _SingleSeasonDeleted extends SingleSeasonEvent {
  _SingleSeasonDeleted();
}

class _SingleSeasonLoadedInvites extends SingleSeasonEvent {
  final Iterable<InviteToTeam> invites;

  _SingleSeasonLoadedInvites({this.invites});
}

class _SingleSeasonLoadedGames extends SingleSeasonEvent {
  final BuiltList<Game> games;

  _SingleSeasonLoadedGames({@required this.games});
}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleSeasonBloc extends Bloc<SingleSeasonEvent, SingleSeasonState> {
  final SeasonBloc seasonBloc;
  final String seasonUid;

  StreamSubscription<SeasonState> _seasonSub;
  StreamSubscription<Iterable<InviteToTeam>> _inviteSub;
  StreamSubscription<GameSnapshotEvent> _gameSub;

  // Create the bloc and do exciting things with it.
  SingleSeasonBloc({this.seasonBloc, this.seasonUid}) {
    _seasonSub = seasonBloc.state.listen((SeasonState state) {
      if (state.seasons.containsKey(seasonUid)) {
        Season season = state.seasons[seasonUid];

        // Only send this if the team is not the same.
        if (season != currentState.season) {
          dispatch(_SingleNewTeamSeason(newSeason: season));
        }
      } else {
        dispatch(_SingleSeasonDeleted());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _seasonSub?.cancel();
    _seasonSub = null;
    _inviteSub?.cancel();
    _inviteSub = null;
    _gameSub?.cancel();
    _gameSub = null;
  }

  @override
  SingleSeasonState get initialState {
    if (seasonBloc.currentState.seasons.containsKey(seasonUid)) {
      return SingleSeasonLoaded(
          season: seasonBloc.currentState.seasons[seasonUid],
          loadedGames: false,
          loadedInvites: false,
          games: BuiltList(),
          invites: BuiltList());
    } else {
      return SingleSeasonDeleted();
    }
  }

  @override
  Stream<SingleSeasonState> mapEventToState(SingleSeasonEvent event) async* {
    if (event is _SingleNewTeamSeason) {
      yield SingleSeasonLoaded(season: event.newSeason, state: currentState);
    }

    // The team is deleted.
    if (event is _SingleSeasonDeleted) {
      yield SingleSeasonDeleted();
    }

    // Save the team.
    if (event is SingleSeasonUpdate) {
      yield SingleSeasonSaving(state: currentState);
      try {
        await seasonBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreSeason(event.season.build(), false);
        yield SingleSeasonLoaded(
            season: event.season.build(), state: currentState);
      } catch (e) {
        yield SingleSeasonSaveFailed(state: currentState, error: e);
      }
    }

    if (event is SingleSeasonLoadInvites) {
      if (_inviteSub == null) {
        _inviteSub = seasonBloc.coordinationBloc.databaseUpdateModel
            .getInviteForSeasonStream(
                userUid: seasonBloc
                    .coordinationBloc.authenticationBloc.currentUser.uid,
                seasonUid: seasonUid,
                teamUid: currentState.season.teamUid)
            .listen((Iterable<InviteToTeam> invites) {
          dispatch(_SingleSeasonLoadedInvites(invites: invites));
        });
      }
    }

    if (event is SingleSeasonLoadGames) {
      print('Loading games');
      if (_gameSub == null) {
        _gameSub = seasonBloc.coordinationBloc.databaseUpdateModel
            .getSeasonGames(currentState.season)
            .listen((GameSnapshotEvent games) {
          dispatch(
              _SingleSeasonLoadedGames(games: BuiltList.of(games.newGames)));
        });
      }
    }

    if (event is _SingleSeasonLoadedGames) {
      print('Loaded games');
      yield SingleSeasonLoaded(
          state: currentState, games: event.games, loadedGames: true);
    }

    if (event is _SingleSeasonLoadedInvites) {
      yield SingleSeasonLoaded(
          invites: BuiltList.from(event.invites),
          state: currentState,
          loadedInvites: true);
    }
  }
}
