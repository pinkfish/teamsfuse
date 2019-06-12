import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:fusemodel/blocs.dart';

// Shows the current invites pending for this user.
class InviteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    InviteBloc bloc = BlocProvider.of<InviteBloc>(context);
    return BlocBuilder(
      bloc: bloc,
      builder: (BuildContext context, InviteState state) {
        if (bloc.currentState.invites.length > 0) {
          Widget card = new Card(
            color: Colors.limeAccent,
            child: new ListTile(
              leading: const Icon(CommunityIcons.emailOpen),
              title: new Text(
                Messages.of(context)
                    .invitedpeople(bloc.currentState.invites.length),
              ),
            ),
          );
          return card;
        }

        return new SizedBox(
          width: 1.0,
        );
      },
    );
  }
}
