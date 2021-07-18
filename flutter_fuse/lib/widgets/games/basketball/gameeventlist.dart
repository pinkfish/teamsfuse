import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/blocs.dart';
import '../../util/loading.dart';
import 'gameeventwidget.dart';

///
/// The list of game events associated with the single game bloc.
///
class GameEventList extends StatelessWidget {
  /// Filtering method, only show the events where this is true.
  final bool Function(GameEvent) eventCheck;

  /// Show the name in the event.
  final bool showName;

  /// Show the timestamp.
  final bool showTimestamp;

  /// Show the period.
  final bool showPeriod;

  /// What to do on a tap.
  final GameEventTapCallback onTap;

  /// Create an event list.
  GameEventList(
      {this.eventCheck,
      this.showName = false,
      this.showPeriod = true,
      this.showTimestamp = true,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<SingleGameBloc>(context),
      builder: (BuildContext context, SingleGameState state) {
        if (!state.loadedEvents) {
          BlocProvider.of<SingleGameBloc>(context).add(SingleGameLoadEvents());
          return Center(
            child: LoadingWidget(),
          );
        }
        return SingleChildScrollView(
          child: Column(
            children: state.gameEvents
                .where(eventCheck)
                .map(
                  (GameEvent e) => GameEventWidget(
                    gameEvent: e,
                    showTimestamp: showTimestamp,
                    showPeriod: showPeriod,
                    showName: showName,
                    onTap: onTap,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
