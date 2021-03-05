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

  @override
  List<Object> get props => [playerName, relationship];
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddPlayerBloc extends Bloc<AddPlayerEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;

  AddPlayerBloc({@required this.coordinationBloc})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddPlayerEvent event) async* {
    // Create a new Player.
    if (event is AddPlayerEventCommit) {
      yield AddItemSaving();

      try {
        var updatedPlayer = Player((b) => b
          ..name = event.playerName
          ..usersData[coordinationBloc.authenticationBloc.currentUser.uid] =
              PlayerUserInternal((b) => b
                ..relationship = event.relationship
                ..added = true));
        var uid = await coordinationBloc.databaseUpdateModel
            .addFirestorePlayer(updatedPlayer);
        yield AddItemDone(uid: uid);
      } catch (e, stack) {
        coordinationBloc.analytics.recordException(e, stack);

        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
