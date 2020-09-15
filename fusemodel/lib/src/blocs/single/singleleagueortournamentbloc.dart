import 'dart:async';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/async_hydrated_bloc/asynchydratedbloc.dart';
import 'package:meta/meta.dart';

import 'data/singleleagueortournamentbloc.dart';

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
class SingleLeagueOrTournamentBloc extends AsyncHydratedBloc<
    SingleLeagueOrTournamentEvent, SingleLeagueOrTournamentState> {
  final DatabaseUpdateModel db;
  final String leagueUid;

  StreamSubscription<LeagueOrTournament> _coordSub;
  StreamSubscription<Iterable<LeagueOrTournamentSeason>>
      _leagueOrTournamentSnapshot;

  SingleLeagueOrTournamentBloc({@required this.db, @required this.leagueUid})
      : super(SingleLeagueOrTournamentUninitialized(), leagueUid) {
    _coordSub = db.getLeagueData(leagueUid: leagueUid).listen((league) {
      if (league != null) {
        add(_SingleLeagueOrTournamentEventLeagueLoaded(league: league));
      } else {
        add(_SingleLeagueOrTournamentEventDeleted());
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
  SingleLeagueOrTournamentState get initialState {}

  void _updateSeasons(Iterable<LeagueOrTournamentSeason> seasons) {
    add(_SingleLeagueOrTournamentEventSeasons(seasons: seasons));
  }

  ///
  /// Update the image for this league or tournament.
  ///
  Stream<SingleLeagueOrTournamentState> _updateImage(File imageFile) async* {
    yield SingleLeagueOrTournamentSaving.fromState(state).build();
    try {
      await db.updateLeagueImage(state.league, imageFile);
      yield SingleLeagueOrTournamentSaveDone.fromState(state).build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
    } catch (e) {
      yield (SingleLeagueOrTournamentSaveFailed.fromState(state)..error = e)
          .build();
    }
  }

  ///
  /// Deletea a member from this league or tournment.
  ///
  Stream<SingleLeagueOrTournamentState> _deleteMember(String memberUid) async* {
    yield SingleLeagueOrTournamentSaving.fromState(state).build();
    try {
      await db.deleteLeagueMember(state.league, memberUid);
      yield SingleLeagueOrTournamentSaveDone.fromState(state).build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
    } catch (e) {
      yield (SingleLeagueOrTournamentSaveFailed.fromState(state)..error = e)
          .build();
    }
  }

  ///
  /// Invites a member to this league or tournment.
  ///
  Stream<SingleLeagueOrTournamentState> _inviteMember(String email) async* {
    yield SingleLeagueOrTournamentSaving.fromState(state).build();
    try {
      InviteToLeagueAsAdmin inviteToClub = new InviteToLeagueAsAdmin((b) => b
        ..sentByUid = db.currentUser.uid
        ..email = email
        ..leagueUid = state.league.uid
        ..leagueName = state.league.name);

      await db.inviteUserToLeague(inviteToClub);
      yield SingleLeagueOrTournamentSaveDone.fromState(state).build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
    } catch (e) {
      yield (SingleLeagueOrTournamentSaveFailed.fromState(state)..error = e)
          .build();
    }
  }

  ///
  /// Invites a member to this league or tournment.
  ///
  Stream<SingleLeagueOrTournamentState> _inviteToTeam(
      String teamUid, String seasonUid, String email) async* {
    yield SingleLeagueOrTournamentSaving.fromState(state).build();
    try {
      LeagueOrTournamentTeam team = await db.getLeagueTeamData(teamUid).first;
      LeagueOrTournamentSeason season =
          await db.getLeagueSeasonData(seasonUid).single;

      await db.inviteUserToLeagueTeam(
        leagueTeam: team,
        leagueSeasonUid: season.uid,
      );
      yield SingleLeagueOrTournamentSaveDone.fromState(state).build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
    } catch (e) {
      yield (SingleLeagueOrTournamentSaveFailed.fromState(state)..error = e)
          .build();
    }
  }

  Stream<SingleLeagueOrTournamentState> _updateLeague(
      LeagueOrTournament league, bool includeMembers) async* {
    if (league.uid == leagueUid) {
      yield SingleLeagueOrTournamentSaving.fromState(state).build();
      try {
        await db.updateLeague(league, includeMembers: includeMembers);
        yield SingleLeagueOrTournamentSaveDone.fromState(state).build();
        yield SingleLeagueOrTournamentLoaded.fromState(state).build();
      } catch (e) {
        yield (SingleLeagueOrTournamentSaveFailed.fromState(state)..error = e)
            .build();
      }
    } else {
      yield (SingleLeagueOrTournamentSaveFailed.fromState(state)
            ..error = ArgumentError("league uids don't match"))
          .build();
    }
  }

  Stream<SingleLeagueOrTournamentState> _addSeason(String seasonName) async* {
    yield SingleLeagueOrTournamentSaving.fromState(state).build();
    try {
      LeagueOrTournamentSeason season = new LeagueOrTournamentSeason((b) => b
        ..uid = null
        ..name = seasonName
        ..leagueOrTournmentUid = state.league.uid);

      await db.updateLeagueSeason(season);
      yield SingleLeagueOrTournamentSaveDone.fromState(state).build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
    } catch (e) {
      yield (SingleLeagueOrTournamentSaveFailed.fromState(state)..error = e)
          .build();
    }
  }

  @override
  Stream<SingleLeagueOrTournamentState> mapEventToState(
      SingleLeagueOrTournamentEvent event) async* {
    if (event is _SingleLeagueOrTournamentEventLeagueLoaded) {
      yield (SingleLeagueOrTournamentLoaded.fromState(state)
            ..league = event.league.toBuilder())
          .build();
    }

    if (event is _SingleLeagueOrTournamentEventDeleted) {
      yield SingleLeagueOrTournamentDeleted();
    }

    if (event is SingleLeagueOrTournamentLoadSeasons) {
      if (_leagueOrTournamentSnapshot != null) {
        _leagueOrTournamentSnapshot = db
            .getLeagueSeasons(
              leagueUid: leagueUid,
            )
            .listen((Iterable<LeagueOrTournamentSeason> seasons) =>
                _updateSeasons(seasons));
      }
    }

    if (event is _SingleLeagueOrTournamentEventSeasons) {
      var newSeasons = MapBuilder<String, LeagueOrTournamentSeason>();
      for (LeagueOrTournamentSeason season in event.seasons) {
        newSeasons[season.uid] = season;
      }
      yield (SingleLeagueOrTournamentLoaded.fromState(state)
            ..seasons = newSeasons
            ..loadedSeasons = true)
          .build();
    }

    // Unload everything.
    if (event is _SingleLeagueOrTournamentEventLogout) {
      yield SingleLeagueOrTournamentDeleted();
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

  @override
  SingleLeagueOrTournamentState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return SingleLeagueOrTournamentUninitialized();
    }

    SingleLeagueOrTournamentBlocStateType type =
        SingleLeagueOrTournamentBlocStateType.valueOf(json["type"]);
    switch (type) {
      case SingleLeagueOrTournamentBlocStateType.Uninitialized:
        return SingleLeagueOrTournamentUninitialized();
      case SingleLeagueOrTournamentBlocStateType.Loaded:
        var ret = SingleLeagueOrTournamentLoaded.fromMap(json);
        return ret;
      case SingleLeagueOrTournamentBlocStateType.Deleted:
        return SingleLeagueOrTournamentDeleted.fromMap(json);
      case SingleLeagueOrTournamentBlocStateType.SaveFailed:
        return SingleLeagueOrTournamentSaveFailed.fromMap(json);
      case SingleLeagueOrTournamentBlocStateType.Saving:
        return SingleLeagueOrTournamentSaving.fromMap(json);
      case SingleLeagueOrTournamentBlocStateType.SaveDone:
        return SingleLeagueOrTournamentSaveDone.fromMap(json);
    }
  }

  @override
  Map<String, dynamic> toJson(SingleLeagueOrTournamentState state) {
    return state.toMap();
  }
}
