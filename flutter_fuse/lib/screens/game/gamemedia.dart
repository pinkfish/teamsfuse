import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/widgets/blocs/singlegameprovider.dart';
import 'package:flutter_fuse/widgets/media/mediacard.dart';
import 'package:flutter_fuse/widgets/teams/opponentname.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// Show the media associated with the game.
///
class GameMediaScreen extends StatefulWidget {
  /// The gameUid for the media.
  final String gameUid;

  /// Creates the team media screen.
  GameMediaScreen(this.gameUid);

  @override
  State<StatefulWidget> createState() {
    return _GameMediaScreenState();
  }
}

class _GameMediaScreenState extends State<GameMediaScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleGameProvider(
      gameUid: widget.gameUid,
      builder: (context, singleGameBloc) => BlocBuilder(
        bloc: singleGameBloc,
        builder: (context, gameState) {
          if (gameState is SingleGameDeleted) {
            Navigator.pop(context);
            return Text(Messages.of(context).teamDeleted);
          }
          if (gameState is SingleGameUninitialized) {
            return LoadingWidget();
          }

          var actions = <Widget>[
            IconButton(
              icon: Icon(Icons.image),
              onPressed: () => Navigator.pushNamed(
                context,
                '/Game/Media/View/${widget.gameUid}',
              ),
            ),
          ];

          singleGameBloc.add(SingleGameLoadMedia());

          return Scaffold(
            appBar: AppBar(
              title: OpponentName(
                opponentUid: singleGameBloc.state.game.opponentUid,
                teamUid: singleGameBloc.state.game.teamUid,
              ),
              actions: actions,
            ),
            body: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: gameState.media
                          .map<Widget>((m) => MediaCard(
                                media: m,
                                allMedia: gameState.media,
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
