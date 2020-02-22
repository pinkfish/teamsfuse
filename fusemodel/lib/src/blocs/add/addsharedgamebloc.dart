import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import 'additemstate.dart';

abstract class AddSharedGameEvent extends Equatable {}

///
/// Adds this shared game into the set of games.
///
class AddSharedGameEventCommit extends AddSharedGameEvent {
  final GameSharedData newSharedData;

  AddSharedGameEventCommit({@required this.newSharedData});

  @override
  // TODO: implement props
  List<Object> get props => [newSharedData];
}

///
/// Deals with specific shared games to allow for adding.
///
class AddSharedGameBloc extends Bloc<AddSharedGameEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;

  AddSharedGameBloc({@required this.coordinationBloc}) {}

  @override
  AddItemState get initialState => new AddItemUninitialized();

  @override
  Stream<AddItemState> mapEventToState(AddSharedGameEvent event) async* {
    // Create a new Game.
    if (event is AddSharedGameEventCommit) {
      yield AddItemSaving();

      try {
        String uid = await coordinationBloc.databaseUpdateModel
            .updateFirestoreSharedGame(event.newSharedData);
        yield AddItemDone(uid: uid);
      } catch (e) {
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
