import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';

///
/// Basic state for all the data in this system.
///
class InviteState extends Equatable {
  final Map<String, Invite> invites;
  final String uid;

  InviteState({@required this.invites, @required this.uid});

  @override
  List<Object> get props => [invites, uid];
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

abstract class InviteEvent extends Equatable {}

class _InviteEventUserLoaded extends InviteEvent {
  final String uid;

  _InviteEventUserLoaded({@required this.uid});

  @override
  String toString() {
    return '_InviteEventUserLoaded{}';
  }

  @override
  List<Object> get props => [uid];
}

class _InviteEventLogout extends InviteEvent {
  @override
  List<Object> get props => [];
}

class _InviteEventNewDataLoaded extends InviteEvent {
  final Map<String, Invite> invites;
  final String uid;

  _InviteEventNewDataLoaded({@required this.invites, @required this.uid});

  @override
  List<Object> get props => [invites, uid];
}

class _InviteEventLoadFirestore extends InviteEvent {
  final String uid;

  _InviteEventLoadFirestore({@required this.uid});

  @override
  String toString() {
    return '_InviteEventLoadFirestore{}';
  }

  @override
  List<Object> get props => [uid];
}

///
/// Deletes a specific invite.
///
class InviteEventDeleteInvite extends InviteEvent {
  final String inviteUid;

  InviteEventDeleteInvite({this.inviteUid});

  @override
  List<Object> get props => [inviteUid];
}

///
/// Handles the work around the invites and invites system inside of
/// the app.
///
class InviteBloc extends Bloc<InviteEvent, InviteState> {
  final CoordinationBloc coordinationBloc;
  final PersistenData persistentData;
  final DatabaseUpdateModel databaseUpdateModel;
  final AnalyticsSubsystem analyticsSubsystem;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<Iterable<Invite>> _inviteChangeSub;

  InviteBloc(
      {@required this.coordinationBloc,
      @required this.persistentData,
      @required this.analyticsSubsystem,
      @required this.databaseUpdateModel}) {
    _coordSub = coordinationBloc.listen((CoordinationState coordinationState) {
      if (coordinationState is CoordinationStateLoggedOut) {
        add(_InviteEventLogout());
      } else if (coordinationState is CoordinationStateStartLoadingSql) {
        _startLoading(coordinationState);
      } else if (coordinationState is CoordinationStateStartLoadingFirestore) {
        _startLoadingFirestore(coordinationState);
      }
    });
    if (coordinationBloc.state is CoordinationStateStartLoadingSql) {
      _startLoading(coordinationBloc.state);
    }
  }

  @override
  Future<void> close() async {
    await _coordSub?.cancel();
    _inviteChangeSub?.cancel();
    _inviteChangeSub = null;
    return super.close();
  }

  void _startLoading(CoordinationStateStartLoadingSql state) {
    add(_InviteEventUserLoaded(uid: state.uid));
  }

  void _startLoadingFirestore(CoordinationStateStartLoadingFirestore state) {
    add(_InviteEventLoadFirestore(uid: state.uid));
  }

  @override
  InviteState get initialState => new InviteUninitialized();

  void _onInviteUpdated(Iterable<Invite> invites) {
    Map<String, Invite> newInvites = new Map<String, Invite>();

    // Completely clear the invite table.
    persistentData.clearTable(PersistenData.invitesTable);
    for (Invite invite in invites) {
      newInvites[invite.uid] = invite;
      persistentData.updateElement(
          PersistenData.invitesTable, invite.uid, invite.toJSON());
    }
    add(_InviteEventNewDataLoaded(invites: newInvites, uid: state.uid));
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
        coordinationBloc.sqlTrace.incrementCounter("invites");
        invitesTrace.incrementCounter("invites");
        Invite invite = InviteFactory.makeInviteFromJSON(uid, input);
        newInvites[uid] = invite;
      });
      print(
          'End invites ${coordinationBloc.start.difference(new DateTime.now())}');
      invitesTrace.stop();
      yield InviteLoaded(invites: newInvites, uid: event.uid);
      coordinationBloc.add(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Invite, sql: true));
    }

    if (event is _InviteEventLoadFirestore) {
      print('getting invites');
      _inviteChangeSub = databaseUpdateModel
          .getInvites(coordinationBloc.authenticationBloc.currentUser.email)
          .listen((Iterable<Invite> invites) {
        coordinationBloc.loadingTrace?.incrementCounter("invite");
        this._onInviteUpdated(invites);
      });
      print(
          'End firebase invites ${coordinationBloc.start.difference(new DateTime.now())}');
    }

    // New data from above.  Mark ourselves as done.
    if (event is _InviteEventNewDataLoaded) {
      yield InviteLoaded(invites: event.invites, uid: event.uid);
      coordinationBloc.add(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Invite, sql: false));
    }

    // Unload everything.
    if (event is _InviteEventLogout) {
      yield InviteUninitialized();
      _inviteChangeSub?.cancel();
      _inviteChangeSub = null;
    }

    if (event is InviteEventDeleteInvite) {
      coordinationBloc.databaseUpdateModel
          .firestoreInviteDelete(event.inviteUid);
    }
  }
}
