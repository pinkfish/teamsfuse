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
        return AlertDialog(
          title: Text(mess.deletemember),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(mess.confirmdeletemember(profile)),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
    if (result) {
      clubBloc.add(ClubDeleteMember(clubUid: club.uid, memberUid: profile.uid));
    }
  }

  Widget _buildFromFuture(
      BuildContext context, SingleProfileState state, bool admin, String uid) {
    if ((state is SingleProfileLoaded)) {
      FusedUserProfile profile = state.profile;
      if (profile != null) {
        AuthenticationBloc authenticationBloc =
            BlocProvider.of<AuthenticationBloc>(context);
        return ListTile(
          leading: UserImage(profile),
          title: Text(profile.displayName),
          subtitle: Text(admin ? Messages.of(context).administrator : ""),
          trailing: club.isAdmin() &&
                  profile.uid != authenticationBloc.currentUser.uid
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteMember(context, profile),
                )
              : null,
        );
      }
    }
    return ListTile(
      leading: const Icon(Icons.help),
      title: Text(Messages.of(context).loading),
    );
  }

  List<Widget> _buildMembers(BuildContext context) {
    List<Widget> members = <Widget>[];

    for (String adminUid in club.adminsUids) {
      var bloc = SingleProfileBloc(
          coordinationBloc: BlocProvider.of<CoordinationBloc>(context),
          profileUid: adminUid,
          playerBloc: BlocProvider.of<PlayerBloc>(context));
      members.add(
        BlocProvider(
          create: (BuildContext context) => bloc,
          child: BlocBuilder(
            cubit: bloc,
            builder: (BuildContext context, SingleProfileState state) =>
                _buildFromFuture(context, state, true, adminUid),
          ),
        ),
      );
    }
    for (String memberUid in club.members) {
      var bloc = SingleProfileBloc(
          coordinationBloc: BlocProvider.of<CoordinationBloc>(context),
          profileUid: memberUid,
          playerBloc: BlocProvider.of<PlayerBloc>(context));
      members.add(
        BlocProvider(
          create: (BuildContext context) => bloc,
          child: BlocBuilder(
            cubit: bloc,
            builder: (BuildContext context, SingleProfileState state) =>
                _buildFromFuture(context, state, false, memberUid),
          ),
        ),
      );
    }
    return members;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildMembers(context),
      ),
    );
  }
}
