import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'leagueortournamentbloc.dart';

///
/// Basic state for all the data in this system.
///
abstract class SingleLeagueOrTournamentState extends Equatable {
  final LeagueOrTournament leagueOrTournament;
  final Map<String, LeagueOrTournamentSeason> leagueOrTournamentSeasons;

  SingleLeagueOrTournamentState(
      {@required this.leagueOrTournament,
      @required this.leagueOrTournamentSeasons});
}

///
/// Loaded the data like a boss.
///
class SingleLeagueOrTournamentLoaded extends SingleLeagueOrTournamentState {
  SingleLeagueOrTournamentLoaded(
      {@required LeagueOrTournament leagueOrTournament,
      Map<String, LeagueOrTournamentSeason> leagueOrTournamentSeasons})
      : super(
            leagueOrTournament: leagueOrTournament,
            leagueOrTournamentSeasons: leagueOrTournamentSeasons);

  @override
  String toString() {
    return 'LeagueOrTournamentLoaded{}';
  }
}

///
/// Saveing failed, with an specified error.
///
class SingleLeagueOrTournamentSaveFailed extends SingleLeagueOrTournamentState {
  final Error error;

  SingleLeagueOrTournamentSaveFailed(
      {@required SingleLeagueOrTournamentState leagueOrTournament,
      @required this.error})
      : super(
            leagueOrTournament: leagueOrTournament.leagueOrTournament,
            leagueOrTournamentSeasons:
                leagueOrTournament.leagueOrTournamentSeasons);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentSaveFailed{}';
  }
}

///
/// In the process of saving.
///
class SingleLeagueOrTournamentSaving extends SingleLeagueOrTournamentState {
  SingleLeagueOrTournamentSaving(
      {@required SingleLeagueOrTournamentState leagueOrTournament})
      : super(
            leagueOrTournament: leagueOrTournament.leagueOrTournament,
            leagueOrTournamentSeasons:
                leagueOrTournament.leagueOrTournamentSeasons);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentSaving{}';
  }
}

///
/// Deleted
///
class SingleLeagueOrTournamentDeleted extends SingleLeagueOrTournamentState {
  SingleLeagueOrTournamentDeleted(
      {@required SingleLeagueOrTournamentState leagueOrTournament})
      : super(
            leagueOrTournament: leagueOrTournament.leagueOrTournament,
            leagueOrTournamentSeasons:
                leagueOrTournament.leagueOrTournamentSeasons);
  SingleLeagueOrTournamentDeleted.empty()
      : super(leagueOrTournament: null, leagueOrTournamentSeasons: {});
  @override
  String toString() {
    return 'SingleLeagueOrTournamentDeleted{}';
  }
}

abstract class SingleLeagueOrTournamentEvent extends Equatable {}

class _SingleLeagueOrTournamentEventLeagueLoaded
    extends SingleLeagueOrTournamentEvent {
  final LeagueOrTournament league;

  _SingleLeagueOrTournamentEventLeagueLoaded({@required this.league});

  @override
  String toString() {
    return '_SingleLeagueOrTournamentEventLeagueLoaded{}';
  }
}

class _SingleLeagueOrTournamentEventDeleted
    extends SingleLeagueOrTournamentEvent {}

class _SingleLeagueOrTournamentEventLogout
    extends SingleLeagueOrTournamentEvent {}

