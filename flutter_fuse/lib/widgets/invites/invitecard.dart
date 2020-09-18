import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../util/communityicons.dart';

// Shows the current invites pending for this user.
class InviteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    InviteBloc bloc = BlocProvider.of<InviteBloc>(context);
    return BlocBuilder(
      cubit: bloc,
      builder: (BuildContext context, InviteState state) {
        if (bloc.state.invites.length > 0) {
          Widget card = Card(
            color: Colors.limeAccent,
            child: ListTile(
              leading: const Icon(CommunityIcons.emailOpen),
              title: Text(
                Messages.of(context).invitedpeople(bloc.state.invites.length),
              ),
            ),
          );
          return card;
        }

        return SizedBox(
          width: 1.0,
        );
      },
    );
  }
}
