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
            if (player.hasData) {
              if (player.data.name == null) {
                return new Text(Messages.of(context).unknown, style: style);
              }
              return new Text(player.data.name, style: style);
            }
            return new Text(Messages.of(context).loading, style: style);
          },
        );
}
