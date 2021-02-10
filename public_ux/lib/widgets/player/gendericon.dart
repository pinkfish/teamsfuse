import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

///
/// Shwows an icon based on the gender passed in
///
class GenderIcon extends Icon {
  /// Constructor for the gender icon.
  GenderIcon(Gender gender, {double size})
      : super(_getIcon(gender), size: size);

  static IconData _getIcon(Gender gender) {
    switch (gender) {
      case Gender.Female:
        return MdiIcons.genderFemale;
      case Gender.Male:
        return MdiIcons.genderMale;
      case Gender.Coed:
        return MdiIcons.genderMaleFemale;
      case Gender.NA:
        return Icons.person;
    }
    return MdiIcons.nullIcon;
  }
}
