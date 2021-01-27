import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleplayerprovider.dart';

import '../../services/messages.dart';

///
/// Puts the name of the player in a nixe widget.
///
class PlayerName extends StatelessWidget {
  /// Constructor.
  PlayerName({@required this.playerUid, this.style, this.textScaleFactor});

  /// The player uid to show the name for,
  final String playerUid;

  /// Style to use for the player name on the screen.
  final TextStyle style;

  final double textScaleFactor;

  @override
  Widget build(BuildContext context) {
    return SinglePlayerProvider(
      playerUid: playerUid,
      builder: (context, bloc) => BlocBuilder(
        cubit: bloc,
        builder: (context, playerState) {
          var play = playerState.player;

          Widget widgetOne;
          Widget widgetTwo;
          var state = CrossFadeState.showFirst;

          if (play != null) {
            widgetTwo = Text(
              Messages.of(context).unknown,
              style: style,
              textScaleFactor: textScaleFactor,
            );
            if (play.name != null) {
              widgetTwo = Text(
                play.name,
                style: style,
                textScaleFactor: textScaleFactor,
              );
            }
            state = CrossFadeState.showSecond;
          } else {
            widgetTwo = Text("");
          }

          widgetOne = Text(
            Messages.of(context).loading,
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
