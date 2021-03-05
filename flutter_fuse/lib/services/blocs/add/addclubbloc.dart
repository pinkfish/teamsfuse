import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import 'additemstate.dart';

/// Basic event for adding things to the club.
abstract class AddClubEvent extends Equatable {}

///
/// Adds this player into the set of players.
///
class AddClubEventCommit extends AddClubEvent {
  /// The club to add.
  final Club club;

  /// The image for the club to add.
  final Uint8List imageFile;

  /// The add event to write this new club out.
  AddClubEventCommit({@required this.club, @required this.imageFile});

  @override
  List<Object> get props => [club, imageFile];
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddClubBloc extends Bloc<AddClubEvent, AddItemState> {
  /// The coordination bloc to handle talking to the database and users.
  final CoordinationBloc coordinationBloc;

  /// Create a new add club bloc with the right details.
  AddClubBloc({@required this.coordinationBloc})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddClubEvent event) async* {
    // Create a new Player.
    if (event is AddClubEventCommit) {
      yield AddItemSaving();

      try {
        var updated = event.club.toBuilder();
        var wrap = coordinationBloc.databaseUpdateModel.precreateClubUid();
        updated.membersData[coordinationBloc.authenticationBloc.currentUser
            .uid] = AddedOrAdmin((b) => b..admin = true);
        updated.uid = wrap.documentID;
        var uid = await coordinationBloc.databaseUpdateModel
            .addClub(wrap, updated.build());
        if (event.imageFile != null) {
          updated.uid = uid;
          await coordinationBloc.databaseUpdateModel.updateClubImage(
              updated.build(),
              event.imageFile != null ? event.imageFile : null);
        }
        yield AddItemDone(uid: uid);
      } on Exception catch (e, stack) {
        coordinationBloc.analytics.recordException(e, stack);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
