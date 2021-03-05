import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

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

class _SingleLeagueOrTournamentEventSeasons
    extends SingleLeagueOrTournamentEvent {
  final Iterable<LeagueOrTournamentSeason> seasons;

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
  final Uint8List image;

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

  SingleLeagueOrTournamentInviteToTeam({this.email, this.leagueTeamUid});
  @override
  List<Object> get props => [email, leagueTeamUid];
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
  final AnalyticsSubsystem crashes;

  StreamSubscription<LeagueOrTournament> _leagueSub;
  StreamSubscription<Iterable<LeagueOrTournamentSeason>>
      _leagueOrTournamentSnapshot;

  SingleLeagueOrTournamentBloc(
      {@required this.db, @required this.leagueUid, @required this.crashes})
      : super(SingleLeagueOrTournamentUninitialized(), leagueUid) {
    _leagueSub = db.getLeagueData(leagueUid: leagueUid).listen((league) {
      if (league != null) {
        add(_SingleLeagueOrTournamentEventLeagueLoaded(league: league));
      } else {
        add(_SingleLeagueOrTournamentEventDeleted());
      }
    });
    _leagueSub.onError((e, stack) => crashes.recordException(e, stack));
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanupStuff();
    _leagueSub?.cancel();
    _leagueSub = null;
  }

  void _cleanupStuff() {
    _leagueOrTournamentSnapshot?.cancel();
    _leagueOrTournamentSnapshot = null;
  }

  ///
  /// Update the image for this league or tournament.
  ///
  Stream<SingleLeagueOrTournamentState> _updateImage(
      Uint8List imageFile) async* {
    yield SingleLeagueOrTournamentSaving.fromState(state).build();
    try {
      await db.updateLeagueImage(state.league, await imageFile);
      yield SingleLeagueOrTournamentSaveDone.fromState(state).build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
    } catch (e, stack) {
      yield (SingleLeagueOrTournamentSaveFailed.fromState(state)
            ..error = RemoteError(e.messages, stack.toString()))
          .build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
      crashes.recordException(e, stack);
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
    } catch (e, stack) {
      yield (SingleLeagueOrTournamentSaveFailed.fromState(state)
            ..error = RemoteError(e.messages, stack.toString()))
          .build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
      crashes.recordException(e, stack);
    }
  }

  ///
  /// Invites a member to this league or tournment.
  ///
  Stream<SingleLeagueOrTournamentState> _inviteMember(String email) async* {
    yield SingleLeagueOrTournamentSaving.fromState(state).build();
    try {
      InviteToLeagueAsAdmin inviteToClub = InviteToLeagueAsAdmin((b) => b
        ..sentByUid = db.currentUser.uid
        ..email = email
        ..leagueUid = state.league.uid
        ..leagueName = state.league.name);

      await db.inviteUserToLeague(inviteToClub);
      yield SingleLeagueOrTournamentSaveDone.fromState(state).build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
    } catch (e, stack) {
      yield (SingleLeagueOrTournamentSaveFailed.fromState(state)
            ..error = RemoteError(e.messages, stack.toString()))
          .build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
      crashes.recordException(e, stack);
    }
  }

  ///
  /// Invites a member to this league or tournment.
  ///
  Stream<SingleLeagueOrTournamentState> _inviteToTeam(
      String teamUid, String email) async* {
    yield SingleLeagueOrTournamentSaving.fromState(state).build();
    try {
      LeagueOrTournamentTeam team = await db.getLeagueTeamData(teamUid).first;
      LeagueOrTournamentSeason season =
          await db.getLeagueSeasonData(team.leagueOrTournamentSeasonUid).single;

      await db.inviteUserToLeagueTeam(
        leagueTeam: team,
        leagueSeasonUid: season.uid,
      );
      yield SingleLeagueOrTournamentSaveDone.fromState(state).build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
    } catch (e, stack) {
      yield (SingleLeagueOrTournamentSaveFailed.fromState(state)
            ..error = RemoteError(e.messages, stack.toString()))
          .build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
      crashes.recordException(e, stack);
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
      } catch (e, stack) {
        yield (SingleLeagueOrTournamentSaveFailed.fromState(state)
              ..error = RemoteError(e.messages, stack.toString()))
            .build();
        yield SingleLeagueOrTournamentLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    } else {
      yield (SingleLeagueOrTournamentSaveFailed.fromState(state)
            ..error = ArgumentError('league uids do not match'))
          .build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
    }
  }

  Stream<SingleLeagueOrTournamentState> _addSeason(String seasonName) async* {
    yield SingleLeagueOrTournamentSaving.fromState(state).build();
    try {
      LeagueOrTournamentSeason season = LeagueOrTournamentSeason((b) => b
        ..uid = null
        ..name = seasonName
        ..leagueOrTournmentUid = state.league.uid);

      await db.updateLeagueSeason(season);
      yield SingleLeagueOrTournamentSaveDone.fromState(state).build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
    } catch (e, stack) {
      yield (SingleLeagueOrTournamentSaveFailed.fromState(state)
            ..error = RemoteError(e.messages, stack.toString()))
          .build();
      yield SingleLeagueOrTournamentLoaded.fromState(state).build();
      crashes.recordException(e, stack);
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
      if (_leagueOrTournamentSnapshot == null) {
        _leagueOrTournamentSnapshot = db
            .getLeagueSeasons(
              leagueUid: leagueUid,
            )
            .listen((Iterable<LeagueOrTournamentSeason> seasons) =>
                add(_SingleLeagueOrTournamentEventSeasons(seasons: seasons)));
        _leagueOrTournamentSnapshot
            .onError((e, stack) => crashes.recordException(e, stack));
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
      yield* _inviteToTeam(event.leagueTeamUid, event.email);
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
    if (!(state is SingleLeagueOrTournamentUninitialized)) {
      return state;
    }

    if (json == null || !json.containsKey('type')) {
      return SingleLeagueOrTournamentUninitialized();
    }

    try {
      SingleLeagueOrTournamentBlocStateType type =
          SingleLeagueOrTournamentBlocStateType.valueOf(json['type']);
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
    } catch (e, stack) {
      if (e is Error) {
        crashes.recordError(e, stack);
      } else {
        crashes.recordException(e, stack);
      }
    }

    return SingleLeagueOrTournamentUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleLeagueOrTournamentState state) {
    return state.toMap();
  }
}
