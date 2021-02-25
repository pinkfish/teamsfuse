import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'additemstate.dart';

/// The basic event for all the add newsItem events
abstract class AddNewsItemEvent extends Equatable {}

///
/// Adds this newsitem into the set of news items.
///
class AddNewsItemEventCommit extends AddNewsItemEvent {
  /// The newsItem to add.
  final NewsItem newsItem;

  /// Event to commit the add newsItem to the database.
  AddNewsItemEventCommit({@required this.newsItem});

  @override
  List<Object> get props => [newsItem];
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddNewsItemBloc extends Bloc<AddNewsItemEvent, AddItemState> {
  /// The database model to use for updates to the db.
  final DatabaseUpdateModel db;

  /// The analytics system to use to track logged in ness.
  final AnalyticsSubsystem crashes;

  /// Adds the newsItem into the system with a nice block.
  AddNewsItemBloc({@required this.db, @required this.crashes})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddNewsItemEvent event) async* {
    // Create a new Player.
    if (event is AddNewsItemEventCommit) {
      yield AddItemSaving();

      try {
        var newsItem = await db.addClubNews(event.newsItem);

        yield AddItemDone(uid: newsItem.uid);
      } on Exception catch (e, stack) {
        crashes.recordException(e, stack);
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
