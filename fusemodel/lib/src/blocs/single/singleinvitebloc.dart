import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'invitebloc.dart';
import 'teambloc.dart';

///
/// Basic state for all the data in this system.
///
class SingleInviteState extends Equatable {
  final Invite invite;

  SingleInviteState({@required this.invite});
}

///
/// No data at all yet.
///
class SingleInviteUninitialized extends SingleInviteState {
  SingleInviteUninitialized() : super(invite: null);

  @override
  String toString() {
    return 'SingleInviteUninitialized{}';
  }
}

///
/// Doing something.
///
class SingleInviteLoaded extends SingleInviteState {
  SingleInviteLoaded({@required Invite invite}) : super(invite: invite);

  @override
  String toString() {
    return 'SingleInviteLoaded{}';
  }
}

///
/// Doing something.
///
class SingleInviteSaving extends SingleInviteState {
  SingleInviteSaving({@required Invite invite}) : super(invite: invite);

  @override
  String toString() {
    return 'SingleInviteLoaded{}';
  }
}

///
/// Data is now loaded.
///
class SingleInviteDeleted extends SingleInviteState {
  SingleInviteDeleted({@required Invite invite}) : super(invite: invite);

  @override
  String toString() {
    return 'SingleInviteDeleted{}';
  }
}

///
/// Failed to save the invite (this could be an accept or an add).
///
class SingleInviteSaveFailed extends SingleInviteState {
  final Error error;

  SingleInviteSaveFailed({@required Invite failedInvite, @required this.error})
      : super(invite: failedInvite);

  @override
  String toString() {
    return 'SingleInviteSaveFailed{}';
  }
}

class SingleInviteEvent extends Equatable {}

///
/// Accept this invite and do whatever than means in acceptance.
///
class SingleInviteEventAcceptInviteToTeam extends SingleInviteEvent {
  final Map<String, String> playerNameToUid;
  final Map<String, Relationship> relationship;
  final String teamUid;
  final String seasonUid;

  SingleInviteEventAcceptInviteToTeam(
      {this.playerNameToUid, this.relationship, this.teamUid, this.seasonUid});
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
  final String playerUid;
  final String seasonUid;

  SingleInviteEventAcceptInviteToLeagueTeam(
      {@required this.teamUid,
      @required this.playerUid,
      @required this.seasonUid});
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
  final String teamUid;

  SingleInviteEventAcceptInviteAsAdmin({@required this.teamUid});
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
  final String inviteUid;

  SingleInviteEventLoaded({@required this.inviteUid});
}

///
/// Adds this invite into the set of invites.  We fire and forget this.
///
class SingleInviteEventAddInviteToPlayer extends SingleInviteEvent {
  String playerUid;
  String email;

  SingleInviteEventAddInviteToPlayer(
      {@required this.playerUid, @required this.email});
}

///
/// Deals with specific invites to allow for accepting/deleting/etc of the
/// invites.
///
class SingleInviteBloc extends Bloc<SingleInviteEvent, SingleInviteState> {
  final InviteBloc inviteBloc;
  final TeamBloc teamBloc;
  final String inviteUid;

  StreamSubscription<InviteState> _inviteState;

  /// Used for the season/team etc if we want to make a new one.
  static String createNew = "createNew";

  SingleInviteBloc(
      {@required this.inviteBloc,
      @required this.teamBloc,
      @required this.inviteUid}) {
    _inviteState = inviteBloc.state.listen((InviteState state) {
      if (state is InviteLoaded) {
        if (state.invites.containsKey(inviteUid)) {
          if (state.invites[inviteUid] == currentState.invite) {
            dispatch(_SingleInviteUpdated(
                invite: state.invites[currentState.invite.uid]));
          }
        }
      } else {
        dispatch(_SingleInviteEventUnloaded());
      }
    });
    if (inviteBloc.currentState is InviteLoaded) {
      if (inviteBloc.currentState.invites.containsKey(inviteUid)) {
        if (inviteBloc.currentState.invites[inviteUid] == currentState.invite) {
          dispatch(_SingleInviteUpdated(
              invite:
                  inviteBloc.currentState.invites[currentState.invite.uid]));
        }
      }
    }
  }

  @override
  void dispose() {
    _inviteState?.cancel();
    super.dispose();
  }

  @override
  SingleInviteState get initialState => new SingleInviteUninitialized();

