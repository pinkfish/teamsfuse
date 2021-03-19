import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleprofileprovider.dart';

///
/// The user name to display in the UX
///
class UserName extends StatelessWidget {
  /// Constructor,
  UserName({@required this.userId, this.overflow, this.style})
      : assert(userId != null);

  /// The userId to display the name for.
  final String userId;

  /// TextOverflow behaviour
  final TextOverflow overflow;

  /// Style to use for the text.
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SingleProfileProvider(
      userUid: userId,
      builder: (context, bloc) => BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          Widget inner;
          if (state is SingleProfileLoaded) {
            inner = Text(
              state.profile.displayName,
              overflow: overflow,
              style: style,
            );
          } else {
            inner = Text(
              Messages.of(context).loading,
              overflow: overflow,
              style: style,
            );
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
