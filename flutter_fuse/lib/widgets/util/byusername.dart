import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class ByUserNameComponent extends FutureBuilder<FusedUserProfile> {
  ByUserNameComponent({@required String userId})
      : super(
          future: UserDatabaseData.instance.userAuth.getProfile(userId),
          builder:
              (BuildContext context, AsyncSnapshot<FusedUserProfile> profile) {
            Widget inner;
            if (profile.hasData) {
              inner = Text(
                  Messages.of(context).invitedby(profile.data.displayName));
            } else {
              inner = Text(Messages.of(context).loading);
            }
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: inner,
            );
          },
        );
}
