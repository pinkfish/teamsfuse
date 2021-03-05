import 'dart:async';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

/// The base event type to use for all the club coach stuff.
abstract class SingleNewsItemEvent extends Equatable {}

///
/// Updates the newsItem (writes it out to firebase.
///
class SingleNewsItemUpdate extends SingleNewsItemEvent {
  /// The new value for the coach.
  final NewsItem newsItem;

  /// Creates a new update for the coach details.
  SingleNewsItemUpdate({@required this.newsItem});

  @override
  List<Object> get props => [newsItem];
}

///
/// Delete this coach from the world.
///
class SingleNewsItemDelete extends SingleNewsItemEvent {
  @override
  List<Object> get props => [];
}

class _SingleNewsItemDeleted extends SingleNewsItemEvent {
  @override
  List<Object> get props => [];
}

class _SingleNewsItemNewCoach extends SingleNewsItemEvent {
  final NewsItem newsItem;

  _SingleNewsItemNewCoach({this.newsItem});
  @override
  List<Object> get props => [newsItem];
}

///
/// Bloc to handle updates and state of a specific newsItem.
///
class SingleNewsItemBloc
    extends AsyncHydratedBloc<SingleNewsItemEvent, SingleNewsItemState> {
  /// The database to use for writing out to firestore.
  final DatabaseUpdateModel db;

  /// Handles all the crashes.
  final AnalyticsSubsystem crashes;

  /// The uid for the coach to load.
  final String newsItemUid;

  /// The uid for the club to load.
  final String clubUid;

  StreamSubscription<NewsItem> _newsItemSub;

  ///
  /// Creates the club coach bloc.
  ///
  SingleNewsItemBloc(
      {@required this.db,
      @required this.clubUid,
      @required this.newsItemUid,
      @required this.crashes})
      : super(SingleNewsItemUninitialized(),
            'SinglenewsItem_$clubUid.$newsItemUid') {
    _newsItemSub =
        db.getSingleClubNews(clubUid, newsItemUid).listen((newsItem) {
      if (newsItem != null) {
        add(_SingleNewsItemNewCoach(newsItem: newsItem));
      } else {
        add(_SingleNewsItemDeleted());
      }
    });
    _newsItemSub.onError((e, stack) {
      add(_SingleNewsItemDeleted());
      if (e is Exception) {
        crashes.recordException(e, stack);
      } else if (e is Error) {
        crashes.recordError(e, stack);
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _newsItemSub?.cancel();
  }

  @override
  Stream<SingleNewsItemState> mapEventToState(
      SingleNewsItemEvent event) async* {
    if (event is _SingleNewsItemNewCoach) {
      yield (SingleNewsItemLoaded.fromState(state)
            ..newsItem = event.newsItem.toBuilder())
          .build();
    }

    // The newsItem is deleted.
    if (event is _SingleNewsItemDeleted) {
      yield SingleNewsItemDeleted.fromState(state).build();
    }

    // Save the newsItem.
    if (event is SingleNewsItemUpdate) {
      yield SingleNewsItemSaving.fromState(state).build();
      try {
        await db.updateClubNews(event.newsItem);
        yield SingleNewsItemSaveDone.fromState(state).build();
        yield (SingleNewsItemLoaded.fromState(state)
              ..newsItem = event.newsItem.toBuilder())
            .build();
      } on Exception catch (e, stack) {
        yield (SingleNewsItemSaveFailed.fromState(state)..error = e).build();
        yield SingleNewsItemLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleNewsItemDelete) {
      yield SingleNewsItemSaving.fromState(state).build();
      try {
        await db.deleteClubNews(state.newsItem);
        yield SingleNewsItemSaveDone.fromState(state).build();
        yield SingleNewsItemLoaded.fromState(state).build();
      } on Exception catch (e, stack) {
        yield (SingleNewsItemSaveFailed.fromState(state)..error = e).build();
        yield SingleNewsItemLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }
  }

  @override
  SingleNewsItemState fromJson(Map<String, dynamic> json) {
    if (!(state is SingleNewsItemUninitialized)) {
      return state;
    }
    if (json == null || !json.containsKey('type')) {
      return SingleNewsItemUninitialized();
    }

    try {
      var type = SingleNewsItemBlocStateType.valueOf(json['type']);
      switch (type) {
        case SingleNewsItemBlocStateType.Uninitialized:
          return SingleNewsItemUninitialized();
        case SingleNewsItemBlocStateType.Loaded:
          return SingleNewsItemLoaded.fromMap(json);
        case SingleNewsItemBlocStateType.Deleted:
          return SingleNewsItemDeleted.fromMap(json);
        case SingleNewsItemBlocStateType.SaveFailed:
          return SingleNewsItemSaveFailed.fromMap(json);
        case SingleNewsItemBlocStateType.Saving:
          return SingleNewsItemSaving.fromMap(json);
        case SingleNewsItemBlocStateType.SaveDone:
          return SingleNewsItemSaveDone.fromMap(json);
      }
    } on Exception catch (e, stack) {
      crashes.recordException(e, stack);
    }

    return SingleNewsItemUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleNewsItemState state) {
    return state.toMap();
  }
}
