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
      print(localeName);
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

  String get login {
    return Intl.message(
      'Login',
      name: 'Login button text',
    );
  }

  String get forgotPassword {
    return Intl.message(
      'Forgot Password',
      name: 'Forgot password button text',
    );
  }

  String get resendverify {
    return Intl.message(
      'Resend email',
      name: 'Button to resend the email to verify their email address',
    );
  }

  String get verifyexplanation {
    return Intl.message(
      'Email address needs to be verified, please check your email or resend the verification details',
      name: 'Button to resend the email to verify their email address',
    );
  }

  String get createnew {
    return Intl.message(
      'Create new',
      name: 'Create new account button text',
    );
  }

  String get newmail {
    return Intl.message("New message",
        name: "New message in the teamfuse system");
  }

  String get newbuttontext {
    return Intl.message("NEW", name: "New button text in the system");
  }

  String get email {
    return Intl.message('Email', name: 'Email input field');
  }

  String get youremailHint {
    return Intl.message('Your email address',
        name: 'Your email input field hint');
  }

  String get playeremailHint {
    return Intl.message('Player email address',
        name: 'Player email input field hint');
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

  String get where {
    return Intl.message('Where', name: 'Where the game is');
  }

  String get subject {
    return Intl.message("Subject",
        name: "Subject for the message, title of input field");
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
      'Game notes',
      name: 'Notes for the game',
      desc: 'The notes associated with the game',
    );
  }

  String get trainingnoteshint {
    return Intl.message(
      'Notes for the training',
      name: 'Notes for the game hint',
      desc: 'The hint text for notes associated with the game',
    );
  }

  String get trainingnotes {
    return Intl.message(
      'Training notes',
      name: 'Notes for the game',
      desc: 'The notes associated with the game',
    );
  }

  String get repeat {
    return Intl.message(
      'Repeat',
      name: 'Repeat title for the traning create steps',
    );
  }

  String get noneperiod {
    return Intl.message(
      'No repeat',
      name: 'No repeat period',
    );
  }

  String get weeklyperiod {
    return Intl.message(
      'Weekly',
      name: 'Weekly repeat',
    );
  }

  String get monthlyperiod {
    return Intl.message(
      'Monthly',
      name: 'Monthly repeat',
    );
  }

  String get trainingtimes {
    return Intl.message("Training times",
        name: 'HEader for the extra training times in a repeat event');
  }

  String get opponentselect {
    return Intl.message(
      'Select opponent',
      name: 'Select opponent for the event',
      desc: 'The hint text for selecting opponent for the game',
    );
  }

  String get until {
    return Intl.message("Until", name: 'Drop down for the until option');
  }

  String get noevent {
    return Intl.message("All events", name: 'Drop down for all the events');
  }

  String get gametype {
    return Intl.message("Games", name: 'Drop down for onlhy the game events');
  }

  String get trainingtype {
    return Intl.message("Training",
        name: 'Drop down foronlhy the training events');
  }

  String get eventtype {
    return Intl.message("Special Events",
        name: 'Drop down for only the special events');
  }

  String get noresult {
    return Intl.message("All Games", name: 'Drop down for all the games');
  }

  String get notfinished {
    return Intl.message("Not finished",
        name: 'Drop down for  the not finished result');
  }

  String get allteams {
    return Intl.message("All teams",
        name: 'Drop down for  the all teams result');
  }

  String get everyone {
    return Intl.message("Everyone",
        name: 'Message to mean everyone in the team (coaches + everyone)');
  }

  String get allgames {
    return Intl.message("All games", name: 'Checkbox to select all the games');
  }

  String get nogamesfiltered {
    return Intl.message("No games to display, check filters",
        name: 'No games to display based on filters');
  }

  String get win {
    return Intl.message("Win", name: 'Drop down for  the win result');
  }

  String get loss {
    return Intl.message("Loss", name: 'Drop down for  the loss result');
  }

  String get tie {
    return Intl.message("Tie", name: 'Drop down for  the tie result');
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

  String teamandseason(String teamMame, String seasonName) {
    return Intl.message("Team $teamMame\nSeason $seasonName");
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

  String get roleselect {
    return Intl.message('Select role',
        name: 'Drop down to select the role in the team');
  }

  String get needtoselectrole {
    return Intl.message('Need to select a role',
        name: 'Error to say they must select the role in the team');
  }

  String sportname(Sport sport) {
    switch (sport) {
      case Sport.Basketball:
        return Intl.message('Basketball',
            name: 'Basketball',
            desc: 'Name for the item in a drop down for basketball');
      case Sport.Softball:
        return Intl.message('Softball',
            name: 'Softball',
            desc: 'Name for the item in a drop down for softball');
      case Sport.Soccer:
        return Intl.message('Soccer',
            name: 'Soccer',
            desc: 'Name for the item in a drop down for soccer');
      case Sport.Other:
        return Intl.message('Other sport',
            name: 'Other sport',
            desc: 'Name for the item in a drop down for other');
    }
    return unknown;
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

  String get addplayer {
    return Intl.message('Add Player',
        name: 'Loading message', desc: 'Message for loading the app');
  }

  String opponentwinrecord(
      Opponent opponent, String seasonUid, String seasonName) {
    WinRecord rec = opponent.record[seasonUid];
    if (rec == null) {
      rec = new WinRecord();
    }
    return Intl.message(
        '${opponent.name} - $seasonName Win: ${rec.win} Loss: ${rec.loss} Tie: ${rec.tie}',
        name: 'Win record for an opponent for this season',
        desc: 'Win record for an opponent for this season');
  }

  String get previousSeasons {
    return Intl.message('Previous Seasons',
        name: 'Previous seasons for this game',
        desc: 'Previous seasons for this game');
  }

  String winrecord(WinRecord record) {
    return Intl.message(
        'Win: ${record.win} Loss: ${record.loss} Tie: ${record.tie}',
        name: 'Win record for a team',
        desc: 'Win record for a team');
  }

  String wearuniform(String wear) {
    return Intl.message('Wear $wear',
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

  String get addgame {
    return Intl.message('Add game', name: 'Button to add a game');
  }

  String get addinvite {
    return Intl.message('Add player');
  }

  String get addtraining {
    return Intl.message('Add training',
        name: 'Button to add a training to a team');
  }

  String get addevent {
    return Intl.message('Add event', name: 'Button to add an event to a team');
  }

  String get deleteinvite {
    return Intl.message('Delete invite',
        name: 'Title for the dialog to delete an invite');
  }

  String get gamecreate {
    return Intl.message('Create', name: 'Title for the step to create a game');
  }

  String confirmdelete(Invite invite) {
    return Intl.message(
        'Do you want to delete the invite to ${invite.teamName} for ${invite.playerName}',
        name: 'Text to delete the invite to the team in the alert dialog.');
  }

  String get newplayername {
    return Intl.message('New player name',
        name: 'Text to show before the player name.');
  }

  String get newplayernamehint {
    return Intl.message('New player name of player in team',
        name: 'Hint for the name of the player in the team.');
  }

  String gameresult(GameResult result) {
    switch (result) {
      case GameResult.Unknown:
        return unknown;
      case GameResult.InProgress:
        return unknown;
      case GameResult.Win:
        return Intl.message('Win', name: 'Win', desc: 'Short message for win');
      case GameResult.Tie:
        return Intl.message('Tie', name: 'Tie', desc: 'Short message for tie');
      case GameResult.Loss:
        return Intl.message('Loss',
            name: 'Loss', desc: 'Short message for loss');
    }
    return unknown;
  }

  String relationships(Relationship rel) {
    switch (rel) {
      case Relationship.Me:
        return Intl.message('Me',
            name: 'Relationship is me', desc: 'Relationship desc for me');
      case Relationship.Friend:
        return Intl.message('Friend',
            name: 'Relationship is friend',
            desc: 'Relationship desc for friend');
      case Relationship.Guardian:
        return Intl.message('Guardian',
            name: 'Relationship is guardian',
            desc: 'Relationship desc for guardian');
      case Relationship.Parent:
        return Intl.message('Parent',
            name: 'Relationship is parent',
            desc: 'Relationship desc for parent');
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
    return Intl.message('Game vs $oppponent',
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

  String roleingame(RoleInTeam role) {
    switch (role) {
      case RoleInTeam.Player:
        return Intl.message("Player", desc: "Player role in the team");
      case RoleInTeam.Coach:
        return Intl.message("Coach", desc: "Coach role in the team");
      case RoleInTeam.NonPlayer:
        return Intl.message("Non Player", desc: "Non Player role in the team");
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

  String get displayname {
    return Intl.message('Name',
        desc: 'Name for the edit box to edit the user name');
  }

  String get displaynamehint {
    return Intl.message('Your name',
        desc: 'Name for the edit box to edit the user name');
  }

  String get changerole {
    return Intl.message('Change role',
        desc: 'Button to change the role of the member of the team');
  }

  String get deleteplayer {
    return Intl.message('Remove from team',
        desc: 'Button to change the remove a member from the team');
  }

  String confirmremovefromteam(String name) {
    return Intl.message('Are you sure you want to remove $name from the team?',
        desc: 'Dialog text to confirm removing a user from the team');
  }

  String displaynamerelationship(String name, Relationship relationship) {
    String rel = relationships(relationship);
    return Intl.message('$name ($rel)',
        desc: 'Name for the edit box to edit the user name');
  }

  String get phonenumber {
    return Intl.message('Phone Number',
        desc: 'Phone number for the edit box to edit the phone number');
  }

  String get phonenumberhint {
    return Intl.message('Contact phone number',
        desc: 'Phone number for the edit box to edit the phone number');
  }

  String get phonenumberhintoptional {
    return Intl.message('Phone number (optional)',
        desc:
            'Phone number for the edit box to edit the phone number marked as optional');
  }

  String get password {
    return Intl.message('Password', desc: 'Input box for a password');
  }

  String get verifypassword {
    return Intl.message('Verify password',
        desc: 'Input box for a verification to the main password password');
  }

  String get createaccount {
    return Intl.message('Create', desc: 'Create account button text');
  }

  String get passwordsnotmatching {
    return Intl.message('Passwords must match',
        desc: 'Passwords must match signup form error');
  }

  String invitedpeople(int num) {
    return Intl.message("Invited: $num");
  }

  String finalscorebody(num ptsFor, num ptsAgainst, String result) {
    return Intl.message(
        'Do you want to set $ptsFor $ptsAgainst $result as the final score?',
        desc: 'Start game dialofg body text');
  }

  String get message {
    return Intl.message('Message',
        desc: 'In a text edit box to send a message to the team');
  }

  String get includemyself {
    return Intl.message('Send to yourself',
        desc: 'If the message should also be sent to ourselves');
  }

  String get sendmessage {
    return Intl.message('Send message',
        desc: 'In a text edit box to send a message to a user');
  }

  String get sendmessagebuttontext {
    return Intl.message('SEND', desc: 'Button to send the message');
  }

  String get nomessages {
    return Intl.message('No Messages',
        desc: 'In a text edit box to send a message to the team');
  }

  String get archivemessage {
    return Intl.message("Archive", name: "Archive message button");
  }

  String get deletemessage {
    return Intl.message("Delete", name: "Delete message button");
  }

  String get gameend {
    return Intl.message('Game end',
        desc: 'Title for the time drop down to choose the game end time');
  }

  String get selectplace {
    return Intl.message('Select place',
        desc: 'Title for the drop down to say select place if nothing is selected');

  }

  String get trainingend {
    return Intl.message('Training end',
        desc: 'Title for the time drop down to choose the training end time');
  }

  String gametitle(String time, String endTime, String opponent) {
    if (endTime != null) {
      return Intl.message('$time - $endTime vs $opponent',
          desc: 'Game title in game list');
    }
    return Intl.message('$time vs $opponent', desc: 'Game title in game list');
  }

  String gametitlenow(String time, String endTime, String opponent) {
    if (endTime != null) {
      return Intl.message('NOW! $time - $endTime vs $opponent',
          name: 'Game title in game list', desc: 'Game title in game list');
    }
    return Intl.message('NOW! $time vs $opponent',
        name: 'Game title in game list', desc: 'Game title in game list');
  }

  String eventtitle(String time, String endTime) {
    if (endTime != null) {
      return Intl.message('Event $time - $endTime',
          desc: 'Special event title in game list');
    }
    return Intl.message('Event $time',
        desc: 'Special event title in game list');
  }

  String eventtitlenow(String time, String endTime) {
    if (endTime != null) {
      return Intl.message('NOW! Event $time - $endTime',
          desc: 'Special event title in game list');
    }
    return Intl.message('NOW! Event $time',
        desc: 'Special event title in game list');
  }

  String trainingtitle(String time, String endTime) {
    if (endTime != null) {
      return Intl.message('Practice $time - $endTime',
          desc: 'Practice title in game list');
    }
    return Intl.message('Practice $time', desc: 'Practice title in game list');
  }

  String trainingtitlenow(String time, String endTime) {
    if (endTime != null) {
      return Intl.message('NOW! Practice $time - $endTime',
          desc: 'Training title in game list');
    }
    return Intl.message('NOW! Practice $time',
        desc: 'Training title in game list');
  }

  String gameaddressarriveat(String arriveAt, String address) {
    return Intl.message('Arrive by $arriveAt\n$address',
        desc: 'Game address in game list with arrive by');
  }

  String get players {
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
