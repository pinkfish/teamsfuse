import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'additemstate.dart';

/// Basic event for adding things to the club.
abstract class AddMediaEvent extends Equatable {}

///
/// Adds this player into the set of players.
///
class AddMediaEventCommit extends AddMediaEvent {
  /// The season to add to.
  final String seasonUid;

  /// The team to add to.
  final String teamUid;

  /// The game to add to.
  final String gameUid;

  /// The player to add to.
  final String playerUid;

  /// The media type to add.
  final MediaType mediaType;

  /// The media to add.
  final Uint8List imageFile;

  /// The start time for the media data.
  final DateTime startAt;

  /// The description of the media info.
  final String description;

  /// The add event to write this new club out.
  AddMediaEventCommit({
    @required this.seasonUid,
    @required this.teamUid,
    @required this.gameUid,
    @required this.playerUid,
    @required this.mediaType,
    @required this.imageFile,
    @required this.description,
    @required this.startAt,
  });

  @override
  List<Object> get props => [
        seasonUid,
        teamUid,
        gameUid,
        playerUid,
        mediaType,
        imageFile,
        description,
        startAt,
      ];
}

///
/// Allows adding media into the system.
///
class AddMediaBloc extends Bloc<AddMediaEvent, AddItemState> {
  /// The coordination bloc to handle talking to the database and users.
  final DatabaseUpdateModel db;

  /// The system for crashes.
  final AnalyticsSubsystem crashes;

  /// Create a new add club bloc with the right details.
  AddMediaBloc({@required this.db, @required this.crashes})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddMediaEvent event) async* {
    // Create a new Player.
    if (event is AddMediaEventCommit) {
      yield AddItemSaving();

      try {
        final media = MediaInfo((b) => b
          ..uid = ''
          ..gameUid = event.gameUid
          ..seasonUid = event.seasonUid
          ..teamUid = event.teamUid
          ..length = Duration(seconds: 0));
        final uid = await db.addMedia(media: media, imageFile: event.imageFile);
        yield AddItemDone(uid: uid);
      } on Exception catch (e, stack) {
        crashes.recordException(e, stack);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
