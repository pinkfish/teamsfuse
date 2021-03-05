import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';

abstract class InviteEvent extends Equatable {}

class _InviteEventLogout extends InviteEvent {
  @override
  List<Object> get props => [];
}

class _InviteEventNewDataLoaded extends InviteEvent {
  final BuiltMap<String, Invite> invites;

  _InviteEventNewDataLoaded({@required this.invites});

  @override
  List<Object> get props => [
        invites,
      ];
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
  final AnalyticsSubsystem crashes;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<Iterable<Invite>> _inviteChangeSub;

  bool _loadingFirestore = false;

  InviteBloc(
      {@required this.coordinationBloc,
      @required this.crashes,
      @required this.databaseUpdateModel})
      : super(InviteUninitialized()) {
    _coordSub = coordinationBloc.listen((CoordinationState coordinationState) {
      if (coordinationState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;

        add(_InviteEventLogout());
      } else if (coordinationState is CoordinationStateLoadingFirestore) {
        _startLoadingFirestore(coordinationState);
      }
    });
    if (coordinationBloc.state is CoordinationStateLoadingFirestore) {
      _startLoadingFirestore(coordinationBloc.state);
    }
  }

  @override
  Future<void> close() async {
    await _coordSub?.cancel();
    await _inviteChangeSub?.cancel();
    _inviteChangeSub = null;
    return super.close();
  }

  void _startLoadingFirestore(CoordinationStateLoadingFirestore state) {
    if (!_loadingFirestore) {
      _loadingFirestore = true;

      add(_InviteEventLoadFirestore(uid: state.uid));
    }
  }

  void _onInviteUpdated(Iterable<Invite> invites) {
    var newInvites = MapBuilder<String, Invite>();

    add(_InviteEventNewDataLoaded(invites: newInvites.build()));
  }

  @override
  Stream<InviteState> mapEventToState(InviteEvent event) async* {
    if (event is _InviteEventLoadFirestore) {
      _inviteChangeSub =
          databaseUpdateModel.getInvites().listen((Iterable<Invite> invites) {
        coordinationBloc.loadingTrace?.incrementCounter('invite');
        _onInviteUpdated(invites);
      });
      print(
          'End firebase invites ${coordinationBloc.start.difference(clock.now())}');
    }

    // New data from above.  Mark ourselves as done.
    if (event is _InviteEventNewDataLoaded) {
      yield (InviteLoaded.fromState(state)..invites = event.invites.toBuilder())
          .build();
      coordinationBloc
          .add(CoordinationEventLoadedData(loaded: BlocsToLoad.Invite));
    }

    // Unload everything.
    if (event is _InviteEventLogout) {
      yield InviteUninitialized();
      await _inviteChangeSub?.cancel();
      _inviteChangeSub = null;
    }

    if (event is InviteEventDeleteInvite) {
      await coordinationBloc.databaseUpdateModel
          .firestoreInviteDelete(event.inviteUid);
    }
  }

  @override
  InviteState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey('type')) {
      return InviteUninitialized();
    }

    var type = InviteBlocStateType.valueOf(json['type']);
    switch (type) {
      case InviteBlocStateType.Uninitialized:
        return InviteUninitialized();
      case InviteBlocStateType.Loaded:
        try {
          var invitesTrace = crashes.newTrace('invitesData');
          invitesTrace.start();
          var loaded = InviteLoaded.fromMap(json);
          invitesTrace.stop();
          return loaded;
        } catch (e, stack) {
          if (e is Error) {
            crashes.recordError(e, stack);
          } else {
            crashes.recordException(e, stack);
          }
        }
        return InviteUninitialized();
      default:
        return InviteUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(InviteState state) {
    return state.toMap();
  }
}
