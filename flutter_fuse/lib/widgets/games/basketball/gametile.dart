import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/games/gametitle.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../services/localutilities.dart';

class GameTile extends StatelessWidget {
  final Game game;
  final Function onTap;

  GameTile({@required this.game, this.onTap});

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.subtitle1;
    switch (game.result.result) {
      case GameResult.Win:
        style = style.copyWith(
            fontSize: style.fontSize * 1, color: Theme.of(context).accentColor);
        break;
      case GameResult.Tie:
        style = style.copyWith(fontSize: style.fontSize * 1);
        style = style.copyWith(
            fontSize: style.fontSize * 1,
            color: Theme.of(context).indicatorColor);
        break;
      case GameResult.Loss:
        style = style.copyWith(
            fontSize: style.fontSize * 1,
            color: Theme.of(context).indicatorColor);
        break;
    }
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            //begin: Alignment.bottomLeft,
            //end: Alignment.topRight,
            colors: LocalUtilities.isDark(context)
                ? [
                    LocalUtilities.brighten(Theme.of(context).primaryColor, 10),
                    Theme.of(context).splashColor,
                  ]
                : [
                    LocalUtilities.brighten(Theme.of(context).primaryColor, 90),
                    LocalUtilities.brighten(Theme.of(context).primaryColor, 95),
                  ],
          ),
        ),
        child: ListTile(
          leading: Icon(MdiIcons.basketball),
          title: GameTitle(
            game,
            null,
            style: Theme.of(context).textTheme.headline6,
            textScaleFactor: 1.2,
          ),
          subtitle: Text(
            DateFormat('dd MMM hh:mm').format(game.sharedData.time.toLocal()),
            style: Theme.of(context).textTheme.subtitle2.copyWith(
                  color: Theme.of(context).accentColor,
                ),
            textScaleFactor: 1.2,
          ),
          onTap: onTap,
          trailing: Hero(
            tag: 'game' + game.uid,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  game.result.totalScore.ptsFor.toString(),
                  style: style.copyWith(fontWeight: FontWeight.w600),
                  textScaleFactor: 1.3,
                ),
                Text(
                  game.result.totalScore.ptsAgainst.toString(),
                  style: style.copyWith(fontWeight: FontWeight.w600),
                  textScaleFactor: 1.3,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
