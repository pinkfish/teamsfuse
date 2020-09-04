import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';

class FusedDrawerHeader extends StatelessWidget {
  void _showProfile(BuildContext context) {
    Navigator.pushNamed(context, "Profile");
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: BlocProvider.of<AuthenticationBloc>(context),
      builder: (BuildContext context, AuthenticationState state) {
        if (state is AuthenticationLoggedIn) {
          return UserAccountsDrawerHeader(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage('assets/images/banner.jpg'),
                  fit: BoxFit.cover),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: const AssetImage(
                "assets/images/defaultavatar2.png",
              ),
            ),
            onDetailsPressed: () => _showProfile(context),
            accountName: new Text(state.user.profile != null
                ? state.user.profile.displayName
                : Messages.of(context).unknown),
            accountEmail: new Text(state.user.profile != null
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
