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

  String get editgame {
    return Intl.message(
      'Edit Game',
      name: 'Edit Game',
      desc: 'Edit Game help text for button',
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

  String get editbuttontext {
    return Intl.message(
      'EDIT',
      name: 'Edit button text',
      desc: 'The edit text for the dialog',
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
        name: 'Attendence for the game',
        desc: 'Are you attending the game title');
  }

  String get attendanceyes {
    return Intl.message('Will be there',
        name: 'Positive attendence for the game',
        desc: 'Positive attendence for the game');
  }

  String get attendanceno {
    return Intl.message('Not making it',
        name: 'Negative attendence for the game',
        desc: 'Negative attendence for the game');
  }

  String get attendncemaybe {
    return Intl.message('Maybe',
        name: 'Maybe attendence for the game',
        desc: 'Maybe attendence for the game');
  }

  String get loading {
    return Intl.message('Loading...',
        name: 'Loading message', desc: 'Message for loading the app');
  }

  String oppoentwinrecord(Opponent opponent) {
    return Intl.message(
        '${opponent.name} Win: ${opponent.record.win} Loss: ${opponent.record.loss} Tie: ${opponent.record.tie}',
        name: 'Win record for an opponent',
        desc: 'Win record for an opponent');
  }

  String winrecord(WinRecord record) {
    return Intl.message(
        'Win: ${record.win} Loss: ${record.loss} Tie: ${record.tie}',
        name: 'Win record for a team',
        desc: 'Win record for a team');
  }

  String wearuniform(String wear) {
    return Intl.message('Wear ${wear}',
        name: 'Wear uniform message in game des',
        desc: 'Wear uniform in a game desc');
  }

  String get gamedetails {
    return Intl.message('Details',
        name: 'Details for the game',
        desc: 'Details for the game, botton tab bar title');
  }

  String get gameavailability {
    return Intl.message('Availability',
        name: 'Availability for the game',
        desc: 'Availability for the game, botton tab bar title');
  }

  String get resultunknown {
    return Intl.message('No result.',
        name: 'No result for the game yet', desc: 'No result for the game');
  }

  String gameresult(GameResult result) {
    switch (result) {
      case GameResult.Unknown:
        return unknown;
      case GameResult.InProgress:
        return unknown;
      case GameResult.Win:
        return Intl.message('Win',
            name: 'Win', desc: 'Short message for win');
      case GameResult.Tie:
        return Intl.message('Win',
            name: 'Tie', desc: 'Short message for tie');
      case GameResult.Loss:
        return Intl.message('Loss',
            name: 'Loss', desc: 'Short message for loss');
    }
    return unknown;
  }

  String resultwin(GameResultDetails result) {
    return Intl.message('Win ${result.ptsFor} - ${result.ptsAgainst}',
        name: 'Win result details', desc: 'Win result details');
  }

  String resultloss(GameResultDetails result) {
    return Intl.message('Loss ${result.ptsFor} - ${result.ptsAgainst}',
        name: 'Loss result details', desc: 'Loss result details');
  }

  String resulttie(GameResultDetails result) {
    return Intl.message('Tie ${result.ptsFor} - ${result.ptsAgainst}',
        name: 'Tie result details', desc: 'Tie result details');
  }

  String resultinprogress(GameResultDetails result) {
    return Intl.message('In progress ${result.ptsFor} - ${result.ptsAgainst}',
        name: 'In progress result details', desc: 'In progress result details');
  }

  String gametitlevs(String oppponent) {
    return Intl.message('Game vs ${oppponent}',
        name: 'Game details title', desc: 'Game details title for the screen');
  }

  String gameinprogress(GameInProgress val) {
    switch (val) {
      case GameInProgress.First:
        return Intl.message("1st", desc: "Game in progress 1st period");
      case GameInProgress.Second:
        return Intl.message("2nd", desc: "Game in progress 2nd period");
      case GameInProgress.Third:
        return Intl.message("3nd", desc: "Game in progress 3rd period");
      case GameInProgress.Fourth:
        return Intl.message("4nd", desc: "Game in progress 4th period");
      case GameInProgress.Fifth:
        return Intl.message("5nd", desc: "Game in progress 5th period");
      case GameInProgress.Sixth:
        return Intl.message("6nd", desc: "Game in progress 6th period");
      case GameInProgress.Seventh:
        return Intl.message("7nd", desc: "Game in progress 7th period");
      case GameInProgress.Eighth:
        return Intl.message("8th", desc: "Game in progress 8th period");
      case GameInProgress.Nineth:
        return Intl.message("9th", desc: "Game in progress 9th period");
      case GameInProgress.Tenth:
        return Intl.message("10th", desc: "Game in progress 10th period");
      case GameInProgress.Half:
        return Intl.message("Half", desc: "Game in progress Half ");
      case GameInProgress.Final:
        return Intl.message("Final", desc: "Game in finalized");
      case GameInProgress.NotStarted:
        return Intl.message("Not started", desc: "Game in progress 1st period");
    }
    return unknown;
  }

  String get startgame {
    return Intl.message('Start Game', desc: 'Start game dialofg title');
  }

  String get startgamebody {
    return Intl.message('Do you want to start the game?',
        desc: 'Start game dialofg body text');
  }

  String get finalscore {
    return Intl.message('Final score', desc: 'Final score dialofg title');
  }

  String finalscorebody(num ptsFor, num ptsAgainst, String result) {
    return Intl.message(
        'Do you want to set ${ptsFor} ${ptsAgainst} ${result} as the final score?',
        desc: 'Start game dialofg body text');
  }

  String get message {
    return Intl.message('Message',
        desc: 'In a text edit box to send a message to the team');
  }

  String get nomessages {
    return Intl.message('No Messages',
        desc: 'In a text edit box to send a message to the team');
  }

  String gametitle(String time, String opponent) {
    return Intl.message('${time} vs ${opponent}', desc: 'Game title in game list');
  }

  String gametitlenow(String time, String opponent) {
    return Intl.message('NOW! ${time} vs ${opponent}',
        name: 'Game title in game list', desc: 'Game title in game list');
  }

  String gameaddressarriveat(String arriveAt, String address) {
    return Intl.message('Arrive by ${arriveAt}\n${address}',
        desc: 'Game address in game list with arrive by');
  }

  String get players{
    return Intl.message('Players',
        desc: 'Title in the bottom navigation tab for players');
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
