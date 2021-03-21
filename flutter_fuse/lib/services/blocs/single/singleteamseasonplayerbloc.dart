import 'dart:async';
import 'dart:isolate';

import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

///
/// The player in the specific team/season.
///
abstract class SingleTeamSeasonPlayerEvent extends Equatable {}

///
/// Updates the team (writes it out to firebase.
///
class SingleTeamSeasonPlayerUpdate extends SingleTeamSeasonPlayerEvent {
  final SeasonPlayer player;

  SingleTeamSeasonPlayerUpdate({@required this.player});

  @override
  List<Object> get props => [player];
}

class _SingleTeamNewTeamSeasonPlayer extends SingleTeamSeasonPlayerEvent {
  final SeasonPlayer newPlayer;

  _SingleTeamNewTeamSeasonPlayer({@required this.newPlayer});

  @override
  List<Object> get props => [newPlayer];
}

class _SingleTeamSeasonPlayerDeleted extends SingleTeamSeasonPlayerEvent {
  @override
  List<Object> get props => [];
}

///
/// Delete this player from the season.
///
class SingleTeamSeasonPlayerDelete extends SingleTeamSeasonPlayerEvent {
  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleTeamSeasonPlayerBloc extends AsyncHydratedBloc<
    SingleTeamSeasonPlayerEvent, SingleTeamSeasonPlayerState> {
  final String seasonUid;
  final String playerUid;
  final AnalyticsSubsystem crashes;
  final DatabaseUpdateModel db;

  StreamSubscription<SeasonState> _seasonSub;

  /// Create the bloc for the team season bloc.
  SingleTeamSeasonPlayerBloc(
      {@required this.db,
      @required this.seasonUid,
      @required this.playerUid,
      @required this.crashes})
      : super(SingleTeamSeasonPlayerUninitialized(), seasonUid) {
    db.getSingleSeason(seasonUid).listen((Season season) {
      if (season != null) {
        // Only send this if the season is not the same.
        if (season.players.any((SeasonPlayer p) => p.playerUid == playerUid)) {
          var player = season.players
              .firstWhere((SeasonPlayer p) => p.playerUid == playerUid);
          if (player != state.seasonPlayer) {
            add(_SingleTeamNewTeamSeasonPlayer(newPlayer: player));
          }
        } else {
          add(_SingleTeamSeasonPlayerDeleted());
        }
      } else {
        add(_SingleTeamSeasonPlayerDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    await _seasonSub?.cancel();
    _seasonSub = null;
  }

  @override
  Stream<SingleTeamSeasonPlayerState> mapEventToState(
      SingleTeamSeasonPlayerEvent event) async* {
    if (event is _SingleTeamNewTeamSeasonPlayer) {
      yield (SingleTeamSeasonPlayerLoaded.fromState(state)
            ..seasonPlayer = event.newPlayer.toBuilder())
          .build();
    }

    // The team is deleted.
    if (event is _SingleTeamSeasonPlayerDeleted) {
      yield SingleTeamSeasonPlayerDeleted();
    }

    if (event is SingleTeamSeasonPlayerDelete) {
      // Do its thing and it should remove ourselves whern it saves.
      yield SingleTeamSeasonPlayerSaving.fromState(state).build();
      try {
        await db.removePlayerFromSeason(seasonUid, playerUid);
      } catch (e, stack) {
        yield (SingleTeamSeasonPlayerSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleTeamSeasonPlayerLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    // Save the team.
    if (event is SingleTeamSeasonPlayerUpdate) {
      yield SingleTeamSeasonPlayerSaving.fromState(state).build();
      try {
        await db.updateSeasonPlayerForSeason(
          seasonUid,
          event.player,
        );
      } catch (e, stack) {
        yield (SingleTeamSeasonPlayerSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleTeamSeasonPlayerLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }
  }

  @override
  SingleTeamSeasonPlayerState fromJson(Map<String, dynamic> json) {
    if (!(state is SingleTeamSeasonPlayerUninitialized)) {
      return state;
    }
    if (json == null || !json.containsKey('type')) {
      return SingleTeamSeasonPlayerUninitialized();
    }

    var type = SingleTeamSeasonPlayerBlocStateType.valueOf(json['type']);
    try {
      switch (type) {
        case SingleTeamSeasonPlayerBlocStateType.Uninitialized:
          return SingleTeamSeasonPlayerUninitialized();
        case SingleTeamSeasonPlayerBlocStateType.Loaded:
          var ret = SingleTeamSeasonPlayerLoaded.fromMap(json);
          return ret;
        case SingleTeamSeasonPlayerBlocStateType.Deleted:
          return SingleTeamSeasonPlayerDeleted.fromMap(json);
        case SingleTeamSeasonPlayerBlocStateType.SaveFailed:
          return SingleTeamSeasonPlayerSaveFailed.fromMap(json);
        case SingleTeamSeasonPlayerBlocStateType.Saving:
          return SingleTeamSeasonPlayerSaving.fromMap(json);
        case SingleTeamSeasonPlayerBlocStateType.SaveDone:
          return SingleTeamSeasonPlayerSaveDone.fromMap(json);
      }
    } catch (e, stack) {
      if (e is Error) {
        crashes.recordError(e, stack);
      } else {
        crashes.recordException(e, stack);
      }
    }
    return SingleTeamSeasonPlayerUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleTeamSeasonPlayerState state) {
    return state.toMap();
  }
}
