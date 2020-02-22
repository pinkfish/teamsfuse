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
      this.loadedInvites});

  @override
  List<Object> get props =>
      [season, invites, games, loadedGames, loadedInvites];
}

///
/// We have a team, default state.
///
class SingleSeasonLoaded extends SingleSeasonState {
  SingleSeasonLoaded(
      {@required SingleSeasonState state,
      Season season,
      BuiltList<InviteToTeam> invites,
      BuiltList<Game> games,
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
  final Iterable<InviteToTeam> invites;

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
class SingleSeasonBloc extends Bloc<SingleSeasonEvent, SingleSeasonState> {
  final SeasonBloc seasonBloc;
  final String seasonUid;

  StreamSubscription<SeasonState> _seasonSub;
  StreamSubscription<Iterable<InviteToTeam>> _inviteSub;
  StreamSubscription<GameSnapshotEvent> _gameSub;

  // Create the bloc and do exciting things with it.
  SingleSeasonBloc({this.seasonBloc, this.seasonUid}) {
    _seasonSub = seasonBloc.listen((SeasonState seasonState) {
      if (seasonState.seasons.containsKey(seasonUid)) {
        Season season = seasonState.seasons[seasonUid];

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
  SingleSeasonState get initialState {
    if (seasonBloc.state.seasons.containsKey(seasonUid)) {
      print('SingleSeasonBLoc: found $seasonUid}');
      return SingleSeasonLoaded(
          season: seasonBloc.state.seasons[seasonUid],
          loadedGames: false,
          loadedInvites: false,
          games: BuiltList(),
          state: null,
          invites: BuiltList());
    } else {
      print('SingleSeasonBLoc: deleted $seasonUid ${seasonBloc.state.seasons}');
      return SingleSeasonDeleted();
    }
  }

  @override
  Stream<SingleSeasonState> mapEventToState(SingleSeasonEvent event) async* {
    if (event is _SingleNewTeamSeason) {
      yield SingleSeasonLoaded(season: event.newSeason, state: state);
    }

    // The team is deleted.
    if (event is _SingleSeasonDeleted) {
      yield SingleSeasonDeleted();
    }

    // Save the team.
    if (event is SingleSeasonUpdate) {
      yield SingleSeasonSaving(state: state);
      try {
        await seasonBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreSeason(event.season.build(), false);
        yield SingleSeasonLoaded(season: event.season.build(), state: state);
      } catch (e) {
        yield SingleSeasonSaveFailed(state: state, error: e);
      }
    }

    if (event is SingleSeasonLoadInvites) {
      if (_inviteSub == null) {
        _inviteSub = seasonBloc.coordinationBloc.databaseUpdateModel
            .getInviteForSeasonStream(
                userUid: seasonBloc
                    .coordinationBloc.authenticationBloc.currentUser.uid,
                seasonUid: seasonUid,
                teamUid: state.season.teamUid)
            .listen((Iterable<InviteToTeam> invites) {
          add(_SingleSeasonLoadedInvites(invites: invites));
        });
      }
    }

    if (event is SingleSeasonLoadGames) {
      print('Loading games');
      if (_gameSub == null) {
        _gameSub = seasonBloc.coordinationBloc.databaseUpdateModel
            .getSeasonGames(state.season)
            .listen((GameSnapshotEvent games) {
          add(_SingleSeasonLoadedGames(games: BuiltList.of(games.newGames)));
        });
      }
    }

    if (event is _SingleSeasonLoadedGames) {
      print('Loaded games');
      yield SingleSeasonLoaded(
          state: state, games: event.games, loadedGames: true);
    }

    if (event is _SingleSeasonLoadedInvites) {
      yield SingleSeasonLoaded(
          invites: BuiltList.from(event.invites),
          state: state,
          loadedInvites: true);
    }
  }
}
