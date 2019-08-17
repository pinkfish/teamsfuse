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
abstract class SingleTeamSeaonState extends Equatable {
  final Season season;
  final BuiltList<InviteToTeam> invites;

  SingleTeamSeaonState({@required this.season, @required this.invites})
      : super([season, invites]);
}

///
/// We have a team, default state.
///
class SingleTeamSeasonLoaded extends SingleTeamSeaonState {
  SingleTeamSeasonLoaded(
      {@required Season season, @required BuiltList<InviteToTeam> invites})
      : super(season: season, invites: invites);

  @override
  String toString() {
    return 'SingleTeamSeasonLoaded{season: $season}';
  }
}

///
/// Saving operation in progress.
///
class SingleTeamSeasonSaving extends SingleTeamSeaonState {
  SingleTeamSeasonSaving({@required SingleTeamSeaonState state})
      : super(season: state.season, invites: state.invites);

  @override
  String toString() {
    return 'SingleTeamSeasonSaving{season: $season}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleTeamSeasonSaveFailed extends SingleTeamSeaonState {
  final Error error;

  SingleTeamSeasonSaveFailed({@required SingleTeamSeaonState state, this.error})
      : super(season: state.season, invites: state.invites);

  @override
  String toString() {
    return 'SingleTeamSeasonSaveFailed{season: $season}';
  }
}

///
/// Team got deleted.
///
class SingleTeamSeasonDeleted extends SingleTeamSeaonState {
  SingleTeamSeasonDeleted() : super(season: null, invites: BuiltList());

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
class SingleTeamLoadSeasonInvites extends SingleTeamSeasonEvent {}

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

///
/// Bloc to handle updates and state of a specific team.
///
class SingleTeamSeasonBloc
    extends Bloc<SingleTeamSeasonEvent, SingleTeamSeaonState> {
  final TeamBloc teamBloc;
  final String teamUid;
  final String seasonUid;

  StreamSubscription<TeamState> _teamSub;
  StreamSubscription<Iterable<InviteToTeam>> _inviteSub;

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
  }

  @override
  SingleTeamSeaonState get initialState {
    Team t = teamBloc.currentState.getTeam(teamUid);
    if (t != null && t.seasons.containsKey(seasonUid)) {
      return SingleTeamSeasonLoaded(season: t.seasons[seasonUid]);
    } else {
      return SingleTeamSeasonDeleted();
    }
  }

  @override
  Stream<SingleTeamSeaonState> mapEventToState(
      SingleTeamSeasonEvent event) async* {
    if (event is _SingleTeamNewTeamSeason) {
      yield SingleTeamSeasonLoaded(season: event.newSeason);
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
        yield SingleTeamSeasonLoaded(season: event.season.build());
      } catch (e) {
        yield SingleTeamSeasonSaveFailed(state: currentState, error: e);
      }
    }

    if (event is SingleTeamLoadSeasonInvites) {
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

    if (event is _SingleTeamSeasonLoadedInvites) {
      yield SingleTeamSeasonLoaded(
          season: currentState.season, invites: BuiltList.from(event.invites));
    }
  }
}