  Future<SingleInviteState> _acceptInviteToClub(
      SingleInviteEventAcceptInviteToClub event, Invite invite) async {
    if (invite is InviteToClub) {
      //
      // Invite to club.
      //
      await inviteBloc.databaseUpdateModel.addUserToClub(
          invite.clubUid, inviteBloc.currentState.uid, invite.admin);
      // This should cause the data to update
      await inviteBloc.databaseUpdateModel.firestoreInviteDelete(invite);
      return SingleInviteDeleted(invite: invite);
    } else {
      //
      // End this thing.
      //
      return SingleInviteSaveFailed(
          failedInvite: invite, error: ArgumentError('Not a club invite'));
    }
  }

  Future<SingleInviteState> _acceptInviteToLeagueAdmin(
      SingleInviteEventAcceptInviteToLeagueAdmin event, Invite invite) async {
    if (invite is InviteToLeagueAsAdmin) {
      //
      // Invite to league admin
      //
      if (invite.leagueUid != null) {
        await inviteBloc.databaseUpdateModel.addUserToLeague(
            invite.leagueUid, inviteBloc.currentState.uid, true);
      }
      if (invite.leagueSeasonUid != null) {
        await inviteBloc.databaseUpdateModel.addUserToLeagueSeason(
            invite.leagueSeasonUid, inviteBloc.currentState.uid, true);
      }
      if (invite.leagueDivisonUid != null) {
        await inviteBloc.databaseUpdateModel.addUserToLeagueDivison(
            invite.leagueDivisonUid, inviteBloc.currentState.uid, true);
      }

      // This should cause the data to update
      await inviteBloc.databaseUpdateModel.firestoreInviteDelete(invite);
      return SingleInviteDeleted(invite: invite);
    } else {
      return SingleInviteSaveFailed(
          failedInvite: invite,
          error: ArgumentError('Not a league admin invite'));
    }
  }

