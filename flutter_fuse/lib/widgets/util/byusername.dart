import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';


import '../../services/messages.dart';
import '../blocs/singleprofileprovider.dart';

///
/// Shows the user name for a specific user.
///
class ByUserNameComponent extends StatelessWidget {
  /// Constructor.
  ByUserNameComponent({@required this.userId, this.style});

  /// The userId to display the name of.
  final String userId;

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SingleProfileProvider(
      userUid: userId,
      builder: (context, bloc) => BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          Widget inner;
          if (state is SingleProfileLoaded) {
            inner =
                Text(Messages.of(context).invitedby(state.profile.displayName), style: style);
          } else {
            inner = Text(Messages.of(context).loading, style: style);
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
