import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../leagueortournamentbloc.dart';

///
/// Basic state for all the data in this system.
///
abstract class SingleLeagueOrTournamentState extends Equatable {
  final LeagueOrTournament leagueOrTournament;
  final BuiltMap<String, LeagueOrTournamentSeason> leagueOrTournamentSeasons;
  final bool loadedSeasons;

  SingleLeagueOrTournamentState(
      {@required this.leagueOrTournament,
      @required this.leagueOrTournamentSeasons,
      @required this.loadedSeasons});

  @override
  List<Object> get props =>
      [leagueOrTournament, leagueOrTournamentSeasons, loadedSeasons];
}

///
/// Loaded the data like a boss.
///
class SingleLeagueOrTournamentLoaded extends SingleLeagueOrTournamentState {
  SingleLeagueOrTournamentLoaded(
      {@required LeagueOrTournament leagueOrTournament,
      BuiltMap<String, LeagueOrTournamentSeason> leagueOrTournamentSeasons,
      bool loadedSeasons})
      : super(
            leagueOrTournament: leagueOrTournament,
            leagueOrTournamentSeasons: leagueOrTournamentSeasons ?? BuiltMap(),
            loadedSeasons: loadedSeasons ?? false);

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
                leagueOrTournament.leagueOrTournamentSeasons,
            loadedSeasons: leagueOrTournament.loadedSeasons);

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
                leagueOrTournament.leagueOrTournamentSeasons,
            loadedSeasons: leagueOrTournament.loadedSeasons);

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
                leagueOrTournament.leagueOrTournamentSeasons,
            loadedSeasons: leagueOrTournament.loadedSeasons);
  SingleLeagueOrTournamentDeleted.empty()
      : super(
            leagueOrTournament: null,
            leagueOrTournamentSeasons: BuiltMap(),
            loadedSeasons: false);
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

  @override
  List<Object> get props => [league];
}

class _SingleLeagueOrTournamentEventDeleted
    extends SingleLeagueOrTournamentEvent {
  @override
  List<Object> get props => [];
}

class _SingleLeagueOrTournamentEventLogout
    extends SingleLeagueOrTournamentEvent {
  @override
  List<Object> get props => [];
}

