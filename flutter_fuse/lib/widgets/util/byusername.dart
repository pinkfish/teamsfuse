import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../blocs/singleprofileprovider.dart';

///
/// Shows the user name for a specific user.
class ByUserNameComponent extends StatelessWidget {
  /// Constructor.
  ByUserNameComponent({@required this.userId});

  /// The userId to display the name of.
  final String userId;

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
                Text(Messages.of(context).invitedby(state.profile.displayName));
          } else {
            inner = Text(Messages.of(context).loading);
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
