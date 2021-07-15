import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import 'messages.dart';

/// The shared valiaations users for forms.
class Validations {
  /// Validate a name is correct.
  String validateName(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).nameRequired;
    }
    var nameExp = RegExp(r'^[A-za-z ]+$');
    if (!nameExp.hasMatch(value)) {
      return Messages.of(context).invalidName;
    }
    return null;
  }

  /// Validates a display name is correct.
  String validateDisplayName(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).nameRequired;
    }
    return null;
  }

  /// Validates a subject is correct.
  String validateSubject(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).subjectRequired;
    }
    return null;
  }

  /// Validate an email is correct.
  String validateEmail(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).emailRequired;
    }
    var nameExp = RegExp(r'^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$');
    if (!nameExp.hasMatch(value)) {
      return Messages.of(context).invalidEmail;
    }
    return null;
  }

  /// Validate a passsword is correct.
  String validatePassword(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).emptyPassword;
    }
    return null;
  }

  /// Validate an opponent name is correct.
  String validateOpponent(BuildContext context, String value) {
    if (value == 'none' || value == 'add') {
      return Messages.of(context).needToSelectOpponent;
    }
    return null;
  }

  /// Validate the sport is correct.
  String validateSport(BuildContext context, Sport value) {
    if (value == Sport.None) {
      return Messages.of(context).needToSelectSport;
    }
    return null;
  }

  /// Valdate the season is correct.
  String validateSeason(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).seasonRequired;
    }
    return null;
  }

  /// Validate the role in the team is correct.
  String validateRoleInTeam(BuildContext context, String value) {
    if (value == 'none' || value == 'add') {
      return Messages.of(context).needToSelectRole;
    }
    return null;
  }

  /// Validate the gender is correct.
  String validateGender(BuildContext context, String value) {
    if (value == 'none') {
      return Messages.of(context).needToSelectGender;
    }
    return null;
  }

  /// Validate the phone number is correct.
  String validatePhone(BuildContext context, String value) {
    return null;
  }

  String validateGamePlace(BuildContext context, GamePlace place) {
    if (place.name.isEmpty && place.address.isEmpty) {
      return Messages.of(context).needToSelectPlace;
    }
    return null;
  }

  /// Validates the youtube url.
  static String validateYoutubeUrl(BuildContext context, String url) {
    if (url == null) {
      return Messages.of(context).invalidYoutubeURL;
    }

    if (url.isEmpty) {
      return Messages.of(context).invalidYoutubeURL;
    }

    var pattern = RegExp(
        r'^(?:https?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))((\w|-){11})(?:\S+)?$');
    var match = pattern.hasMatch(url);

    if (match) return null;

    return Messages.of(context).invalidYoutubeURL;
  }
}
