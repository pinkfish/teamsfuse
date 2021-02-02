import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../util/userimage.dart';

///
/// Display the members of the club.
///
class ClubMembers extends StatelessWidget {
  /// Constructor.
  ClubMembers(this.club);

  /// The club to show members for.
  final Club club;

  void _deleteMember(BuildContext context, FusedUserProfile profile) async {
    var clubBloc = BlocProvider.of<ClubBloc>(context);

    var mess = Messages.of(context);
    // Show an alert dialog first.
    var result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
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
      var profile = state.profile;
      if (profile != null) {
        var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
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
    var members = <Widget>[];

    for (var adminUid in club.adminsUids) {
      var bloc = SingleProfileBloc(
          coordinationBloc: BlocProvider.of<CoordinationBloc>(context),
          profileUid: adminUid,
          playerBloc: BlocProvider.of<PlayerBloc>(context));
      members.add(
        BlocProvider(
          create: (context) => bloc,
          child: BlocBuilder(
            cubit: bloc,
            builder: (context, state) =>
                _buildFromFuture(context, state, true, adminUid),
          ),
        ),
      );
    }
    for (var memberUid in club.members) {
      var bloc = SingleProfileBloc(
          coordinationBloc: BlocProvider.of<CoordinationBloc>(context),
          profileUid: memberUid,
          playerBloc: BlocProvider.of<PlayerBloc>(context));
      members.add(
        BlocProvider(
          create: (context) => bloc,
          child: BlocBuilder(
            cubit: bloc,
            builder: (context, state) =>
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