class _SingleLeagueOrTournamentEventSeasons
    extends SingleLeagueOrTournamentEvent {
  Iterable<LeagueOrTournamentSeason> seasons;

  _SingleLeagueOrTournamentEventSeasons({this.seasons});
  @override
  List<Object> get props => [seasons];
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentLoadSeasons
    extends SingleLeagueOrTournamentEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentUpdate extends SingleLeagueOrTournamentEvent {
  final LeagueOrTournament leagueOrTournament;
  final bool includeMembers;

  SingleLeagueOrTournamentUpdate(
      {this.leagueOrTournament, this.includeMembers});
  @override
  List<Object> get props => [leagueOrTournament, includeMembers];
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentUpdateImage
    extends SingleLeagueOrTournamentEvent {
  final File image;

  SingleLeagueOrTournamentUpdateImage({this.image});

  @override
  List<Object> get props => [image];
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentDeleteAdmin
    extends SingleLeagueOrTournamentEvent {
  final String memberUid;

  SingleLeagueOrTournamentDeleteAdmin({this.memberUid});
  @override
  List<Object> get props => [memberUid];
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentInviteAsAdmin
    extends SingleLeagueOrTournamentEvent {
  final String email;

  SingleLeagueOrTournamentInviteAsAdmin({this.email});
  @override
  List<Object> get props => [email];
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentInviteToTeam
    extends SingleLeagueOrTournamentEvent {
  final String email;
  final String leagueTeamUid;
  final String leagueSeasonUid;

  SingleLeagueOrTournamentInviteToTeam(
      {this.email, this.leagueTeamUid, this.leagueSeasonUid});
  @override
  List<Object> get props => [email, leagueTeamUid, leagueSeasonUid];
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentAddSeason extends SingleLeagueOrTournamentEvent {
  final String name;

  SingleLeagueOrTournamentAddSeason({this.name});
  @override
  List<Object> get props => [name];
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
        leagueOrTournamentBloc.listen((LeagueOrTournamentState leagueState) {
      if (leagueState is LeagueOrTournamentLoaded) {
        if (leagueState.leagueOrTournaments.containsKey(leagueUid)) {
          add(_SingleLeagueOrTournamentEventLeagueLoaded(
              league: leagueState.leagueOrTournaments[leagueUid]));
        } else {
          add(_SingleLeagueOrTournamentEventDeleted());
        }
      }
      if (state is LeagueOrTournamentUninitialized) {
        add(_SingleLeagueOrTournamentEventLogout());
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanupStuff();
    _coordSub?.cancel();
  }

  void _cleanupStuff() {
    _leagueOrTournamentSnapshot?.cancel();
    _leagueOrTournamentSnapshot = null;
  }

  @override
  SingleLeagueOrTournamentState get initialState {
    if (leagueOrTournamentBloc.state.leagueOrTournaments
        .containsKey(leagueUid)) {
      return SingleLeagueOrTournamentLoaded(
          leagueOrTournament:
              leagueOrTournamentBloc.state.leagueOrTournaments[leagueUid]);
    } else {
      return SingleLeagueOrTournamentDeleted.empty();
    }
  }

  void _updateSeasons(Iterable<LeagueOrTournamentSeason> seasons) {
    add(_SingleLeagueOrTournamentEventSeasons(seasons: seasons));
  }

  ///
  /// Update the image for this league or tournament.
  ///
  Stream<SingleLeagueOrTournamentState> _updateImage(File imageFile) async* {
    yield SingleLeagueOrTournamentSaving(leagueOrTournament: state);
    try {
      await leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
          .updateLeagueImage(state.leagueOrTournament, imageFile);
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: state.leagueOrTournament,
          leagueOrTournamentSeasons: state.leagueOrTournamentSeasons,
          loadedSeasons: state.loadedSeasons);
    } catch (e) {
      yield SingleLeagueOrTournamentSaveFailed(
          leagueOrTournament: state, error: e);
    }
  }

  ///
  /// Deletea a member from this league or tournment.
  ///
  Stream<SingleLeagueOrTournamentState> _deleteMember(String memberUid) async* {
    yield SingleLeagueOrTournamentSaving(leagueOrTournament: state);
    try {
      await leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
          .deleteLeagueMember(state.leagueOrTournament, memberUid);
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: state.leagueOrTournament,
          leagueOrTournamentSeasons: state.leagueOrTournamentSeasons,
          loadedSeasons: state.loadedSeasons);
    } catch (e) {
      yield SingleLeagueOrTournamentSaveFailed(
          leagueOrTournament: state, error: e);
    }
  }

  ///
  /// Invites a member to this league or tournment.
  ///
  Stream<SingleLeagueOrTournamentState> _inviteMember(String email) async* {
    yield SingleLeagueOrTournamentSaving(leagueOrTournament: state);
    try {
      InviteToLeagueAsAdmin inviteToClub = new InviteToLeagueAsAdmin((b) => b
        ..sentByUid = leagueOrTournamentBloc
            .coordinationBloc.authenticationBloc.currentUser.uid
        ..email = email
        ..leagueUid = state.leagueOrTournament.uid
        ..leagueName = state.leagueOrTournament.name);

      await leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
          .inviteUserToLeague(inviteToClub);
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: state.leagueOrTournament,
          leagueOrTournamentSeasons: state.leagueOrTournamentSeasons,
          loadedSeasons: state.loadedSeasons);
    } catch (e) {
      yield SingleLeagueOrTournamentSaveFailed(
          leagueOrTournament: state, error: e);
    }
  }

  ///
  /// Invites a member to this league or tournment.
  ///
  Stream<SingleLeagueOrTournamentState> _inviteToTeam(
      String teamUid, String seasonUid, String email) async* {
    yield SingleLeagueOrTournamentSaving(leagueOrTournament: state);
    try {
      LeagueOrTournamentTeam team = await leagueOrTournamentBloc
          .coordinationBloc.databaseUpdateModel
          .getLeagueTeamData(teamUid)
          .first;
      LeagueOrTournamentSeason season = await leagueOrTournamentBloc
          .coordinationBloc.databaseUpdateModel
          .getLeagueSeasonData(seasonUid);

      await leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
          .inviteUserToLeagueTeam(
              leagueTeam: team,
              leagueSeasonUid: season.uid,
              userUid: leagueOrTournamentBloc
                  .coordinationBloc.authenticationBloc.currentUser.uid);
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: state.leagueOrTournament,
          leagueOrTournamentSeasons: state.leagueOrTournamentSeasons,
          loadedSeasons: state.loadedSeasons);
    } catch (e) {
      yield SingleLeagueOrTournamentSaveFailed(
          leagueOrTournament: state, error: e);
    }
  }

  Stream<SingleLeagueOrTournamentState> _updateLeague(
      LeagueOrTournament league, bool includeMembers) async* {
    if (league.uid == leagueUid) {
      yield SingleLeagueOrTournamentSaving(leagueOrTournament: state);
      try {
        await leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
            .updateLeague(league, includeMembers: includeMembers);
        yield SingleLeagueOrTournamentLoaded(
            leagueOrTournament: state.leagueOrTournament,
            leagueOrTournamentSeasons: state.leagueOrTournamentSeasons,
            loadedSeasons: state.loadedSeasons);
      } catch (e) {
        yield SingleLeagueOrTournamentSaveFailed(
            leagueOrTournament: state, error: e);
      }
    } else {
      yield SingleLeagueOrTournamentSaveFailed(
          leagueOrTournament: state,
          error: ArgumentError("league uids don't match"));
    }
  }

  Stream<SingleLeagueOrTournamentState> _addSeason(String seasonName) async* {
    yield SingleLeagueOrTournamentSaving(leagueOrTournament: state);
    try {
      LeagueOrTournamentSeason season = new LeagueOrTournamentSeason((b) => b
        ..uid = null
        ..name = seasonName
        ..leagueOrTournmentUid = state.leagueOrTournament.uid);

      await leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
          .updateLeagueSeason(season);
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: state.leagueOrTournament,
          leagueOrTournamentSeasons: state.leagueOrTournamentSeasons,
          loadedSeasons: state.loadedSeasons);
    } catch (e) {
      yield SingleLeagueOrTournamentSaveFailed(
          leagueOrTournament: state, error: e);
    }
  }

  @override
  Stream<SingleLeagueOrTournamentState> mapEventToState(
      SingleLeagueOrTournamentEvent event) async* {
    if (event is _SingleLeagueOrTournamentEventLeagueLoaded) {
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: event.league,
          leagueOrTournamentSeasons: state.leagueOrTournamentSeasons,
          loadedSeasons: state.loadedSeasons);
    }

    if (event is _SingleLeagueOrTournamentEventDeleted) {
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: state.leagueOrTournament,
          leagueOrTournamentSeasons: state.leagueOrTournamentSeasons,
          loadedSeasons: state.loadedSeasons);
    }

    if (event is SingleLeagueOrTournamentLoadSeasons) {
      if (!state.loadedSeasons) {
        _leagueOrTournamentSnapshot = leagueOrTournamentBloc
            .coordinationBloc.databaseUpdateModel
            .getLeagueSeasons(
                leagueUid: leagueUid,
                userUid: leagueOrTournamentBloc
                    .coordinationBloc.authenticationBloc.currentUser.uid)
            .listen((Iterable<LeagueOrTournamentSeason> seasons) =>
                _updateSeasons(seasons));
      }
    }

    if (event is _SingleLeagueOrTournamentEventSeasons) {
      Map<String, LeagueOrTournamentSeason> newSeasons = {};
      for (LeagueOrTournamentSeason season in event.seasons) {
        newSeasons[season.uid] = season;
      }
      yield SingleLeagueOrTournamentLoaded(
          leagueOrTournament: state.leagueOrTournament,
          leagueOrTournamentSeasons: BuiltMap.from(newSeasons),
          loadedSeasons: true);
    }

    // Unload everything.
    if (event is _SingleLeagueOrTournamentEventLogout) {
      yield SingleLeagueOrTournamentDeleted.empty();
      _cleanupStuff();
    }

    if (event is SingleLeagueOrTournamentUpdate) {
      yield* _updateLeague(event.leagueOrTournament, event.includeMembers);
    }

    if (event is SingleLeagueOrTournamentDeleteAdmin) {
      yield* _deleteMember(event.memberUid);
    }

    if (event is SingleLeagueOrTournamentInviteAsAdmin) {
      yield* _inviteMember(event.email);
    }

    if (event is SingleLeagueOrTournamentInviteToTeam) {
      yield* _inviteToTeam(
          event.leagueTeamUid, event.leagueSeasonUid, event.email);
    }

    if (event is SingleLeagueOrTournamentUpdateImage) {
      yield* _updateImage(event.image);
    }

    if (event is SingleLeagueOrTournamentAddSeason) {
      yield* _addSeason(event.name);
    }
  }
}
