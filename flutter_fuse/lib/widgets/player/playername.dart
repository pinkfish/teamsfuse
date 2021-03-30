import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleplayerprovider.dart';

///
/// Puts the name of the player in a nixe widget.
///
class PlayerName extends StatelessWidget {
  /// Constructor.
  PlayerName({
    @required this.playerUid,
    this.style,
    this.textScaleFactor,
    this.fallback,
    this.overflow = TextOverflow.visible,
    this.maxLines = 5,
  });

  /// The player uid to show the name for,
  final String playerUid;

  /// Fallback string to display if the player name doesn't load.
  final String fallback;

  /// Style to use for the player name on the screen.
  final TextStyle style;

  /// The scale factor for the player name text.
  final double textScaleFactor;

  /// The overflow for the test.
  final TextOverflow overflow;

  /// The maximum number of lines.
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return SinglePlayerProvider(
      playerUid: playerUid,
      builder: (context, bloc) => BlocBuilder(
        bloc: bloc,
        builder: (context, playerState) {
          var play = playerState.player;

          Widget widgetOne;
          Widget widgetTwo;
          var state = CrossFadeState.showFirst;

          if (play != null) {
            widgetTwo = Text(
              fallback ?? Messages.of(context).unknown,
              style: style,
              textScaleFactor: textScaleFactor,
              overflow: overflow,
              maxLines: maxLines,
            );
            if (play.name != null) {
              if (play.users.isEmpty && play.playerType == PlayerType.player) {
                widgetTwo = Text(
                  Messages.of(context).invitedToTeamWithName(play.name),
                  style: style,
                  textScaleFactor: textScaleFactor,
                  overflow: overflow,
                  maxLines: maxLines,
                );
              } else {
                widgetTwo = Text(
                  play.name,
                  style: style,
                  textScaleFactor: textScaleFactor,
                  overflow: overflow,
                  maxLines: maxLines,
                );
              }
            }
            state = CrossFadeState.showSecond;
          } else {
            widgetTwo = Text('');
          }

          widgetOne = Text(
            fallback ?? Messages.of(context).loading,
            style: style,
            textScaleFactor: textScaleFactor,
            overflow: overflow,
            maxLines: maxLines,
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
