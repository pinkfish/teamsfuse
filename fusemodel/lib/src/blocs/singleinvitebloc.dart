import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'invitebloc.dart';

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

///
/// Data is now loaded.
///
class SingleInviteDoesntExist extends SingleInviteState {
  final String inviteUid;
  SingleInviteDoesntExist({@required this.inviteUid}) : super(invite: null);

  @override
  String toString() {
    return 'SingleInviteDoesntExist{}';
  }
}

class SingleInviteEvent extends Equatable {}

///
/// Accept this invite and do whatever than means in acceptance.
///
class SingleInviteEventAcceptInvite extends SingleInviteEvent {
  final String inviteUid;
  final String season;
  final Map<String, String> playerNameToUid;
  final Map<String, Relationship> relationship;
  final String teamUid;
  final String seasonUid;

  /// Used for the season/team etc if we want to make a new one.
  static String createNew = "createNew";

  SingleInviteEventAcceptInvite(
      {@required this.inviteUid,
      this.season,
      this.playerNameToUid,
      this.relationship,
      this.teamUid,
      this.seasonUid});
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

  StreamSubscription<InviteState> _inviteState;

  SingleInviteBloc({@required this.inviteBloc}) {
    _inviteState = inviteBloc.state.listen((InviteState state) {
      if (state is InviteLoaded) {
        _startLoading(state);
      } else {
        dispatch(_SingleInviteEventUnloaded());
      }
    });
  }

  @override
  void dispose() {
    _inviteState?.cancel();
  }

  void _startLoading(InviteLoaded state) {
    // See if this is diffeerent for our current invite.
    if (currentState.invite != null) {
      if (state.invites[currentState.invite.uid]
              .compareTo(currentState.invite) !=
          0) {
        dispatch(_SingleInviteUpdated(
            invite: state.invites[currentState.invite.uid]));
      }
    }
  }

  @override
  SingleInviteState get initialState => new SingleInviteUninitialized();

  Future<bool> _acceptTeamInvite(InviteToTeam invite, String playerUid) async {
    inviteBloc.analyticsSubsystem.logSignUp(signUpMethod: "inviteToTeam");
    // We add ourselves to the season.
    Season doc =
        await inviteBloc.databaseUpdateModel.getSeason(invite.seasonUid);
    if (doc != null) {
      // Update it!  First we add to the player.
      SeasonPlayer seasonPlayer =
          new SeasonPlayer(playerUid: playerUid, role: invite.role);
      await inviteBloc.databaseUpdateModel
          .addPlayerToSeason(invite.seasonUid, seasonPlayer);
      return true;
    }
    return false;
  }

