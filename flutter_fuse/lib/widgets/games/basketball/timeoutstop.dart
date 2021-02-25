import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/blocs.dart';
import '../../../services/messages.dart';
import '../gametitle.dart';

///
/// DIsplay information to end the timeout.
///
class TimeoutEnd extends StatelessWidget {
  /// The game to update the timeout for.
  final Game game;

  /// Create the timeout end screen.
  TimeoutEnd({@required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppBar(
            title: GameTitle(game, null),
          ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/sports/Sport.Basketball.png",
                height: 90.0,
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(Messages.of(context).endTimeout),
              FlatButton(
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  Messages.of(context).endButton,
                  textScaleFactor: 2.0,
                ),
                onPressed: () {
                  // ignore: close_sinks
                  var undoBloc = BlocProvider.of<GameEventUndoStack>(context);
                  undoBloc.addEvent(
                    GameEvent((b) => b
                      ..gameUid = game.uid
                      ..playerUid = ""
                      ..period = game.currentPeriod.toBuilder()
                      ..timestamp = DateTime.now().toUtc()
                      ..opponent = false
                      ..eventTimeline = game.currentGameTime
                      ..points = 0
                      ..type = GameEventType.TimeoutEnd),
                    false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
