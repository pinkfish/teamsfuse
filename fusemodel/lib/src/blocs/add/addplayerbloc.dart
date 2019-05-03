import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import 'additemstate.dart';

abstract class AddPlayerEvent extends Equatable {}

///
/// Adds this player into the set of players.
///
class AddPlayerEventCommit extends AddPlayerEvent {
  final String playerName;
  final Relationship relationship;

  AddPlayerEventCommit(
      {@required this.playerName, @required this.relationship});
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddPlayerBloc extends Bloc<AddPlayerEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;

  AddPlayerBloc({@required this.coordinationBloc}) {}

  @override
  AddItemState get initialState => new AddItemUninitialized();

  @override
  Stream<AddItemState> mapEventToState(AddPlayerEvent event) async* {
    // Create a new Player.
    if (event is AddPlayerEventCommit) {
      yield AddItemSaving();

      try {
        Player updatedPlayer = Player((b) => b
          ..name = event.playerName
          ..users[coordinationBloc
              .authenticationBloc.currentUser.uid] = PlayerUser((b) => b
            ..relationship = event.relationship
            ..userUid = coordinationBloc.authenticationBloc.currentUser.uid));
        String uid = await coordinationBloc.databaseUpdateModel
            .addFirestorePlayer(updatedPlayer);
        yield AddItemDone(uid: uid);
      } catch (e) {
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
