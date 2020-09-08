import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'data/inviteblocstate.dart';
import 'internal/blocstoload.dart';

abstract class InviteEvent extends Equatable {}

class _InviteEventLogout extends InviteEvent {
  @override
  List<Object> get props => [];
}

class _InviteEventNewDataLoaded extends InviteEvent {
  final BuiltMap<String, Invite> invites;
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
class InviteBloc extends HydratedBloc<InviteEvent, InviteState> {
  final CoordinationBloc coordinationBloc;
  final DatabaseUpdateModel databaseUpdateModel;
  final AnalyticsSubsystem analyticsSubsystem;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<Iterable<Invite>> _inviteChangeSub;

  bool _loadingFirestore = false;

  InviteBloc(
      {@required this.coordinationBloc,
      @required this.analyticsSubsystem,
      @required this.databaseUpdateModel})
      : super(InviteUninitialized()) {
    coordinationBloc
        .add(CoordinationEventTrackLoading(toLoad: BlocsToLoad.Invite));
    _coordSub = coordinationBloc.listen((CoordinationState coordinationState) {
      if (coordinationState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;

        add(_InviteEventLogout());
      } else if (coordinationState is CoordinationStateLoadingFirestore) {
        if (!_loadingFirestore) {
          _loadingFirestore = true;

          _startLoadingFirestore(coordinationState);
        }
      }
    });
  }

  @override
  Future<void> close() async {
    await _coordSub?.cancel();
    _inviteChangeSub?.cancel();
    _inviteChangeSub = null;
    return super.close();
  }

  void _startLoadingFirestore(CoordinationStateLoadingFirestore state) {
    add(_InviteEventLoadFirestore(uid: state.uid));
  }

  void _onInviteUpdated(Iterable<Invite> invites) {
    MapBuilder<String, Invite> newInvites = new MapBuilder<String, Invite>();

    add(_InviteEventNewDataLoaded(invites: newInvites.build(), uid: state.uid));
  }

  @override
  Stream<InviteState> mapEventToState(InviteEvent event) async* {
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
      yield (InviteLoaded.fromState(state)
            ..invites = event.invites.toBuilder()
            ..uid = event.uid)
          .build();
      coordinationBloc
          .add(CoordinationEventLoadedData(loaded: BlocsToLoad.Invite));
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

  @override
  InviteState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return InviteUninitialized();
    }

    InviteBlocStateType type = InviteBlocStateType.valueOf(json["type"]);
    switch (type) {
      case InviteBlocStateType.Uninitialized:
        return InviteUninitialized();
      case InviteBlocStateType.Loaded:
        TraceProxy invitesTrace = analyticsSubsystem.newTrace("invitesData");
        invitesTrace.start();
        var loaded = InviteLoaded.fromMap(json);
        print(
            'End invites ${coordinationBloc.start.difference(new DateTime.now())} ${loaded.invites.length}');
        invitesTrace.stop();
        return loaded;
      default:
        return InviteUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(InviteState state) {
    return state.toMap();
  }
}
