import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleopponentprovider.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

import '../../services/messages.dart';

///
/// Create the game title as a simple item for the list.
///
class GameTitle extends StatelessWidget {
  /// The game to make the title of.
  final Game game;

  /// The league or team associated with this.
  final LeagueOrTournamentTeam leagueTeam;

  /// The style to display.
  final TextStyle style;

  /// The scale factor.
  final double textScaleFactor;

  /// What to do with the overflow.
  final TextOverflow overflow;

  /// Creates a game title.
  GameTitle(
    this.game,
    this.leagueTeam, {
    this.style = const TextStyle(fontWeight: FontWeight.bold),
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
  });

  String _opponentUid(Game game) {
    if (game.sharedData.type == EventType.Game && game.opponentUid.isNotEmpty) {
      return game.opponentUid;
    }
    return '123';
  }

  Opponent _opponentData(BuildContext context, Game game,
      LeagueOrTournamentTeam leagueTeam, SingleOpponentState opState) {
    if (game.sharedData.type == EventType.Game && game.opponentUid.isNotEmpty) {
      return opState.opponent;
    } else if (game.sharedData.type == EventType.Game && leagueTeam != null) {
      return (OpponentBuilder()..name = leagueTeam.name).build();
    } else {
      return (OpponentBuilder()
            ..name = Messages.of(context).unknown
            ..teamUid = game.teamUid
            ..uid = '12')
          .build();
    }
  }

  String _titleWidget(BuildContext context, Game game,
      LeagueOrTournamentTeam leagueTeam, SingleOpponentState opState) {
    String title;

    var op = _opponentData(context, game, leagueTeam, opState);

    var day = TimeOfDay.fromDateTime(game.sharedData.tzTime);
    var formattedStartTime =
        MaterialLocalizations.of(context).formatTimeOfDay(day);
    String formattedEndTime;
    String tzShortName;
    if (game.sharedData.timezone != local.name) {
      tzShortName = getLocation(game.sharedData.timezone)
          .timeZone(game.sharedData.time.millisecondsSinceEpoch)
          .abbr;
    }

    if (game.sharedData.time != game.sharedData.endTime) {
      var endDay = TimeOfDay.fromDateTime(game.sharedData.tzEndTime);
      formattedEndTime =
          MaterialLocalizations.of(context).formatTimeOfDay(endDay);
    }
    switch (game.sharedData.type) {
      case EventType.Game:
        String opName;
        if (op == null) {
          opName = Messages.of(context).loading;
        } else {
          opName = op.name;
        }
        print('op $opName');
        // Within an hour.
        title = Messages.of(context).gameTitle(
            formattedStartTime, formattedEndTime, tzShortName, opName);
        print('op $title');

        break;

      case EventType.Event:
        title = Messages.of(context).eventTitle(formattedStartTime,
            game.sharedData.name, formattedEndTime, tzShortName);

        break;

      case EventType.Practice:
        title = Messages.of(context)
            .trainingTitle(formattedStartTime, formattedEndTime, tzShortName);

        break;
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return SingleOpponentProvider(
      opponentUid: _opponentUid(game),
      teamUid: game.teamUid,
      builder: (context, opBloc) => BlocBuilder(
        bloc: opBloc,
        builder: (context, opState) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            _titleWidget(context, game, leagueTeam, opState),
            overflow: overflow,
            style: style,
            textScaleFactor: textScaleFactor,
          ),
        ),
      ),
    );
  }
}
