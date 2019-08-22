import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import 'additemstate.dart';

abstract class AddSeasonEvent extends Equatable {}

///
/// Adds this player into the set of players.
///
class AddSeasonEventCommit extends AddSeasonEvent {
  final String teamUid;
  final String name;
  final ListBuilder<SeasonPlayer> players;

  AddSeasonEventCommit(
      {@required this.teamUid, @required this.name, @required this.players});
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddSeasonBloc extends Bloc<AddSeasonEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;

  AddSeasonBloc({@required this.coordinationBloc}) {}

  @override
  AddItemState get initialState => new AddItemUninitialized();

  @override
  Stream<AddItemState> mapEventToState(AddSeasonEvent event) async* {
    // Create a new Player.
    if (event is AddSeasonEventCommit) {
      yield AddItemSaving();

      try {
        Season season = Season((b) => b
          ..teamUid = event.teamUid
          ..name = event.name
          ..players = event.players);
        Season ret = await coordinationBloc.databaseUpdateModel
            .addFirestoreSeason(season, null);
        yield AddItemDone(uid: ret.uid);
      } catch (e) {
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}