  Future<SingleInviteState> _acceptInvite(
      SingleInviteEventAcceptInvite event) async {
    Invite invite = currentState.invite;
    if (invite is InviteToClub) {
      //
      // Invite to club.
      //
      await inviteBloc.databaseUpdateModel.addUserToClub(
          invite.clubUid, inviteBloc.currentState.uid, invite.admin);
    } else if (invite is InviteAsAdmin) {
      //
      // Invite as admin.
      //
      await inviteBloc.databaseUpdateModel
          .addAdmin(invite.teamUid, inviteBloc.currentState.uid);
    } else if (invite is InviteToLeagueAsAdmin) {
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
    } else if (invite is InviteToLeagueTeam) {
      //
      // Invite to league team
      //
      Season season;

      if (event.teamUid == SingleInviteEventAcceptInvite.createNew) {
        Team team = new Team(
          name: invite.leagueTeamName,
        );
        team.admins.add(inviteBloc.currentState.uid);
        await team.updateFirestore();
        String teamUid = team.uid;
        season = new Season(
            name: invite.leagueSeasonName,
            teamUid: teamUid,
            record: WinRecord(),
            players: <SeasonPlayer>[
              SeasonPlayer(
                playerUid: inviteBloc.currentState.uid,
                role: RoleInTeam.NonPlayer,
              )
            ]);
        team.currentSeason = season.precreateUid();
        LeagueOrTournamentTeam leagueTeam = await inviteBloc.databaseUpdateModel
            .getLeagueTeamData(invite.leagueTeamUid);
        if (leagueTeam.seasonUid != null) {
          // Someone beat them to it!
          // TODO: Say someone beat them to it.
        } else {
          leagueTeam.seasonUid = season.precreateUid();
          await season.updateFirestore();
          await leagueTeam.firebaseUpdate();
          await team.updateFirestore();
        }
      } else if (event.seasonUid == SingleInviteEventAcceptInvite.createNew) {
        season = new Season(
          name: invite.leagueSeasonName,
          teamUid: event.teamUid,
        );
        await season.updateFirestore();
      } else {
        season = UserDatabaseData
            .instance.teams[event.teamUid].seasons[event.seasonUid];
      }
      await inviteBloc.databaseUpdateModel.connectLeagueTeamToSeason(
          invite.leagueTeamUid, inviteBloc.currentState.uid, season);
    } else if (invite is InviteToTeam) {
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
        return SingleInviteSaveFailed(failedInvite: invite);
      }
      invite.playerName.clear();
      for (String name in event.playerNameToUid.keys) {
        String uid;
        if (event.playerNameToUid[name]
                .compareTo(SingleInviteEventAcceptInvite.createNew) ==
            0) {
          Player player = new Player();
          player.name = name;
          player.users = new Map<String, PlayerUser>();
          player.users[inviteBloc.currentState.uid] = new PlayerUser();
          player.users[inviteBloc.currentState.uid].relationship =
              event.relationship[name];
          uid = await inviteBloc.databaseUpdateModel.createPlayer(player);
        } else {
          uid = event.playerNameToUid[name];
        }
        await _acceptTeamInvite(invite, uid);
      }
    } else if (invite is InviteToPlayer) {
      //
      // Invite to player!!!
      //
      if (event.relationship == null &&
          event.relationship.containsKey(invite.playerName)) {
        return SingleInviteSaveFailed(
            failedInvite: invite,
            error: ArgumentError("Relationship incorrect"));
      }
      inviteBloc.analyticsSubsystem.logSignUp(signUpMethod: "inviteToPlayer");
      // Add ourselves to the player.
      bool exists =
          await inviteBloc.databaseUpdateModel.playerExists(invite.playerUid);
      if (!exists) {
        return SingleInviteSaveFailed(failedInvite: invite);
      }
      // Yay!  We have a player.
      PlayerUser playerUser = new PlayerUser(
          userUid: inviteBloc.currentState.uid,
          relationship: event.relationship[invite.playerName]);
      await inviteBloc.databaseUpdateModel
          .addUserToPlayer(invite.playerUid, playerUser);
    } else {
      //
      // End this thing.
      //
      return SingleInviteSaveFailed(failedInvite: invite);
    }
    // This should cause the data to update
    await inviteBloc.databaseUpdateModel.firestoreInviteDelete(invite);
    return SingleInviteDeleted(invite: invite);
  }

  @override
  Stream<SingleInviteState> mapEventToState(SingleInviteEvent event) async* {
    if (event is SingleInviteEventLoaded) {
      if (inviteBloc.currentState.invites.containsKey(event.inviteUid)) {
        yield SingleInviteLoaded(
            invite: inviteBloc.currentState.invites[event.inviteUid]);
      } else {
        yield SingleInviteDoesntExist(inviteUid: event.inviteUid);
      }
    }
    // Delete the invite
    if (event is SingleInviteEventDeleteInvite) {
      yield SingleInviteSaving(invite: currentState.invite);
      // Leave it to do it's thing.  The main loop above should push back with
      // a change when it is committed.
      await inviteBloc.databaseUpdateModel
          .firestoreInviteDelete(currentState.invite);
      yield SingleInviteDeleted(invite: currentState.invite);
    }

    // Accept the invite.
    if (event is SingleInviteEventAcceptInvite) {
      yield SingleInviteSaving(invite: currentState.invite);
      yield await _acceptInvite(event as SingleInviteEventAcceptInvite);
    }

    if (event is _SingleInviteEventUnloaded) {
      yield SingleInviteDeleted(invite: currentState.invite);
    }

    if (event is _SingleInviteUpdated) {
      yield SingleInviteLoaded(invite: event.invite);
    }

    if (event is SingleInviteEventAddInviteToPlayer) {
      if (!inviteBloc.playerBloc.currentState.players
          .containsKey(event.playerUid)) {
        InviteToPlayer invite = new InviteToPlayer(
            playerUid: event.playerUid,
            playerName: 'Unknown',
            email: event.email,
            sentByUid: inviteBloc.authenticationBloc.currentUser.uid);
        yield SingleInviteSaveFailed(
            failedInvite: invite, error: ArgumentError("Player doesn't exist"));
      } else {
        Player player =
            inviteBloc.playerBloc.currentState.players[event.playerUid];
        InviteToPlayer invite = new InviteToPlayer(
            playerUid: player.uid,
            playerName: player.name,
            email: event.email,
            sentByUid: inviteBloc.authenticationBloc.currentUser.uid);
        yield SingleInviteSaving(invite: invite);
        try {
          await inviteBloc.databaseUpdateModel
              .inviteUserToPlayer(player, email: event.email);
          yield SingleInviteLoaded(invite: invite);
        } catch (e) {
          yield SingleInviteSaveFailed(failedInvite: invite, error: e);
        }
      }
    }
  }
}
