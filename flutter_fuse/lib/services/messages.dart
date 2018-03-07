import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_fuse/i10n/messages_all.dart';
import 'package:flutter_fuse/services/databasedetails.dart';

class Messages {
  static Future<Messages> load(Locale locale) async {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((dynamic _) {
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
    return Intl.message('Please choose an opponent.',
        name: 'Message to suggest they need to select an oppoent',
        desc: 'Message to suggest they need to select an oppoent');
  }

  String get needtoselectgender {
    return Intl.message('Please choose a gender.',
        name: 'Message to suggest they need to select a gender',
        desc: 'Message to suggest they need to select a gender');
  }

  String get needtoselectsport {
    return Intl.message('Please choose a sport.',
        name: 'Message to suggest they need to select a sport',
        desc: 'Message to suggest they need to select a sport');
  }

  String get emptypassword {
    return Intl.message('Please choose a password.',
        name: 'Empty password in form',
        desc: 'Message to say they have an empty password field');
  }

  String get emailrequired {
    return Intl.message('Email is empty.',
        name: 'Empty email in form',
        desc: 'Message to say they have an empty email field');
  }

  String get invalidemail {
    return Intl.message('Email address must be of form xxx@xxx.',
        name: 'Invalid email in form',
        desc: 'Message to say they have an invalid email field');
  }

  String get namerequired {
    return Intl.message('Username is empty.',
        name: 'Empty email in form',
        desc: 'Message to say they have an empty email field');
  }

  String get invalidname {
    return Intl.message('Name can only contain alphanumerical characters.',
        name: 'Invalid user name in form',
        desc: 'Message to say they have an invalid user name field');
  }

  String get teamname {
    return Intl.message('Name', name: 'Team Name', desc: 'Name of the team');
  }

  String get teamnamehint {
    return Intl.message('Name',
        name: 'Team Name hint', desc: 'Hint for the name of the team');
  }

  String get teamedithint {
    return Intl.message('Change team',
        name: 'Team editing hint',
        desc: 'Hint for the button to edit the team');
  }

  String get sportselect {
    return Intl.message('Select sport',
        name: 'Name for the default select sport text',
        desc: 'Name for the default select sport text');
  }

  String get sportbasketball {
    return Intl.message('Basketball',
        name: 'Basketball',
        desc: 'Name for the item in a drop down for basketball');
  }

  String get sportother {
    return Intl.message('Other sport',
        name: 'Other sport',
        desc: 'Name for the item in a drop down for other');
  }

  String get sportsoftball {
    return Intl.message('Softball',
        name: 'Softball',
        desc: 'Name for the item in a drop down for softball');
  }

  String get sportsoccer {
    return Intl.message('Soccer',
        name: 'Soccer', desc: 'Name for the item in a drop down for soccer');
  }

  String get genderfemale {
    return Intl.message('Female',
        name: 'Female gemder',
        desc: 'Female gender for the sport in the drop down');
  }

  String get gendermale {
    return Intl.message('Male',
        name: 'Male gemder',
        desc: 'Male gender for the sport in the drop down');
  }

  String get gendercoed {
    return Intl.message('Coed',
        name: 'Coed gemder',
        desc: 'Coed gender for the sport in the drop down');
  }

  String get genderna {
    return Intl.message('N/A',
        name: 'Gender not applicable',
        desc: 'Not applicable gender for the sport in the drop down');
  }

  String get genderselect {
    return Intl.message('Select gender',
        name: 'Hint text to select a gender',
        desc: 'Hint text to select a gender');
  }

  String get league {
    return Intl.message('League',
        name: 'League', desc: 'The league the team is playing in');
  }

  String get leaguehint {
    return Intl.message('League the team is playing in',
        name: 'League the team is playing in',
        desc: 'League the team is playing in');
  }

  String get formerror {
    return Intl.message('Please fix the items outlined in red',
        name: 'Error in a form', desc: 'Error when submitting a form');
  }

  String get attendanceselect {
    return Intl.message('Attendence',
    name: 'Attendence for the game', desc: 'Are you attending the game title');
  }

  String get attendanceyes {
    return Intl.message('Will be there',
        name: 'Positive attendence for the game', desc: 'Positive attendence for the game');
  }

  String get attendanceno {
    return Intl.message('Not making it',
        name: 'Negative attendence for the game', desc: 'Negative attendence for the game');
  }

  String get attendncemaybe {
    return Intl.message('Maybe',
        name: 'Maybe attendence for the game', desc: 'Maybe attendence for the game');
  }
  String get loading {
    return Intl.message('Loading...',
        name: 'Loading message', desc: 'Message for loading the app');
  }

  String winrecord(WinRecord record) {
    return Intl.message('Win: ${record.win} Loss: ${record.loss} Tie: ${record.tie}',
        name: 'Win record for a team', desc: 'Win record for a team');
  }

  String wearuniform(String wear) {
    return Intl.message('Wear ${wear}',
        name: 'Wear uniform message in game des', desc: 'Wear uniform in a game desc');

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
