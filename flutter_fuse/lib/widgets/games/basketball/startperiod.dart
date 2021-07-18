import 'package:built_collection/built_collection.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/blocs.dart';
import '../../../services/localutilities.dart';
import '../../../services/messages.dart';
import '../editresultdialog.dart';
import '../gametitle.dart';
import 'perioddropdown.dart';
import 'playermultiselect.dart';

///
/// Pulls up some data to start the period.
///
class StartPeriod extends StatefulWidget {
  /// The game to start the period for,
  final Game game;

  /// The season for the game.
  final Season season;

  /// How the setup is orientated.
  final Orientation orientation;

  /// The bloc associated with the game.
  final SingleGameBloc singleGameBloc;

  /// The full player details for the game.  Used for sorting.
  final BuiltMap<String, Player> fullPlayerDetails;

  /// The media for the team.
  final BuiltList<MediaInfo> media;

  /// The constructor for the start period selector.
  StartPeriod(
      {@required this.game,
      @required this.season,
      @required this.orientation,
      this.media,
      this.singleGameBloc,
      this.fullPlayerDetails});

  @override
  State<StatefulWidget> createState() {
    return _StartPeriodState();
  }
}

class _StartPeriodState extends State<StartPeriod> {
  GamePeriod _period;
  final List<String> _selectedPlayers = [];

  void _editResult() async {
    // Call up a dialog to edit the result.
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return EditResultDialog(widget.game.uid);
      },
    );
    // Means the result was written and we should leave.
    if (result != null && result == true) {
      Navigator.pop(context);
    }
  }

  void _addWithVideo() {}

  @override
  Widget build(BuildContext context) {
    var foundVideo = false;
    if (widget.media != null) {
      for (var m in widget.media) {
        if (m.type == MediaType.videoOnDemand ||
            m.type == MediaType.youtubeID) {
          foundVideo = true;
        }
      }
    }
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
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          AppBar(
            title: GameTitle(widget.game, null),
          ),
          SizedBox(
            height: 20.0,
          ),
          ButtonBar(
            children: [
              widget.game.sharedData.time
                      .isBefore(DateTime.now().subtract(Duration(hours: 2)))
                  ? TextButton(
                      onPressed: _editResult,
                      style: TextButton.styleFrom(),
                      child: Text(Messages.of(context).finalScoreButton),
                    )
                  : SizedBox(height: 0),
              foundVideo
                  ? TextButton(
                      onPressed: _addWithVideo,
                      style: TextButton.styleFrom(),
                      child: Text(Messages.of(context).addWithVideo),
                    )
                  : SizedBox(height: 0),
            ],
          ),
          widget.orientation == Orientation.portrait
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.game.result.totalScore.ptsFor}',
                      textScaleFactor: 3.0,
                    ),
                    SizedBox(width: 20),
                    Image.asset(
                      'assets/sports/Sport.Basketball.png',
                      height: 90.0,
                    ),
                    SizedBox(width: 20),
                    Text(
                      '${widget.game.result.totalScore.ptsAgainst}',
                      textScaleFactor: 3.0,
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
                value: _period,
                onPeriodChange: (GamePeriod p) => setState(() => _period = p),
              ),
              SizedBox(width: 30.0),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: LocalUtilities.isDark(context)
                      ? Theme.of(context).primaryColor
                      : LocalUtilities.brighten(
                          Theme.of(context).accentColor, 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  // ignore: close_sinks
                  var undoBloc = BlocProvider.of<GameEventUndoStack>(context);
                  undoBloc.addEvent(
                    GameEvent((b) => b
                      ..gameUid = widget.game.uid
                      ..playerUid = ''
                      ..period = _period.toBuilder()
                      ..timestamp = clock.now().toUtc()
                      ..opponent = false
                      ..eventTimeline = widget.game.currentGameTime
                      ..points = 0
                      ..type = GameEventType.PeriodStart),
                    false,
                  );
                  // Update the game to start the clock.
                  var players = widget.game.players.map((u, d) => MapEntry(
                      u,
                      d.rebuild((b) =>
                          b..currentlyPlaying = _selectedPlayers.contains(u))));
                  // If there is no opponent, we add one.
                  var opponents = widget.game.opponents.map((u, d) => MapEntry(
                      u,
                      d.rebuild((b) =>
                          b..currentlyPlaying = _selectedPlayers.contains(u))));
                  if (_period.type == GamePeriodType.Final) {
                    // Finish the game.
                    widget.singleGameBloc.add(
                      SingleGameUpdate(
                        game: widget.game.rebuild((b) => b
                          ..runningFrom = null
                          ..result.currentPeriod = _period.toBuilder()
                          ..players = players.toBuilder()
                          ..result.inProgress = GameInProgress.Final
                          ..opponents = opponents.toBuilder()),
                      ),
                    );
                  } else {
                    widget.singleGameBloc.add(
                      SingleGameUpdate(
                        game: widget.game.rebuild((b) => b
                          ..runningFrom = clock.now().toUtc()
                          ..result.currentPeriod = _period.toBuilder()
                          ..result.inProgress = GameInProgress.InProgress
                          ..players = players.toBuilder()
                          ..opponents = opponents.toBuilder()),
                      ),
                    );
                  }
                },
                child: Text(
                  Messages.of(context).startButton,
                  textScaleFactor: 2.0,
                ),
              ),
            ],
          ),
          Expanded(
            //fit: FlexFit.loose,
            child: PlayerMultiselect(
              game: widget.game,
              season: widget.season,
              isSelected: (s) => _selectedPlayers.contains(s),
              selectPlayer: _selectPlayer,
              orientation: widget.orientation,
              fullPlayerDetails: widget.fullPlayerDetails,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    switch (widget.game.result.currentPeriod.type) {
      case GamePeriodType.NotStarted:
        _period = GamePeriod.regulation1;
        break;
      case GamePeriodType.Regulation:
        _period = widget.game.result.currentPeriod.rebuild((b) => b
          ..periodNumber = widget.game.result.currentPeriod.periodNumber + 1);
        break;
      case GamePeriodType.Overtime:
        _period = widget.game.result.currentPeriod.rebuild((b) => b
          ..periodNumber = widget.game.result.currentPeriod.periodNumber + 1);
        break;
      case GamePeriodType.Penalty:
        _period = GamePeriod.finalPeriod;
        break;
      default:
        _period = widget.game.result.currentPeriod;
        break;
    }

    // Find the currently in play people and mark them.
    widget.game.players.forEach((uid, s) {
      if (s.currentlyPlaying) {
        _selectedPlayers.add(uid);
      }
    });
    super.initState();
  }

  /// Updates the current set of selected players.
  void _selectPlayer(String uid, bool remove) {
    if (remove) {
      setState(() => _selectedPlayers.remove(uid));
    } else {
      setState(() => _selectedPlayers.add(uid));
    }
  }
}
