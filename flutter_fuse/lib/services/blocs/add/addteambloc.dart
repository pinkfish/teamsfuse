import 'dart:async';
import 'dart:typed_data';

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
  final Uint8List teamImage;

  AddTeamEventCommit(
      {@required this.team,
      @required this.playerUid,
      this.seasonName,
      this.clubUid,
      this.teamImage});

  @override
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
        var players = <SeasonPlayer>[];
        players.add(SeasonPlayer((b) => b
          ..playerUid = event.playerUid.trim()
          ..role = RoleInTeam.Player));
        var entries = Map<String, BuiltMap<String, bool>>.fromEntries(
          [
            MapEntry<String, BuiltMap<String, bool>>(
              coordinationBloc.authenticationBloc.currentUser.uid,
              BuiltMap.of(
                Map<String, bool>.fromEntries(
                  [
                    ...players.map(
                      (e) => MapEntry(
                        e.playerUid.trim(),
                        true,
                      ),
                    ),
                    MapEntry('admin', true),
                    MapEntry('added', true),
                  ],
                ),
              ),
            ),
          ],
        );
        var season = Season((b) => b
          ..uid = ''
          ..teamUid = ''
          ..name = event.seasonName
          ..record = (WinRecordBuilder()
            ..loss = 0
            ..tie = 0
            ..win = 0)
          ..playersData =
              MapBuilder({for (var p in players) p.playerUid.trim(): p})
          ..users = MapBuilder(entries));
        var team = event.team;
        team.uid = '';
        team.adminsData = MapBuilder({
          coordinationBloc.authenticationBloc.currentUser.uid:
              BuiltMap<String, bool>.of({
            'added': true,
            'admin': true,
          }),
        });
        team.users = MapBuilder(entries);

        var uid = await coordinationBloc.databaseUpdateModel.addFirestoreTeam(
            team.build(),
            null,
            season,
            event.teamImage == null ? null : event.teamImage);

        yield AddItemDone(uid: uid);
      } catch (e, stack) {
        coordinationBloc.analytics.recordException(e, stack);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
