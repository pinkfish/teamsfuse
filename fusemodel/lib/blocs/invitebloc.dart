import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'authenticationbloc.dart';

///
/// Basic state for all the data in this system.
///
class InviteState extends Equatable {
  final Map<String, Invite> invites;
  final String uid;

  InviteState({@required this.invites, @required this.uid});
}

///
/// No data at all yet.
///
class InviteUninitialized extends InviteState {
  InviteUninitialized() : super(invites: {}, uid: null);

  @override
  String toString() {
    return 'InviteUninitialized{}';
  }
}

///
/// Doing something.
///
class InviteLoading extends InviteState {
  InviteLoading({@required Map<String, Invite> invites, @required String uid})
      : super(invites: invites, uid: uid);

  @override
  String toString() {
    return 'InviteUninitialized{}';
  }
}

///
/// Data is now loaded.
///
class InviteData extends InviteState {
  InviteData({@required Map<String, Invite> invites, @required String uid})
      : super(invites: invites, uid: uid);

  @override
  String toString() {
    return 'InviteData{}';
  }
}

///
/// Successfully completed the invite flow.
///
class InviteAcceptFailed extends InviteState {
  final Invite failedInvite;

  InviteAcceptFailed(
      {@required Map<String, Invite> invites,
      @required String uid,
      @required this.failedInvite})
      : super(invites: invites, uid: uid);

  @override
  String toString() {
    return 'InviteData{}';
  }
}

class InviteEvent extends Equatable {}

///
/// Accept this invite and do whatever than means in acceptance.
///
class InviteEventAcceptInvite extends InviteEvent {
  final String inviteUid;
  final String season;
  final String playerUid;
  final Relationship relationship;
  final String teamUid;
  final String seasonUid;

  /// Used for the season/team etc if we want to make a new one.
  static String createNew = "createNew";

  InviteEventAcceptInvite(
      {@required this.inviteUid,
      this.season,
      this.playerUid,
      this.relationship,
      this.teamUid,
      this.seasonUid});
}

///
/// Delete this invite.  No way jose!
///
class InviteEventDeleteInvite extends InviteEvent {
  final String inviteUid;

  InviteEventDeleteInvite({@required this.inviteUid});
}

class _InviteEventUserLoaded extends InviteEvent {
  final String uid;
  final TraceProxy loadingTrace;
  final TraceProxy sqlTrace;
  final DateTime start;

  _InviteEventUserLoaded(
      {@required this.uid,
      @required this.loadingTrace,
      @required this.sqlTrace,
      @required this.start});

  @override
  String toString() {
    return 'PlayerDataUpdates{}';
  }
}

class _InviteEventLogout extends InviteEvent {}

class _InviteEventNewDataLoaded extends InviteEvent {
  final Map<String, Invite> invites;
  final String uid;

  _InviteEventNewDataLoaded({@required this.invites, @required this.uid});
}

///
/// Handles the work around the invites and invites system inside of
/// the app.
///
class InviteBloc extends Bloc<InviteEvent, InviteState> {
  final AuthenticationBloc authenticationBloc;
  final PersistenData persistentData;
  final DatabaseUpdateModel databaseUpdateModel;
  final AnalyticsSubsystem analyticsSubsystem;

  StreamSubscription<AuthenticationState> _authSub;
  StreamSubscription<FirestoreChangedData> _inviteChangeSub;

