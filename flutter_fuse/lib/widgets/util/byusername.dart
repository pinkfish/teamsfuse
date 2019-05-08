import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';

import '../blocs/singleuserprovider.dart';

class ByUserNameComponent extends StatelessWidget {
  final String userId;

  ByUserNameComponent({@required this.userId});

  Widget build(BuildContext context) {
    return SingleUserProvider(
      userUid: userId,
      builder: (BuildContext context, SingleUserBloc bloc) => BlocBuilder(
            bloc: bloc,
            builder: (BuildContext context, SingleUserState state) {
              Widget inner;
              if (state is SingleUserLoaded) {
                inner = Text(
                    Messages.of(context).invitedby(state.profile.displayName));
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
