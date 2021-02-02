import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/blocs.dart';
import '../../../services/localutilities.dart';
import '../../../services/messages.dart';
import '../gametitle.dart';
import 'perioddropdown.dart';
import 'playermultiselect.dart';

///
/// Pulls up some data to start the period.
///
class StartPeriod extends StatefulWidget {
  final Game game;
  final Season season;
  final Orientation orientation;

  StartPeriod(
      {@required this.game, @required this.season, @required this.orientation});

  @override
  State<StatefulWidget> createState() {
    return _StartPeriodState();
  }
}

class _StartPeriodState extends State<StartPeriod> {
  GamePeriod period;
  List<String> selectedPlayers = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LocalUtilities.isDark(context)
            ? Theme.of(context).backgroundColor
            : Colors.white,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppBar(
            title: GameTitle(widget.game, null),
          ),
          SizedBox(
            height: 20.0,
          ),
          widget.orientation == Orientation.portrait
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/basketball.png",
                      height: 90.0,
                    ),
                  ],
                )
              : SizedBox(
                  height: 0.0,
                ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PeriodDropdown(
                value: period,
                onPeriodChange: (GamePeriod p) => setState(() => period = p),
              ),
              SizedBox(width: 30.0),
              FlatButton(
                color: LocalUtilities.isDark(context)
                    ? Theme.of(context).primaryColor
                    : LocalUtilities.brighten(
                        Theme.of(context).accentColor, 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  Messages.of(context).startButton,
                  textScaleFactor: 2.0,
                ),
                onPressed: () {
                  // ignore: close_sinks
                  var bloc = BlocProvider.of<SingleGameBloc>(context);
                  var undoBloc = BlocProvider.of<GameEventUndoStack>(context);
                  undoBloc.addEvent(
                    GameEvent((b) => b
                      ..gameUid = widget.game.uid
                      ..playerUid = ""
                      ..period = period.toBuilder()
                      ..timestamp = DateTime.now().toUtc()
                      ..opponent = false
                      ..eventTimeline = bloc.state.game.currentGameTime
                      ..points = 0
                      ..type = GameEventType.PeriodStart),
                    false,
                  );
                  // Update the game to start the clock.
                  var players = bloc.state.game.players.map((u, d) => MapEntry(
                      u,
                      d.rebuild((b) =>
                          b..currentlyPlaying = selectedPlayers.contains(u))));
                  // If there is no opponent, we add one.
                  var opponents = bloc.state.game.opponents.map((u, d) =>
                      MapEntry(
                          u,
                          d.rebuild((b) => b
                            ..currentlyPlaying = selectedPlayers.contains(u))));
                  bloc.add(
                    SingleGameUpdate(
                      game: bloc.state.game.rebuild((b) => b
                        ..runningFrom = DateTime.now().toUtc()
                        ..currentPeriod = period.toBuilder()
                        ..players = players.toBuilder()
                        ..opponents = opponents.toBuilder()),
                    ),
                  );
                },
              ),
            ],
          ),
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: PlayerMultiselect(
                game: widget.game,
                season: widget.season,
                isSelected: (s) => selectedPlayers.contains(s),
                selectPlayer: _selectPlayer,
                orientation: widget.orientation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    switch (widget.game.currentPeriod.type) {
      case GamePeriodType.NotStarted:
        period = GamePeriod.regulation1;
        break;
      case GamePeriodType.Regulation:
        period = widget.game.currentPeriod.rebuild((b) =>
            b..periodNumber = widget.game.currentPeriod.periodNumber + 1);
        break;
      case GamePeriodType.Overtime:
        period = widget.game.currentPeriod.rebuild((b) =>
            b..periodNumber = widget.game.currentPeriod.periodNumber + 1);
        break;
      case GamePeriodType.Penalty:
        period = GamePeriod.finalPeriod;
        break;
      default:
        period = widget.game.currentPeriod;
        break;
    }

    // Find the currently in play people and mark them.
    widget.game.players.forEach((uid, s) {
      if (s.currentlyPlaying) {
        selectedPlayers.add(uid);
      }
    });
    super.initState();
  }

  /// Updates the current set of selected players.
  void _selectPlayer(String uid, bool remove) {
    print("$uid $remove");
    if (remove) {
      setState(() => selectedPlayers.remove(uid));
    } else {
      setState(() => selectedPlayers.add(uid));
    }
  }
}
