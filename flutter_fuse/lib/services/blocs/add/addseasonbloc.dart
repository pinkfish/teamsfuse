import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import '../playerbloc.dart';
import 'additemstate.dart';

abstract class AddSeasonEvent extends Equatable {}

///
/// Adds this player into the set of players.
///
class AddSeasonEventCommit extends AddSeasonEvent {
  final String teamUid;
  final String name;
  final BuiltList<SeasonPlayer> players;

  AddSeasonEventCommit(
      {@required this.teamUid, @required this.name, @required this.players});

  @override
  List<Object> get props => [teamUid, name, players];
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddSeasonBloc extends Bloc<AddSeasonEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;
  final PlayerBloc playersBloc;

  AddSeasonBloc({@required this.coordinationBloc, @required this.playersBloc})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddSeasonEvent event) async* {
    // Create a new Player.
    if (event is AddSeasonEventCommit) {
      yield AddItemSaving();

      try {
        var map = Map<String, SeasonPlayer>.fromIterable(event.players,
            key: (p) => p.playerUid,
            value: (p) => p.rebuild((b) => b..added = true));
        // Only setup ourselves, not the whole team.
        var usersMap = Map<String, Map<String, bool>>();
        usersMap[coordinationBloc.authenticationBloc.currentUser.uid] =
            Map<String, bool>();
        usersMap[coordinationBloc.authenticationBloc.currentUser.uid]["added"] =
            true;
        // Add in all my players.
        for (final pl in event.players) {
          if (playersBloc.state.players.containsKey(pl.playerUid)) {
            usersMap[coordinationBloc.authenticationBloc.currentUser.uid]
            [pl.playerUid] = true;
          }
        }

        Season season = Season((b) => b
          ..teamUid = event.teamUid
          ..name = event.name
          ..playersData = MapBuilder(map)
          ..record.win = 0
          ..record.loss = 0
          ..record.tie = 0
          ..uid = "");
        Season ret = await coordinationBloc.databaseUpdateModel
            .addFirestoreSeason(season, null);
        yield AddItemDone(uid: ret.uid);
      } catch (e) {
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
