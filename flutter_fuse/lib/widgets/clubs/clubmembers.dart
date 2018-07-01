import 'package:fusemodel/fusemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/firestore.dart';
import 'package:flutter_fuse/widgets/util/userimage.dart';

class ClubMembers extends StatelessWidget {
  final Club club;

  ClubMembers(this.club);

  void _deleteMember(BuildContext context, FusedUserProfile profile) async {
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
      club.deleteClubMember(profile.uid);
    }
  }

  Widget _buildFromFuture(BuildContext context,
      AsyncSnapshot<FusedUserProfile> profile, bool admin) {
    if (profile.hasData) {
      return new ListTile(
        leading: new UserImage(profile.data),
        title: new Text(profile.data.displayName),
        subtitle: new Text(admin ? Messages.of(context).administrator : ""),
        trailing: club.isAdmin() &&
                profile.data.uid != UserDatabaseData.instance.userUid
            ? new IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteMember(context, profile.data),
              )
            : null,
      );
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
        new FutureBuilder<FusedUserProfile>(
          future: UserDatabaseData.instance.userAuth.getProfile(adminUid),
          builder:
              (BuildContext context, AsyncSnapshot<FusedUserProfile> profile) =>
                  _buildFromFuture(context, profile, true),
        ),
      );
    }
    for (String memberUid in club.members) {
      members.add(
        new FutureBuilder<FusedUserProfile>(
          future: UserDatabaseData.instance.userAuth.getProfile(memberUid),
          builder:
              (BuildContext context, AsyncSnapshot<FusedUserProfile> profile) =>
                  _buildFromFuture(context, profile, false),
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
