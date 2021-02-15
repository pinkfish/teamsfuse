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

  String get addclub {
    return Intl.message("ADD CLUB",
        desc: "Add a new club button", locale: locale);
  }

  String get addclubmemebertitle =>
      Intl.message('Add club member', locale: locale);

  String get addCoach => Intl.message("Add Coach",
      desc: "Add coach menu item in the drop down", locale: locale);

  String get adddivison => Intl.message('ADD DIVISON',
      desc: 'Add a division inside a league/tournament', locale: locale);

  String get addevent => Intl.message('ADD EVENT',
      desc: 'Button to add an event to a team', locale: locale);

  String get addgamebutton =>
      Intl.message('GAME', desc: 'Button to add a game', locale: locale);

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
      desc: 'Add new opponent for game',
    );
  }

  String get addplayer {
    return Intl.message('ADD PLAYER', desc: 'Message for loading the app');
  }

  String get addPlayerButton => Intl.message("PLAYER",
      desc: "Text on a add player button", locale: locale);

  String get addPlayerTooltip => Intl.message("Add Player",
      desc: "Message to on the tooltip to add a player", locale: locale);

  String get addresultbutton {
    return Intl.message('ADD RESULT');
  }

  String get addseason {
    return Intl.message('ADD SEASON', desc: 'Add a season to the team');
  }

  String get addteam {
    return Intl.message("ADD TEAM", desc: "Add a new team button");
  }

  String get addteamadmin {
    return Intl.message('SHARE TEAM');
  }

  String get addtournament {
    return Intl.message('Add Tournamwent');
  }

  String get addtraining {
    return Intl.message('ADD TRAINING',
        desc: 'Button to add a training to a team');
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
    return Intl.message("All games", desc: 'Checkbox to select all the games');
  }

  String get allPeriods => Intl.message("All Periods",
      desc: "Drop down menu item for all periods", locale: locale);

  String get allPlayers => Intl.message('All Players', locale: locale);

  String get allSeasons => Intl.message('All Seasons', locale: locale);

  String get allteams {
    return Intl.message("All teams",
        desc: 'Drop down for  the all teams result');
  }

  String get allteamsbbutton {
    return Intl.message("ALL TEAMS",
        desc: 'Drop down for  the all teams result');
  }

  String get archived {
    return Intl.message('Archived');
  }

  String get archivedteams {
    return Intl.message('Archived Teams');
  }

  String get archivemessage {
    return Intl.message("Archive", desc: "Archive message button");
  }

  String get archiveteam {
    return Intl.message('Archive Team');
  }

  String get arriveat {
    return Intl.message(
      'Arrive At',
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
        desc: 'Negative attendence for the game');
  }

  String get attendanceselect {
    return Intl.message('Attendence', desc: 'Are you attending the game title');
  }

  String get attendanceyes {
    return Intl.message('Will be there',
        desc: 'Positive attendence for the game');
  }

  String get attendncemaybe {
    return Intl.message('Maybe', desc: 'Maybe attendence for the game');
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

  String get clubDeleted => Intl.message('Club deleted', locale: locale);

  String get clubdetails {
    return Intl.message('Details');
  }

  String get clubsettingdescription => Intl.message(
      'To setup a club for a team you need to be an '
      'administrator for both the club and for the team.  This will let you '
      'connect the both together.  Once connected all administators of the '
      'club will also be adminstragtors for the team.',
      locale: locale);
  String get coachAbout => Intl.message("About",
      desc: "Title for a form field about the coach", locale: locale);

  String get coachAboutHint => Intl.message("Information about the coach",
      desc: "Hint text for a form field about the coach", locale: locale);

  String get coachDeleted => Intl.message('Coach deleted',
      desc: "Coach associated with a club is deleted", locale: locale);

  String get coaches => Intl.message('Coaches',
      desc: 'Header to display the coaches for the team/club', locale: locale);

  String get coachName => Intl.message("Name",
      desc: "Title for a form field for the coachs name", locale: locale);

  String get coachNameHint => Intl.message("Name of the coach",
      desc: "Hint text for a form field for the coachs name", locale: locale);

  String get copyseasonfrom =>
      Intl.message('Copy details from', locale: locale);

  String get create => Intl.message(
        'Create new',
        desc: 'Create new account button text',
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
        desc: 'Title for the step to create a game or team in a stepper');
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

  String get deleteGameGame => Intl.message("Delete game");

  String get deleteGamePractice => Intl.message("Delete training");

  String get deleteGameSpecialEvent => Intl.message("Delete special event");

  String get deleteinvite {
    return Intl.message('Delete invite',
        desc: 'Title for the dialog to delete an invite');
  }

  String get deleteinvitebutton {
    return Intl.message('DELETE INVITE',
        desc: 'Title for the dialog to delete an invite');
  }

  String get deletemember {
    return Intl.message('Delete member');
  }

  String get deletemessage {
    return Intl.message("Delete", desc: "Delete message button");
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
        desc: 'Details fin a stepper for a game or team');
  }

  String get directionsbuttons {
    return Intl.message('DIRECTIONS');
  }

  String get displayname => Intl.message('Name',
      desc: 'Name for the edit box to edit the user name', locale: locale);

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
      desc: 'The edit text for the dialog',
    );
  }

  String get editgame {
    return Intl.message(
      'Edit Game',
      desc: 'Edit Game help text for button',
    );
  }

  String get editimagebutton {
    return Intl.message('EDIT IMAGE', desc: 'Button to edit the image');
  }

  String get editteam {
    return Intl.message(
      'Edit Team',
      desc: 'Edit Team help text for button',
    );
  }

  String get email {
    return Intl.message('Email', desc: 'Email input field');
  }

  String get emailheader {
    return Intl.message("Email Preferences");
  }

  String get emailonupcoming {
    return Intl.message("Upcoming games/events",
        desc: 'Switch text for emailing on upcoming games');
  }

  String get emailonupdates {
    return Intl.message("On changes to games/events",
        desc: 'Switch text for emailing on updates');
  }

  String get emailrequired {
    return Intl.message('Email is empty.',
        desc: 'Message to say they have an empty email field');
  }

  String get emptypassword {
    return Intl.message('Please choose a password.',
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
        desc: 'Drop down for only the special events');
  }

  String get everyone {
    return Intl.message("Everyone",
        desc: 'Message to mean everyone in the team (coaches + everyone)');
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
      desc: 'Forgot password button text',
    );
  }

  String get forgotPasswordHint {
    return Intl.message(
      'The email to resend the password to',
      desc: 'Forgot password happy button',
    );
  }

  String get forgotPasswordSent {
    return Intl.message(
      'Sent email to your email address to reset your password',
      desc: 'Forgot password happy button',
    );
  }

  String get formerror => Intl.message('Please fix the items outlined in red',
      desc: 'Error when submitting a form', locale: locale);

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
        desc: 'Availability for the game, botton tab bar title');
  }

  String get gameend {
    return Intl.message('Game end',
        desc: 'Title for the time drop down to choose the game end time');
  }

  String get gamenotes {
    return Intl.message(
      'Game notes',
      desc: 'The notes associated with the game',
    );
  }

  String get gamenoteshint {
    return Intl.message(
      'Notes for the game',
      desc: 'The hint text for notes associated with the game',
    );
  }

  String get gameResultAwayTeamWon =>
      Intl.message("Away team won", locale: locale);

  String get gameResultHomeTeamWon =>
      Intl.message("Home team won", locale: locale);

  String get gameResultInProgress =>
      Intl.message("In progress", locale: locale);

  String get gameResultLoss => Intl.message("Loss", locale: locale);

  String get gameResultTie => Intl.message("Tie", locale: locale);

  String get gameResultWin => Intl.message("Win", locale: locale);

  String get games {
    return Intl.message('Games');
  }

  String get gametime {
    return Intl.message(
      'Game Time',
      desc: 'Title for the game time',
    );
  }

  String get gametype {
    return Intl.message("Games", desc: 'Drop down for onlhy the game events');
  }

  String get gendercoed {
    return Intl.message('Coed',
        desc: 'Coed gender for the sport in the drop down');
  }

  String get genderfemale {
    return Intl.message('Female',
        desc: 'Female gender for the sport in the drop down');
  }

  String get gendermale {
    return Intl.message('Male',
        desc: 'Male gender for the sport in the drop down');
  }

  String get genderna {
    return Intl.message('N/A',
        desc: 'Not applicable gender for the sport in the drop down');
  }

  String get genderselect {
    return Intl.message('Select gender', desc: 'Hint text to select a gender');
  }

  String get home {
    return Intl.message("home");
  }

  String get homeaway {
    return Intl.message(
      'Home',
      desc: 'Title for the home game checkbox',
    );
  }

  String get imageMediaType =>
      Intl.message("Photo", desc: "Upload a photo", locale: locale);

  String get importplayers {
    return Intl.message('Import\nplayers',
        desc: 'Import players from previous season');
  }

  String get includemyself {
    return Intl.message('Send to yourself',
        desc: 'If the message should also be sent to ourselves');
  }

  String get invalidemail {
    return Intl.message('Email address must be of form xxx@xxx.',
        desc: 'Message to say they have an invalid email field');
  }

  String get invalidname {
    return Intl.message('Name can only contain alphanumerical characters.',
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
    return Intl.message('League', desc: 'The league the team is playing in');
  }

  String get leaguehint {
    return Intl.message('League the team is playing in',
        desc: 'League the team is playing in');
  }

  String get leaguetournament {
    return Intl.message('League/Tournaments',
        desc: 'Link to the league/tournament section');
  }

  String get loading {
    return Intl.message('Loading...', desc: 'Message for loading the app');
  }

  String get location =>
      Intl.message("Location", desc: "Location of the game", locale: locale);

  String get login {
    return Intl.message(
      'LOGIN',
      desc: 'Login button text',
    );
  }

  String get logout {
    return Intl.message(
      'LOGOUT',
      desc: 'Logout button text',
    );
  }

  String get longDescription {
    return Intl.message('Description',
        desc:
            'Long description of a tournament/league to display on the league page');
  }

  String get longDescriptionHint {
    return Intl.message('Detailed Description',
        desc:
            'Long description of a tournament/league to display on the league/tournament page');
  }

  String get loss {
    return Intl.message("Loss", desc: 'Drop down for  the loss result');
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
      desc: 'Monthly repeat',
    );
  }

  String get namerequired => Intl.message('Username is empty.',
      desc: 'Message to say they have an empty email field', locale: locale);

  String get needtobeadmin =>
      Intl.message('Need to be an administrator', locale: locale);

  String get needtoselectgender => Intl.message('Please choose a gender.',
      desc: 'Message to suggest they need to select a gender', locale: locale);

  String get needtoselectopponent {
    return Intl.message('Please choose an opponent.',
        desc: 'Message to suggest they need to select an oppoent');
  }

  String get needtoselectrole {
    return Intl.message('Need to select a role',
        desc: 'Error to say they must select the role in the team');
  }

  String get needtoselectsport {
    return Intl.message('Please choose a sport.',
        desc: 'Message to suggest they need to select a sport');
  }

  String get newbuttontext {
    return Intl.message("NEW", desc: "New button text in the system");
  }

  String get newdivisonhint {
    return Intl.message('New Divison Name');
  }

  String get newmail {
    return Intl.message("NEW MESSAGE",
        desc: "New message in the teamfuse system");
  }

  String get newplayername {
    return Intl.message('New player name',
        desc: 'Text to show before the player name.');
  }

  String get newplayernamehint {
    return Intl.message('New player name of player in team',
        desc: 'Hint for the name of the player in the team.');
  }

  String get newseasonhint {
    return Intl.message('New Season Name');
  }

  String get news {
    return Intl.message('News',
        desc: 'Header the for the news section', locale: locale);
  }

  String get noNews {
    return Intl.message('No News',
        desc: 'No news in the stuff', locale: locale);
  }

  String get noclub {
    return Intl.message('No club');
  }

  String get noCoaches => Intl.message("No coaches",
      desc: 'Message to show that there are no coaches for this club',
      locale: locale);

  String get nodivisons {
    return Intl.message("No divisions",
        desc: "Divisons inside the season for a league/tournament");
  }

  String get noevent {
    return Intl.message("All events", desc: 'Drop down for all the events');
  }

  String get nogames {
    return Intl.message(
      'No games',
      desc: 'No games scheduled',
    );
  }

  String get nogamesfiltered {
    return Intl.message("No games to display, check filters",
        desc: 'No games to display based on filters');
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
      desc: 'No repeat period',
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
    return Intl.message("All Games", desc: 'Drop down for all the games');
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
      desc: 'Title for the opponent marker',
    );
  }

  String get opponentcontact {
    return Intl.message(
      'Contact',
      desc: 'The text for the contact of an opponent',
    );
  }

  String get opponentcontacthint {
    return Intl.message(
      'Contact for the opponent',
      desc: 'The hint text for the contact of an opponent',
    );
  }

  String get opponentname {
    return Intl.message(
      'Name',
      desc: 'The text for the name of an opponent',
    );
  }

  String get opponentnamehint {
    return Intl.message(
      'Name of the opponent.',
      desc: 'The hint text for the name of an opponent',
    );
  }

  String get opponentselect {
    return Intl.message(
      'Select opponent',
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
        desc: 'Player email input field hint');
  }

  String get playerName => Intl.message('Player Name', locale: locale);

  String get players {
    return Intl.message('Players',
        desc: 'Title in the bottom navigation tab for players');
  }

  String get playerselect {
    return Intl.message("Player", desc: "Label for the player drop down");
  }

  String get playerselecthint {
    return Intl.message("Select player",
        desc: "Label for the player drop down");
  }

  String get points => Intl.message("Points",
      desc: "Drop down menu item for points", locale: locale);

  String get pointsGameSummary =>
      Intl.message("Pts", desc: "Points summary in game", locale: locale);

  String get pointsTitle =>
      Intl.message("Pts", desc: "Points abbreviation", locale: locale);
  String get previousSeasons {
    return Intl.message('Previous Seasons',
        desc: 'Previous seasons for this game');
  }

  String get publicalyVisibleNo =>
      Intl.message('Don\'t track attendence', locale: locale);

  String get publicalyVisibleYes =>
      Intl.message('Track attendence', locale: locale);

  String get quoteDontPanic =>
      Intl.message("Don't Panic", desc: "Douglas Adams quote", locale: locale);

  String get quoteGreatThings => Intl.message(
      "You must expect great things of yourself before you can do them.",
      desc: "Michael Jordan quote",
      locale: locale);

  String get quoteInTheWay =>
      Intl.message("What stands in the way, becomes the way.",
          desc: "Marcus Aurelius quote", locale: locale);

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

  String get quoteNoChances => Intl.message(
      "The only time you run out of chances is when you stop taking them.",
      desc: "David Beckham quote",
      locale: locale);

  String get quoteStatistics => Intl.message("Lies, damn lies and statistics",
      desc: "Mark Twain quote", locale: locale);

  String get rebounds => Intl.message("Rebounds",
      desc: "Drop down menu item for rebounds", locale: locale);

  String get reboundsGameSummary =>
      Intl.message("RBs", desc: "Rebounds in game summary", locale: locale);

  String get regulationperiod {
    return Intl.message('Regulation');
  }

  String get relationshipFriend =>
      Intl.message('Friend', desc: 'Relationship desc for friend');

  String get relationshipGuardian =>
      Intl.message('Guardian', desc: 'Relationship desc for guardian');

  String get relationshipMe =>
      Intl.message('Me', desc: 'Relationship desc for me', locale: locale);

  String get relationshipParent =>
      Intl.message('Parent', desc: 'Relationship desc for parent');

  String get relationshipselect {
    return Intl.message("Select relationship",
        desc: "Label to select the relatiobship from a drop down");
  }

  String get repeat {
    return Intl.message(
      'Repeat',
      desc: 'Repeat title for the traning create steps',
    );
  }

  String get resendverify {
    return Intl.message(
      'RESEND EMAIL',
      desc: 'Button to resend the email to verify their email address',
    );
  }

  String get resettimer {
    return Intl.message("Reset Timer");
  }

  String get resettimerbody {
    return Intl.message("Do you want to reset the timer to zero?");
  }

  String get resultunknown {
    return Intl.message('No result.', desc: 'No result for the game');
  }

  String get role => Intl.message('Role',
      desc: 'Header for a column talking about the role', locale: locale);

  String get roleselect => Intl.message('Select role',
      desc: 'Drop down to select the role in the team', locale: locale);

  String get savebuttontext {
    return Intl.message(
      'SAVE',
      desc: 'The save text for the dialog',
    );
  }

  String get saveButtonText => Intl.message('SAVE', locale: locale);

  String get savefailed {
    return Intl.message('Save Failed', desc: 'Save failed, server error');
  }

  String get season {
    return Intl.message(
      'Season',
      desc: 'Title for the season marker',
    );
  }

  String get seasonhint {
    return Intl.message(
      'Current team season',
      desc: 'Hint for the season text box',
    );
  }

  String get seasonrequired {
    return Intl.message("Season name is required",
        desc: "The error text when the season name is required");
  }

  String get seasons => Intl.message("Seasons",
      desc: "Header for the seasons section", locale: locale);

  String get seasonselect {
    return Intl.message(
      'Select season',
      desc: 'Title for the select season marker',
    );
  }

  String get selectclub => Intl.message('Select club', locale: locale);

  String get selectImageButton =>
      Intl.message("GALLERY", desc: "Live video streaming", locale: locale);

  String get selectMediaType => Intl.message("Select Media",
      desc: "Title for the dialog to select a video", locale: locale);

  String get selectplace => Intl.message('Select place',
      desc:
          'Title for the drop down to say select place if nothing is selected',
      locale: locale);

  String get subjectRequired => Intl.message('Need to have a subject',
      desc: 'Error to display for the form when a subject is empty.',
      locale: locale);

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
        desc: 'Short description of a tournament/league to display in the ux');
  }

  String get shortDescriptionHint {
    return Intl.message('Short Description',
        desc: 'Short description of a tournament/league to display in the ux');
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
      desc: 'Title in the bottom navigation bar for the stats', locale: locale);

  String get stealEventType => Intl.message(
        "Steal",
        desc: "Steal a ball",
        locale: locale,
      );

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
        desc: "Subject for the message, title of input field");
  }

  String get subsitutionEventType => Intl.message("Subsitution",
      desc: "Subsitiution of player", locale: locale);

  String get takePhotoButton =>
      Intl.message("CAMERA", desc: "Live video streaming", locale: locale);

  String get team {
    return Intl.message(
      'Team',
      desc: 'Title for the team marker',
    );
  }

  String get teamdeleted => Intl.message('Team deleted', locale: locale);

  String get teamedithint {
    return Intl.message('Change team',
        desc: 'Hint for the button to edit the team');
  }

  String get teamname {
    return Intl.message('Name', desc: 'Name of the team');
  }

  String get teamnamehint {
    return Intl.message('Name', desc: 'Hint for the name of the team');
  }

  String get teams {
    return Intl.message('Teams');
  }

  String get teamselect {
    return Intl.message(
      'Select team',
      desc: 'The text for notes for selecting team for the event',
    );
  }

  String get teamselected {
    return Intl.message('Team Selected');
  }

  String get tie {
    return Intl.message("Tie", desc: 'Drop down for  the tie result');
  }

  String get timercountup {
    return Intl.message("Timer count up");
  }

  String get title {
    return Intl.message(
      'Team Fuse',
      desc: 'Title for the Team Fuse application',
    );
  }

  String get tournament => Intl.message('Tournament',
      desc: "Title for the tournament section", locale: locale);

  String get trackAttendenceNo =>
      Intl.message('Don\'t track attendence', locale: locale);

  String get trackAttendenceUnset =>
      Intl.message('Attendence is from team', locale: locale);

  String get trackAttendenceYes =>
      Intl.message('Track attendence', locale: locale);

  String get trainingend => Intl.message('Training end',
      desc: 'Title for the time drop down to choose the training end time',
      locale: locale);

  String get trainingnotes {
    return Intl.message(
      'Training notes',
      desc: 'The notes associated with the game',
    );
  }

  String get trainingnoteshint {
    return Intl.message(
      'Notes for the training',
      desc: 'The hint text for notes associated with the game',
    );
  }

  String get trainingtimes {
    return Intl.message("Training times",
        desc: 'HEader for the extra training times in a repeat event');
  }

  String get trainingtype {
    return Intl.message("Training",
        desc: 'Drop down foronlhy the training events');
  }

  String get turnOverEventType => Intl.message(
        "Turnover",
        desc: "Caused a turnover",
        locale: locale,
      );

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
      desc: 'Title for the uniform input box',
    );
  }

  String get uniformhint {
    return Intl.message(
      'Uniform to wear',
      desc: 'Hint for the uniform input box',
    );
  }

  String get unknown {
    return Intl.message(
      'Unknown',
      desc: 'Unknown name',
    );
  }

  String get until {
    return Intl.message("Until", desc: 'Drop down for the until option');
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
        desc: 'Button to pull the offical results in from the shared game');
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
      desc: 'Weekly repeat',
    );
  }

  String get where {
    return Intl.message('Where', desc: 'Where the game is');
  }

  String get win {
    return Intl.message("Win", desc: 'Drop down for  the win result');
  }

  String get youremailHint {
    return Intl.message('Your email address',
        desc: 'Your email input field hint');
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

  String cardresultinprogressfinal(GameResultPerPeriod finalScore) =>
      Intl.message(
          '${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
          desc: 'In progress result details');

  String cardresultinprogressovertime(
          GameResultPerPeriod finalScore, GameResultPerPeriod overtimeScore) =>
      Intl.message(
          '${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
          '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})',
          desc: 'Win result details with penalty shootout',
          args: [finalScore, overtimeScore]);

  String cardresultinprogressovertimeandpenalty(
          GameResultPerPeriod finalScore,
          GameResultPerPeriod overtimeScore,
          GameResultPerPeriod penaltyScore) =>
      Intl.message(
        '${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
        '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})'
        '(Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
        desc: 'Win result details with penalty shootout',
        args: [finalScore, overtimeScore, penaltyScore],
      );

  String cardresultinprogresspenalty(
          GameResultPerPeriod finalScore, GameResultPerPeriod penaltyScore) =>
      Intl.message(
          '${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} (Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          desc: 'In progress result details with penalty shootout',
          args: [finalScore, penaltyScore]);

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

  String confirmdeleteasadmin(InviteAsAdmin inviteAdmin) => Intl.message(
      'Do you want to delete the invite to be admin for the team ${inviteAdmin.teamName}?',
      desc: 'Text to delete the invite to be an admin in the alert dialog.',
      args: [inviteAdmin]);

  String confirmdeleteclub(InviteToClub inviteClub) => Intl.message(
      'Do you want to delete the invite to be in the club ${inviteClub.clubName}?',
      desc: 'Text to delete the invite to the club in the alert dialog.',
      args: [inviteClub]);

  String confirmdeleteinviteplayer(InviteToPlayer invitePlayer) => Intl.message(
      'Do you want to delete the invite to follow ${invitePlayer.playerName}?',
      desc: 'Text to delete the invite to the team in the alert dialog.',
      args: [invitePlayer]);

  String confirmdeleteinviteteam(InviteToTeam inviteTeam) => Intl.message(
      'Do you want to delete the invite to ${inviteTeam.teamName} for ${inviteTeam.playerName}?',
      desc: 'Text to delete the invite to the team in the alert dialog.',
      args: [inviteTeam]);

  String confirmdeleteleagueasadmin(InviteToLeagueAsAdmin invite) => Intl.message(
      'Do you want to delete the invite to be in the league ${invite.leagueName}?',
      desc: 'Text to delete the invite to the league in the alert dialog.',
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

  String eventTitleNowSpecialEvent(String time) =>
      Intl.message('NOW! Event $time',
          desc: 'Special event title in game list', args: [time]);

  String eventTitleNowSpecialEventName(String name, String time) =>
      Intl.message("NOW! $name $time",
          desc: 'Special event title in game list', args: [name, time]);

  String eventTitleNowSpecialEventNameEndTime(
          String name, String time, String endTime) =>
      Intl.message('NOW! $name $time - $endTime',
          desc: 'Special event title in game list',
          args: [name, time, endTime]);

  String eventTitleNowSpecialEventNameEndTimeTimeZone(
          String name, String time, String endTime, String tzShortName) =>
      Intl.message('NOW! $name $time - $endTime  ($tzShortName)',
          desc: 'Special event title in game list',
          args: [name, time, endTime, tzShortName]);

  String eventTitleNowSpecialEventNameTimeZone(
          String name, String time, String tzShortName) =>
      Intl.message('NOW! $name $time ($tzShortName)',
          desc: 'Special event title in game list',
          args: [name, time, tzShortName]);

  String eventTitleNowSpecialEventStartAndEnd(String time, String endTime) =>
      Intl.message('NOW! Event $time - $endTime',
          desc: 'Special event title in game list');
  String eventTitleNowSpecialEventStartAndEndTimezone(
          String time, String endTime, String tzShortName) =>
      Intl.message('NOW! Event $time - $endTime ($tzShortName)',
          desc: 'Special event title in game list',
          args: [time, endTime, tzShortName]);
  String eventTitleNowSpecialWithTimezone(String time, String tzShortName) =>
      Intl.message('NOW! Event $time ($tzShortName)',
          desc: 'Special event title in game list with timezone',
          args: [time, tzShortName]);

  String eventTitleSpecialEvent(String time) => Intl.message('Event $time',
      desc: 'Special event title in game list', args: [time]);

  String eventTitleSpecialEventName(String name, String time) =>
      Intl.message("$name $time",
          desc: 'Special event title in game list', args: [name, time]);

  String eventTitleSpecialEventNameEndTime(
          String name, String time, String endTime) =>
      Intl.message('$name $time - $endTime',
          desc: 'Special event title in game list',
          args: [name, time, endTime]);

  String eventTitleSpecialEventNameEndTimeTimeZone(
          String name, String time, String endTime, String tzShortName) =>
      Intl.message('$name $time - $endTime  ($tzShortName)',
          desc: 'Special event title in game list',
          args: [name, time, endTime, tzShortName]);

  String eventTitleSpecialEventNameTimeZone(
          String name, String time, String tzShortName) =>
      Intl.message('$name $time ($tzShortName)',
          desc: 'Special event title in game list',
          args: [name, time, tzShortName]);

  String eventTitleSpecialEventStartAndEnd(String time, String endTime) =>
      Intl.message('Event $time - $endTime',
          desc: 'Special event title in game list');

  String eventTitleSpecialEventStartAndEndTimezone(
          String time, String endTime, String tzShortName) =>
      Intl.message('Event $time - $endTime ($tzShortName)',
          desc: 'Special event title in game list',
          args: [time, endTime, tzShortName]);

  String eventTitleSpecialWithTimezone(String time, String tzShortName) =>
      Intl.message('Event $time ($tzShortName)',
          desc: 'Special event title in game list with timezone',
          args: [time, tzShortName]);

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

  String gameResultOffical(
          String resultString, GameResultPerPeriod regulationPeriodResult) =>
      Intl.message(
          "$resultString\nHome: ${regulationPeriodResult.score.ptsFor} "
          "Away: ${regulationPeriodResult.score.ptsAgainst}",
          args: [resultString, regulationPeriodResult]);

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
            desc: 'Game title in game list');
      }
      return Intl.message('NOW! $time - $endTime vs $opponent',
          desc: 'Game title in game list');
    }
    if (tzShortName != null) {
      return Intl.message('NOW! $time ($tzShortName) vs $opponent',
          desc: 'Game title in game list');
    }
    return Intl.message('NOW! $time vs $opponent',
        desc: 'Game title in game list');
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

  String madeEventType(int points) => Intl.message(
        "$points",
        args: [points],
        desc: "+num points",
        locale: locale,
      );
  String missedEventType(int points) => Intl.message(
        "Miss $points",
        args: [points],
        desc: "missed num points",
        locale: locale,
      );
  String nameandteam(Team team, Player player) {
    return Intl.message("${team.name} ${player.name}",
        desc: "Format for name and player for the team",
        args: [team, player],
        locale: locale);
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
        desc: "Shows the opponent and season");
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
        desc: 'Win record for an opponent for this season');
  }

  String pendinginvites(int num) {
    return Intl.message('Pending Invites: $num',
        desc: 'Header showing the number of pending invites');
  }

  String periodEnd(String periodName) {
    return Intl.message(
      "End of $periodName",
      args: [periodName],
      desc: "End of period",
      locale: locale,
    );
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

  String periodStart(String periodName) {
    return Intl.message(
      "Start of $periodName",
      args: [periodName],
      desc: "Start of period",
      locale: locale,
    );
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

  String publicalyVisible(Tristate private) {
    if (private == Tristate.Unset) {
      return unknown;
    }
    if (private == Tristate.Yes) {
      return publicalyVisibleYes;
    }
    return publicalyVisibleNo;
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
            desc: 'Win result details with penalty shootout');
      }
      return Intl.message(
          'Playing ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
          '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})',
          desc: 'Win result details with penalty shootout');
    }
    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return Intl.message(
          'Playing ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} (Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          desc: 'Win result details with penalty shootout');
    }
    return Intl.message(
        'Playing ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
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
            desc: 'Loss result details with penalty shootout');
      }
      return Intl.message(
          'Loss ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
          '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})',
          desc: 'Loss result details in overtime');
    }

    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return Intl.message(
          'Loss ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} (Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          desc: 'Loss result details with penalty shootout');
    }
    return Intl.message(
        'Loss ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
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
            desc: 'Tie result details with penalty shootout');
      }
      return Intl.message(
          'Tie ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
          '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})',
          desc: 'Tie result details in overtime');
    }

    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return Intl.message(
          'Tie ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} (Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          desc: 'Tie details with penalty shootout');
    }
    return Intl.message(
        'Tie ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
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
            desc: 'Win result details with penalty shootout');
      }
      return Intl.message(
          'Win ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} '
          '(Overtime ${overtimeScore.score.ptsFor} - ${overtimeScore.score.ptsAgainst})',
          desc: 'Win result details in overtime');
    }

    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return Intl.message(
          'Win ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} (Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          desc: 'Win result details with penalty shootout');
    }
    return Intl.message(
        'Win ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
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
    return Intl.message(
      "Pts $points Blks $blocks Stls $steals",
      desc: "Subtitle to markt he season as current",
      args: [points, blocks, steals],
      locale: locale,
    );
  }

  String sportname(Sport sport) {
    switch (sport) {
      case Sport.Basketball:
        return Intl.message('Basketball',
            desc: 'Name for the item in a drop down for basketball');
      case Sport.Softball:
        return Intl.message('Softball',
            desc: 'Name for the item in a drop down for softball');
      case Sport.Soccer:
        return Intl.message('Soccer',
            desc: 'Name for the item in a drop down for soccer');
      case Sport.Other:
        return Intl.message('Other sport',
            desc: 'Name for the item in a drop down for other');
      case Sport.None:
        return Intl.message('None',
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
      desc: 'Button to resend the email to verify their email address',
      args: [email],
    );
  }

  String wearuniform(String wear) {
    return Intl.message('Wear $wear',
        desc: 'Wear uniform in a game desc', args: [wear]);
  }

  String winrecord(WinRecord record) {
    return Intl.message(
        'Win: ${record.win} Loss: ${record.loss} Tie: ${record.tie}',
        desc: 'Win record for a team',
        args: [record]);
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
