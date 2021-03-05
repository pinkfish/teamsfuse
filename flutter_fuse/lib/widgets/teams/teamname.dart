import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// Displays an image for the team.
///
class TeamName extends StatelessWidget {
  /// Constructor the team image display.  Must specify a team or teamUid or
  /// teamImage
  TeamName({@required this.teamUid, this.style, Key key})
      : super(
          key: key,
        ) {
    assert(teamUid != null);
  }

  /// Uid of the team to display.
  final String teamUid;

  /// The style of the name
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: teamUid,
      builder: (context, singleTeamBloc) => BlocBuilder(
        cubit: singleTeamBloc,
        builder: (context, teamState) {
          Widget inner;
          if (teamState is SingleTeamUninitialized) {
            inner = Text(Messages.of(context).loading, style: style);
          } else if (teamState is SingleTeamDeleted) {
            inner = Text(Messages.of(context).teamdeleted, style: style);
          } else {
            inner = Text(teamState.team.name, style: style);
          }
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: inner,
          );
        },
      ),
    );
  }
}
