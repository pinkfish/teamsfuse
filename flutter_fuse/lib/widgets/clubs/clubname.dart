import 'package:cached_network_image/cached_network_image.dart';
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
  ClubName({@required this.clubUid, Key key, this.style}) : super(key: key);

  /// The club to lookup.
  final String clubUid;

  /// The style of the image.
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: clubUid,
      builder: (context, bloc) => BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          Widget img;
          if (state is SingleClubUninitialized || state is SingleClubDeleted) {
            img = Text(Messages.of(context).loading, style: style);
          } else {
            img = Text(state.club.name, style: style);
          }
          return AnimatedSwitcher(
              duration: Duration(milliseconds: 500), child: img);
        },
      ),
    );
  }
}
