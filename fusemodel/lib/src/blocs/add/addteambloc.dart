import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import 'additemstate.dart';

abstract class AddTeamEvent extends Equatable {}

///
/// Adds this player into the set of players.
///
class AddTeamEventCommit extends AddTeamEvent {
  final TeamBuilder team;
  final String seasonName;
  final String playerUid;
  final String clubUid;
  final File teamImage;

  AddTeamEventCommit(
      {@required this.team,
      @required this.playerUid,
      this.seasonName,
      this.clubUid,
      this.teamImage});

  @override
  // TODO: implement props
  List<Object> get props => [team, playerUid, seasonName, clubUid, teamImage];
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddTeamBloc extends Bloc<AddTeamEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;

  AddTeamBloc({@required this.coordinationBloc})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddTeamEvent event) async* {
    // Create a new Player.
    if (event is AddTeamEventCommit) {
      yield AddItemSaving();

      try {
        // Create the season too.
        ListBuilder<SeasonPlayer> players = ListBuilder<SeasonPlayer>();
        players.add(SeasonPlayer((b) => b
          ..playerUid = event.playerUid
          ..role = RoleInTeam.Player));
        Season season = Season((b) => b
          ..name = event.seasonName
          ..players = players);

        String uid = await coordinationBloc.databaseUpdateModel
            .addFirestoreTeam(
                event.team.build(), null, season, event.teamImage);

        yield AddItemDone(uid: uid);
      } catch (e) {
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
