import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';

import '../blocs/singleprofileprovider.dart';

class UserName extends StatelessWidget {
  UserName({@required this.userId, this.overflow, this.style});

  final String userId;
  final TextOverflow overflow;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SingleProfileProvider(
      userUid: userId,
      builder: (BuildContext context, SingleProfileBloc bloc) => BlocBuilder(
        bloc: bloc,
        builder: (BuildContext context, SingleProfileState state) {
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
