import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'additemstate.dart';

/// The basic event for all the add coach events
abstract class AddCoachEvent extends Equatable {}

///
/// Adds this player into the set of players.
///
class AddCoachEventCommit extends AddCoachEvent {
  /// The coach to add.
  final Coach coach;

  /// The image file associated with the coach.
  final Uint8List imageFile;

  /// Event to commit the add coach to the database.
  AddCoachEventCommit({@required this.coach, @required this.imageFile});

  @override
  List<Object> get props => [coach, imageFile];
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddCoachBloc extends Bloc<AddCoachEvent, AddItemState> {
  /// The database model to use for updates to the db.
  final DatabaseUpdateModel db;

  /// The analytics system to use to track logged in ness.
  final AnalyticsSubsystem crashes;

  /// Adds the coach into the system with a nice block.
  AddCoachBloc({@required this.db, @required this.crashes})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddCoachEvent event) async* {
    // Create a new Player.
    if (event is AddCoachEventCommit) {
      yield AddItemSaving();

      try {
        var coach = await db.addClubCoach(event.coach, event.imageFile);

        yield AddItemDone(uid: coach.uid);
      } on Exception catch (e, stack) {
        crashes.recordException(e, stack);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
