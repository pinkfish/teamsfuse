import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'communityicons.dart';

///
/// Shwows an icon based on the gender passed in
///
class GenderIcon extends Icon {
  GenderIcon(Gender gender) : super(_getIcon(gender));

  static IconData _getIcon(Gender gender) {
    switch (gender) {
      case Gender.Female:
        return CommunityIcons.genderFemale;
      case Gender.Male:
        return CommunityIcons.genderMale;
      case Gender.Coed:
        return CommunityIcons.genderMaleFemale;
      case Gender.NA:
        return CommunityIcons.nullIcon;
    }
    return CommunityIcons.nullIcon;
  }
}
