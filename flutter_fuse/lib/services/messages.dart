import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_fuse/i10n/messages_all.dart';

class Messages {
  static Future<Messages> load(Locale locale) async {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((dynamic _)  {
      Intl.defaultLocale = localeName;
      return new Messages();
    });
  }

  static Messages of(BuildContext context) {
    return Localizations.of<Messages>(context, Messages);
  }

  String get title {
    return Intl.message(
      'Team Fuse',
      name: 'title',
      desc: 'Title for the Team Fuse application',
    );
  }

  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: 'Unknown name',
    );
  }

  String get nogames {
    return Intl.message(
      'No games',
      name: 'No games',
      desc: 'No games scheduled',
    );
  }

  String get editteam {
    return Intl.message(
      'Edit Team',
      name: 'Edit Team',
      desc: 'Edit Team help text for button',
    );
  }

  String get gamenoteshint {
    return Intl.message(
      'Notes for the game',
      name: 'Notes for the game hint',
      desc: 'The hint text for notes associated with the game',
    );
  }

  String get gamenotes {
    return Intl.message(
      'Game Notes',
      name: 'Notes for the game',
      desc: 'The notes associated with the game',
    );
  }

  String get opponentselect {
    return Intl.message(
      'Select opponent',
      name: 'Select opponent for the event',
      desc: 'The hint text for selecting opponent for the game',
    );
  }

  String get opponentname {
    return Intl.message(
      'Name',
      name: 'Opponent name',
      desc: 'The text for the name of an opponent',
    );
  }

  String get opponentnamehint {
    return Intl.message(
      'Name of the opponent.',
      name: 'Opponent name hint',
      desc: 'The hint text for the name of an opponent',
    );
  }

  String get opponentcontacthint {
    return Intl.message(
      'Contact for the opponent',
      name: 'Opponent contact hint',
      desc: 'The hint text for the contact of an opponent',
    );
  }

  String get savebuttontext {
    return Intl.message(
      'SAVE',
      name: 'Save button text',
      desc: 'The save text for the dialog',
    );
  }

   String get opponentcontact {
    return Intl.message(
      'Contact',
      name: 'Opponent contact',
      desc: 'The text for the contact of an opponent',
    );
  }


  String get teamselect {
    return Intl.message(
      'Select team',
      name: 'Select team',
      desc: 'The text for notes for selecting team for the event',
    );
  }

  String get addopponent {
    return Intl.message(
      'Add new',
      name: 'Add new',
      desc: 'Add new opponent for game',
    );
  }

  String get team {
    return Intl.message(
      'Team',
      name: 'Team',
      desc: 'Title for the team marker',
    );
  }

  String get arriveat {
    return Intl.message(
      'Arrive At',
      name: 'Arrive At',
      desc: 'Title for when to arrive',
    );
  }

  String get gametime {
    return Intl.message(
      'Game Time',
      name: 'Team',
      desc: 'Title for the game time',
    );
  }

  String get season {
    return Intl.message(
      'Season',
      name: 'Season',
      desc: 'Title for the season marker',
    );
  }

  String get seasonselect {
    return Intl.message(
      'Select season',
      name: 'Select Season',
      desc: 'Title for the select season marker',
    );
  }

  String get opponent {
    return Intl.message(
      'Opponent',
      name: 'Opponent',
      desc: 'Title for the opponent marker',
    );
  }


  String get uniform {
    return Intl.message(
      'Uniform',
      name: 'Uniform',
      desc: 'Title for the uniform input box',
    );
  }

  String get uniformhint {
    return Intl.message(
      'Uniform to wear',
      name: 'Uniform to wear',
      desc: 'Hint for the uniform input box',
    );
  }

  String get homeaway {
    return Intl.message(
      'Home',
      name: 'Home game flag',
      desc: 'Title for the home game checkbox',
    );
  }

  String get needtoselectopponent {
    return Intl.message(
        'Please choose an opponent.',
        name: 'Message to suggest they need to select an oppoent',
        desc: 'Message to suggest they need to select an oppoent'
    );
  }

  String get emptypassword {
    return Intl.message(
        'Please choose a password.',
        name: 'Empty password in form',
        desc: 'Message to say they have an empty password field'
    );
  }

  String get emailrequired {
    return Intl.message(
        'Email is empty.',
        name: 'Empty email in form',
        desc: 'Message to say they have an empty email field'
    );
  }

  String get invalidemail {
    return Intl.message(
        'Email address must be of form xxx@xxx.',
        name: 'Invalid email in form',
        desc: 'Message to say they have an invalid email field'
    );
  }

  String get namerequired {
    return Intl.message(
        'Username is empty.',
        name: 'Empty email in form',
        desc: 'Message to say they have an empty email field'
    );
  }

  String get invalidname {
    return Intl.message(
        'Name can only contain alphanumerical characters.',
        name: 'Invalid user name in form',
        desc: 'Message to say they have an invalid user name field'
    );
  }


}

class MessagesDelegate extends LocalizationsDelegate<Messages> {
  const MessagesDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<Messages> load(Locale locale) => Messages.load(locale);

  @override
  bool shouldReload(MessagesDelegate old) => false;
}