import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class PlayerName extends FutureBuilder<Player> {
  PlayerName({@required String playerUid, TextStyle style})
      : super(
          future: UserDatabaseData.instance
              .getPlayer(playerUid)
              .then((Player play) {
            if (play == null) {
              play = new Player();
            }
            return play;
          }).catchError((dynamic e) {
            return new Player();
          }),
          builder: (BuildContext context, AsyncSnapshot<Player> player) {
            Widget widgetOne;
            Widget widgetTwo;
            CrossFadeState state = CrossFadeState.showFirst;

            widgetTwo = new Text(Messages.of(context).unknown, style: style);
            if (player.hasData) {
              if (player.data.name != null) {
                widgetTwo = new Text(player.data.name, style: style);
              }
              state = CrossFadeState.showSecond;
            }
            widgetOne = new Text(Messages.of(context).loading, style: style);
            return AnimatedCrossFade(
              firstChild: widgetOne,
              secondChild: widgetTwo,
              duration: Duration(milliseconds: 500),
              crossFadeState: state,
            );
          },
        );
}
