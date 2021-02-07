import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import 'additemstate.dart';

abstract class AddClubEvent extends Equatable {}

///
/// Adds this player into the set of players.
///
class AddClubEventCommit extends AddClubEvent {
  final Club club;
  final File imageFile;

  AddClubEventCommit({@required this.club, @required this.imageFile});

  @override
  List<Object> get props => [this.club, this.imageFile];
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddClubBloc extends Bloc<AddClubEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;

  AddClubBloc({@required this.coordinationBloc})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddClubEvent event) async* {
    // Create a new Player.
    if (event is AddClubEventCommit) {
      yield AddItemSaving();

      try {
        ClubBuilder updated = event.club.toBuilder();
        var wrap = coordinationBloc.databaseUpdateModel.precreateClubUid();
        updated.membersData[coordinationBloc.authenticationBloc.currentUser
            .uid] = AddedOrAdmin((b) => b..admin = true);
        updated.uid = wrap.documentID;
        String uid = await coordinationBloc.databaseUpdateModel
            .addClub(wrap, updated.build());
        if (event.imageFile != null) {
          updated.uid = uid;
          coordinationBloc.databaseUpdateModel.updateClubImage(
              updated.build(), await event.imageFile.readAsBytes());
        }
        yield AddItemDone(uid: uid);
      } catch (e, stack) {
        coordinationBloc.analytics.recordException(e, stack);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
