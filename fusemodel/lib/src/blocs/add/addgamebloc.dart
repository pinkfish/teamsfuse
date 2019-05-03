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
  final String gameName;
  final Relationship relationship;

  AddGameEventCommit({@required this.gameName, @required this.relationship});
}

///
/// Deals with specific games to allow for accepting/deleting/etc of the
/// games.
///
class AddGameBloc extends Bloc<AddGameEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;

  AddGameBloc({@required this.coordinationBloc}) {}

  @override
  AddItemState get initialState => new AddItemUninitialized();

  @override
  Stream<AddItemState> mapEventToState(AddGameEvent event) async* {
    // Create a new Game.
    if (event is AddGameEventCommit) {
      yield AddItemSaving();

      try {
        Game updatedGame = Game((b) => b
          ..name = event.gameName
          ..users[coordinationBloc
              .authenticationBloc.currentUser.uid] = GameUser((b) => b
            ..relationship = event.relationship
            ..userUid = coordinationBloc.authenticationBloc.currentUser.uid));
        Game g = await coordinationBloc.databaseUpdateModel
            .updateFirestoreGame(updatedGame, true);
        yield AddItemDone(uid: g.uid);
      } catch (e) {
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
