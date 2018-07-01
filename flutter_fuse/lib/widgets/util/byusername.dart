import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class ByUserNameComponent extends FutureBuilder<FusedUserProfile> {
  ByUserNameComponent({@required String userId})
      : super(
          future: UserDatabaseData.instance.userAuth.getProfile(userId),
          builder:
              (BuildContext context, AsyncSnapshot<FusedUserProfile> profile) {
            if (profile.hasData) {
              return new Text(
                  Messages.of(context).invitedby(profile.data.displayName));
            }
            return new Text(Messages.of(context).loading);
          },
        );
}
