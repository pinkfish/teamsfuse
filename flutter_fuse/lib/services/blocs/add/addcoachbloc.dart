import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'additemstate.dart';

abstract class AddCoachEvent extends Equatable {}

///
/// Adds this player into the set of players.
///
class AddCoachEventCommit extends AddCoachEvent {
  final Coach coach;
  final File imageFile;

  AddCoachEventCommit({@required this.coach, @required this.imageFile});

  @override
  List<Object> get props => [this.coach, this.imageFile];
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddCoachBloc extends Bloc<AddCoachEvent, AddItemState> {
  final DatabaseUpdateModel db;
  final AnalyticsSubsystem crashes;

  AddCoachBloc({@required this.db, @required this.crashes})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddCoachEvent event) async* {
    // Create a new Player.
    if (event is AddCoachEventCommit) {
      yield AddItemSaving();

      try {
        var coach = await db.addClubCoach(
            event.coach, await event.imageFile.readAsBytes());

        yield AddItemDone(uid: coach.uid);
      } catch (e, stack) {
        crashes.recordException(e, stack);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
