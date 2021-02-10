import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

abstract class SingleclubCoachEvent extends Equatable {}

///
/// Updates the clubCoach (writes it out to firebase.
///
class SingleClubCoachUpdate extends SingleclubCoachEvent {
  final Coach coach;
  final File image;

  SingleClubCoachUpdate({@required this.coach, this.image});

  @override
  List<Object> get props => [coach, image];
}

///
/// Delete this coach from the world.
///
class SingleClubCoachDelete extends SingleclubCoachEvent {
  @override
  List<Object> get props => [];
}

class _SingleClubCoachDeleted extends SingleclubCoachEvent {
  @override
  List<Object> get props => [];
}

class _SingleClubCoachNew extends SingleclubCoachEvent {
  final Coach coach;

  _SingleClubCoachNew({this.coach});
  @override
  List<Object> get props => [coach];
}


///
/// Bloc to handle updates and state of a specific clubCoach.
///
class SingleclubCoachBloc
    extends AsyncHydratedBloc<SingleclubCoachEvent, SingleClubCoachState> {
  final DatabaseUpdateModel db;
  final AnalyticsSubsystem crashes;
  final String clubCoachUid;
  final String clubUid;

  StreamSubscription<Coach> _clubCoachSub;

  SingleclubCoachBloc(
      {@required this.db,
      @required this.clubCoachUid,
      @required this.clubUid,
      @required this.crashes})
      : super(
            SingleClubCoachUninitialized(), "SingleclubCoach" + clubCoachUid) {
    _clubCoachSub = db
        .getClubCoach(clubUid: clubUid, clubCoachUid: clubCoachUid)
        .listen((clubCoach) {
      if (clubCoach != null) {
        add(_SingleclubCoachNewclubCoach(newclubCoach: clubCoach));
      } else {
        add(_SingleclubCoachDeleted());
      }
    });
    _clubCoachSub.onError((e, stack) {
      add(_SingleclubCoachDeleted());
      if (e is Exception) {
        crashes.recordException(e, stack);
      } else if (e is Error) {
        crashes.recordError(e, stack);
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _clubCoachSub?.cancel();
    _inviteSub?.cancel();
  }

  @override
  Stream<SingleClubCoachState> mapEventToState(
      SingleclubCoachEvent event) async* {
    if (event is _SingleclubCoachNewclubCoach) {
      yield (SingleClubCoachLoaded.fromState(state)
            ..clubCoach = event.newclubCoach.toBuilder())
          .build();
    }

    // The clubCoach is deleted.
    if (event is _SingleclubCoachDeleted) {
      yield SingleClubCoachDeleted.fromState(state).build();
    }

    // Save the clubCoach.
    if (event is SingleclubCoachUpdate) {
      yield SingleClubCoachSaving.fromState(state).build();
      try {
        Coach clubCoach = event.clubCoach;
        await db.updateClubCoach(
            clubCoach, event.image != null ? event.image.readAsBytes() : null);
        yield SingleClubCoachSaveDone.fromState(state).build();
        yield (SingleclubCoachLoaded.fromState(state)
              ..clubCoach = event.clubCoach.toBuilder())
            .build();
      } catch (e, stack) {
        yield (SingleclubCoachSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleclubCoachLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleclubCoachUpdateImage) {
      yield SingleClubCoachSaving.fromState(state).build();
      try {
        Uri clubCoachUri = await db.updateClubCoach(
            state.clubCoach, await event.image.readAsBytes());

        yield SingleClubCoachSaveDone.fromState(state).build();
        yield (SingleClubCoachLoaded.fromState(state)
              ..clubCoach = (state.clubCoach.toBuilder()
                ..photoUrl = clubCoachUri.toString()))
            .build();
      } catch (e, stack) {
        yield (SingleClubCoachSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleClubCoachLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleClubCoachDelete) {
      yield SingleClubCoachSaving.fromState(state).build();
      try {
        await db.deleteClubCoach(state.coach);
        yield SingleClubCoachSaveDone.fromState(state).build();
        yield SingleClubCoachLoaded.fromState(state).build();
      } catch (e, stack) {
        yield (SingleClubCoachSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleClubCoachLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }
  }

  @override
  SingleclubCoachState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return SingleclubCoachUninitialized();
    }

    try {
      SingleclubCoachBlocStateType type =
          SingleclubCoachBlocStateType.valueOf(json["type"]);
      switch (type) {
        case SingleclubCoachBlocStateType.Uninitialized:
          return SingleclubCoachUninitialized();
        case SingleclubCoachBlocStateType.Loaded:
          return SingleclubCoachLoaded.fromMap(json);
        case SingleclubCoachBlocStateType.Deleted:
          return SingleclubCoachDeleted.fromMap(json);
        case SingleclubCoachBlocStateType.SaveFailed:
          return SingleclubCoachSaveFailed.fromMap(json);
        case SingleclubCoachBlocStateType.Saving:
          return SingleclubCoachSaving.fromMap(json);
        case SingleclubCoachBlocStateType.SaveDone:
          return SingleclubCoachSaveDone.fromMap(json);
      }
    } catch (e, stack) {
      if (e is Error) {
        crashes.recordError(e, stack);
      } else {
        crashes.recordException(e, stack);
      }
      print(e);
    }

    return SingleclubCoachUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleclubCoachState state) {
    return state.toMap();
  }
}
