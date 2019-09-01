import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../teambloc.dart';

///
/// The basic state for all the bits of the single team bloc.
///
abstract class SingleTeamSeasonState extends Equatable {
  final Season season;
  final BuiltList<InviteToTeam> invites;
  final BuiltList<Game> games;
  final bool loadedInvites;
  final bool loadedGames;

  SingleTeamSeasonState(
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
class SingleTeamSeasonLoaded extends SingleTeamSeasonState {
  SingleTeamSeasonLoaded(
      {@required SingleTeamSeasonState state,
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
    return 'SingleTeamSeasonLoaded{season: ${season.name}, team: ${season.teamUid}, games: ${games.length}, invites: ${invites.length}, loadedGames: $loadedGames, loadedInvites: $loadedInvites}';
  }
}

///
/// Saving operation in progress.
///
class SingleTeamSeasonSaving extends SingleTeamSeasonState {
  SingleTeamSeasonSaving({@required SingleTeamSeasonState state})
      : super(
            season: state.season,
            invites: state.invites,
            loadedGames: state.loadedGames,
            loadedInvites: state.loadedInvites,
            games: state.games);

  @override
  String toString() {
    return 'SingleTeamSeasonSaving{season: $season}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleTeamSeasonSaveFailed extends SingleTeamSeasonState {
  final Error error;

  SingleTeamSeasonSaveFailed(
      {@required SingleTeamSeasonState state, this.error})
      : super(
            season: state.season,
            invites: state.invites,
            loadedInvites: state.loadedInvites,
            loadedGames: state.loadedGames,
            games: state.games);

  @override
  String toString() {
    return 'SingleTeamSeasonSaveFailed{season: $season}';
  }
}

///
/// Team got deleted.
///
class SingleTeamSeasonDeleted extends SingleTeamSeasonState {
  SingleTeamSeasonDeleted()
      : super(
            season: null,
            invites: BuiltList(),
            games: BuiltList(),
            loadedGames: false,
            loadedInvites: false);

  @override
  String toString() {
    return 'SingleTeamSeasonDeleted{season: $season}';
  }
}

abstract class SingleTeamSeasonEvent extends Equatable {}

///
/// Updates the team (writes it out to firebase.
///
class SingleTeamSeasonUpdate extends SingleTeamSeasonEvent {
  final SeasonBuilder season;

  SingleTeamSeasonUpdate({@required this.season});
}

///
/// Loads all the invites for this season.
///
class SingleTeamSeasonLoadInvites extends SingleTeamSeasonEvent {}

///
/// Loads all the games for this season.
///
class SingleTeamSeasonLoadGames extends SingleTeamSeasonEvent {}

class _SingleTeamNewTeamSeason extends SingleTeamSeasonEvent {
  final Season newSeason;

  _SingleTeamNewTeamSeason({@required this.newSeason});
}

class _SingleTeamSeasonDeleted extends SingleTeamSeasonEvent {
  _SingleTeamSeasonDeleted();
}

class _SingleTeamSeasonLoadedInvites extends SingleTeamSeasonEvent {
  final Iterable<InviteToTeam> invites;

  _SingleTeamSeasonLoadedInvites({this.invites});
}

class _SingleTeamSeasonLoadedGames extends SingleTeamSeasonEvent {
  final BuiltList<Game> games;

  _SingleTeamSeasonLoadedGames({@required this.games});
}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleTeamSeasonBloc
    extends Bloc<SingleTeamSeasonEvent, SingleTeamSeasonState> {
  final TeamBloc teamBloc;
  final String teamUid;
  final String seasonUid;

  StreamSubscription<TeamState> _teamSub;
  StreamSubscription<Iterable<InviteToTeam>> _inviteSub;
  StreamSubscription<GameSnapshotEvent> _gameSub;

  SingleTeamSeasonBloc({this.teamBloc, this.teamUid, this.seasonUid}) {
    _teamSub = teamBloc.state.listen((TeamState state) {
      Team team = state.getTeam(teamUid);
      if (team != null && team.seasons.containsKey(seasonUid)) {
        Season season = team.seasons[seasonUid];

        // Only send this if the team is not the same.
        if (season != currentState.season) {
          dispatch(_SingleTeamNewTeamSeason(newSeason: season));
        }
      } else {
        dispatch(_SingleTeamSeasonDeleted());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _teamSub?.cancel();
    _teamSub = null;
    _inviteSub?.cancel();
    _inviteSub = null;
    _gameSub?.cancel();
    _gameSub = null;
  }

  @override
  SingleTeamSeasonState get initialState {
    Team t = teamBloc.currentState.getTeam(teamUid);
    if (t != null && t.seasons.containsKey(seasonUid)) {
      return SingleTeamSeasonLoaded(
          season: t.seasons[seasonUid],
          loadedGames: false,
          loadedInvites: false,
          games: BuiltList(),
          invites: BuiltList());
    } else {
      return SingleTeamSeasonDeleted();
    }
  }

  @override
  Stream<SingleTeamSeasonState> mapEventToState(
      SingleTeamSeasonEvent event) async* {
    if (event is _SingleTeamNewTeamSeason) {
      yield SingleTeamSeasonLoaded(
          season: event.newSeason, state: currentState);
    }

    // The team is deleted.
    if (event is _SingleTeamSeasonDeleted) {
      yield SingleTeamSeasonDeleted();
    }

    // Save the team.
    if (event is SingleTeamSeasonUpdate) {
      yield SingleTeamSeasonSaving(state: currentState);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreSeason(event.season.build(), false);
        yield SingleTeamSeasonLoaded(
            season: event.season.build(), state: currentState);
      } catch (e) {
        yield SingleTeamSeasonSaveFailed(state: currentState, error: e);
      }
    }

    if (event is SingleTeamSeasonLoadInvites) {
      if (_inviteSub == null) {
        _inviteSub = teamBloc.coordinationBloc.databaseUpdateModel
            .getInviteForSeasonStream(
                userUid: teamBloc
                    .coordinationBloc.authenticationBloc.currentUser.uid,
                seasonUid: seasonUid,
                teamUid: teamUid)
            .listen((Iterable<InviteToTeam> invites) {
          dispatch(_SingleTeamSeasonLoadedInvites(invites: invites));
        });
      }
    }

    if (event is SingleTeamSeasonLoadGames) {
      print('Loading games');
      if (_gameSub == null) {
        _gameSub = teamBloc.coordinationBloc.databaseUpdateModel
            .getSeasonGames(currentState.season)
            .listen((GameSnapshotEvent games) {
          switch (games.type) {
            case GameSnapshotEventType.SharedGameUpdate:
              break;
            case GameSnapshotEventType.GameList:
              dispatch(_SingleTeamSeasonLoadedGames(
                  games: BuiltList.of(games.newGames)));
              break;
          }
        });
      }
    }

    if (event is _SingleTeamSeasonLoadedGames) {
      print('Loaded games');
      yield SingleTeamSeasonLoaded(
          state: currentState, games: event.games, loadedGames: true);
    }

    if (event is _SingleTeamSeasonLoadedInvites) {
      yield SingleTeamSeasonLoaded(
          invites: BuiltList.from(event.invites),
          state: currentState,
          loadedInvites: true);
    }
  }
}
