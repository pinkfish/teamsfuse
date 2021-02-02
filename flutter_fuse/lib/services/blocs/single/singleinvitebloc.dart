import 'dart:async';
import 'dart:isolate';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';
import '../seasonbloc.dart';
import '../teambloc.dart';

class SingleInviteEvent extends Equatable {
  @override
  List<Object> get props => [];
}

///
/// Accept this invite and do whatever than means in acceptance.
///
class SingleInviteEventAcceptInviteToTeam extends SingleInviteEvent {
  final Map<String, String> playerNameToUid;
  final Map<String, Relationship> relationship;

  SingleInviteEventAcceptInviteToTeam(
      {this.playerNameToUid, this.relationship});
}

///
/// Accepts the invite to the club.
///
class SingleInviteEventAcceptInviteToClub extends SingleInviteEvent {
  SingleInviteEventAcceptInviteToClub();
}

///
/// Accepts the invite to the league as an admin.
///
class SingleInviteEventAcceptInviteToLeagueAdmin extends SingleInviteEvent {
  SingleInviteEventAcceptInviteToLeagueAdmin();
}

///
/// Accepts the invite to the league team.
///
class SingleInviteEventAcceptInviteToLeagueTeam extends SingleInviteEvent {
  final String teamUid;
  final String seasonUid;

  SingleInviteEventAcceptInviteToLeagueTeam(
      {@required this.teamUid, @required this.seasonUid});
}

///
/// Accept this invite and do whatever than means in acceptance.
///
class SingleInviteEventAcceptInviteToPlayer extends SingleInviteEvent {
  final Relationship relationship;
  final String playerUid;

  SingleInviteEventAcceptInviteToPlayer(
      {@required this.relationship, this.playerUid});
}

///
/// Accept this invite and do whatever than means in acceptance.
///
class SingleInviteEventAcceptInviteAsAdmin extends SingleInviteEvent {
  SingleInviteEventAcceptInviteAsAdmin();
}

///
/// Delete this invite.  No way jose!
///
class SingleInviteEventDeleteInvite extends SingleInviteEvent {
  final String inviteUid;

  SingleInviteEventDeleteInvite({@required this.inviteUid});
}

class _SingleInviteEventUnloaded extends SingleInviteEvent {
  _SingleInviteEventUnloaded();
}

class _SingleInviteUpdated extends SingleInviteEvent {
  final Invite invite;

  _SingleInviteUpdated({this.invite});
}

///
/// Started the whole process for this bloc.
///
class SingleInviteEventLoaded extends SingleInviteEvent {
  final Invite invite;

  SingleInviteEventLoaded({@required this.invite});
}

