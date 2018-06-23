import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class PlayerName extends FutureBuilder<Player> {
  PlayerName({@required String playerUid, TextStyle style})
      : super(
          future: UserDatabaseData.instance.getPlayer(playerUid),
          builder: (BuildContext context, AsyncSnapshot<Player> player) {
            if (player.hasData) {
              return new Text(player.data.name, style: style);
            }
            return new Text(Messages.of(context).loading, style: style);
          },
        );
}
