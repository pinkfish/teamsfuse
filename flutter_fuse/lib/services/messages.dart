import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart';

import '../i10n/messages_all.dart';

///
/// The main messages class for the system, all the strings that need
/// to be translated.
///
class Messages {
  final String locale;

  Messages(this.locale);

  String get about {
    return Intl.message('About');
  }

  String get acceptinviteasadmin {
    return Intl.message('Invited as an Administrator');
  }

  String get addadmin => Intl.message('ADD ADMIN',
      desc: 'Message to show as the title for the admin adding screen',
      locale: locale);

  String get noCoaches => Intl.message("No coaches",
      desc: 'Message to show that there are no coaches for this club',
      locale: locale);

  String get coaches => Intl.message('Coaches',
      desc: 'Header to display the coaches for the team/club', locale: locale);

  String get addclub {
    return Intl.message("ADD CLUB", name: "Add a new club button");
  }

  String get addclubmemebertitle => Intl.message('Add club member');

  String get adddivison {
    return Intl.message('ADD DIVISON',
        name: 'Add a division inside a league/tournament');
  }

  String get addevent {
    return Intl.message('ADD EVENT', name: 'Button to add an event to a team');
  }

  String get addgamebutton =>
      Intl.message('GAME', name: 'Button to add a game', locale: locale);

  String get addGameTooltip => Intl.message("Add Game",
      desc: "Message to on the tooltip to add a game", locale: locale);

  String get addinvite {
    return Intl.message('SHARE PLAYER');
  }

  String get addleague {
    return Intl.message('Add League');
  }

  String get addopponent {
    return Intl.message(
      'Add new',
      name: 'Add new',
      desc: 'Add new opponent for game',
    );
  }

  String get addplayer {
    return Intl.message('ADD PLAYER',
        name: 'Loading message', desc: 'Message for loading the app');
  }

  String get addPlayerButton => Intl.message("PLAYER",
      desc: "Text on a add player button", locale: locale);

  String get addPlayerTooltip => Intl.message("Add Player",
      desc: "Message to on the tooltip to add a player", locale: locale);

  String get addresultbutton {
    return Intl.message('ADD RESULT');
  }

  String get addseason {
    return Intl.message('ADD SEASON', name: 'Add a season to the team');
  }

  String get addteam {
    return Intl.message("ADD TEAM", name: "Add a new team button");
  }

  String get addteamadmin {
    return Intl.message('SHARE TEAM');
  }

  String get addtournament {
    return Intl.message('Add Tournamwent');
  }

  String get addtraining {
    return Intl.message('ADD TRAINING',
        name: 'Button to add a training to a team');
  }

  String get administrator {
    return Intl.message('Adminstrator');
  }

  String get againstpts {
    return Intl.message("Against",
        desc:
            "Title to the spinner for showing points against in the results screen");
  }

  String get allEvents => Intl.message("All Events",
      desc: "Drop down menu item for all events", locale: locale);

  String get allgames {
    return Intl.message("All games", name: 'Checkbox to select all the games');
  }

  String get allPeriods => Intl.message("All Periods",
      desc: "Drop down menu item for all periods", locale: locale);

  String get allteams {
    return Intl.message("All teams",
        name: 'Drop down for  the all teams result');
  }

  String get allteamsbbutton {
    return Intl.message("ALL TEAMS",
        name: 'Drop down for  the all teams result');
  }

  String get archived {
    return Intl.message('Archived');
  }

  String get archivedteams {
    return Intl.message('Archived Teams');
  }

  String get archivemessage {
    return Intl.message("Archive", name: "Archive message button");
  }

  String get archiveteam {
    return Intl.message('Archive Team');
  }

  String get arriveat {
    return Intl.message(
      'Arrive At',
      name: 'Arrive At',
      desc: 'Title for when to arrive',
    );
  }

  String get arrivebeforehint {
    return Intl.message('Minutes to arrive before game');
  }

  String get arrivebeforelabel {
    return Intl.message('Minutes before game');
  }

  String get assistTitle => Intl.message("Assists",
      desc: "Title for the section on a player assist", locale: locale);

