import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/userimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class ClubMembers extends StatelessWidget {
  ClubMembers(this.club);

  final Club club;

  void _deleteMember(BuildContext context, FusedUserProfile profile) async {
    ClubBloc clubBloc = BlocProvider.of<ClubBloc>(context);

    Messages mess = Messages.of(context);
    // Show an alert dialog first.
    bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(mess.deletemember),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(mess.confirmdeletemember(profile)),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
            ),
            new FlatButton(
              child:
                  new Text(MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
    if (result) {
      clubBloc.dispatch(
          ClubDeleteMember(clubUid: club.uid, memberUid: profile.uid));
    }
  }

  Widget _buildFromFuture(
      BuildContext context, UserState state, bool admin, String uid) {
    if ((state is UserLoaded) && state.users.containsKey(uid)) {
      FusedUserProfile profile = state.users[uid];
      if (profile != null) {
        AuthenticationBloc authenticationBloc =
            BlocProvider.of<AuthenticationBloc>(context);
        return new ListTile(
          leading: new UserImage(profile),
          title: new Text(profile.displayName),
          subtitle: new Text(admin ? Messages.of(context).administrator : ""),
          trailing: club.isAdmin() &&
                  profile.uid != authenticationBloc.currentUser.uid
              ? new IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteMember(context, profile),
                )
              : null,
        );
      }
    }
    return new ListTile(
      leading: const Icon(Icons.help),
      title: new Text(Messages.of(context).loading),
    );
  }

  List<Widget> _buildMembers(BuildContext context) {
    List<Widget> members = <Widget>[];

    for (String adminUid in club.adminsUids) {
      members.add(
        BlocBuilder(
          bloc: BlocProvider.of<UserBloc>(context),
          builder: (BuildContext context, UserState state) =>
              _buildFromFuture(context, state, true, adminUid),
        ),
      );
    }
    for (String memberUid in club.members) {
      members.add(
        BlocBuilder(
          bloc: BlocProvider.of<UserBloc>(context),
          builder: (BuildContext context, UserState state) =>
              _buildFromFuture(context, state, false, memberUid),
        ),
      );
    }
    return members;
  }

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildMembers(context),
      ),
    );
  }
}
