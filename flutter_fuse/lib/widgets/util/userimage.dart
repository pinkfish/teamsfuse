import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Displays the user image.
///
class UserImage extends CircleAvatar {
  UserImage(
    FusedUserProfile profile, {
    Key key,
    double radius = 20.0,
    Color backgroundColor,
  }) : super(
            backgroundColor: backgroundColor,
            radius: radius,
            child: Text(profile.initials()));
}
