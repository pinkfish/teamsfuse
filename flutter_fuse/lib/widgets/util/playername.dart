import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Puts the name of the player in a nixe widget.
///
class PlayerName extends StatelessWidget {
  PlayerName({@required this.playerUid, this.style});

  final String playerUid;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);

    return BlocBuilder(
      cubit: playerBloc,
      builder: (BuildContext context, PlayerState playerState) {
        Player play = playerState.getPlayer(playerUid);

        Widget widgetOne;
        Widget widgetTwo;
        CrossFadeState state = CrossFadeState.showFirst;

        if (play != null) {
          widgetTwo = Text(Messages.of(context).unknown, style: style);
          if (play.name != null) {
            widgetTwo = Text(play.name, style: style);
          }
          state = CrossFadeState.showSecond;
        } else {
          widgetTwo = Text("");
        }

        widgetOne = Text(Messages.of(context).loading, style: style);
        return AnimatedCrossFade(
          firstChild: widgetOne,
          secondChild: widgetTwo,
          duration: Duration(milliseconds: 500),
          crossFadeState: state,
        );
      },
    );
  }
}
