import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../blocs/singleprofileprovider.dart';

class ByUserNameComponent extends StatelessWidget {
  ByUserNameComponent({@required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return SingleProfileProvider(
      userUid: userId,
      builder: (BuildContext context, SingleProfileBloc bloc) => BlocBuilder(
        cubit: bloc,
        builder: (BuildContext context, SingleProfileState state) {
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
