import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/firestore.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleclubprovider.dart';
import '../util/savingoverlay.dart';
import '../util/userimage.dart';

///
/// Display the members of the club.
///
class ClubMembers extends StatelessWidget {
  /// Constructor.
  ClubMembers(this.club);

  /// The club to show members for.
  final Club club;

  void _deleteMember(BuildContext context, FusedUserProfile profile,
      SingleClubBloc bloc) async {
    var mess = Messages.of(context);
    // Show an alert dialog first.
    var result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: Text(mess.deleteMember),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(mess.confirmDeleteMember(profile.displayName)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
          ],
        );
      },
    );
    if (result) {
      bloc.add(SingleClubDeleteMember(memberUid: profile.uid));
    }
  }

  Widget _buildFromFuture(BuildContext context, SingleProfileState state,
      bool admin, String uid, SingleClubBloc bloc) {
    if ((state is SingleProfileLoaded)) {
      var profile = state.profile;
      if (profile != null) {
        var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
        return ListTile(
          leading: UserImage(profile.uid),
          title: Text(profile.displayName),
          subtitle: Text(admin ? Messages.of(context).administrator : ''),
          trailing: club.isAdmin() &&
                  profile.uid != authenticationBloc.currentUser.uid
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteMember(context, profile, bloc),
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

  List<Widget> _buildMembers(
      BuildContext context, SingleClubBloc singleClubBloc) {
    var members = <Widget>[];

    for (var adminUid in club.adminsUids) {
      var bloc = SingleProfileBloc(
          userAuth: RepositoryProvider.of<UserAuthImpl>(context),
          crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
          profileUid: adminUid,
          db: RepositoryProvider.of<DatabaseUpdateModel>(context));
      members.add(
        BlocProvider(
          create: (context) => bloc,
          child: BlocBuilder(
            bloc: bloc,
            builder: (context, state) => _buildFromFuture(
                context, state, true, adminUid, singleClubBloc),
          ),
        ),
      );
    }
    for (var memberUid in club.members) {
      var bloc = SingleProfileBloc(
          userAuth: RepositoryProvider.of<UserAuthImpl>(context),
          crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
          profileUid: memberUid,
          db: RepositoryProvider.of<DatabaseUpdateModel>(context));
      members.add(
        BlocProvider(
          create: (context) => bloc,
          child: BlocBuilder(
            bloc: bloc,
            builder: (context, state) => _buildFromFuture(
                context, state, false, memberUid, singleClubBloc),
          ),
        ),
      );
    }
    return members;
  }

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: club.uid,
      builder: (context, singleClubBloc) => BlocBuilder(
        bloc: singleClubBloc,
        builder: (context, clubState) => SavingOverlay(
          saving: clubState is SingleClubSaving ||
              clubState is SingleClubUninitialized,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildMembers(context, singleClubBloc),
            ),
          ),
        ),
      ),
    );
  }
}
