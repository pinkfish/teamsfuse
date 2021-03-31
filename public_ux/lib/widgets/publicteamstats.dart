import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs/single/singleseasonbloc.dart';
import 'package:flutter_fuse/services/blocs/single/singleteambloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleseasonprovider.dart';
import 'package:flutter_fuse/widgets/player/playerdropdown.dart';
import 'package:flutter_fuse/widgets/teams/stats/teamseasonstats.dart';
import 'package:flutter_fuse/widgets/util/deleted.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Shows statistics for the overall team, showing trends over
/// a season.
///
class PublicTeamStatsWidget extends StatefulWidget {
  /// The team bloc to use for this ux
  final SingleTeamBloc teamBloc;

  PublicTeamStatsWidget({
    @required this.teamBloc,
  });

  @override
  State<StatefulWidget> createState() {
    return _TeamStatsWidgetState();
  }
}

class _TeamStatsWidgetState extends State<PublicTeamStatsWidget> {
  String _currentSeasonUid;
  String _playerUid = PlayerDropDown.allValue;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: widget.teamBloc,
      builder: (BuildContext context, SingleTeamState state) {
        if (state is SingleTeamLoaded && !state.loadedSeasons) {
          widget.teamBloc.add(SingleTeamLoadSeasons());
        }
        if (state is SingleTeamUninitialized) {
          return LoadingWidget();
        }
        if (state is SingleTeamDeleted) {
          return DeletedWidget();
        }
        _currentSeasonUid ??= state.team.currentSeason;
        return SingleSeasonProvider(
          seasonUid: _currentSeasonUid,
          builder: (context, singleSeasonBloc) => Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Player-multi-select button.
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: PlayerDropDown(
                        singleSeasonBloc,
                        value: _playerUid,
                        isExpanded: true,
                        onChanged: (s) => setState(() => _playerUid = s),
                        includeAll: true,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: BlocConsumer(
                    bloc: singleSeasonBloc,
                    listener: (BuildContext context, SingleSeasonState state) {
                      if (state is SingleSeasonLoaded && !state.loadedGames) {
                        BlocProvider.of<SingleSeasonBloc>(context)
                            .add(SingleSeasonLoadGames());
                      }
                    },
                    builder: (BuildContext context, SingleSeasonState state) {
                      if (state is SingleSeasonUninitialized) {
                        return LoadingWidget();
                      }
                      if (state is SingleSeasonDeleted) {
                        return DeletedWidget();
                      }
                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: TeamSeasonStats(
                          state: state,
                          gameData: ShowGameData.All,
                          playerUid: _playerUid,
                        ),
                      );
                    }),
              ),
            ],
          ),
        );
      },
    );
  }
}