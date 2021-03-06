import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import 'additemstate.dart';

abstract class AddLeagueOrTournamentEvent extends Equatable {}

///
/// Adds this player into the set of players.
///
class AddLeagueOrTournamentEventCommit extends AddLeagueOrTournamentEvent {
  final LeagueOrTournament leagueOrTournament;
  final Uint8List imageFile;

  AddLeagueOrTournamentEventCommit(
      {@required this.leagueOrTournament, @required this.imageFile});

  @override
  List<Object> get props => [leagueOrTournament, imageFile];
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddLeagueOrTournamentBloc
    extends Bloc<AddLeagueOrTournamentEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;

  AddLeagueOrTournamentBloc({@required this.coordinationBloc})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(
      AddLeagueOrTournamentEvent event) async* {
    // Create a new Player.
    if (event is AddLeagueOrTournamentEventCommit) {
      yield AddItemSaving();

      try {
        var uid = await coordinationBloc.databaseUpdateModel
            .updateLeague(event.leagueOrTournament);
        yield AddItemDone(uid: uid);
      } catch (e, stack) {
        coordinationBloc.analytics.recordException(e, stack);

        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
