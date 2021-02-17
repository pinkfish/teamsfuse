import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';

///
/// Shows the current invites pending for this user.
///
class InviteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<InviteBloc>(context);
    return BlocBuilder(
      cubit: bloc,
      builder: (context, state) {
        if (bloc.state.invites.length > 0) {
          Widget card = Card(
            color: Colors.limeAccent,
            child: ListTile(
              leading: const Icon(MdiIcons.emailOpen),
              title: Text(
                Messages.of(context).invitedPeople(bloc.state.invites.length),
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
