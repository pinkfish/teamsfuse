import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/messages.dart';
import '../blocs/singleopponentprovider.dart';

///
/// Puts the name of the opponent in a nice widget.
///
class OpponentName extends StatelessWidget {
  /// Constructor.
  OpponentName(
      {@required this.opponentUid,
      @required this.teamUid,
      this.style,
      this.textScaleFactor,
      this.overflow,
      this.fallback});

  /// The opponent uid to show the name for,
  final String opponentUid;

  /// The team uid to show the opponent for,
  final String teamUid;

  /// Fallback string to display if the player name doesn't load.
  final String fallback;

  /// Style to use for the player name on the screen.
  final TextStyle style;

  /// The scale factor for the player name text.
  final double textScaleFactor;

  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return SingleOpponentProvider(
      opponentUid: opponentUid,
      teamUid: teamUid,
      builder: (context, bloc) => BlocBuilder(
        bloc: bloc,
        builder: (context, opponentState) {
          var op = opponentState.opponent;

          Widget widgetOne;
          Widget widgetTwo;
          var state = CrossFadeState.showFirst;

          if (op != null) {
            widgetTwo = Text(
              fallback ?? Messages.of(context).unknown,
              style: style,
              textScaleFactor: textScaleFactor,
            );
            if (op.name != null) {
              widgetTwo = Text(
                op.name,
                style: style,
                textScaleFactor: textScaleFactor,
              );
            }
            state = CrossFadeState.showSecond;
          } else {
            widgetTwo = Text('');
          }

          widgetOne = Text(
            fallback ?? Messages.of(context).loading,
            style: style,
            textScaleFactor: textScaleFactor,
          );
          return AnimatedCrossFade(
            firstChild: widgetOne,
            secondChild: widgetTwo,
            duration: Duration(milliseconds: 500),
            crossFadeState: state,
          );
        },
      ),
    );
  }
}