///
/// Deals with specific invites to allow for accepting/deleting/etc of the
/// invites.
///
class SingleInviteBloc
    extends AsyncHydratedBloc<SingleInviteEvent, SingleInviteState> {
  final TeamBloc teamBloc;
  final SeasonBloc seasonBloc;
  final String inviteUid;
  final DatabaseUpdateModel db;
  final AnalyticsSubsystem crashes;

  StreamSubscription<Invite> _inviteListen;

  /// Used for the season/team etc if we want to make a new one.
  static String createNew = "createNew";

  SingleInviteBloc(
      {@required this.db,
      @required this.crashes,
      @required this.teamBloc,
      @required this.seasonBloc,
      @required this.inviteUid})
      : super(SingleInviteUninitialized(), 'SingleInvite' + inviteUid) {
    _inviteListen = db.getSingleInvite(inviteUid).listen((event) {
      if (event != null) {
        add(_SingleInviteUpdated(invite: event));
      } else {
        add(_SingleInviteEventUnloaded());
      }
    });
  }

  @override
  Future<void> close() async {
    _inviteListen?.cancel();
    await super.close();
  }

  Future<SingleInviteState> _acceptInviteToClub(
      SingleInviteEventAcceptInviteToClub event, Invite invite) async {
    if (invite is InviteToClub) {
      //
      // Invite to club.
      //
      await db.addUserToClub(invite.clubUid, db.currentUser.uid, invite.admin);
      // This should cause the data to update
      await db.firestoreInviteDelete(invite.uid);
      crashes.logInviteAccepted("club", invite.clubUid);
      return SingleInviteDeleted();
    } else {
      //
      // End this thing.
      //
      return (SingleInviteSaveFailed.fromState(state)
            ..error = ArgumentError('Not a club invite'))
          .build();
    }
  }

  Future<SingleInviteState> _acceptInviteToLeagueAdmin(
      SingleInviteEventAcceptInviteToLeagueAdmin event, Invite invite) async {
    if (invite is InviteToLeagueAsAdmin) {
      //
      // Invite to league admin
      //
      if (invite.leagueUid != null) {
        await db.addUserToLeague(invite.leagueUid, true);
      }
      if (invite.leagueSeasonUid != null) {
        await db.addUserToLeagueSeason(invite.leagueSeasonUid, true);
      }
      if (invite.leagueDivisonUid != null) {
        await db.addUserToLeagueDivison(invite.leagueDivisonUid, true);
      }

      // This should cause the data to update
      await db.firestoreInviteDelete(invite.uid);
      crashes.logInviteAccepted("leagueAdmin", invite.leagueUid);
      return SingleInviteDeleted();
    } else {
      return (SingleInviteSaveFailed.fromState(state)
            ..error = ArgumentError('Not a league admin invite'))
          .build();
    }
  }

  Future<SingleInviteState> _acceptInviteToPlayer(
      SingleInviteEventAcceptInviteToPlayer event, Invite invite) async {
    if (invite is InviteToPlayer) {
      //
      // Invite to player!!!
      //
      if (event.relationship == null) {
        return (SingleInviteSaveFailed.fromState(state)
              ..error = ArgumentError('Relationship incorrec'))
            .build();
      }
      crashes.logInviteAccepted("inviteToPlayer", invite.playerUid);
      // Add ourselves to the player.
      bool exists = await db.playerExists(invite.playerUid);
      if (!exists) {
        return (SingleInviteSaveFailed.fromState(state)
              ..error = ArgumentError('Already added to player'))
            .build();
      }
      // Yay!  We have a player.
      PlayerUser playerUser =
          PlayerUser(db.currentUser.uid, event.relationship);
      await db.addUserToPlayer(invite.playerUid, playerUser);

      // This should cause the data to update
      await db.firestoreInviteDelete(invite.uid);
      return SingleInviteDeleted();
    } else {
      return (SingleInviteSaveFailed.fromState(state)
            ..error = ArgumentError('Not a player invite'))
          .build();
    }
  }

  Future<SingleInviteState> _acceptInviteToLeagueTeam(
      SingleInviteEventAcceptInviteToLeagueTeam event, Invite invite) async {
    if (invite is InviteToLeagueTeam) {
      //
      // Invite to league team
      //
      if (event.teamUid == SingleInviteBloc.createNew) {
        TeamBuilder team = new TeamBuilder();
        team.name = invite.leagueTeamName;
        team.adminsData[db.currentUser.uid] = true;
        var pregen = db.precreateTeamUid();
        var pregenSeason = db.precreateUidSeason();
        team.uid = pregen.documentID;
        Season season = new Season((b) => b
          ..uid = pregenSeason.documentID
          ..name = invite.leagueSeasonName
          ..teamUid = team.uid
          ..record = WinRecordBuilder()
          ..playersData = MapBuilder({
            db.currentUser.uid: SeasonPlayer((b) => b
              ..playerUid = db.currentUser.uid
              ..role = RoleInTeam.NonPlayer)
          }));
        team.currentSeason = pregenSeason.documentID;
        LeagueOrTournamentTeam leagueTeam =
            await db.getLeagueTeamData(invite.leagueTeamUid).first;
        if (leagueTeam.seasonUid != null) {
          // Someone beat them to it!
          // TODO: Say someone beat them to it.
        } else {
          leagueTeam =
              leagueTeam.rebuild((b) => b..seasonUid = pregenSeason.documentID);
          await db.updateLeagueTeam(leagueTeam);
          await db.addFirestoreTeam(team.build(), pregen, season, null);
        }
        crashes.logInviteAccepted("leagueTeam", leagueTeam.uid);
      } else if (event.seasonUid == SingleInviteBloc.createNew) {
        var pregenSeason = db.precreateUidSeason();

        Season season = new Season((b) => b
          ..uid = pregenSeason.documentID
          ..name = invite.leagueSeasonName
          ..teamUid = event.teamUid);
        await db.addFirestoreSeason(season, pregenSeason);
        crashes.logInviteAccepted("leagueSeason", season.uid);
      } else {
        Season season = seasonBloc.state.seasons[event.seasonUid];
        await db.connectLeagueTeamToSeason(invite.leagueTeamUid, season);
        crashes.logInviteAccepted("leagueSeasonTeam", invite.leagueTeamUid);
      }
      // This should cause the data to update
      await db.firestoreInviteDelete(invite.uid);
      return SingleInviteDeleted();
    } else {
      return (SingleInviteSaveFailed.fromState(state)
            ..error = ArgumentError('Not a league team invite'))
          .build();
    }
  }

  Future<SingleInviteState> _acceptInviteAsAdmin(
      SingleInviteEventAcceptInviteAsAdmin event, Invite invite) async {
    if (invite is InviteAsAdmin) {
      //
      // Invite as admin.
      //
      await db.addAdmin(invite.teamUid, db.currentUser.uid);

      // This should cause the data to update
      await db.firestoreInviteDelete(invite.uid);
      crashes.logInviteAccepted("admin", invite.teamUid);
      return SingleInviteDeleted();
    } else {
      return (SingleInviteSaveFailed.fromState(state)
            ..error = ArgumentError('Not an admin invite'))
          .build();
    }
  }

  Future<SingleInviteState> _acceptInviteToTeam(
      SingleInviteEventAcceptInviteToTeam event, Invite invite) async {
    if (invite is InviteToTeam) {
      //
      // Invite to team
      //
      if (event.playerNameToUid == null ||
          event.relationship == null ||
          invite.seasonUid == null) {
        return (SingleInviteSaveFailed.fromState(state)
              ..error = ArgumentError(
                  'Relationship or playerNameToUse or seasonUid incorrect'))
            .build();
      }
      crashes.logInviteAccepted("teamSeason", invite.seasonUid);
      // We add ourselves to the season.
      Season doc = await db.getSingleSeason(invite.seasonUid).first;
      if (doc == null) {
        return (SingleInviteSaveFailed.fromState(state)
              ..error = ArgumentError('Season alreeady added to tea,'))
            .build();
      }
      //invite.playerName.clear();
      for (String name in event.playerNameToUid.keys) {
        String playerUid;
        if (event.playerNameToUid[name].compareTo(SingleInviteBloc.createNew) ==
            0) {
          PlayerBuilder player = new PlayerBuilder();
          player.name = name;
          player.usersData[db.currentUser.uid] = PlayerUserInternal((b) => b
            ..relationship = event.relationship[name]
            ..added = true);
          playerUid = await db.createPlayer(player.build());
        } else {
          playerUid = event.playerNameToUid[name];
        }

        crashes.logInviteAccepted("teamPlayer", playerUid);
        // We add ourselves to the season.
        Season doc = await db.getSingleSeason(invite.seasonUid).first;
        if (doc != null) {
          // Update it!  First we add to the player.
          SeasonPlayer seasonPlayer = new SeasonPlayer((b) => b
            ..playerUid = playerUid
            ..role = invite.role);
          await db.addPlayerToSeason(invite.seasonUid, seasonPlayer);
          await db.firestoreInviteDelete(invite.uid);
        }
      }

      // This should cause the data to update
      await db.firestoreInviteDelete(invite.uid);
      return SingleInviteDeleted();
    } else {
      return (SingleInviteSaveFailed.fromState(state)
            ..error = ArgumentError('Not a team invite'))
          .build();
    }
  }

  @override
  String get id => inviteUid;

  @override
  Stream<SingleInviteState> mapEventToState(SingleInviteEvent event) async* {
    if (event is SingleInviteEventLoaded) {
      yield (SingleInviteLoaded.fromState(state)..invite = event.invite)
          .build();
    }
    // Delete the invite
    if (event is SingleInviteEventDeleteInvite) {
      yield SingleInviteSaving.fromState(state).build();
      // Leave it to do it's thing.  The main loop above should push back with
      // a change when it is committed.
      try {
        await db.firestoreInviteDelete(state.invite.uid);
        yield SingleInviteSaveDone.fromState(state).build();
        yield SingleInviteDeleted();
      } catch (e, stack) {
        yield (SingleInviteSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleInviteLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    // Accept the invite to the team.
    if (event is SingleInviteEventAcceptInviteToTeam) {
      yield SingleInviteSaving.fromState(state).build();
      try {
        yield await _acceptInviteToTeam(event, state.invite);
        yield SingleInviteSaveDone.fromState(state).build();
        yield SingleInviteDeleted();
      } catch (e, stack) {
        yield (SingleInviteSaveFailed.fromState(state)..error = e).build();
        yield SingleInviteLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    // Accept the invite to the team.
    if (event is SingleInviteEventAcceptInviteToPlayer) {
      yield SingleInviteSaving.fromState(state).build();
      try {
        yield await _acceptInviteToPlayer(event, state.invite);
        yield SingleInviteSaveDone.fromState(state).build();
        yield SingleInviteDeleted();
      } catch (e, stack) {
        yield (SingleInviteSaveFailed.fromState(state)..error = e).build();
        yield SingleInviteLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    // Accept the invite to the team.
    if (event is SingleInviteEventAcceptInviteToLeagueAdmin) {
      yield SingleInviteSaving.fromState(state).build();
      try {
        yield await _acceptInviteToLeagueAdmin(event, state.invite);
        yield SingleInviteSaveDone.fromState(state).build();
        yield SingleInviteDeleted();
      } catch (e, stack) {
        yield (SingleInviteSaveFailed.fromState(state)..error = e).build();
        yield SingleInviteLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    // Accept the invite to the team.
    if (event is SingleInviteEventAcceptInviteToLeagueTeam) {
      yield SingleInviteSaving.fromState(state).build();
      try {
        yield await _acceptInviteToLeagueTeam(event, state.invite);
        yield SingleInviteSaveDone.fromState(state).build();
        yield SingleInviteDeleted();
      } catch (e, stack) {
        yield (SingleInviteSaveFailed.fromState(state)..error = e).build();
        yield SingleInviteLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    // Accept the invite to the team.
    if (event is SingleInviteEventAcceptInviteAsAdmin) {
      yield SingleInviteSaving.fromState(state).build();
      try {
        yield await _acceptInviteAsAdmin(event, state.invite);
        yield SingleInviteSaveDone.fromState(state).build();
        yield SingleInviteDeleted();
      } catch (e, stack) {
        yield (SingleInviteSaveFailed.fromState(state)..error = e).build();
        yield SingleInviteLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    // Accept the invite to the team.
    if (event is SingleInviteEventAcceptInviteToClub) {
      yield SingleInviteSaving.fromState(state).build();
      try {
        yield await _acceptInviteToClub(event, state.invite);
        yield SingleInviteSaveDone.fromState(state).build();
        yield SingleInviteDeleted();
      } catch (e, stack) {
        yield (SingleInviteSaveFailed.fromState(state)..error = e).build();
        yield SingleInviteLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is _SingleInviteEventUnloaded) {
      yield SingleInviteDeleted();
    }

    if (event is _SingleInviteUpdated) {
      yield (SingleInviteLoaded.fromState(state)..invite = event.invite)
          .build();
    }
  }

  @override
  SingleInviteState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return SingleInviteUninitialized();
    }

    SingleInviteBlocStateType type =
        SingleInviteBlocStateType.valueOf(json["type"]);
    switch (type) {
      case SingleInviteBlocStateType.Uninitialized:
        return SingleInviteUninitialized();
      case SingleInviteBlocStateType.Loaded:
        var ret = SingleInviteLoaded.fromMap(json);

        return ret;
      case SingleInviteBlocStateType.Deleted:
        return SingleInviteDeleted.fromMap(json);
      case SingleInviteBlocStateType.SaveFailed:
        return SingleInviteSaveFailed.fromMap(json);
      case SingleInviteBlocStateType.Saving:
        return SingleInviteSaving.fromMap(json);
      case SingleInviteBlocStateType.SaveDone:
        return SingleInviteSaveDone.fromMap(json);
    }
    return SingleInviteUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleInviteState state) {
    return state.toMap();
  }
}
