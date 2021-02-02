import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';

///
/// The header for the fused drawer.
///
class FusedDrawerHeader extends StatelessWidget {
  void _showProfile(BuildContext context) {
    Navigator.pushNamed(context, "Profile");
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: BlocProvider.of<AuthenticationBloc>(context),
      builder: (context, state) {
        if (state is AuthenticationLoggedIn) {
          return UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/banner.jpg'),
                  fit: BoxFit.cover),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage(
                "assets/images/defaultavatar2.png",
              ),
            ),
            onDetailsPressed: () => _showProfile(context),
            accountName: Text(state.user.profile != null
                ? state.user.profile.displayName
                : Messages.of(context).unknown),
            accountEmail: Text(state.user.profile != null
                ? state.user.email
                : Messages.of(context).unknown),
          );
        }
        return SizedBox(
          height: 0,
        );
      },
    );
  }
}