  String get attendanceno {
    return Intl.message('Not making it',
        name: 'Negative attendence for the game',
        desc: 'Negative attendence for the game');
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

  String get attendncemaybe {
    return Intl.message('Maybe',
        name: 'Maybe attendence for the game',
        desc: 'Maybe attendence for the game');
  }

  String get away {
    return Intl.message("away");
  }

  String get blockEventType =>
      Intl.message("Block", desc: "Block of a shot", locale: locale);

  String get blocks => Intl.message("Blocks",
      desc: "Drop down menu item for fouls", locale: locale);

  String get blocksTitle =>
      Intl.message("Blk", desc: "Blocks abbreviation", locale: locale);

  String get changerole {
    return Intl.message('CHANGE ROLE',
        desc: 'Button to change the role of the member of the team');
  }

  String get changescore {
    return Intl.message('Change Score',
        desc:
            'Title for the dialog box to change the score after the game has finished');
  }

  String get choosedivisions {
    return Intl.message("Start Game - Breaks");
  }

  String get club {
    return Intl.message('Club');
  }

  String get clubdetails {
    return Intl.message('Details');
  }

  String get clubsettingdescription => Intl.message(
      'To setup a club for a team you need to be an '
      'administrator for both the club and for the team.  This will let you '
      'connect the both together.  Once connected all administators of the '
      'club will also be adminstragtors for the team.',
      locale: locale);

  String get copyseasonfrom =>
      Intl.message('Copy details from', locale: locale);

  String get allPlayers => Intl.message('All Players', locale: locale);
  String get allSeasons => Intl.message('All Seasons', locale: locale);

  String get playerName => Intl.message('Player Name', locale: locale);

  String get create => Intl.message(
        'Create new',
        name: 'Create new account button text',
      );

  String get createaccount {
    return Intl.message('CREATE', desc: 'Create account button text');
  }

  String get createdaccount {
    return Intl.message(
        "Created an account, please look in your email for the verification code..",
        desc:
            "Confirmation message after requesting the email verification code");
  }

  String get createNew {
    return Intl.message('Create',
        name: 'Title for the step to create a game or team in a stepper');
  }

  String get currentSeason => Intl.message("Current",
      desc: "Subtitle to markt he season as current", locale: locale);

  String get defensiveReboundEventType =>
      Intl.message("Def Rebound", locale: locale);

  String get defensiveReboundTitle => Intl.message("D/RB",
      desc: "Defensive rebound abbreviation", locale: locale);

  String get deleteadmin {
    return Intl.message("Delete Admin");
  }

  String get deleteadmininvite {
    return Intl.message('Delete admin invite');
  }

  String get deletebuttontext {
    return Intl.message('DELETE', desc: 'Button text to delete an iteam');
  }

  String get deleteinvite {
    return Intl.message('Delete invite',
        name: 'Title for the dialog to delete an invite');
  }

  String get deleteinvitebutton {
    return Intl.message('DELETE INVITE',
        name: 'Title for the dialog to delete an invite');
  }

  String get deletemember {
    return Intl.message('Delete member');
  }

  String get deletemessage {
    return Intl.message("Delete", name: "Delete message button");
  }

  String get deleteopponent {
    return Intl.message('Delete opponent',
        desc: 'Title to the alert dialog to delete an opponent from the team');
  }

  String get deletePlayer => Intl.message("Delete Player",
      desc: "Dialog title for deleting a playern", locale: locale);

  String get deleteplayer {
    return Intl.message('REMOVE FROM TEAM',
        desc: 'Button to change the remove a member from the team');
  }

  String get descriptionTitle => Intl.message("Description",
      desc: "Title for the description of the media", locale: locale);

  String get details {
    return Intl.message('Details',
        name: 'Details in a stepper for a game or team',
        desc: 'Details fin a stepper for a game or team');
  }

  String get directionsbuttons {
    return Intl.message('DIRECTIONS');
  }

  String get displayname {
    return Intl.message('Name',
        desc: 'Name for the edit box to edit the user name');
  }

  String get displaynamehint {
    return Intl.message('Your name',
        desc: 'Name for the edit box to edit the user name');
  }

  String get divison {
    return Intl.message('Divison');
  }

  String get doneButton =>
      Intl.message('DONE', desc: 'Done completely button', locale: locale);

  String get duration {
    return Intl.message("Duration");
  }

  String get editbuttontext {
    return Intl.message(
      'EDIT',
      name: 'Edit button text',
      desc: 'The edit text for the dialog',
    );
  }

  String get editgame {
    return Intl.message(
      'Edit Game',
      name: 'Edit Game',
      desc: 'Edit Game help text for button',
    );
  }

  String get editimagebutton {
    return Intl.message('EDIT IMAGE', name: 'Button to edit the image');
  }

  String get editteam {
    return Intl.message(
      'Edit Team',
      name: 'Edit Team',
      desc: 'Edit Team help text for button',
    );
  }

  String get email {
    return Intl.message('Email', name: 'Email input field');
  }

  String get emailheader {
    return Intl.message("Email Preferences");
  }

  String get emailonupcoming {
    return Intl.message("Upcoming games/events",
        name: 'Switch text for emailing on upcoming games');
  }

  String get emailonupdates {
    return Intl.message("On changes to games/events",
        name: 'Switch text for emailing on updates');
  }

  String get emailrequired {
    return Intl.message('Email is empty.',
        name: 'Empty email in form',
        desc: 'Message to say they have an empty email field');
  }

  String get emptypassword {
    return Intl.message('Please choose a password.',
        name: 'Empty password in form',
        desc: 'Message to say they have an empty password field');
  }

  String get emptyText => Intl.message("Must not be empty",
      desc: "Hint text to say the name must not be empty", locale: locale);

  String get endButton =>
      Intl.message("END", desc: "Text on a end button", locale: locale);

  String get endTimeout => Intl.message("End timeout",
      desc: "Text to end the timeout", locale: locale);

  String get errorcreatinguser {
    return Intl.message(
        "Error creating user, maybe the email address is already used");
  }

  String get eventtype {
    return Intl.message("Special Events",
        name: 'Drop down for only the special events');
  }

  String get everyone {
    return Intl.message("Everyone",
        name: 'Message to mean everyone in the team (coaches + everyone)');
  }

  String get finalscore {
    return Intl.message('Final score', desc: 'Final score dialofg title');
  }

  String get finishgamebutton {
    return Intl.message("FINISH",
        desc:
            "Text for the button to finish the game in the update score screen");
  }

  String get forgotPassword {
    return Intl.message(
      'FORGOT PASSWORD',
      name: 'Forgot password button text',
    );
  }

  String get forgotPasswordHint {
    return Intl.message(
      'The email to resend the password to',
      name: 'Forgot password happy button',
    );
  }

  String get forgotPasswordSent {
    return Intl.message(
      'Sent email to your email address to reset your password',
      name: 'Forgot password happy button',
    );
  }

  String get formerror {
    return Intl.message('Please fix the items outlined in red',
        name: 'Error in a form', desc: 'Error when submitting a form');
  }

  String get forpts {
    return Intl.message("For",
        desc:
            "Title to the spinner for showing points for in the results screen");
  }

  String get foulEventType =>
      Intl.message("Foul", desc: "Foul on player", locale: locale);

  String get foulFlagrantEventType => Intl.message("Foul Flagrent",
      desc: "Flagrant foul on player", locale: locale);

  String get fouls => Intl.message("Fouls",
      desc: "Drop down menu item for fouls", locale: locale);

  String get foulsGameSummary =>
      Intl.message("Fouls", desc: "Fouls summary in game", locale: locale);

  String get foulTechnicalEventType => Intl.message("Foul Technical",
      desc: "Technical foul on player", locale: locale);

  String get game {
    return Intl.message("Game");
  }

  String get gameavailability {
    return Intl.message('Availability',
        name: 'Availability for the game',
        desc: 'Availability for the game, botton tab bar title');
  }

  String get gameend {
    return Intl.message('Game end',
        desc: 'Title for the time drop down to choose the game end time');
  }

  String get gamenotes {
    return Intl.message(
      'Game notes',
      name: 'Notes for the game',
      desc: 'The notes associated with the game',
    );
  }

  String get gamenoteshint {
    return Intl.message(
      'Notes for the game',
      name: 'Notes for the game hint',
      desc: 'The hint text for notes associated with the game',
    );
  }

  String get games {
    return Intl.message('Games');
  }

  String get gametime {
    return Intl.message(
      'Game Time',
      name: 'Team',
      desc: 'Title for the game time',
    );
  }

  String get gametype {
    return Intl.message("Games", name: 'Drop down for onlhy the game events');
  }

  String get gendercoed {
    return Intl.message('Coed',
        name: 'Coed gemder',
        desc: 'Coed gender for the sport in the drop down');
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

  String get home {
    return Intl.message("home");
  }

  String get homeaway {
    return Intl.message(
      'Home',
      name: 'Home game flag',
      desc: 'Title for the home game checkbox',
    );
  }

  String get imageMediaType =>
      Intl.message("Photo", desc: "Upload a photo", locale: locale);

  String get importplayers {
    return Intl.message('Import\nplayers',
        name: 'Import players from previous season');
  }

  String get includemyself {
    return Intl.message('Send to yourself',
        desc: 'If the message should also be sent to ourselves');
  }

  String get invalidemail {
    return Intl.message('Email address must be of form xxx@xxx.',
        name: 'Invalid email in form',
        desc: 'Message to say they have an invalid email field');
  }

  String get invalidname {
    return Intl.message('Name can only contain alphanumerical characters.',
        name: 'Invalid user name in form',
        desc: 'Message to say they have an invalid user name field');
  }

  String get invalidUrl => Intl.message('Invalid URL',
      desc: 'Error in a form when the url is invalid', locale: locale);

  String get invite {
    return Intl.message('Invites',
        desc: 'Title for the screen with the list of current invites');
  }

  String get jersyNumber => Intl.message("Jersey Number",
      desc: "Jersey number for the playerr", locale: locale);

  String get joinleague {
    return Intl.message('JOIN LEAGUE');
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

  String get leaguetournament {
    return Intl.message('League/Tournaments',
        name: 'Link to the league/tournament section');
  }

  String get loading {
    return Intl.message('Loading...',
        name: 'Loading message', desc: 'Message for loading the app');
  }

  String get location =>
      Intl.message("Location", desc: "Location of the game", locale: locale);

  String get login {
    return Intl.message(
      'LOGIN',
      name: 'Login button text',
    );
  }

  String get logout {
    return Intl.message(
      'LOGOUT',
      name: 'Logout button text',
    );
  }

  String get longDescription {
    return Intl.message('Description',
        name:
            'Long description of a tournament/league to display on the league page');
  }

  String get longDescriptionHint {
    return Intl.message('Detailed Description',
        name:
            'Long description of a tournament/league to display on the league/tournament page');
  }

  String get loss {
    return Intl.message("Loss", name: 'Drop down for  the loss result');
  }

  String get members {
    return Intl.message('Members');
  }

  String get message {
    return Intl.message('Message',
        desc: 'In a text edit box to send a message to the team');
  }

  String get monthlyperiod {
    return Intl.message(
      'Monthly',
      name: 'Monthly repeat',
    );
  }

  String get namerequired {
    return Intl.message('Username is empty.',
        name: 'Empty email in form',
        desc: 'Message to say they have an empty email field');
  }

  String get needtobeadmin {
    return Intl.message('Need to be an administrator');
  }

  String get needtoselectgender {
    return Intl.message('Please choose a gender.',
        name: 'Message to suggest they need to select a gender',
        desc: 'Message to suggest they need to select a gender');
  }

  String get needtoselectopponent {
    return Intl.message('Please choose an opponent.',
        name: 'Message to suggest they need to select an oppoent',
        desc: 'Message to suggest they need to select an oppoent');
  }

  String get needtoselectrole {
    return Intl.message('Need to select a role',
        name: 'Error to say they must select the role in the team');
  }

  String get needtoselectsport {
    return Intl.message('Please choose a sport.',
        name: 'Message to suggest they need to select a sport',
        desc: 'Message to suggest they need to select a sport');
  }

  String get newbuttontext {
    return Intl.message("NEW", name: "New button text in the system");
  }

  String get newdivisonhint {
    return Intl.message('New Divison Name');
  }

  String get newmail {
    return Intl.message("NEW MESSAGE",
        name: "New message in the teamfuse system");
  }

  String get newplayername {
    return Intl.message('New player name',
        name: 'Text to show before the player name.');
  }

  String get newplayernamehint {
    return Intl.message('New player name of player in team',
        name: 'Hint for the name of the player in the team.');
  }

  String get newseasonhint {
    return Intl.message('New Season Name');
  }

  String get noclub {
    return Intl.message('No club');
  }

  String get nodivisons {
    return Intl.message("No divisions",
        name: "Divisons inside the season for a league/tournament");
  }

  String get noevent {
    return Intl.message("All events", name: 'Drop down for all the events');
  }

  String get nogames {
    return Intl.message(
      'No games',
      name: 'No games',
      desc: 'No games scheduled',
    );
  }

  String get nogamesfiltered {
    return Intl.message("No games to display, check filters",
        name: 'No games to display based on filters');
  }

  String get nogamesthisseason {
    return Intl.message('No games this season',
        desc: 'No games played this season, but some in a previous season');
  }

  String get noinvites {
    return Intl.message('No invites');
  }

  String get noleagues {
    return Intl.message('No leagues');
  }

  String get noMedia =>
      Intl.message("No Media", desc: "No media to display", locale: locale);

  String get nomessages {
    return Intl.message('No Messages',
        desc: 'In a text edit box to send a message to the team');
  }

  String get noneperiod {
    return Intl.message(
      'No repeat',
      name: 'No repeat period',
    );
  }

  String get noplayers {
    return Intl.message('No players', desc: 'Description for no players');
  }

  String get noPlayersForSeasonDialog => Intl.message(
      "You must have some players in a season "
      "to be able to create a game.",
      desc: "Text in a dialog to warn you need players",
      locale: locale);

  String get noresult {
    return Intl.message("All Games", name: 'Drop down for all the games');
  }

  String get noseasons {
    return Intl.message("No seasons");
  }

  String get notarchived {
    return Intl.message('Not archived');
  }

  String get noteams {
    return Intl.message('No teams');
  }

  String get notfinished {
    return Intl.message("Not finished",
        name: 'Drop down for  the not finished result');
  }

  String get notournaments {
    return Intl.message('No tournaments');
  }

  String get offensiveReboundEventType =>
      Intl.message("Off Rebound", locale: locale);

  String get offensiveReboundTitle => Intl.message("O/RB",
      desc: "Offensive rebound abbreviation", locale: locale);

  String get offical {
    return Intl.message('Offical');
  }

  String get officialdontmatch {
    return Intl.message('Offical results don\'t match');
  }

  String get openbutton {
    return Intl.message('OPEN');
  }

  String get opponent {
    return Intl.message(
      'Opponent',
      name: 'Opponent',
      desc: 'Title for the opponent marker',
    );
  }

  String get opponentcontact {
    return Intl.message(
      'Contact',
      name: 'Opponent contact',
      desc: 'The text for the contact of an opponent',
    );
  }

  String get opponentcontacthint {
    return Intl.message(
      'Contact for the opponent',
      name: 'Opponent contact hint',
      desc: 'The hint text for the contact of an opponent',
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

  String get opponentselect {
    return Intl.message(
      'Select opponent',
      name: 'Select opponent for the event',
      desc: 'The hint text for selecting opponent for the game',
    );
  }

  String get opponentwithnoresult {
    return Intl.message('Opponents without results');
  }

  String get opponentwithresult {
    return Intl.message('Opponents with results');
  }

  String get optional => Intl.message('Optional',
      desc: 'Optional subtitle for a stepper', locale: locale);

  String get overtimeperiod {
    return Intl.message('Overtime');
  }

  String get password {
    return Intl.message('Password', desc: 'Input box for a password');
  }

  String get passwordnotcorrect {
    return Intl.message('Email and/or password incorrect',
        desc: 'Passwords or email is not correct, login failed');
  }

  String get passwordsnotmatching {
    return Intl.message('Passwords must match',
        desc: 'Passwords must match signup form error');
  }

  String get penaltyperiod {
    return Intl.message('Penalty');
  }

  String get percentageGameSummary => Intl.message("%age",
      desc: "Percentage made in game summary title", locale: locale);

  String get period => Intl.message("Period",
      desc: "Dialog title for sertting the current period", locale: locale);

  String get periodButton => Intl.message("PERIOD",
      desc: "Button to set the current period", locale: locale);

  String get periodNameBreak =>
      Intl.message("Break", desc: "The game is on a break", locale: locale);

  String get periodNameFinished =>
      Intl.message("Final", desc: "The game has finished", locale: locale);

  String get periodNameNotStarted => Intl.message("Not started",
      desc: "The game is not started", locale: locale);

  String get periodNameOverTime1 => Intl.message("Overtime 1",
      desc: "The game is in overtime", locale: locale);

  String get periodNameOverTime2 => Intl.message("Overtime 1",
      desc: "The game is in overtime", locale: locale);

  String get periodNameOverTime3 => Intl.message("Overtime 1",
      desc: "The game is in overtime", locale: locale);

  String get periodNameOverTime4 => Intl.message("Overtime 1",
      desc: "The game is in overtime", locale: locale);

  String get periodNameOvertimeBreak => Intl.message("Overtime Break",
      desc: "The game is on an overtime break", locale: locale);

  String get periodNamePenalty => Intl.message("Penalty",
      desc: "The game is in penalty time", locale: locale);

  String get periodNamePeriod1 =>
      Intl.message("Period 1", desc: "The game is in period 1", locale: locale);

  String get periodNamePeriod2 =>
      Intl.message("Period 2", desc: "The game is in period 2", locale: locale);

  String get periodNamePeriod3 =>
      Intl.message("Period 3", desc: "The game is in period 3", locale: locale);

  String get periodNamePeriod4 =>
      Intl.message("Period 4", desc: "The game is in period 4", locale: locale);

  String get periodNamePeriod5 =>
      Intl.message("Period 5", desc: "The game is in period 4", locale: locale);

  String get periodNamePeriod6 =>
      Intl.message("Period 6", desc: "The game is in period 4", locale: locale);

  String get periodNamePeriodUnknown => Intl.message("Period x",
      desc: "The game is in an unknown", locale: locale);

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

  String get placesnotes {
    return Intl.message('Place notes, ie court #');
  }

  String get placesnoteshint {
    return Intl.message('Details of the place');
  }

  String get player {
    return Intl.message('Player',
        desc: 'Title in team stepper to select a player');
  }

  String get playeremailHint {
    return Intl.message('Player email address',
        name: 'Player email input field hint');
  }

  String get players {
    return Intl.message('Players',
        desc: 'Title in the bottom navigation tab for players');
  }

  String get playerselect {
    return Intl.message("Player", name: "Label for the player drop down");
  }

  String get playerselecthint {
    return Intl.message("Select player",
        name: "Label for the player drop down");
  }

  /*
  String gameofficalinprogressscore(GameOfficialResults offical) {
    GameResultPerPeriod finalScore;
    GamePeriod finalReg = GamePeriod(type: GamePeriodType.Regulation);
    if (offical.scores.containsKey(finalReg)) {
      finalScore = offical.scores[finalReg];
    } else {
      finalScore = GameResultPerPeriod(
          period: finalReg, score: GameScore(ptsFor: 0, ptsAgainst: 0));
    }
    GamePeriod overtimePeriod = GamePeriod(type: GamePeriodType.Overtime);
    GameResultPerPeriod overtimeScore;
    if (offical.scores.containsKey(overtimePeriod)) {
      overtimeScore = offical.scores[overtimePeriod];
    }
    GamePeriod penaltyPeriod = GamePeriod(type: GamePeriodType.Penalty);
    GameResultPerPeriod penaltyScore;
    if (offical.scores.containsKey(penaltyPeriod)) {
      penaltyScore = offical.scores[penaltyPeriod];
    }
    if (penaltyScore != null && overtimeScore == null) {
      return Intl.message(
          '${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}\m(Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          name: 'Offical result details',
          desc: 'Offical result details with penalty shootout');
    }

    if (penaltyScore != null && overtimeScore != null) {
      return Intl.message(
          '${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}\n(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})\n(Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          name: 'Offical result details',
          desc: 'Offical result details with penalty shootout and overtime');
    }
    if (overtimeScore != null) {
      return Intl.message(
          '${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}\n(Penalty ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})',
          name: 'Offical result details',
          desc: 'Offical result details with overtime');
    }

    return Intl.message(
        '${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
        name: 'Offical result details',
        desc: 'Offical result details');
  }
*/

  String get points => Intl.message("Points",
      desc: "Drop down menu item for points", locale: locale);

  String get pointsGameSummary =>
      Intl.message("Pts", desc: "Points summary in game", locale: locale);

  String get pointsTitle =>
      Intl.message("Pts", desc: "Points abbreviation", locale: locale);

  String get previousSeasons {
    return Intl.message('Previous Seasons',
        name: 'Previous seasons for this game',
        desc: 'Previous seasons for this game');
  }

  String get rebounds => Intl.message("Rebounds",
      desc: "Drop down menu item for rebounds", locale: locale);

  String get reboundsGameSummary =>
      Intl.message("RBs", desc: "Rebounds in game summary", locale: locale);

  String get regulationperiod {
    return Intl.message('Regulation');
  }

  String get relationshipselect {
    return Intl.message("Select relationship",
        name: "Label to select the relatiobship from a drop down");
  }

  String get repeat {
    return Intl.message(
      'Repeat',
      name: 'Repeat title for the traning create steps',
    );
  }

  String get resendverify {
    return Intl.message(
      'RESEND EMAIL',
      name: 'Button to resend the email to verify their email address',
    );
  }

  String get resettimer {
    return Intl.message("Reset Timer");
  }

  String get resettimerbody {
    return Intl.message("Do you want to reset the timer to zero?");
  }

  String get resultunknown {
    return Intl.message('No result.',
        name: 'No result for the game yet', desc: 'No result for the game');
  }

  String get roleselect => Intl.message('Select role',
      name: 'Drop down to select the role in the team', locale: locale);
  String get role => Intl.message('Role',
      name: 'Header for a column talking about the role', locale: locale);

  String get savebuttontext {
    return Intl.message(
      'SAVE',
      name: 'Save button text',
      desc: 'The save text for the dialog',
    );
  }

  String get saveButtonText => Intl.message('SAVE', locale: locale);

  String get savefailed {
    return Intl.message('Save Failed', name: 'Save failed, server error');
  }

  String get season {
    return Intl.message(
      'Season',
      name: 'Season',
      desc: 'Title for the season marker',
    );
  }

  String get seasonhint {
    return Intl.message(
      'Current team season',
      name: 'Hint for the season text box',
    );
  }

  String get seasonrequired {
    return Intl.message("Season name is required",
        name: "The error text when the season name is required");
  }

  String get seasons => Intl.message("Seasons",
      desc: "Header for the seasons section", locale: locale);

  String get seasonselect {
    return Intl.message(
      'Select season',
      name: 'Select Season',
      desc: 'Title for the select season marker',
    );
  }

  String get selectclub {
    return Intl.message('Select club');
  }

  String get selectImageButton =>
      Intl.message("GALLERY", desc: "Live video streaming", locale: locale);

  String get selectMediaType => Intl.message("Select Media",
      desc: "Title for the dialog to select a video", locale: locale);

  String get selectplace {
    return Intl.message('Select place',
        desc:
            'Title for the drop down to say select place if nothing is selected');
  }

  String get selectPlayer => Intl.message("Select Player",
      desc: "Selects the player for the event", locale: locale);

  String get sendmessage {
    return Intl.message('Send message',
        desc: 'In a text edit box to send a message to a user');
  }

  String get sendmessagebuttontext {
    return Intl.message('SEND', desc: 'Button to send the message');
  }

  String get setclub {
    return Intl.message('SET CLUB');
  }

  String get settings {
    return Intl.message('Settings');
  }

  String get shortDescription {
    return Intl.message('Summary',
        name: 'Short description of a tournament/league to display in the ux');
  }

  String get shortDescriptionHint {
    return Intl.message('Short Description',
        name: 'Short description of a tournament/league to display in the ux');
  }

  String get shots => Intl.message("Shots",
      desc: "Heading for the shots sectionn", locale: locale);

  String get signout {
    return Intl.message('Signout');
  }

  String get skipButton =>
      Intl.message('SKIP', desc: 'Skip button text', locale: locale);

  String get sportselect {
    return Intl.message('Select sport',
        name: 'Name for the default select sport text',
        desc: 'Name for the default select sport text');
  }

  String get startButton => Intl.message("START",
      desc: "Text on a button to start the period", locale: locale);

  String get startgame {
    return Intl.message('Start Game', desc: 'Start game dialofg title');
  }

  String get startgamebody {
    return Intl.message('Do you want to start the game?',
        desc: 'Start game dialofg body text');
  }

  String get stats => Intl.message('Stats',
      name: 'stats',
      desc: 'Title in the bottom navigation bar for the stats',
      locale: locale);

  String get stealEventType => Intl.message("Steal",
      desc: "Steal a ball", locale: locale, name: "stealEventType");

  String get steals => Intl.message("Steals",
      desc: "Drop down menu item for steals", locale: locale);

  String get stealsGameSummary =>
      Intl.message("Steals", desc: "Steals summary in game", locale: locale);

  String get stealsTitle =>
      Intl.message("Stl", desc: "Steals abbreviation", locale: locale);

  String get streamButton => Intl.message("STREAM",
      desc: "Button to display a stream", locale: locale);

  String get streamMediaType =>
      Intl.message("Stream Live", desc: "Live video streaming", locale: locale);

  String get subject {
    return Intl.message("Subject",
        name: "Subject for the message, title of input field");
  }

  String get subsitutionEventType => Intl.message("Subsitution",
      desc: "Subsitiution of player", locale: locale);

  String get takePhotoButton =>
      Intl.message("CAMERA", desc: "Live video streaming", locale: locale);

  String get team {
    return Intl.message(
      'Team',
      name: 'Team',
      desc: 'Title for the team marker',
    );
  }

  String get teamdeleted => Intl.message('Team deleted', locale: locale);

  String get clubDeleted => Intl.message('Club deleted', locale: locale);

  String get teamedithint {
    return Intl.message('Change team',
        name: 'Team editing hint',
        desc: 'Hint for the button to edit the team');
  }

  String get teamname {
    return Intl.message('Name', name: 'Team Name', desc: 'Name of the team');
  }

  String get teamnamehint {
    return Intl.message('Name',
        name: 'Team Name hint', desc: 'Hint for the name of the team');
  }

  String get teams {
    return Intl.message('Teams');
  }

  String get teamselect {
    return Intl.message(
      'Select team',
      name: 'Select team',
      desc: 'The text for notes for selecting team for the event',
    );
  }

  String get teamselected {
    return Intl.message('Team Selected');
  }

  String get tie {
    return Intl.message("Tie", name: 'Drop down for  the tie result');
  }

  String get timercountup {
    return Intl.message("Timer count up");
  }

  String get title {
    return Intl.message(
      'Team Fuse',
      name: 'title',
      desc: 'Title for the Team Fuse application',
    );
  }

  String get tournament {
    return Intl.message('Tournament');
  }

  String get trainingend {
    return Intl.message('Training end',
        desc: 'Title for the time drop down to choose the training end time');
  }

  String get trainingnotes {
    return Intl.message(
      'Training notes',
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

  String get trainingtimes {
    return Intl.message("Training times",
        name: 'HEader for the extra training times in a repeat event');
  }

  String get trainingtype {
    return Intl.message("Training",
        name: 'Drop down foronlhy the training events');
  }

  String get turnOverEventType => Intl.message("Turnover",
      desc: "Caused a turnover", locale: locale, name: "turnOverEventType");

  String get turnovers => Intl.message("Turnovers",
      desc: "Drop down menu item for turnovers", locale: locale);

  String get turnoversGameSummary =>
      Intl.message("T/O", desc: "Turnover summary in game", locale: locale);

  String get turnoversTitle =>
      Intl.message("T/O", desc: "Turnover abbreviation", locale: locale);

  String get unabletoloadgames {
    return Intl.message('Unable to load games');
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

  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: 'Unknown name',
    );
  }

  String get until {
    return Intl.message("Until", name: 'Drop down for the until option');
  }

  String get updatescorebutton {
    return Intl.message("UPDATE SCORE",
        desc: "Title to the button to update the score results screen");
  }

  String get uploadButton => Intl.message("UPLOAD",
      desc: "Button to display upload a stream", locale: locale);

  String get urlTitle => Intl.message("URL",
      desc: "Title for the form field to set the url for media",
      locale: locale);

  String get useofficialresultbutton {
    return Intl.message('USE OFFICAL',
        name: 'Button to pull the offical results in from the shared game');
  }

  String get useofficialresultdialog {
    return Intl.message('Use the results of the offical game for '
        'this game?');
  }

  String get verifyemailerror {
    return Intl.message("No account found for email or internal error occured");
  }

  String get verifyemailsent {
    return Intl.message(
        "Sent verification email, please check your email inbox.",
        desc:
            "Confirmation message after requesting the email verification code");
  }

  String get verifypassword {
    return Intl.message('Verify password',
        desc: 'Input box for a verification to the main password password');
  }

  String get video =>
      Intl.message("Video", desc: "Shows video for the game", locale: locale);

  String get videoMediaType =>
      Intl.message("Upload Video", desc: "Upload a video", locale: locale);

  String get weeklyperiod {
    return Intl.message(
      'Weekly',
      name: 'Weekly repeat',
    );
  }

  String get where {
    return Intl.message('Where', name: 'Where the game is');
  }

  String get win {
    return Intl.message("Win", name: 'Drop down for  the win result');
  }

  String get youremailHint {
    return Intl.message('Your email address',
        name: 'Your email input field hint');
  }

  String arrivebefore(int mins) {
    return Intl.message(
      'Arrive ${mins} mins before games',
      args: [mins],
    );
  }

  String cardresultinprogress(GameResultSharedDetails result) {
    GameResultPerPeriod finalScore = result.regulationResult;
    if (finalScore == null) {
      finalScore = GameResultPerPeriod((b) => b
        ..period = GamePeriod.regulation1.toBuilder()
        ..score = (GameScoreBuilder()
          ..ptsFor = 0
          ..ptsAgainst = 0
          ..intermediate = false));
    }
    if (result.overtimeResult != null) {
      GameResultPerPeriod overtimeScore = result.overtimeResult;
      if (result.penaltyResult != null) {
        GameResultPerPeriod penaltyScore = result.penaltyResult;
        return cardresultinprogressovertimeandpenalty(
            finalScore, overtimeScore, penaltyScore);
      }
      return cardresultinprogressovertime(finalScore, overtimeScore);
    }
    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return cardresultinprogresspenalty(finalScore, penaltyScore);
    }
    return cardresultinprogressfinal(finalScore);
  }

  String cardresultinprogressovertimeandpenalty(
          GameResultPerPeriod finalScore,
          GameResultPerPeriod overtimeScore,
          GameResultPerPeriod penaltyScore) =>
      Intl.message(
        '${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
        '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})'
        '(Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
        name: 'In progress result details',
        desc: 'Win result details with penalty shootout',
        args: [finalScore, overtimeScore, penaltyScore],
      );

  String cardresultinprogressfinal(GameResultPerPeriod finalScore) =>
      Intl.message(
          '${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
          name: 'In progress result details in the card',
          desc: 'In progress result details');

  String cardresultinprogresspenalty(
          GameResultPerPeriod finalScore, GameResultPerPeriod penaltyScore) =>
      Intl.message(
          '${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} (Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          name: 'In progress result details in the card',
          desc: 'In progress result details with penalty shootout',
          args: [finalScore, penaltyScore]);

  String cardresultinprogressovertime(
          GameResultPerPeriod finalScore, GameResultPerPeriod overtimeScore) =>
      Intl.message(
          '${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
          '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})',
          name: 'In progress result details',
          desc: 'Win result details with penalty shootout',
          args: [finalScore, overtimeScore]);

  String confirmcreateteamforleague(
          String teamName, String season, String league) =>
      Intl.message(
          'Are you sure you want to create a team $teamName with a season of $season '
          'for the league $league.  This is not possible to undo?',
          args: [teamName, league, season]);

  String confirmdelete(Invite invite) {
    if (invite is InviteToTeam) {
      InviteToTeam inviteTeam = invite;
      return confirmdeleteinviteteam(inviteTeam);
    }
    if (invite is InviteToPlayer) {
      InviteToPlayer invitePlayer = invite;
      return confirmdeleteinviteplayer(invitePlayer);
    }
    if (invite is InviteAsAdmin) {
      InviteAsAdmin inviteAdmin = invite;
      return confirmdeleteasadmin(inviteAdmin);
    }
    if (invite is InviteToClub) {
      InviteToClub inviteClub = invite;
      return confirmdeleteclub(inviteClub);
    }
    if (invite is InviteToLeagueAsAdmin) {
      InviteToLeagueAsAdmin inviteLeague = invite;
      return confirmdeleteleagueasadmin(inviteLeague);
    }
    if (invite is InviteToLeagueTeam) {
      InviteToLeagueTeam inviteLeagueTeam = invite;
      return confirmdeleteleagueteam(inviteLeagueTeam);
    }
    return unknown;
  }

  String confirmdeleteinviteteam(InviteToTeam inviteTeam) => Intl.message(
      'Do you want to delete the invite to ${inviteTeam.teamName} for ${inviteTeam.playerName}?',
      name: 'Text to delete the invite to the team in the alert dialog.',
      args: [inviteTeam]);

  String confirmdeleteinviteplayer(InviteToPlayer invitePlayer) => Intl.message(
      'Do you want to delete the invite to follow ${invitePlayer.playerName}?',
      name: 'Text to delete the invite to the team in the alert dialog.',
      args: [invitePlayer]);

  String confirmdeleteasadmin(InviteAsAdmin inviteAdmin) => Intl.message(
      'Do you want to delete the invite to be admin for the team ${inviteAdmin.teamName}?',
      name: 'Text to delete the invite to be an admin in the alert dialog.',
      args: [inviteAdmin]);

  String confirmdeleteclub(InviteToClub inviteClub) => Intl.message(
      'Do you want to delete the invite to be in the club ${inviteClub.clubName}?',
      name: 'Text to delete the invite to the club in the alert dialog.',
      args: [inviteClub]);

  String confirmdeleteleagueasadmin(InviteToLeagueAsAdmin invite) => Intl.message(
      'Do you want to delete the invite to be in the league ${invite.leagueName}?',
      name: 'Text to delete the invite to the league in the alert dialog.',
      args: [invite]);

  String confirmdeleteleagueteam(InviteToLeagueTeam inviteLeagueTeam) =>
      Intl.message(
        'Do you want to delete the invite to be in the league ${inviteLeagueTeam.leagueName} with team '
        '${inviteLeagueTeam.leagueTeamName}?',
        args: [inviteLeagueTeam],
      );

  String confirmdeletemember(FusedUserProfile profile) =>
      Intl.message('Delete club member ${profile.displayName}?',
          args: [profile]);

  String confirmdeleteplayer(Player player) =>
      Intl.message("Do you want to delete your connection to ${player.name}?",
          desc: 'Text to confirm asking if the players wants to be delete',
          args: [player]);

  String confirmremovefromteam(String name) {
    return Intl.message('Are you sure you want to remove $name from the team?',
        desc: 'Dialog text to confirm removing a user from the team',
        args: [name]);
  }

  String deletegame(GameSharedData game) {
    switch (game.type) {
      case EventType.Game:
        return deleteGameGame;
      case EventType.Practice:
        return deleteGamePractice;
      case EventType.Event:
        return deleteGameSpecialEvent;
    }
    return unknown;
  }

  String get deleteGameGame => Intl.message("Delete game");

  String get deleteGamePractice => Intl.message("Delete training");

  String get deleteGameSpecialEvent => Intl.message("Delete special event");

  String displaynamerelationship(String name, Relationship relationship) {
    String rel = relationships(relationship);
    return Intl.message('$name ($rel)',
        desc: 'Name for the edit box to edit the user name',
        args: [name, relationship]);
  }

  String eventtitle(
      String time, String name, String endTime, String tzShortName) {
    if (name != null && name.isNotEmpty) {
      if (endTime != null) {
        if (tzShortName != null) {
          return eventTitleSpecialEventNameEndTimeTimeZone(
              name, time, endTime, tzShortName);
        }
        return eventTitleSpecialEventNameEndTime(name, time, endTime);
      }
      if (tzShortName != null) {
        return eventTitleSpecialEventNameTimeZone(name, time, tzShortName);
      }
      return eventTitleSpecialEventName(name, time);
    }
    if (endTime != null) {
      if (tzShortName != null) {
        return eventTitleSpecialEventStartAndEndTimezone(
            time, endTime, tzShortName);
      }
      return eventTitleSpecialEventStartAndEnd(time, endTime);
    }
    if (tzShortName != null) {
      return eventTitleSpecialWithTimezone(time, tzShortName);
    }
    return eventTitleSpecialEvent(time);
  }

  String eventTitleSpecialEventNameEndTimeTimeZone(
          String name, String time, String endTime, String tzShortName) =>
      Intl.message('$name $time - $endTime  ($tzShortName)',
          desc: 'Special event title in game list',
          args: [name, time, endTime, tzShortName]);

  String eventTitleSpecialEventNameEndTime(
          String name, String time, String endTime) =>
      Intl.message('$name $time - $endTime',
          desc: 'Special event title in game list',
          args: [name, time, endTime]);

  String eventTitleSpecialEventNameTimeZone(
          String name, String time, String tzShortName) =>
      Intl.message('$name $time ($tzShortName)',
          desc: 'Special event title in game list',
          args: [name, time, tzShortName]);

  String eventTitleSpecialEventName(String name, String time) =>
      Intl.message("$name $time",
          desc: 'Special event title in game list', args: [name, time]);

  String eventTitleSpecialEventStartAndEndTimezone(
          String time, String endTime, String tzShortName) =>
      Intl.message('Event $time - $endTime ($tzShortName)',
          desc: 'Special event title in game list',
          args: [time, endTime, tzShortName]);

  String eventTitleSpecialEventStartAndEnd(String time, String endTime) =>
      Intl.message('Event $time - $endTime',
          desc: 'Special event title in game list');

  String eventTitleSpecialWithTimezone(String time, String tzShortName) =>
      Intl.message('Event $time ($tzShortName)',
          desc: 'Special event title in game list with timezone',
          args: [time, tzShortName]);

  String eventTitleSpecialEvent(String time) => Intl.message('Event $time',
      desc: 'Special event title in game list', args: [time]);

  String eventtitlenow(
      String time, String name, String endTime, String tzShortName) {
    if (name != null && name.isNotEmpty) {
      if (endTime != null) {
        if (tzShortName != null) {
          return eventTitleNowSpecialEventNameEndTimeTimeZone(
              name, time, endTime, tzShortName);
        }
        return eventTitleNowSpecialEventNameEndTime(name, time, endTime);
      }
      if (tzShortName != null) {
        return eventTitleNowSpecialEventNameTimeZone(name, time, tzShortName);
      }
      return eventTitleNowSpecialEventName(name, time);
    }
    if (endTime != null) {
      if (tzShortName != null) {
        return eventTitleNowSpecialEventStartAndEndTimezone(
            time, endTime, tzShortName);
      }
      return eventTitleNowSpecialEventStartAndEnd(time, endTime);
    }
    if (tzShortName != null) {
      return eventTitleNowSpecialWithTimezone(time, tzShortName);
    }
    return eventTitleNowSpecialEvent(time);
  }

  String eventTitleNowSpecialEventNameEndTimeTimeZone(
          String name, String time, String endTime, String tzShortName) =>
      Intl.message('NOW! $name $time - $endTime  ($tzShortName)',
          desc: 'Special event title in game list',
          args: [name, time, endTime, tzShortName]);

  String eventTitleNowSpecialEventNameEndTime(
          String name, String time, String endTime) =>
      Intl.message('NOW! $name $time - $endTime',
          desc: 'Special event title in game list',
          args: [name, time, endTime]);

  String eventTitleNowSpecialEventNameTimeZone(
          String name, String time, String tzShortName) =>
      Intl.message('NOW! $name $time ($tzShortName)',
          desc: 'Special event title in game list',
          args: [name, time, tzShortName]);

  String eventTitleNowSpecialEventName(String name, String time) =>
      Intl.message("NOW! $name $time",
          desc: 'Special event title in game list', args: [name, time]);

  String eventTitleNowSpecialEventStartAndEndTimezone(
          String time, String endTime, String tzShortName) =>
      Intl.message('NOW! Event $time - $endTime ($tzShortName)',
          desc: 'Special event title in game list',
          args: [time, endTime, tzShortName]);

  String eventTitleNowSpecialEventStartAndEnd(String time, String endTime) =>
      Intl.message('NOW! Event $time - $endTime',
          desc: 'Special event title in game list');

  String eventTitleNowSpecialWithTimezone(String time, String tzShortName) =>
      Intl.message('NOW! Event $time ($tzShortName)',
          desc: 'Special event title in game list with timezone',
          args: [time, tzShortName]);

  String eventTitleNowSpecialEvent(String time) =>
      Intl.message('NOW! Event $time',
          desc: 'Special event title in game list', args: [time]);

  String finalofficalscorebody(GameOfficialResults result) {
    GamePeriod regulationPeriod = GamePeriod.regulation1;
    GamePeriod overtimePeriod = GamePeriod.overtime1;
    GamePeriod penaltyPeriod = GamePeriod.penalty;

    GameResultPerPeriod regulationPeriodResult =
        result.scores[regulationPeriod];
    String resultString;
    switch (result.result) {
      case OfficialResult.NotStarted:
        resultString = periodNameNotStarted;
        break;
      case OfficialResult.Tie:
        resultString = tie;
        break;
      case OfficialResult.HomeTeamWon:
        resultString = gameResultHomeTeamWon;
        break;
      case OfficialResult.AwayTeamWon:
        resultString = gameResultAwayTeamWon;
        break;
      case OfficialResult.InProgress:
        resultString = gameResultInProgress;
        break;
    }
    if (result.scores.containsKey(overtimePeriod)) {
      GameResultPerPeriod overtimePeriodResult = result.scores[overtimePeriod];
      if (result.scores.containsKey(penaltyPeriod)) {
        GameResultPerPeriod penaltyPeriodResult = result.scores[penaltyPeriod];
        return Intl.message(
            "$resultString\nHome: ${regulationPeriodResult.score.ptsFor} "
            "Away: ${regulationPeriodResult.score.ptsAgainst}\n"
            "Overtime Home:  ${overtimePeriodResult.score.ptsFor} "
            "Away: ${overtimePeriodResult.score.ptsAgainst}\n"
            "Penalty Home: ${penaltyPeriodResult.score.ptsFor} "
            "Away: ${penaltyPeriodResult.score.ptsAgainst}");
      }
      return Intl.message(
          "$resultString\nHome: ${regulationPeriodResult.score.ptsFor} "
          "Away: ${regulationPeriodResult.score.ptsAgainst}\n"
          "Overtime Home:  ${overtimePeriodResult.score.ptsFor} "
          "Away: ${overtimePeriodResult.score.ptsAgainst}\n");
    }
    if (result.scores.containsKey(penaltyPeriod)) {
      GameResultPerPeriod penaltyPeriodResult = result.scores[penaltyPeriod];
      return Intl.message(
          "$resultString\nHome: ${regulationPeriodResult.score.ptsFor} "
          "Away: ${regulationPeriodResult.score.ptsAgainst}\n"
          "Penalty Home: ${penaltyPeriodResult.score.ptsFor} "
          "Away: ${penaltyPeriodResult.score.ptsAgainst}");
    }
    return gameResultOffical(resultString, regulationPeriodResult);
  }

  String gameResultOffical(
          String resultString, GameResultPerPeriod regulationPeriodResult) =>
      Intl.message(
          "$resultString\nHome: ${regulationPeriodResult.score.ptsFor} "
          "Away: ${regulationPeriodResult.score.ptsAgainst}",
          args: [resultString, regulationPeriodResult]);

  String finalscorebody(num ptsFor, num ptsAgainst, String result) {
    return Intl.message(
        'Do you want to set $ptsFor $ptsAgainst $result as the final score?',
        desc: 'Start game dialofg body text',
        args: [ptsFor, ptsAgainst, result]);
  }

  String fixscore(GameLog log) =>
      Intl.message("Fix score: ${log.score.ptsFor} - ${log.score.ptsAgainst}",
          args: [log]);

  String followplayer(String player) =>
      Intl.message("Follow $player", args: [player]);

  String gameaddressarriveat(String arriveAt, String address) =>
      Intl.message('Arrive by $arriveAt\n$address',
          desc: 'Game address in game list with arrive by',
          args: [arriveAt, address]);

  String gameinprogress(GameInProgress val) {
    switch (val) {
      case GameInProgress.InProgress:
        return gameResultInProgress;
      case GameInProgress.Final:
        return periodNameFinished;
      case GameInProgress.NotStarted:
        return periodNameNotStarted;
    }
    return unknown;
  }

  String gameofficalinprogress(OfficialResult offical) {
    switch (offical) {
      case OfficialResult.NotStarted:
        return periodNameNotStarted;
      case OfficialResult.InProgress:
        return gameResultInProgress;
      case OfficialResult.AwayTeamWon:
        return gameResultAwayTeamWon;
      case OfficialResult.HomeTeamWon:
        return gameResultHomeTeamWon;
      case OfficialResult.Tie:
        return gameResultTie;
    }
    return unknown;
  }

  String get gameResultHomeTeamWon =>
      Intl.message("Home team won", locale: locale);

  String get gameResultAwayTeamWon =>
      Intl.message("Away team won", locale: locale);

  String get gameResultInProgress =>
      Intl.message("In progress", locale: locale);

  String get gameResultTie => Intl.message("Tie", locale: locale);
  String get gameResultWin => Intl.message("Win", locale: locale);
  String get gameResultLoss => Intl.message("Loss", locale: locale);

  String gameresult(GameResult result) {
    switch (result) {
      case GameResult.Unknown:
        return unknown;
      case GameResult.Win:
        return gameResultWin;
      case GameResult.Tie:
        return gameResultTie;
      case GameResult.Loss:
        return gameResultLoss;
    }
    return unknown;
  }

  String gametitle(
      String time, String endTime, String tzShortName, String opponent) {
    if (endTime != null) {
      if (tzShortName != null) {
        return Intl.message('$time - $endTime ($tzShortName) vs $opponent',
            desc: 'Game title in game list');
      }
      return Intl.message('$time - $endTime vs $opponent',
          desc: 'Game title in game list');
    }
    if (tzShortName != null) {
      return Intl.message('$time ($tzShortName} vs $opponent',
          desc: 'Game title in game list');
    }
    return Intl.message('$time vs $opponent', desc: 'Game title in game list');
  }

  String gametitlenow(
      String time, String endTime, String tzShortName, String opponent) {
    if (endTime != null) {
      if (tzShortName != null) {
        return Intl.message('NOW! $time - $endTime ($tzShortName} vs $opponent',
            name: 'Game title in game list', desc: 'Game title in game list');
      }
      return Intl.message('NOW! $time - $endTime vs $opponent',
          name: 'Game title in game list', desc: 'Game title in game list');
    }
    if (tzShortName != null) {
      return Intl.message('NOW! $time ($tzShortName) vs $opponent',
          name: 'Game title in game list', desc: 'Game title in game list');
    }
    return Intl.message('NOW! $time vs $opponent',
        name: 'Game title in game list', desc: 'Game title in game list');
  }

  String gametitleshared(String time, String endTime, String tzShortName) {
    if (endTime != null) {
      if (tzShortName != null) {
        return Intl.message('$time - $endTime ($tzShortName)',
            desc: 'Game title in game list');
      }
      return Intl.message('$time - $endTime', desc: 'Game title in game list');
    }
    if (tzShortName != null) {
      return Intl.message('$time ($tzShortName}',
          desc: 'Game title in game list');
    }
    return Intl.message('$time', desc: 'Game title in game list');
  }

  String gametitlevs(GameSharedData game, String oppponent) {
    switch (game.type) {
      case EventType.Game:
        return Intl.message('Game vs $oppponent',
            name: 'Game details title',
            desc: 'Game details title for the screen');
      case EventType.Event:
        return Intl.message("Event");
      case EventType.Practice:
        return Intl.message("Practice");
    }
    return unknown;
  }

  String getGameEventType(GameEvent p) {
    switch (p.type) {
      case GameEventType.Made:
        return madeEventType(p.points);
      case GameEventType.Missed:
        return missedEventType(p.points);
      case GameEventType.Foul:
        switch (p.foulType) {
          case GameFoulType.Flagrant:
            return foulFlagrantEventType;
          case GameFoulType.Technical:
            return foulTechnicalEventType;
        }
        return foulEventType;
      case GameEventType.Sub:
        return subsitutionEventType;
      case GameEventType.OffsensiveRebound:
        return offensiveReboundEventType;
      case GameEventType.DefensiveRebound:
        return defensiveReboundEventType;
      case GameEventType.Block:
        return blockEventType;
      case GameEventType.Steal:
        return stealEventType;
      case GameEventType.Turnover:
        return turnOverEventType;
      case GameEventType.PeriodStart:
        return periodStart(getPeriodName(p.period));
      case GameEventType.PeriodEnd:
        return periodEnd(getPeriodName(p.period));
    }
    return unknown;
  }

  String getPeriodName(GamePeriod p) {
    switch (p.type) {
      case GamePeriodType.NotStarted:
        return periodNameNotStarted;
      case GamePeriodType.Overtime:
        switch (p.periodNumber) {
          case 1:
            return periodNameOverTime1;
          case 2:
            return periodNameOverTime2;
          case 3:
            return periodNameOverTime3;
          case 4:
            return periodNameOverTime4;
        }
        return periodNameOverTime4;
      case GamePeriodType.Regulation:
        switch (p.periodNumber) {
          case 1:
            return periodNamePeriod1;
          case 2:
            return periodNamePeriod2;
          case 3:
            return periodNamePeriod3;
          case 4:
            return periodNamePeriod4;
          case 5:
            return periodNamePeriod5;
          case 6:
            return periodNamePeriod6;
          default:
            return periodNamePeriodUnknown;
        }
        return periodNamePeriod1;
      case GamePeriodType.Final:
        return periodNameFinished;
      case GamePeriodType.Penalty:
        return periodNamePenalty;
      case GamePeriodType.Break:
        return periodNameBreak;
      case GamePeriodType.OvertimeBreak:
        return periodNameOvertimeBreak;
    }
    return unknown;
  }

  String invitedby(String by) => Intl.message('By $by',
      desc: 'Who did the invite to this team/player', args: [by]);

  String invitedemail(InviteToPlayer invite) => Intl.message("${invite.email}",
      desc: "Message for invited to follow the specific player",
      args: [invite]);

  String invitedpeople(int num) => Intl.message("Invited: $num", args: [num]);

  String madeEventType(int points) => Intl.message("$points",
      args: [points],
      desc: "+num points",
      locale: locale,
      name: "madeEventType");

  String missedEventType(int points) => Intl.message("Miss $points",
      args: [points],
      desc: "missed num points",
      locale: locale,
      name: "missedEventType");

  String nameandteam(Team team, Player player) {
    return Intl.message("${team.name} ${player.name}",
        desc: "Format for name and player for the team");
  }

  String numberofteamsforplayer(int num) {
    if (num == 0) {
      return Intl.message("No teams");
    }
    if (num > 1) {
      return Intl.message("$num teams",
          desc: "Number of teams associated with this player");
    }
    return Intl.message("One team",
        desc: "Number of teams associated with this player");
  }

  String numberofuserforplayer(int num) {
    if (num > 1) {
      return Intl.message("$num users",
          desc: "Number of users associated with this player");
    }
    return Intl.message("One user",
        desc: "Number of user associated with this player");
  }

  String onlyscore(GameScore score) {
    return Intl.message("${score.ptsFor} - ${score.ptsAgainst}");
  }

  String opponentseason(Opponent opponent, String seasonName) {
    return Intl.message("${opponent?.name} - $seasonName",
        name: "Shows the opponent and season");
  }

  String opponentwinrecord(
      Opponent opponent, String seasonUid, String seasonName) {
    WinRecord rec = opponent.record[seasonUid];
    if (rec == null) {
      rec = WinRecord((b) => b
        ..loss = 0
        ..win = 0
        ..tie = 0);
    }
    return Intl.message('Win: ${rec.win} Loss: ${rec.loss} Tie: ${rec.tie}',
        name: 'Win record for an opponent for this season',
        desc: 'Win record for an opponent for this season');
  }

  String pendinginvites(int num) {
    return Intl.message('Pending Invites: $num',
        desc: 'Header showing the number of pending invites');
  }

  String periodEnd(String periodName) {
    return Intl.message("End of $periodName",
        args: [periodName],
        desc: "End of period",
        locale: locale,
        name: "periodEnd");
  }

  String periodname(GamePeriod period) {
    switch (period.type) {
      case GamePeriodType.Regulation:
        if (period.periodNumber > 0) {
          return Intl.message("Regulation ${period.periodNumber}");
        }
        return Intl.message("Regulation");
      case GamePeriodType.Break:
        return Intl.message("Break ${period.periodNumber}");
      case GamePeriodType.OvertimeBreak:
        return Intl.message("Overtime break${period.periodNumber}");
      case GamePeriodType.Overtime:
        if (period.periodNumber > 0) {
          return Intl.message("Overtime ${period.periodNumber}");
        }
        return Intl.message("Overtime");
      case GamePeriodType.Penalty:
        return Intl.message("Penalty");
    }
    return unknown;
  }

  String periodStart(String periodName) {
    return Intl.message("Start of $periodName",
        args: [periodName],
        desc: "Start of period",
        locale: locale,
        name: "periodStart");
  }

  String periodstart(GameLog period) {
    switch (period.period.type) {
      case GamePeriodType.Regulation:
        return Intl.message(
            "Start period ${period.period.periodNumber} Score:  ${period.score.ptsFor} - ${period.score.ptsAgainst}");
      case GamePeriodType.OvertimeBreak:
        return Intl.message(
            "Start overtime period ${period.period.periodNumber} Score: ${period.score.ptsFor} - ${period.score.ptsAgainst}");
      case GamePeriodType.Break:
        return Intl.message(
            "Start period ${period.period.periodNumber} Score: ${period.score.ptsFor} - ${period.score.ptsAgainst}");
      case GamePeriodType.Overtime:
        return Intl.message(
            "Start overtime Score: ${period.score.ptsFor} - ${period.score.ptsAgainst}");
      case GamePeriodType.Penalty:
        return Intl.message(
            "Start penalty Score: ${period.score.ptsFor} - ${period.score.ptsAgainst}");
    }
    return unknown;
  }

  String periodstop(GameLog period) {
    switch (period.period.type) {
      case GamePeriodType.Regulation:
        return "Stop period ${period.period.periodNumber} Score: ${period.score.ptsFor} - ${period.score.ptsAgainst}";
      case GamePeriodType.Break:
        return "Stop period ${period.period.periodNumber} Score: ${period.score.ptsFor} - ${period.score.ptsAgainst}";
      case GamePeriodType.OvertimeBreak:
        return "Stop overtime period ${period.period.periodNumber} Score: ${period.score.ptsFor} - ${period.score.ptsAgainst}";
      case GamePeriodType.Overtime:
        return "Stop overtime Score: ${period.score.ptsFor} - ${period.score.ptsAgainst}";
      case GamePeriodType.Penalty:
        return "Stop penalty Score: ${period.score.ptsFor} - ${period.score.ptsAgainst}";
    }
    return unknown;
  }

  String playerinvitedesc(String name) {
    return Intl.message(
        'This will follow $name and allow you to see which games they are in and ' +
            'all the teams they are in.  Please setup your relationship with the ' +
            'player and save.',
        desc: 'Long description of the player invite accept path.',
        locale: locale,
        args: [name]);
  }

  QuoteAndAuthor quoteforsaving(int quoteId) {
    switch (quoteId % 7) {
      case 0:
        return QuoteAndAuthor(quote: quoteStatistics, author: "Mark Twain");
      case 1:
        return QuoteAndAuthor(
            quote: quoteMissingShots, author: "Michael Jordan");
      case 2:
        return QuoteAndAuthor(
          quote: quoteMissingSpecators,
          author: "Gerald R. Ford",
        );
      case 3:
        return QuoteAndAuthor(quote: quoteInTheWay, author: "Marcus Aurelius");
      case 4:
        return QuoteAndAuthor(
            quote: quoteGreatThings, author: "Michael Jordan");
      case 5:
        return QuoteAndAuthor(quote: quoteNoChances, author: "David Beckham");
      default:
        return QuoteAndAuthor(quote: quoteDontPanic, author: "Douglas Adams");
    }
  }

  String get quoteStatistics => Intl.message("Lies, damn lies and statistics",
      desc: "Mark Twain quote", locale: locale);
  String get quoteMissingShots => Intl.message(
      "I've missed more than 9000 shots in my career. "
      "I've lost almost 300 games. 26 times, "
      "I've been trusted to take the game winning shot and missed. "
      "I've failed over and over and over again in my life. "
      "And that is why I succeed.",
      desc: "Michael Jordan quote",
      locale: locale);
  String get quoteMissingSpecators => Intl.message(
      "I know I am getting better at golf because I am hitting fewer spectators.",
      desc: "Gerald R Ford quote",
      locale: locale);
  String get quoteInTheWay =>
      Intl.message("What stands in the way, becomes the way.",
          desc: "Marcus Aurelius quote", locale: locale);
  String get quoteGreatThings => Intl.message(
      "You must expect great things of yourself before you can do them.",
      desc: "Michael Jordan quote",
      locale: locale);
  String get quoteNoChances => Intl.message(
      "The only time you run out of chances is when you stop taking them.",
      desc: "David Beckham quote",
      locale: locale);
  String get quoteDontPanic =>
      Intl.message("Don't Panic", desc: "Douglas Adams quote", locale: locale);

  String relationships(Relationship rel) {
    switch (rel) {
      case Relationship.Me:
        return relationshipMe;
      case Relationship.Friend:
        return relationshipFriend;
      case Relationship.Guardian:
        return relationshipGuardian;
      case Relationship.Parent:
        return relationshipParent;
    }
    return unknown;
  }

  String get relationshipMe => Intl.message('Me',
      name: 'Relationship is me',
      desc: 'Relationship desc for me',
      locale: locale);
  String get relationshipFriend => Intl.message('Friend',
      name: 'Relationship is friend', desc: 'Relationship desc for friend');
  String get relationshipGuardian => Intl.message('Guardian',
      name: 'Relationship is guardian', desc: 'Relationship desc for guardian');
  String get relationshipParent => Intl.message('Parent',
      name: 'Relationship is parent', desc: 'Relationship desc for parent');

  String resultinprogress(GameResultSharedDetails result) {
    GameResultPerPeriod finalScore;
    if (result.regulationResult != null) {
      finalScore = result.regulationResult;
    } else {
      finalScore = GameResultPerPeriod((b) => b
        ..period = GamePeriod.regulation1.toBuilder()
        ..score = (GameScoreBuilder()
          ..ptsFor = 0
          ..ptsAgainst = 0
          ..intermediate = false));
    }
    if (result.overtimeResult != null) {
      GameResultPerPeriod overtimeScore = result.overtimeResult;
      if (result.penaltyResult != null) {
        GameResultPerPeriod penaltyScore = result.penaltyResult;
        return Intl.message(
            'Playing ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
            '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})'
            '(Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
            name: 'In progress result details',
            desc: 'Win result details with penalty shootout');
      }
      return Intl.message(
          'Playing ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
          '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})',
          name: 'In progress result details',
          desc: 'Win result details with penalty shootout');
    }
    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return Intl.message(
          'Playing ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} (Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          name: 'In progress result details',
          desc: 'Win result details with penalty shootout');
    }
    return Intl.message(
        'Playing ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
        name: 'In progress result details',
        desc: 'In progress result details');
  }

  String resultloss(GameResultSharedDetails result) {
    GameResultPerPeriod finalScore = result.regulationResult;
    if (finalScore == null) {
      finalScore = GameResultPerPeriod((b) => b
        ..period = GamePeriod.regulation1.toBuilder()
        ..score = (GameScoreBuilder()
          ..ptsFor = 0
          ..ptsAgainst = 0
          ..intermediate = false));
    }
    if (result.overtimeResult != null) {
      GameResultPerPeriod overtimeScore = result.overtimeResult;
      if (result.penaltyResult != null) {
        GameResultPerPeriod penaltyScore = result.penaltyResult;
        return Intl.message(
            'Loss ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
            '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})'
            '(Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
            name: 'In progress result details',
            desc: 'Loss result details with penalty shootout');
      }
      return Intl.message(
          'Loss ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
          '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})',
          name: 'In progress result details',
          desc: 'Loss result details in overtime');
    }

    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return Intl.message(
          'Loss ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} (Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          name: 'Loss result details',
          desc: 'Loss result details with penalty shootout');
    }
    return Intl.message(
        'Loss ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
        name: 'Loss result details',
        desc: 'Loss result details');
  }

  String resulttie(GameResultSharedDetails result) {
    GameResultPerPeriod finalScore = result.regulationResult;
    if (finalScore == null) {
      finalScore = GameResultPerPeriod((b) => b
        ..period = GamePeriod.regulation1.toBuilder()
        ..score = (GameScoreBuilder()
          ..ptsFor = 0
          ..ptsAgainst = 0
          ..intermediate = false));
    }
    if (result.overtimeResult != null) {
      GameResultPerPeriod overtimeScore = result.overtimeResult;
      if (result.penaltyResult != null) {
        GameResultPerPeriod penaltyScore = result.penaltyResult;
        return Intl.message(
            'Tie ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
            '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})'
            '(Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
            name: 'In progress result details',
            desc: 'Tie result details with penalty shootout');
      }
      return Intl.message(
          'Tie ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
          '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})',
          name: 'In progress result details',
          desc: 'Tie result details in overtime');
    }

    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return Intl.message(
          'Tie ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} (Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          name: 'Tie result details',
          desc: 'Tie details with penalty shootout');
    }
    return Intl.message(
        'Tie ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
        name: 'Tie result details',
        desc: 'Tie result details');
  }

  String resultwin(GameResultSharedDetails result) {
    GameResultPerPeriod finalScore = result.regulationResult;
    if (finalScore == null) {
      finalScore = GameResultPerPeriod((b) => b
        ..period = GamePeriod.regulation1.toBuilder()
        ..score = (GameScoreBuilder()
          ..ptsFor = 0
          ..ptsAgainst = 0
          ..intermediate = false));
    }
    if (result.overtimeResult != null) {
      GameResultPerPeriod overtimeScore = result.overtimeResult;
      if (result.penaltyResult != null) {
        GameResultPerPeriod penaltyScore = result.penaltyResult;
        return Intl.message(
            'Win ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
            '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})'
            '(Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
            name: 'In progress result details',
            desc: 'Win result details with penalty shootout');
      }
      return Intl.message(
          'Win ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
          '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})',
          name: 'In progress result details',
          desc: 'Win result details in overtime');
    }

    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return Intl.message(
          'Win ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} (Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          name: 'Win result details',
          desc: 'Win result details with penalty shootout');
    }
    return Intl.message(
        'Win ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
        name: 'Win result details',
        desc: 'Win result details');
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

  String seasonSummary(SeasonPlayerSummary summary) {
    return seasonSummaryExpanded(summary.basketballSummary.points,
        summary.basketballSummary.blocks, summary.basketballSummary.steals);
  }

  String seasonSummaryExpanded(int points, int blocks, int steals) {
    return Intl.message("Pts $points Blks $blocks Stls $steals",
        desc: "Subtitle to markt he season as current",
        args: [points, blocks, steals],
        locale: locale,
        name: "seasonSummaryExpanded");
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
      case Sport.None:
        return Intl.message('None',
            name: 'No sport',
            desc:
                'Name for the item in a drop down for none as the sport type');
    }
    return unknown;
  }

  String teamandseason(String teamMame, String seasonName) {
    return Intl.message("Team $teamMame\nSeason $seasonName");
  }

  String teamnumbers(int num) {
    return Intl.message("${num} club teams",
        desc: 'How many teams in the club');
  }

  String titlewith(String str) {
    return Intl.message(
      'Team Fuse ($str)',
      name: 'title',
      desc: 'Title for the Team Fuse application with some context',
    );
  }

  String trackattendence(Tristate attend) {
    if (attend == Tristate.Unset) {
      return trackAttendenceUnset;
    }
    if (attend == Tristate.Yes) {
      return trackAttendenceYes;
    }
    return trackAttendenceNo;
  }

  String get trackAttendenceUnset =>
      Intl.message('Attendence is from team', locale: locale);
  String get trackAttendenceYes =>
      Intl.message('Track attendence', locale: locale);
  String get trackAttendenceNo =>
      Intl.message('Don\'t track attendence', locale: locale);

  String publicalyVisible(Tristate private) {
    if (private == Tristate.Unset) {
      return unknown;
    }
    if (private == Tristate.Yes) {
      return publicalyVisibleYes;
    }
    return publicalyVisibleNo;
  }

  String get publicalyVisibleYes =>
      Intl.message('Track attendence', locale: locale);
  String get publicalyVisibleNo =>
      Intl.message('Don\'t track attendence', locale: locale);

  String trainingtitle(String time, String endTime, String tzShortName) {
    if (endTime != null) {
      if (tzShortName != null) {
        return Intl.message('Practice $time - $endTime ($tzShortName)',
            desc: 'Practice title in game list');
      }
      return Intl.message('Practice $time - $endTime',
          desc: 'Practice title in game list');
    }
    if (tzShortName != null) {
      return Intl.message('Practice $time ($tzShortName)',
          desc: 'Practice title in game list');
    }
    return Intl.message('Practice $time', desc: 'Practice title in game list');
  }

  String trainingtitlenow(String time, String endTime, String tzShortName) {
    if (endTime != null) {
      if (tzShortName != null) {
        return Intl.message('NOW! Practice $time - $endTime ($tzShortName)',
            desc: 'Training title in game list');
      }
      return Intl.message('NOW! Practice $time - $endTime',
          desc: 'Training title in game list');
    }
    if (tzShortName != null) {
      return Intl.message('NOW! Practice $time ($tzShortName)',
          desc: 'Training title in game list');
    }
    return Intl.message('NOW! Practice $time',
        desc: 'Training title in game list');
  }

  String verifyexplanation(String email) {
    return Intl.message(
      'Email address $email needs to be verified, please check your email or resend the verification details.',
      name: 'Button to resend the email to verify their email address',
    );
  }

  String wearuniform(String wear) {
    return Intl.message('Wear $wear',
        name: 'Wear uniform message in game des',
        desc: 'Wear uniform in a game desc');
  }

  String winrecord(WinRecord record) {
    return Intl.message(
        'Win: ${record.win} Loss: ${record.loss} Tie: ${record.tie}',
        name: 'Win record for a team',
        desc: 'Win record for a team');
  }

  /// Load the messages for the specific locale.
  static Future<Messages> load(Locale locale) async {
    var name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    var localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((dynamic _) {
      Intl.defaultLocale = localeName;
      return Messages(localeName);
    });
  }

  /// The test version.
  static Future<Messages> loadTest(Locale locale) async {
    return Messages(locale.toString());
  }

  /// The messages in the system from the context.
  static Messages of(BuildContext context) {
    return Localizations.of<Messages>(context, Messages);
  }
}

///
/// The delegate for the messages to load it with fluff.
///
class MessagesDelegate extends LocalizationsDelegate<Messages> {
  const MessagesDelegate();

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  Future<Messages> load(Locale locale) => Messages.load(locale);

  @override
  bool shouldReload(MessagesDelegate old) => false;
}

///
/// The delegate for the messages to load it with fluff.
///
class MessagesTestDelegate extends LocalizationsDelegate<Messages> {
  const MessagesTestDelegate();

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  Future<Messages> load(Locale locale) => Messages.loadTest(locale);

  @override
  bool shouldReload(MessagesDelegate old) => false;
}

class QuoteAndAuthor {
  String quote;

  String author;

  QuoteAndAuthor({this.quote, this.author});
}
