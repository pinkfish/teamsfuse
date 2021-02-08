import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import 'additemstate.dart';

abstract class AddGameEvent extends Equatable {}

///
/// Adds this game into the set of games.
///
class AddGameEventCommit extends AddGameEvent {
  final Game newGame;

  AddGameEventCommit({@required this.newGame});

  @override
  List<Object> get props => [this.newGame];
}

///
/// Deals with specific games to allow for accepting/deleting/etc of the
/// games.
///
class AddGameBloc extends Bloc<AddGameEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;

  AddGameBloc({@required this.coordinationBloc})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddGameEvent event) async* {
    // Create a new Game.
    if (event is AddGameEventCommit) {
      yield AddItemSaving();

      try {
        Game updatedGame = event.newGame;
        Game g = await coordinationBloc.databaseUpdateModel
            .updateFirestoreGame(updatedGame, true);
        print(g);
        yield AddItemDone(uid: g.uid);
      } catch (e, stack) {
        coordinationBloc.analytics.recordException(e, stack);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