  InviteBloc(
      {@required this.authenticationBloc,
      @required this.persistentData,
      @required this.analyticsSubsystem,
      @required this.databaseUpdateModel}) {
    _authSub = authenticationBloc.state.listen((AuthenticationState state) {
      if (state is AuthenticationLoggedIn) {
        _startLoading(state);
      } else {
        dispatch(_InviteEventLogout());
      }
    });
    if (authenticationBloc.currentState is AuthenticationLoggedIn) {
      _startLoading(authenticationBloc.currentState);
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _inviteChangeSub?.cancel();
    _inviteChangeSub = null;
  }

  void _startLoading(AuthenticationLoggedIn state) {
    dispatch(_InviteEventUserLoaded(
        uid: state.user.uid,
        loadingTrace: state.loadingTrace,
        sqlTrace: state.sqlTrace,
        start: state.start));
  }

  @override
  InviteState get initialState => new InviteUninitialized();

  void _onInviteUpdated(List<FirestoreWrappedData> query) {
    Map<String, Invite> newInvites = new Map<String, Invite>();

    // Completely clear the invite table.
    persistentData.clearTable(PersistenData.invitesTable);
    query.forEach((FirestoreWrappedData doc) {
      String uid = doc.id;
      Invite invite = InviteFactory.makeInviteFromJSON(uid, doc.data);
      newInvites[uid] = invite;
      persistentData.updateElement(
          PersistenData.invitesTable, uid, invite.toJSON());
    });
    dispatch(
        _InviteEventNewDataLoaded(invites: newInvites, uid: currentState.uid));
  }

  Future<InviteState> _acceptInvite(
      InviteEventAcceptInvite event, Invite invite) async {
    if (invite is InviteToClub) {
      //
      // Invite to club.
      //
      await databaseUpdateModel.addUserToClub(
          invite.clubUid, currentState.uid, invite.admin);
    } else if (invite is InviteAsAdmin) {
      //
      // Invite as admin.
      //
      await databaseUpdateModel.addAdmin(invite.teamUid, currentState.uid);
    } else if (invite is InviteToLeagueAsAdmin) {
      //
      // Invite to league admin
      //
      if (invite.leagueUid != null) {
        await databaseUpdateModel.addUserToLeague(
            invite.leagueUid, currentState.uid, true);
      }
      if (invite.leagueSeasonUid != null) {
        await databaseUpdateModel.addUserToLeagueSeason(
            invite.leagueSeasonUid, currentState.uid, true);
      }
      if (invite.leagueDivisonUid != null) {
        await databaseUpdateModel.addUserToLeagueDivison(
            invite.leagueDivisonUid, currentState.uid, true);
      }
    } else if (invite is InviteToLeagueTeam) {
      //
      // Invite to league team
      //
      Season season;

      if (event.teamUid == InviteEventAcceptInvite.createNew) {
        Team team = new Team(
          name: invite.leagueTeamName,
        );
        team.admins.add(UserDatabaseData.instance.userUid);
        await team.updateFirestore();
        String teamUid = team.uid;
        season = new Season(
            name: invite.leagueSeasonName,
            teamUid: teamUid,
            record: WinRecord(),
            players: <SeasonPlayer>[
              SeasonPlayer(
                playerUid: UserDatabaseData.instance.mePlayer.uid,
                role: RoleInTeam.NonPlayer,
              )
            ]);
        team.currentSeason = season.precreateUid();
        LeagueOrTournamentTeam leagueTeam = await UserDatabaseData
            .instance.updateModel
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
      } else if (event.seasonUid == InviteEventAcceptInvite.createNew) {
        season = new Season(
          name: invite.leagueSeasonName,
          teamUid: event.teamUid,
        );
        await season.updateFirestore();
      } else {
        season = UserDatabaseData
            .instance.teams[event.teamUid].seasons[event.seasonUid];
      }
      await databaseUpdateModel.connectLeagueTeamToSeason(
          invite.leagueTeamUid, currentState.uid, season);
    } else if (invite is InviteToTeam) {
      //
      // Invite to team
      //
      if (event.playerUid == null) {
        return InviteAcceptFailed(
            invites: currentState.invites,
            uid: currentState.uid,
            failedInvite: invite);
      }
      analyticsSubsystem.logSignUp(signUpMethod: "inviteToTeam");
      // We add ourselves to the season.
      Season doc = await databaseUpdateModel.getSeason(invite.seasonUid);
      if (doc == null) {
        return InviteAcceptFailed(
            invites: currentState.invites,
            uid: currentState.uid,
            failedInvite: invite);
      }
      // Update it!  First we add to the player.
      SeasonPlayer seasonPlayer =
          new SeasonPlayer(playerUid: event.playerUid, role: invite.role);
      await databaseUpdateModel.addPlayerToSeason(
          invite.seasonUid, seasonPlayer);
    } else if (invite is InviteToPlayer) {
      //
      // Invite to player!!!
      //
      if (event.relationship == null) {
        return InviteAcceptFailed(
            invites: currentState.invites,
            uid: currentState.uid,
            failedInvite: invite);
      }
      analyticsSubsystem.logSignUp(signUpMethod: "inviteToPlayer");
      // Add ourselves to the player.
      bool exists = await databaseUpdateModel.playerExists(invite.playerUid);
      if (!exists) {
        return InviteAcceptFailed(
            invites: currentState.invites,
            uid: currentState.uid,
            failedInvite: invite);
      }
      // Yay!  We have a player.
      PlayerUser playerUser = new PlayerUser(
          userUid: currentState.uid, relationship: event.relationship);
      await databaseUpdateModel.addUserToPlayer(invite.playerUid, playerUser);
    } else {
      //
      // End this thing.
      //
      return InviteAcceptFailed(
          invites: currentState.invites,
          uid: currentState.uid,
          failedInvite: invite);
    }
    // This should cause the data to update
    await databaseUpdateModel.firestoreInviteDelete(invite);
  }

  @override
  Stream<InviteState> mapEventToState(
      InviteState currentState, InviteEvent event) async* {
    if (event is _InviteEventUserLoaded) {
      // Reset stuff first.
      _inviteChangeSub?.cancel();
      _inviteChangeSub = null;

      TraceProxy invitesTrace = analyticsSubsystem.newTrace("invitesData");
      invitesTrace.start();
      Map<String, Map<String, dynamic>> data =
          await persistentData.getAllElements(PersistenData.invitesTable);
      Map<String, Invite> newInvites = new Map<String, Invite>();
      data.forEach((String uid, Map<String, dynamic> input) {
        event.sqlTrace.incrementCounter("invites");
        invitesTrace.incrementCounter("invites");
        Invite invite = InviteFactory.makeInviteFromJSON(uid, input);
        newInvites[uid] = invite;
      });
      print('End invites ${event.start.difference(new DateTime.now())}');
      invitesTrace.stop();
      yield InviteLoading(invites: newInvites, uid: event.uid);

      print('getting invites');
      InitialSubscription inviteInitialData =
          databaseUpdateModel.getInvites(authenticationBloc.currentUser.email);
      inviteInitialData.startData.then((List<FirestoreWrappedData> data) {
        event.loadingTrace?.incrementCounter("invite");
        this._onInviteUpdated(data);
      });
      _inviteChangeSub =
          inviteInitialData.stream.listen((FirestoreChangedData data) {
        this._onInviteUpdated(data.newList);
      });
      print(
          'End firebase invites ${event.start.difference(new DateTime.now())}');
    }

    // New data from above.  Mark ourselves as done.
    if (event is _InviteEventNewDataLoaded) {
      yield InviteData(invites: event.invites, uid: event.uid);
    }

    // Unload everything.
    if (event is _InviteEventLogout) {
      yield InviteUninitialized();
      _inviteChangeSub?.cancel();
      _inviteChangeSub = null;
    }

    // Delete the invite
    if (event is InviteEventDeleteInvite) {
      // Only do this is if still there.
      if (currentState.invites.containsKey(event.inviteUid)) {
        // Mark ourselves as loading.
        yield InviteLoading(
            invites: currentState.invites, uid: currentState.uid);
        // Leave it to do it's thing.  The main loop above should push back with
        // a change when it is committed.
        databaseUpdateModel
            .firestoreInviteDelete(currentState.invites[event.inviteUid]);
      }
    }

    // Accept the invite.
    if (event is InviteEventAcceptInvite) {
      yield InviteLoading(invites: currentState.invites, uid: currentState.uid);
      Invite invite = currentState.invites[event.inviteUid];
      yield await _acceptInvite(event, invite);
    }
  }
}
