import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/teams/stats/seasonplayerlist.dart';

/// Called when the player is tapped on.
typedef PlayerChangeSort = void Function(SortPlayerBy sort);

///
/// The header for the season player stats.
///
class SeasonPlayerHeader extends StatelessWidget {
  /// constraints for the box.
  final double width;

  /// The style to use for the header.
  final TextStyle style;

  /// How the players are currently sorted.
  final SortPlayerBy sortBy;

  /// The scale to use th3e text.
  final double scale;

  /// Change the sort direcgtion.
  final PlayerChangeSort onSort;

  /// If we should show a name column or not.
  final bool showName;

  SeasonPlayerHeader({
    this.style,
    this.width,
    this.scale,
    this.sortBy,
    this.onSort,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    if (width == null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          var width = constraints.maxWidth / (showName ? 8 : 6);

          print('Width $width');

          var scale = constraints.maxWidth > 600 ? 1.2 : 1.0;
          return _innerBuilder(context, width, scale);
        },
      );
    }
    return _innerBuilder(context, width, scale);
  }

  Widget _innerBuilder(
      BuildContext context, double boxWidth, double textScale) {
    final dataStyle = style ??
        Theme.of(context).textTheme.subtitle1.copyWith(
            fontSize: Theme.of(context).textTheme.subtitle1.fontSize * 1.25);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        showName
            ? SizedBox(
                width: boxWidth * 2,
                child: Text(
                  '',
                  style: dataStyle.copyWith(fontWeight: FontWeight.bold),
                  textScaleFactor: textScale,
                ),
              )
            : SizedBox(width: 0),
        SizedBox(
          width: boxWidth,
          child: TextButton(
            onPressed: () => onSort(SortPlayerBy.points),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Pts',
                overflow: TextOverflow.fade,
                softWrap: false,
                style: dataStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: sortBy == SortPlayerBy.points
                      ? Theme.of(context).accentColor
                      : null,
                ),
                textScaleFactor: textScale,
              ),
            ),
          ),
        ),
        SizedBox(
          width: boxWidth,
          child: TextButton(
            onPressed: () => onSort(SortPlayerBy.madePercentage),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Pct',
                overflow: TextOverflow.fade,
                softWrap: false,
                style: dataStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: sortBy == SortPlayerBy.madePercentage
                      ? Theme.of(context).accentColor
                      : null,
                ),
                textScaleFactor: textScale,
              ),
            ),
          ),
        ),
        SizedBox(
          width: boxWidth,
          child: TextButton(
            onPressed: () => onSort(SortPlayerBy.fouls),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Fouls',
                overflow: TextOverflow.fade,
                softWrap: false,
                style: dataStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: sortBy == SortPlayerBy.fouls
                      ? Theme.of(context).accentColor
                      : null,
                ),
                textScaleFactor: textScale,
              ),
            ),
          ),
        ),
        SizedBox(
          width: boxWidth,
          child: TextButton(
            onPressed: () => onSort(SortPlayerBy.turnovers),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'T/O',
                overflow: TextOverflow.fade,
                softWrap: false,
                style: dataStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: sortBy == SortPlayerBy.turnovers
                      ? Theme.of(context).accentColor
                      : null,
                ),
                textScaleFactor: textScale,
              ),
            ),
          ),
        ),
        SizedBox(
          width: boxWidth,
          child: TextButton(
            onPressed: () => onSort(SortPlayerBy.steals),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Steals',
                softWrap: false,
                overflow: TextOverflow.clip,
                style: dataStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: sortBy == SortPlayerBy.steals
                      ? Theme.of(context).accentColor
                      : null,
                ),
                textScaleFactor: textScale,
              ),
            ),
          ),
        ),
        SizedBox(
          width: boxWidth,
          child: TextButton(
            onPressed: () => onSort(SortPlayerBy.blocks),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Blk',
                softWrap: false,
                overflow: TextOverflow.clip,
                style: dataStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: sortBy == SortPlayerBy.blocks
                      ? Theme.of(context).accentColor
                      : null,
                ),
                textScaleFactor: textScale,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
