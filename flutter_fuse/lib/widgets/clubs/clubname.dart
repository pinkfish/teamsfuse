import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleclubprovider.dart';
import '../../services/messages.dart';

///
/// Show the name of the club.
///
class ClubName extends StatelessWidget {
  /// Constructor.
  ClubName({
    @required this.clubUid,
    Key key,
    this.style,
    this.overflow = TextOverflow.visible,
    this.maxLines = 5,
  }) : super(key: key);

  /// The club to lookup.
  final String clubUid;

  /// The style of the image.
  final TextStyle style;

  /// Overflow for thetest
  final TextOverflow overflow;

  /// Max lines to display.
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: clubUid,
      builder: (context, bloc) => BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          Widget img;
          if (state is SingleClubUninitialized || state is SingleClubDeleted) {
            img = Text(
              Messages.of(context).loading,
              style: style,
              overflow: overflow,
              maxLines: maxLines,
            );
          } else {
            img = Text(
              state.club.name,
              style: style,
              overflow: overflow,
              maxLines: maxLines,
            );
          }
          return AnimatedSwitcher(
              duration: Duration(milliseconds: 500), child: img);
        },
      ),
    );
  }
}
