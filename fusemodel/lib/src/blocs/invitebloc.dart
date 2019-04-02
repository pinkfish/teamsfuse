import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'authenticationbloc.dart';
import 'playerbloc.dart';

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
class InviteLoaded extends InviteState {
  InviteLoaded({@required Map<String, Invite> invites, @required String uid})
      : super(invites: invites, uid: uid);

  @override
  String toString() {
    return 'InviteUninitialized{}';
  }
}

class InviteEvent extends Equatable {}

class _InviteEventUserLoaded extends InviteEvent {
  final String uid;

  _InviteEventUserLoaded({@required this.uid});

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
  final PlayerBloc playerBloc;
  final PersistenData persistentData;
  final DatabaseUpdateModel databaseUpdateModel;
  final AnalyticsSubsystem analyticsSubsystem;

  StreamSubscription<AuthenticationState> _authSub;
  StreamSubscription<FirestoreChangedData> _inviteChangeSub;

  InviteBloc(
      {@required this.authenticationBloc,
      @required this.playerBloc,
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
    dispatch(_InviteEventUserLoaded(uid: state.user.uid));
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

  @override
  Stream<InviteState> mapEventToState(InviteEvent event) async* {
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
        playerBloc.sqlTrace.incrementCounter("invites");
        invitesTrace.incrementCounter("invites");
        Invite invite = InviteFactory.makeInviteFromJSON(uid, input);
        newInvites[uid] = invite;
      });
      print('End invites ${playerBloc.start.difference(new DateTime.now())}');
      invitesTrace.stop();
      yield InviteLoaded(invites: newInvites, uid: event.uid);

      print('getting invites');
      InitialSubscription inviteInitialData =
          databaseUpdateModel.getInvites(authenticationBloc.currentUser.email);
      inviteInitialData.startData.then((List<FirestoreWrappedData> data) {
        playerBloc.loadingTrace?.incrementCounter("invite");
        this._onInviteUpdated(data);
      });
      _inviteChangeSub =
          inviteInitialData.stream.listen((FirestoreChangedData data) {
        this._onInviteUpdated(data.newList);
      });
      print(
          'End firebase invites ${playerBloc.start.difference(new DateTime.now())}');
    }

    // New data from above.  Mark ourselves as done.
    if (event is _InviteEventNewDataLoaded) {
      yield InviteLoaded(invites: event.invites, uid: event.uid);
    }

    // Unload everything.
    if (event is _InviteEventLogout) {
      yield InviteUninitialized();
      _inviteChangeSub?.cancel();
      _inviteChangeSub = null;
    }
  }
}
