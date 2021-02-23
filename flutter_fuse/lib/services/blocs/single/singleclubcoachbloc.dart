import 'dart:async';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

/// The base event type to use for all the club coach stuff.
abstract class SingleClubCoachEvent extends Equatable {}

///
/// Updates the clubCoach (writes it out to firebase.
///
class SingleClubCoachUpdate extends SingleClubCoachEvent {
  /// The new value for the coach.
  final Coach coach;

  /// Optional image, if this is set then the image is updated.
  final Uint8List image;

  /// Creates a new update for the coach details.
  SingleClubCoachUpdate({@required this.coach, this.image});

  @override
  List<Object> get props => [coach, image];
}

///
/// Delete this coach from the world.
///
class SingleClubCoachDelete extends SingleClubCoachEvent {
  @override
  List<Object> get props => [];
}

class _SingleClubCoachDeleted extends SingleClubCoachEvent {
  @override
  List<Object> get props => [];
}

class _SingleClubCoachNewCoach extends SingleClubCoachEvent {
  final Coach coach;

  _SingleClubCoachNewCoach({this.coach});
  @override
  List<Object> get props => [coach];
}

///
/// Bloc to handle updates and state of a specific clubCoach.
///
class SingleClubCoachBloc
    extends AsyncHydratedBloc<SingleClubCoachEvent, SingleClubCoachState> {
  /// The database to use for writing out to firestore.
  final DatabaseUpdateModel db;

  /// Handles all the crashes.
  final AnalyticsSubsystem crashes;

  /// The uid for the coach to load.
  final String coachUid;

  /// The uid for the club to load.
  final String clubUid;

  StreamSubscription<Coach> _clubCoachSub;

  ///
  /// Creates the club coach bloc.
  ///
  SingleClubCoachBloc(
      {@required this.db,
      @required this.coachUid,
      @required this.clubUid,
      @required this.crashes})
      : super(SingleClubCoachUninitialized(), "SingleclubCoach$coachUid") {
    _clubCoachSub =
        db.getSingleClubCoach(clubUid, coachUid).listen((clubCoach) {
      if (clubCoach != null) {
        add(_SingleClubCoachNewCoach(coach: clubCoach));
      } else {
        add(_SingleClubCoachDeleted());
      }
    });
    _clubCoachSub.onError((e, stack) {
      add(_SingleClubCoachDeleted());
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
  }

  @override
  Stream<SingleClubCoachState> mapEventToState(
      SingleClubCoachEvent event) async* {
    if (event is _SingleClubCoachNewCoach) {
      yield (SingleClubCoachLoaded.fromState(state)
            ..coach = event.coach.toBuilder())
          .build();
    }

    // The clubCoach is deleted.
    if (event is _SingleClubCoachDeleted) {
      yield SingleClubCoachDeleted.fromState(state).build();
    }

    // Save the clubCoach.
    if (event is SingleClubCoachUpdate) {
      yield SingleClubCoachSaving.fromState(state).build();
      try {
        var clubCoach = event.coach;
        await db.updateClubCoach(
            clubCoach, event.image != null ? await event.image : null);
        yield SingleClubCoachSaveDone.fromState(state).build();
        yield (SingleClubCoachLoaded.fromState(state)
              ..coach = event.coach.toBuilder())
            .build();
      } on Exception catch (e, stack) {
        yield (SingleClubCoachSaveFailed.fromState(state)..error = e).build();
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
      } on Exception catch (e, stack) {
        yield (SingleClubCoachSaveFailed.fromState(state)..error = e).build();
        yield SingleClubCoachLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }
  }

  @override
  SingleClubCoachState fromJson(Map<String, dynamic> json) {
    if (!(state is SingleClubCoachUninitialized)) {
      return state;
    }

    if (json == null || !json.containsKey("type")) {
      return SingleClubCoachUninitialized();
    }

    try {
      var type = SingleClubCoachBlocStateType.valueOf(json["type"]);
      switch (type) {
        case SingleClubCoachBlocStateType.Uninitialized:
          return SingleClubCoachUninitialized();
        case SingleClubCoachBlocStateType.Loaded:
          return SingleClubCoachLoaded.fromMap(json);
        case SingleClubCoachBlocStateType.Deleted:
          return SingleClubCoachDeleted.fromMap(json);
        case SingleClubCoachBlocStateType.SaveFailed:
          return SingleClubCoachSaveFailed.fromMap(json);
        case SingleClubCoachBlocStateType.Saving:
          return SingleClubCoachSaving.fromMap(json);
        case SingleClubCoachBlocStateType.SaveDone:
          return SingleClubCoachSaveDone.fromMap(json);
      }
    } on Exception catch (e, stack) {
      crashes.recordException(e, stack);
    }

    return SingleClubCoachUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleClubCoachState state) {
    return state.toMap();
  }
}
