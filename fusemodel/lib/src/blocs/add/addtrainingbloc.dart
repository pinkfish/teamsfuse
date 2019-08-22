import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import 'additemstate.dart';

abstract class AddTrainingEvent extends Equatable {}

///
/// Adds this game into the set of games.
///
class AddTrainingEventCommit extends AddTrainingEvent {
  final Game newGame;
  final List<DateTime> repeatTimes;

  AddTrainingEventCommit({@required this.newGame, @required this.repeatTimes});
}

///
/// Deals with specific games to allow for accepting/deleting/etc of the
/// games.
///
class AddTrainingBloc extends Bloc<AddTrainingEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;

  AddTrainingBloc({@required this.coordinationBloc}) {}

  @override
  AddItemState get initialState => new AddItemUninitialized();

  @override
  Stream<AddItemState> mapEventToState(AddTrainingEvent event) async* {
    // Create a new Game.
    if (event is AddTrainingEventCommit) {
      yield AddItemSaving();

      try {
        Game updatedGame = event.newGame;
        await coordinationBloc.databaseUpdateModel
            .addTrainingEvents(updatedGame, event.repeatTimes);

        yield AddItemDone(uid: null);
      } catch (e) {
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}