  Future<SingleInviteState> _acceptInviteToPlayer(
      SingleInviteEventAcceptInviteToPlayer event, Invite invite) async {
    if (invite is InviteToPlayer) {
      //
      // Invite to player!!!
      //
      if (event.relationship == null) {
        return SingleInviteSaveFailed(
            failedInvite: invite,
            error: ArgumentError("Relationship incorrect"));
      }
      inviteBloc.analyticsSubsystem.logSignUp(signUpMethod: "inviteToPlayer");
      // Add ourselves to the player.
      bool exists =
          await inviteBloc.databaseUpdateModel.playerExists(invite.playerUid);
      if (!exists) {
        return SingleInviteSaveFailed(
            failedInvite: invite,
            error: ArgumentError("already added to player"));
      }
      // Yay!  We have a player.
      PlayerUser playerUser = new PlayerUser((b) => b
        ..userUid = inviteBloc.currentState.uid
        ..relationship = event.relationship);
      await inviteBloc.databaseUpdateModel
          .addUserToPlayer(invite.playerUid, playerUser);

      // This should cause the data to update
      await inviteBloc.databaseUpdateModel.firestoreInviteDelete(invite);
      return SingleInviteDeleted(invite: invite);
    } else {
      return SingleInviteSaveFailed(
          failedInvite: invite, error: ArgumentError('Not a player invite'));
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
        team.admins.add(inviteBloc.currentState.uid);
        var pregen = inviteBloc.databaseUpdateModel.precreateTeamUid();
        var pregenSeason = inviteBloc.databaseUpdateModel.precreateUidSeason();
        team.uid = pregen.documentID;
        Season season = new Season((b) => b
          ..uid = pregenSeason.documentID
          ..name = invite.leagueSeasonName
          ..teamUid = team.uid
          ..record = WinRecordBuilder()
          ..players = ListBuilder([
            SeasonPlayer((b) => b
              ..playerUid = inviteBloc.currentState.uid
              ..role = RoleInTeam.NonPlayer)
          ]));
        team.currentSeason = pregenSeason.documentID;
        LeagueOrTournamentTeam leagueTeam = await inviteBloc.databaseUpdateModel
            .getLeagueTeamData(invite.leagueTeamUid);
        if (leagueTeam.seasonUid != null) {
          // Someone beat them to it!
          // TODO: Say someone beat them to it.
        } else {
          leagueTeam =
              leagueTeam.rebuild((b) => b..seasonUid = pregenSeason.documentID);
          await inviteBloc.databaseUpdateModel.updateLeagueTeam(leagueTeam);
          inviteBloc.coordinationBloc.databaseUpdateModel
              .addFirestoreTeam(team.build(), pregen);
          inviteBloc.coordinationBloc.databaseUpdateModel
              .addFirestoreSeason(season, pregenSeason);
        }
      } else if (event.seasonUid == SingleInviteBloc.createNew) {
        var pregenSeason = inviteBloc.databaseUpdateModel.precreateUidSeason();

        Season season = new Season((b) => b
          ..uid = pregenSeason.documentID
          ..name = invite.leagueSeasonName
          ..teamUid = event.teamUid);
        inviteBloc.coordinationBloc.databaseUpdateModel
            .addFirestoreSeason(season, pregenSeason);
      } else {
        Season season = teamBloc
            .currentState.teamsByPlayer[event.teamUid].seasons[event.seasonUid];
        await inviteBloc.databaseUpdateModel.connectLeagueTeamToSeason(
            invite.leagueTeamUid, inviteBloc.currentState.uid, season);
      }
      // This should cause the data to update
      await inviteBloc.databaseUpdateModel.firestoreInviteDelete(invite);
      return SingleInviteDeleted(invite: invite);
    } else {
      return SingleInviteSaveFailed(
          failedInvite: invite,
          error: ArgumentError('Not a league team invite'));
    }
  }

  Future<SingleInviteState> _acceptInviteAsAdmin(
      SingleInviteEventAcceptInviteAsAdmin event, Invite invite) async {
    if (invite is InviteAsAdmin) {
      //
      // Invite as admin.
      //
      await inviteBloc.databaseUpdateModel
          .addAdmin(invite.teamUid, inviteBloc.currentState.uid);

      // This should cause the data to update
      await inviteBloc.databaseUpdateModel.firestoreInviteDelete(invite);
      return SingleInviteDeleted(invite: invite);
    } else {
      return SingleInviteSaveFailed(
          failedInvite: invite, error: ArgumentError('Not an admin invite'));
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
        return SingleInviteSaveFailed(
            failedInvite: invite,
            error: ArgumentError(
                "Relationship or playerNameToUse or seasonUid incorrect"));
      }
      inviteBloc.analyticsSubsystem.logSignUp(signUpMethod: "inviteToTeam");
      // We add ourselves to the season.
      Season doc =
          await inviteBloc.databaseUpdateModel.getSeason(invite.seasonUid);
      if (doc == null) {
        return SingleInviteSaveFailed(
            failedInvite: invite,
            error: ArgumentError("season already added to team"));
      }
      //invite.playerName.clear();
      for (String name in event.playerNameToUid.keys) {
        String playerUid;
        if (event.playerNameToUid[name].compareTo(SingleInviteBloc.createNew) ==
            0) {
          PlayerBuilder player = new PlayerBuilder();
          player.name = name;
          player.users[inviteBloc.coordinationBloc.authenticationBloc
              .currentUser.uid] = new PlayerUser((b) => b
            ..relationship = event.relationship[name]
            ..userUid =
                inviteBloc.coordinationBloc.authenticationBloc.currentUser.uid);
          playerUid =
              await inviteBloc.databaseUpdateModel.createPlayer(player.build());
        } else {
          playerUid = event.playerNameToUid[name];
        }

        teamBloc.coordinationBloc.analyticsSubsystem
            .logSignUp(signUpMethod: "inviteToTeam");
        // We add ourselves to the season.
        Season doc =
            await inviteBloc.databaseUpdateModel.getSeason(invite.seasonUid);
        if (doc != null) {
          // Update it!  First we add to the player.
          SeasonPlayer seasonPlayer = new SeasonPlayer((b) => b
            ..playerUid = playerUid
            ..role = invite.role);
          await inviteBloc.databaseUpdateModel
              .addPlayerToSeason(invite.seasonUid, seasonPlayer);
          await inviteBloc.databaseUpdateModel.firestoreInviteDelete(invite);
        }
      }

      // This should cause the data to update
      await inviteBloc.databaseUpdateModel.firestoreInviteDelete(invite);
      return SingleInviteDeleted(invite: invite);
    } else {
      return SingleInviteSaveFailed(
          failedInvite: invite, error: ArgumentError('Not a team invite'));
    }
  }

  @override
  Stream<SingleInviteState> mapEventToState(SingleInviteEvent event) async* {
    if (event is SingleInviteEventLoaded) {
      if (inviteBloc.currentState.invites.containsKey(event.inviteUid)) {
        yield SingleInviteLoaded(
            invite: inviteBloc.currentState.invites[event.inviteUid]);
      } else {
        yield SingleInviteDeleted(invite: currentState.invite);
      }
    }
    // Delete the invite
    if (event is SingleInviteEventDeleteInvite) {
      yield SingleInviteSaving(invite: currentState.invite);
      // Leave it to do it's thing.  The main loop above should push back with
      // a change when it is committed.
      try {
        await inviteBloc.databaseUpdateModel
            .firestoreInviteDelete(currentState.invite);
        yield SingleInviteDeleted(invite: currentState.invite);
      } catch (e) {
        yield SingleInviteSaveFailed(
            error: e, failedInvite: currentState.invite);
      }
    }

    // Accept the invite to the team.
    if (event is SingleInviteEventAcceptInviteToTeam) {
      yield SingleInviteSaving(invite: currentState.invite);
      try {
        yield await _acceptInviteToTeam(event, currentState.invite);
      } catch (e) {
        yield SingleInviteSaveFailed(
            error: e, failedInvite: currentState.invite);
      }
    }

    // Accept the invite to the team.
    if (event is SingleInviteEventAcceptInviteToPlayer) {
      yield SingleInviteSaving(invite: currentState.invite);
      try {
        yield await _acceptInviteToPlayer(event, currentState.invite);
      } catch (e) {
        yield SingleInviteSaveFailed(
            error: e, failedInvite: currentState.invite);
      }
    }

    // Accept the invite to the team.
    if (event is SingleInviteEventAcceptInviteToLeagueAdmin) {
      yield SingleInviteSaving(invite: currentState.invite);
      try {
        yield await _acceptInviteToLeagueAdmin(event, currentState.invite);
      } catch (e) {
        yield SingleInviteSaveFailed(
            error: e, failedInvite: currentState.invite);
      }
    }

    // Accept the invite to the team.
    if (event is SingleInviteEventAcceptInviteToLeagueTeam) {
      yield SingleInviteSaving(invite: currentState.invite);
      try {
        yield await _acceptInviteToLeagueTeam(event, currentState.invite);
      } catch (e) {
        yield SingleInviteSaveFailed(
            error: e, failedInvite: currentState.invite);
      }
    }

    // Accept the invite to the team.
    if (event is SingleInviteEventAcceptInviteAsAdmin) {
      yield SingleInviteSaving(invite: currentState.invite);
      try {
        yield await _acceptInviteAsAdmin(event, currentState.invite);
      } catch (e) {
        yield SingleInviteSaveFailed(
            error: e, failedInvite: currentState.invite);
      }
    }

    // Accept the invite to the team.
    if (event is SingleInviteEventAcceptInviteToClub) {
      yield SingleInviteSaving(invite: currentState.invite);
      try {
        yield await _acceptInviteToClub(event, currentState.invite);
      } catch (e) {
        yield SingleInviteSaveFailed(
            error: e, failedInvite: currentState.invite);
      }
    }

    if (event is _SingleInviteEventUnloaded) {
      yield SingleInviteDeleted(invite: currentState.invite);
    }

    if (event is _SingleInviteUpdated) {
      yield SingleInviteLoaded(invite: event.invite);
    }

    if (event is SingleInviteEventAddInviteToPlayer) {
      if (!teamBloc.playerBloc.currentState.players
          .containsKey(event.playerUid)) {
        InviteToPlayer invite = new InviteToPlayer((b) => b
          ..playerUid = event.playerUid
          ..playerName = 'Unknown'
          ..email = event.email
          ..sentByUid =
              inviteBloc.coordinationBloc.authenticationBloc.currentUser.uid);
        yield SingleInviteSaveFailed(
            failedInvite: invite, error: ArgumentError("Player doesn't exist"));
      } else {
        Player player =
            teamBloc.playerBloc.currentState.players[event.playerUid];
        InviteToPlayer invite = new InviteToPlayer((b) => b
          ..playerUid = player.uid
          ..playerName = player.name
          ..email = event.email
          ..sentByUid =
              inviteBloc.coordinationBloc.authenticationBloc.currentUser.uid);
        yield SingleInviteSaving(invite: invite);
        try {
          await inviteBloc.databaseUpdateModel.inviteUserToPlayer(
              playerUid: player.uid,
              playerName: player.name,
              email: event.email);
          yield SingleInviteLoaded(invite: invite);
        } catch (e) {
          yield SingleInviteSaveFailed(failedInvite: invite, error: e);
        }
      }
    }
  }
}
