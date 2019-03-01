import 'package:flutter/material.dart';
import 'messages.dart';
import 'package:fusemodel/fusemodel.dart';

class Validations {
  String validateName(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).namerequired;
    }
    final RegExp nameExp = new RegExp(r'^[A-za-z ]+$');
    if (!nameExp.hasMatch(value)) {
      return Messages
          .of(context)
          .invalidname;
    }
    return null;
  }

  String validateDisplayName(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).namerequired;
    }
    return null;
  }

  String validateEmail(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).emailrequired;
    }
    final RegExp nameExp = new RegExp(r'^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$');
    if (!nameExp.hasMatch(value)) {
      return Messages.of(context).invalidemail;
    }
    return null;
  }

  String validatePassword(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).emptypassword;
    }
    return null;
  }

  String validateOpponent(BuildContext context, String value) {
    if (value == 'none' || value == 'add') {
      return Messages.of(context).needtoselectopponent;
    }
    return null;
  }

  String validateSport(BuildContext context, Sport value) {
    if (value == Sport.None) {
      return Messages.of(context).needtoselectsport;
    }
    return null;
  }

  String validateSeason(BuildContext context, String value) {
    if (value.isEmpty) {
      return Messages.of(context).seasonrequired;
    }
    return null;
  }

  String validateRoleInTeam(BuildContext context, String value) {
    if (value == 'none' || value == 'add') {
      return Messages.of(context).needtoselectrole;
    }
    return null;
  }

  String validateGender(BuildContext context, String value) {
    if (value == 'none') {
      return Messages.of(context).needtoselectgender;
    }
    return null;
  }

  String validatePhone(BuildContext context, String value) {
    return null;
  }
}