class _SingleLeagueOrTournamentEventSeasons
    extends SingleLeagueOrTournamentEvent {
  Iterable<LeagueOrTournamentSeason> seasons;

  _SingleLeagueOrTournamentEventSeasons({this.seasons});
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentLoadSeasons
    extends SingleLeagueOrTournamentEvent {}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentUpdate extends SingleLeagueOrTournamentEvent {
  final LeagueOrTournament leagueOrTournament;
  final bool includeMembers;

  SingleLeagueOrTournamentUpdate(this.leagueOrTournament, this.includeMembers);
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentUpdateImage
    extends SingleLeagueOrTournamentEvent {
  final File image;

  SingleLeagueOrTournamentUpdateImage(this.image);
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentDeleteMember
    extends SingleLeagueOrTournamentEvent {
  final String memberUid;

  SingleLeagueOrTournamentDeleteMember(this.memberUid);
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentInviteMember
    extends SingleLeagueOrTournamentEvent {
  final String email;

  SingleLeagueOrTournamentInviteMember(this.email);
}

///
/// Handles the work around the clubs and club system inside of
/// the app.
///
class SingleLeagueOrTournamentBloc
    extends Bloc<SingleLeagueOrTournamentEvent, SingleLeagueOrTournamentState> {
  final LeagueOrTournamentBloc leagueOrTournamentBloc;
  final String leagueUid;

  StreamSubscription<LeagueOrTournamentState> _coordSub;
  StreamSubscription<Iterable<LeagueOrTournamentSeason>>
      _leagueOrTournamentSnapshot;

  SingleLeagueOrTournamentBloc(
      {@required this.leagueOrTournamentBloc, @required this.leagueUid}) {
    _coordSub =
        leagueOrTournamentBloc.state.listen((LeagueOrTournamentState state) {
      if (state is LeagueOrTournamentLoaded) {
        if (state.leagueOrTournaments.containsKey(leagueUid)) {
          dispatch(_SingleLeagueOrTournamentEventLeagueLoaded(
              league: state.leagueOrTournaments[leagueUid]));
        } else {
          dispatch(_SingleLeagueOrTournamentEventDeleted());
        }
      }
      if (state is LeagueOrTournamentUninitialized) {
        dispatch(_SingleLeagueOrTournamentEventLogout());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _cleanupStuff();
    _coordSub?.cancel();
  }

  void _cleanupStuff() {
    _leagueOrTournamentSnapshot?.cancel();
    _leagueOrTournamentSnapshot = null;
  }

  @override
  SingleLeagueOrTournamentState get initialState {
    if (leagueOrTournamentBloc.currentState.leagueOrTournaments
        .containsKey(leagueUid)) {
      return SingleLeagueOrTournamentLoaded(
          leagueOrTournament: leagueOrTournamentBloc
              .currentState.leagueOrTournaments[leagueUid]);
    } else {
      return SingleLeagueOrTournamentDeleted.empty();
    }
  }

  void _updateSeasons(Iterable<LeagueOrTournamentSeason> seasons) {
    dispatch(_SingleLeagueOrTournamentEventSeasons(seasons: seasons));
  }

  ///
  /// Update the image for this league or tournament.
  ///
  Stream<SingleLeagueOrTournamentState> _updateImage(File imageFile) async* {
    yield SingleLeagueOrTournamentSaving(leagueOrTournament: currentState);
    try {
      await leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
          .updateLeagueImage(currentState.leagueOrTournament, imageFile);
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: currentState.leagueOrTournament,
          leagueOrTournamentSeasons: currentState.leagueOrTournamentSeasons);
    } catch (e) {
      yield SingleLeagueOrTournamentSaveFailed(
          leagueOrTournament: currentState, error: e);
    }
  }

  ///
  /// Deletea a member from this league or tournment.
  ///
  Stream<SingleLeagueOrTournamentState> _deleteMember(String memberUid) async* {
    yield SingleLeagueOrTournamentSaving(leagueOrTournament: currentState);
    try {
      await leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
          .deleteLeagueMember(currentState.leagueOrTournament, memberUid);
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: currentState.leagueOrTournament,
          leagueOrTournamentSeasons: currentState.leagueOrTournamentSeasons);
    } catch (e) {
      yield SingleLeagueOrTournamentSaveFailed(
          leagueOrTournament: currentState, error: e);
    }
  }

  ///
  /// Invites a member to this league or tournment.
  ///
  Stream<SingleLeagueOrTournamentState> _inviteMember(String email) async* {
    yield SingleLeagueOrTournamentSaving(leagueOrTournament: currentState);
    try {
      InviteToLeagueAsAdmin inviteToClub = new InviteToLeagueAsAdmin((b) => b
        ..sentByUid = leagueOrTournamentBloc
            .coordinationBloc.authenticationBloc.currentUser.uid
        ..email = email
        ..leagueUid = currentState.leagueOrTournament.uid
        ..leagueName = currentState.leagueOrTournament.name);

      await leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
          .inviteUserToLeague(inviteToClub);
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: currentState.leagueOrTournament,
          leagueOrTournamentSeasons: currentState.leagueOrTournamentSeasons);
    } catch (e) {
      yield SingleLeagueOrTournamentSaveFailed(
          leagueOrTournament: currentState, error: e);
    }
  }

  Stream<SingleLeagueOrTournamentState> _updateLeague(
      LeagueOrTournament league, bool includeMembers) async* {
    if (league.uid == leagueUid) {
      yield SingleLeagueOrTournamentSaving(leagueOrTournament: currentState);
      try {
        await leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
            .updateLeague(league, includeMembers: includeMembers);
        yield SingleLeagueOrTournamentLoaded(
            leagueOrTournament: currentState.leagueOrTournament,
            leagueOrTournamentSeasons: currentState.leagueOrTournamentSeasons);
      } catch (e) {
        yield SingleLeagueOrTournamentSaveFailed(
            leagueOrTournament: currentState, error: e);
      }
    } else {
      yield SingleLeagueOrTournamentSaveFailed(
          leagueOrTournament: currentState,
          error: ArgumentError("league uids don't match"));
    }
  }

  @override
  Stream<SingleLeagueOrTournamentState> mapEventToState(
      SingleLeagueOrTournamentEvent event) async* {
    if (event is _SingleLeagueOrTournamentEventLeagueLoaded) {
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: event.league,
          leagueOrTournamentSeasons: currentState.leagueOrTournamentSeasons);
    }

    if (event is _SingleLeagueOrTournamentEventDeleted) {
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: currentState.leagueOrTournament,
          leagueOrTournamentSeasons: currentState.leagueOrTournamentSeasons);
    }

    if (event is SingleLeagueOrTournamentLoadSeasons) {
      _leagueOrTournamentSnapshot = leagueOrTournamentBloc
          .coordinationBloc.databaseUpdateModel
          .getLeagueSeasons(
              leagueUid: leagueUid,
              userUid: leagueOrTournamentBloc
                  .coordinationBloc.authenticationBloc.currentUser.uid)
          .listen((Iterable<LeagueOrTournamentSeason> seasons) =>
              _updateSeasons(seasons));
    }

    if (event is _SingleLeagueOrTournamentEventSeasons) {
      Map<String, LeagueOrTournamentSeason> newSeasons = {};
      for (LeagueOrTournamentSeason season in event.seasons) {
        newSeasons[season.uid] = season;
      }
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: currentState.leagueOrTournament,
          leagueOrTournamentSeasons: newSeasons);
    }

    // Unload everything.
    if (event is _SingleLeagueOrTournamentEventLogout) {
      yield SingleLeagueOrTournamentDeleted.empty();
      _cleanupStuff();
    }

    if (event is SingleLeagueOrTournamentUpdate) {
      yield* _updateLeague(event.leagueOrTournament, event.includeMembers);
    }

    if (event is SingleLeagueOrTournamentDeleteMember) {
      yield* _deleteMember(event.memberUid);
    }

    if (event is SingleLeagueOrTournamentInviteMember) {
      yield* _inviteMember(event.email);
    }

    if (event is SingleLeagueOrTournamentUpdateImage) {
      yield* _updateImage(event.image);
    }
  }
}
