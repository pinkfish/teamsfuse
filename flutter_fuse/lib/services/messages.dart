import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart';

import '../l10n/messages_all.dart';

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

  String get addAdminButton => Intl.message('ADD ADMIN',
      desc: 'Message to show as the title for the admin adding screen',
      locale: locale);
  String get addAdmin => Intl.message('Add Admin',
      desc: 'Message to show as the title for the admin adding screen',
      locale: locale);
  String get addButton =>
      Intl.message("ADD", desc: "Add a new item button", locale: locale);

  String get addClubButton =>
      Intl.message("ADD CLUB", desc: "Add a new club button", locale: locale);

  String get addNews => Intl.message("Add News",
      desc: "Add a new news drop down menu item", locale: locale);

  String get addClubMemeberTitle =>
      Intl.message('Add club member', locale: locale);

  String get addCoach => Intl.message("Add Coach",
      desc: "Add coach menu item in the drop down", locale: locale);

  String get addDivison => Intl.message('Add Divison',
      desc: 'Add a division inside a league/tournament', locale: locale);

  String get addDivisonButton => Intl.message('ADD DIVISON',
      desc: 'Add a division inside a league/tournament', locale: locale);

  String get addEventButton => Intl.message('ADD EVENT',
      desc: 'Button to add an event to a team', locale: locale);

  String get addGameButton =>
      Intl.message('GAME', desc: 'Button to add a game', locale: locale);

  String get addGameTooltip => Intl.message("Add Game",
      desc: "Message to on the tooltip to add a game", locale: locale);
  String get addInviteButton => Intl.message('ADD INVITE',
      desc: 'Button to add an invite', locale: locale);
  String get addInvite => Intl.message('Add Invite',
      desc: 'Drop down to add an invite', locale: locale);

  String get sharePlayerButton {
    return Intl.message('SHARE PLAYER', locale: locale);
  }

  String get addleague {
    return Intl.message('Add League', locale: locale);
  }

  String get addOpponent {
    return Intl.message('Add new',
        desc: 'Add new opponent for game', locale: locale);
  }

  String get addPlayer => Intl.message("Add Player",
      desc: "Text on a add player drop down", locale: locale);

  String get addPlayerButton => Intl.message("PLAYER",
      desc: "Text on a add player button", locale: locale);

  String get addPlayerTooltip => Intl.message("Add Player",
      desc: "Message to on the tooltip to add a player", locale: locale);

  String get addResultButton {
    return Intl.message('ADD RESULT', locale: locale);
  }

  String get addSeason {
    return Intl.message('Add Season',
        desc: 'Add a season to the team', locale: locale);
  }

  String get addSeasonButton {
    return Intl.message('ADD SEASON',
        desc: 'Add a season to the team', locale: locale);
  }

  String get addTeamButton {
    return Intl.message("ADD TEAM",
        desc: "Add a new team button", locale: locale);
  }

  String get addTeam {
    return Intl.message("Add Team",
        desc: "Add a new team drop down item", locale: locale);
  }

  String get shareTeamButton {
    return Intl.message('SHARE TEAM', locale: locale);
  }

  String get shareTeam {
    return Intl.message('Share team', locale: locale);
  }

  String get addtournament {
    return Intl.message('Add Tournamwent', locale: locale);
  }

  String get addTrainingButton {
    return Intl.message('ADD TRAINING',
        desc: 'Button to add a training to a team', locale: locale);
  }

  String get administrator {
    return Intl.message('Adminstrator', locale: locale);
  }

  String get againstpts {
    return Intl.message("Against",
        desc:
            "Title to the spinner for showing points against in the results screen",
        locale: locale);
  }

  String get allEvents => Intl.message("All Events",
      desc: "Drop down menu item for all events", locale: locale);

  String get allgames {
    return Intl.message("All games",
        desc: 'Checkbox to select all the games', locale: locale);
  }

  String get allPeriods => Intl.message("All Periods",
      desc: "Drop down menu item for all periods", locale: locale);

  String get allPlayers => Intl.message('All Players', locale: locale);

  String get allSeasons => Intl.message('All Seasons', locale: locale);

  String get allteams {
    return Intl.message("All teams",
        desc: 'Drop down for  the all teams result', locale: locale);
  }

  String get allTeamsButton {
    return Intl.message("ALL TEAMS",
        desc: 'Drop down for  the all teams result', locale: locale);
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

  String get changescore => Intl.message('Change Score',
      desc:
          'Title for the dialog box to change the score after the game has finished',
      locale: locale);

  String get checkPlayerNoEmail =>
      Intl.message('Are you sure you want to add a player with no email?',
          desc: 'Text in a dialog for when adding a player with no email',
          locale: locale);

  String get choosedivisions =>
      Intl.message("Start Game - Breaks", locale: locale);

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

  String get coachAboutHint => Intl.message("Information about the coach",
      desc: "Hint text for a form field about the coach", locale: locale);

  String get coachDeleted => Intl.message('Coach deleted',
      desc: "Coach associated with a club is deleted", locale: locale);

  String get coaches => Intl.message('Coaches',
      desc: 'Header to display the coaches for the team/club', locale: locale);

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

  String get deleteadmin => Intl.message("Delete Admin", locale: locale);

  String get deleteadmininvite =>
      Intl.message('Delete admin invite', locale: locale);

  String get deletebuttontext => Intl.message('DELETE',
      desc: 'Button text to delete an iteam', locale: locale);

  String get deleteGameGame => Intl.message("Delete game", locale: locale);

  String get deleteGamePractice =>
      Intl.message("Delete training", locale: locale);

  String get deleteGameSpecialEvent =>
      Intl.message("Delete special event", locale: locale);

  String get deleteinvite => Intl.message('Delete invite',
      desc: 'Title for the dialog to delete an invite', locale: locale);

  String get deleteinvitebutton => Intl.message('DELETE INVITE',
      desc: 'Title for the dialog to delete an invite', locale: locale);

  String get deletemember => Intl.message('Delete member', locale: locale);

  String get deletemessage =>
      Intl.message("Delete", desc: "Delete message button", locale: locale);

  String get deleteopponent => Intl.message('Delete opponent',
      desc: 'Title to the alert dialog to delete an opponent from the team',
      locale: locale);

  String get deletePlayer => Intl.message("Delete Player",
      desc: "Dialog title for deleting a playern", locale: locale);

  String get deleteplayer {
    return Intl.message('REMOVE FROM TEAM',
        desc: 'Button to change the remove a member from the team',
        locale: locale);
  }

  String get details => Intl.message('Details',
      desc: 'Details fin a stepper for a game or team', locale: locale);

  String get directionsbuttons => Intl.message('DIRECTIONS', locale: locale);

  String get name => Intl.message('Name',
      desc: 'Name for the edit box to edit the user name', locale: locale);

  String get displaynamehint => Intl.message('Your name',
      desc: 'Name for the edit box to edit the user name', locale: locale);

  String get divison => Intl.message('Divison', locale: locale);

  String get doneButton =>
      Intl.message('DONE', desc: 'Done completely button', locale: locale);

  String get duration => Intl.message("Duration", locale: locale);

  String get editbuttontext => Intl.message('EDIT',
      desc: 'The edit text for the dialog', locale: locale);

  String get editGame => Intl.message('Edit Game',
      desc: 'Edit Game help text for button', locale: locale);

  String get editimagebutton => Intl.message('EDIT IMAGE',
      desc: 'Button to edit the image', locale: locale);

  String get editteam => Intl.message('Edit Team',
      desc: 'Edit Team help text for button', locale: locale);

  String get email =>
      Intl.message('Email', desc: 'Email input field', locale: locale);

  String get emailheader => Intl.message("Email Preferences", locale: locale);

  String get emailonupcoming => Intl.message("Upcoming games/events",
      desc: 'Switch text for emailing on upcoming games', locale: locale);

  String get emailonupdates => Intl.message("On changes to games/events",
      desc: 'Switch text for emailing on updates', locale: locale);

  String get emailrequired => Intl.message('Email is empty.',
      desc: 'Message to say they have an empty email field', locale: locale);

  String get emptypassword => Intl.message('Please choose a password.',
      desc: 'Message to say they have an empty password field', locale: locale);

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

  String get loading => Intl.message('Loading...',
      desc: 'Message for loading the app', locale: locale);

  String get loadMore => Intl.message('Load more',
      desc: 'Message to load more messages', locale: locale);

  String get deleteNewsItem => Intl.message('Delete News Item',
      desc: 'Dialog title to delete the news item', locale: locale);

  String get newsItemToDelete =>
      Intl.message('Are you sure you want to delete the news item?',
          desc: 'Dialog text to see if the news item should be deleted',
          locale: locale);

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

  String get description => Intl.message('Description',
      desc:
          'Long description of a tournament/league to display on the league page');

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

  String get needToSelectPlace =>
      Intl.message('Need to select a place', locale: locale);
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

  String get noTeams {
    return Intl.message('No teams');
  }

  String get notFinished => Intl.message("Not finished",
      desc: 'Drop down for the not finished result', locale: locale);

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

  String get penalty => Intl.message('Penalty', locale: locale);

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

  String get seasonhint => Intl.message(
        'Current team season',
        desc: 'Hint for the season text box',
        locale: locale,
      );

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

  String get team => Intl.message(
        'Team',
        desc: 'Title for the team marker',
        locale: locale,
      );

  String get teamdeleted => Intl.message('Team deleted', locale: locale);

  String get teamEditHint => Intl.message('Change team',
      desc: 'Hint for the button to edit the team', locale: locale);

  String get teamNameHint => Intl.message('Team Name',
      desc: 'Hint for the name of the team', locale: locale);

  String get teams => Intl.message('Teams', locale: locale);

  String get teamselect => Intl.message(
        'Select team',
        desc: 'The text for notes for selecting team for the event',
        locale: locale,
      );

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

  String get where =>
      Intl.message('Where', desc: 'Where the game is', locale: locale);

  String get win => Intl.message("Win",
      desc: 'Drop down for  the win result', locale: locale);

  String get youremailHint {
    return Intl.message('Your email address',
        desc: 'Your email input field hint');
  }

  String arrivebefore(int mins) => Intl.message(
        'Arrive ${mins} mins before games',
        args: [mins],
        name: 'arrivebefore',
      );

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
        return cardResultInProgressOvertimeAndPenalty(
            finalScore.score.ptsFor,
            finalScore.score.ptsAgainst,
            overtimeScore.score.ptsFor,
            overtimeScore.score.ptsAgainst,
            penaltyScore.score.ptsFor,
            penaltyScore.score.ptsAgainst);
      }
      return cardResultInProgressOvertime(
          finalScore.score.ptsFor,
          finalScore.score.ptsAgainst,
          overtimeScore.score.ptsFor,
          overtimeScore.score.ptsAgainst);
    }
    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return cardResultInProgressPenalty(
          finalScore.score.ptsFor,
          finalScore.score.ptsAgainst,
          penaltyScore.score.ptsFor,
          penaltyScore.score.ptsAgainst);
    }
    return cardResultInProgressFinal(
        finalScore.score.ptsFor, finalScore.score.ptsAgainst);
  }

  String cardResultInProgressFinal(
    num ptsFor,
    num ptsAgainst,
  ) =>
      Intl.message('$ptsFor - $ptsAgainst',
          desc: 'In progress result details',
          args: [ptsFor, ptsAgainst],
          name: 'cardResultInProgressFinal');

  String cardResultInProgressOvertime(
    num ptsFor,
    num ptsAgainst,
    num overtimeFor,
    num overtimeAgainst,
  ) =>
      Intl.message(
        '$ptsFor - $ptsAgainst '
        '(Overtime $overtimeFor - $overtimeAgainst)',
        desc: 'Win result details with penalty shootout',
        args: [
          ptsFor,
          ptsAgainst,
          overtimeFor,
          overtimeAgainst,
        ],
        name: 'cardResultInProgressOvertime',
        locale: locale,
      );

  String cardResultInProgressOvertimeAndPenalty(
          num ptsFor,
          num ptsAgainst,
          num overtimeFor,
          num overtimeAgainst,
          num penaltyFor,
          num penaltyAgainst) =>
      Intl.message(
        '$ptsFor - $ptsAgainst '
        '(Overtime $overtimeFor - $overtimeAgainst)'
        '(Penalty $penaltyFor - $penaltyAgainst)',
        desc: 'Win result details with penalty shootout',
        args: [
          ptsFor,
          ptsAgainst,
          overtimeFor,
          overtimeAgainst,
          penaltyFor,
          penaltyAgainst
        ],
        name: 'cardResultInProgressOvertimeAndPenalty',
        locale: locale,
      );

  String cardResultInProgressPenalty(
          num ptsFor, num ptsAgainst, num penaltyFor, num penaltyAgainst) =>
      Intl.message(
          '$ptsFor - $ptsAgainst (Penalty $penaltyFor - $penaltyAgainst)',
          desc: 'In progress result details with penalty shootout',
          args: [ptsFor, ptsAgainst, penaltyFor, penaltyAgainst],
          name: 'cardResultInProgressPenalty',
          locale: locale);

  String confirmCreateTeamForLeague(
          String teamName, String season, String league) =>
      Intl.message(
          'Are you sure you want to create a team $teamName with a season of $season '
          'for the league $league.  This is not possible to undo?',
          args: [teamName, season, league],
          name: 'confirmCreateTeamForLeague',
          locale: locale);

  String confirmdelete(Invite invite) {
    if (invite is InviteToPlayer) {
      InviteToPlayer invitePlayer = invite;
      return confirmDeleteInvitePlayer(invitePlayer.playerName);
    }
    if (invite is InviteAsAdmin) {
      InviteAsAdmin inviteAdmin = invite;
      return confirmDeleteAsAdmin(inviteAdmin.teamName);
    }
    if (invite is InviteToClub) {
      InviteToClub inviteClub = invite;
      return confirmDeleteClub(inviteClub.clubName);
    }
    if (invite is InviteToLeagueAsAdmin) {
      InviteToLeagueAsAdmin inviteLeague = invite;
      return confirmDeleteLeagueAsAdmin(inviteLeague.leagueName);
    }
    if (invite is InviteToLeagueTeam) {
      InviteToLeagueTeam inviteLeagueTeam = invite;
      return confirmDeleteLeagueTeam(
          inviteLeagueTeam.leagueName, inviteLeagueTeam.leagueTeamName);
    }
    return unknown;
  }

  String confirmDeleteAsAdmin(String teamName) => Intl.message(
      'Do you want to delete the invite to be admin for the team $teamName?',
      desc: 'Text to delete the invite to be an admin in the alert dialog.',
      args: [teamName],
      name: 'confirmDeleteAsAdmin',
      locale: locale);

  String confirmDeleteClub(String clubName) => Intl.message(
      'Do you want to delete the invite to be in the club $clubName?',
      desc: 'Text to delete the invite to the club in the alert dialog.',
      args: [clubName],
      name: 'confirmDeleteClub',
      locale: locale);

  String confirmDeleteInvitePlayer(String playerName) =>
      Intl.message('Do you want to delete the invite to follow $playerName?',
          desc: 'Text to delete the invite to the team in the alert dialog.',
          args: [playerName],
          name: 'confirmDeleteInvitePlayer',
          locale: locale);

  String confirmDeleteInviteTeam(String teamName, String playerName) =>
      Intl.message(
          'Do you want to delete the invite to $teamName for $playerName?',
          desc: 'Text to delete the invite to the team in the alert dialog.',
          args: [teamName, playerName],
          locale: locale,
          name: 'confirmDeleteInviteTeam');

  String confirmDeleteLeagueAsAdmin(String leagueName) => Intl.message(
      'Do you want to delete the invite to be in the league $leagueName?',
      desc: 'Text to delete the invite to the league in the alert dialog.',
      args: [leagueName],
      locale: locale,
      name: 'confirmDeleteLeagueAsAdmin');

  String confirmDeleteLeagueTeam(String leagueName, String leagueTeamName) =>
      Intl.message(
          'Do you want to delete the invite to be in the league $leagueName with team '
          '$leagueTeamName?',
          args: [leagueName, leagueTeamName],
          name: 'confirmDeleteLeagueTeam',
          locale: locale);

  String confirmDeleteMember(String displayName) =>
      Intl.message('Delete club member $displayName?',
          args: [displayName], locale: locale, name: 'confirmDeleteMember');

  String confirmDeletePlayer(Player player) =>
      confirmDeletePlayerBreakout(player.name);
  String confirmDeletePlayerBreakout(String playerName) =>
      Intl.message("Do you want to delete your connection to $playerName?",
          desc: 'Text to confirm asking if the players wants to be delete',
          args: [playerName],
          name: 'confirmDeletePlayerBreakout',
          locale: locale);

  String confirmRemoveFromTeam(String name) =>
      Intl.message('Are you sure you want to remove $name from the team?',
          desc: 'Dialog text to confirm removing a user from the team',
          args: [name],
          locale: locale,
          name: 'confirmRemoveFromTeam');

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

  String displayNameRelationship(String name, Relationship relationship) {
    String rel = relationships(relationship);
    return displayNameRelationshipBreakout(name, rel);
  }

  String displayNameRelationshipBreakout(String name, String rel) =>
      Intl.message('$name ($rel)',
          desc: 'Name for the edit box to edit the user name',
          args: [name, rel],
          name: 'displayNameRelationshipBreakout',
          locale: locale);

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
          desc: 'Special event title in game list',
          args: [time],
          locale: locale,
          name: 'eventTitleNowSpecialEvent');

  String eventTitleNowSpecialEventName(String name, String time) =>
      Intl.message("NOW! $name $time",
          desc: 'Special event title in game list',
          args: [name, time],
          locale: locale,
          name: 'eventTitleNowSpecialEventName');

  String eventTitleNowSpecialEventNameEndTime(
          String name, String time, String endTime) =>
      Intl.message('NOW! $name $time - $endTime',
          desc: 'Special event title in game list',
          args: [name, time, endTime],
          locale: locale,
          name: 'eventTitleNowSpecialEventNameEndTime');

  String eventTitleNowSpecialEventNameEndTimeTimeZone(
          String name, String time, String endTime, String tzShortName) =>
      Intl.message('NOW! $name $time - $endTime  ($tzShortName)',
          desc: 'Special event title in game list',
          args: [name, time, endTime, tzShortName],
          locale: locale,
          name: 'eventTitleNowSpecialEventNameEndTimeTimeZone');

  String eventTitleNowSpecialEventNameTimeZone(
          String name, String time, String tzShortName) =>
      Intl.message('NOW! $name $time ($tzShortName)',
          desc: 'Special event title in game list',
          args: [name, time, tzShortName],
          locale: locale,
          name: 'eventTitleNowSpecialEventNameTimeZone');

  String eventTitleNowSpecialEventStartAndEnd(String time, String endTime) =>
      Intl.message('NOW! Event $time - $endTime',
          desc: 'Special event title in game list',
          locale: locale,
          args: [time, endTime],
          name: 'eventTitleNowSpecialEventStartAndEnd');

  String eventTitleNowSpecialEventStartAndEndTimezone(
          String time, String endTime, String tzShortName) =>
      Intl.message('NOW! Event $time - $endTime ($tzShortName)',
          desc: 'Special event title in game list',
          args: [time, endTime, tzShortName],
          locale: locale,
          name: 'eventTitleNowSpecialEventStartAndEndTimezone');

  String eventTitleNowSpecialWithTimezone(String time, String tzShortName) =>
      Intl.message('NOW! Event $time ($tzShortName)',
          desc: 'Special event title in game list with timezone',
          args: [time, tzShortName],
          locale: locale,
          name: 'eventTitleNowSpecialWithTimezone');

  String eventTitleSpecialEvent(String time) => Intl.message('Event $time',
      desc: 'Special event title in game list',
      args: [time],
      locale: locale,
      name: 'eventTitleSpecialEvent');

  String eventTitleSpecialEventName(String name, String time) =>
      Intl.message("$name $time",
          desc: 'Special event title in game list',
          args: [name, time],
          locale: locale,
          name: 'eventTitleSpecialEventName');

  String eventTitleSpecialEventNameEndTime(
          String name, String time, String endTime) =>
      Intl.message('$name $time - $endTime',
          desc: 'Special event title in game list',
          args: [name, time, endTime],
          locale: locale,
          name: 'eventTitleSpecialEventNameEndTime');

  String eventTitleSpecialEventNameEndTimeTimeZone(
          String name, String time, String endTime, String tzShortName) =>
      Intl.message('$name $time - $endTime  ($tzShortName)',
          desc: 'Special event title in game list',
          args: [name, time, endTime, tzShortName],
          locale: locale,
          name: 'eventTitleSpecialEventNameEndTimeTimeZone');

  String eventTitleSpecialEventNameTimeZone(
          String name, String time, String tzShortName) =>
      Intl.message('$name $time ($tzShortName)',
          desc: 'Special event title in game list',
          args: [
            name,
            time,
            tzShortName,
          ],
          locale: locale,
          name: 'eventTitleSpecialEventNameTimeZone');

  String eventTitleSpecialEventStartAndEnd(String time, String endTime) =>
      Intl.message('Event $time - $endTime',
          desc: 'Special event title in game list',
          args: [
            time,
            endTime,
          ],
          locale: locale,
          name: 'eventTitleSpecialEventStartAndEnd');

  String eventTitleSpecialEventStartAndEndTimezone(
          String time, String endTime, String tzShortName) =>
      Intl.message('Event $time - $endTime ($tzShortName)',
          desc: 'Special event title in game list',
          args: [time, endTime, tzShortName],
          locale: locale,
          name: 'eventTitleSpecialEventStartAndEndTimezone');

  String eventTitleSpecialWithTimezone(String time, String tzShortName) =>
      Intl.message('Event $time ($tzShortName)',
          desc: 'Special event title in game list with timezone',
          args: [time, tzShortName],
          locale: locale,
          name: 'eventTitleSpecialWithTimezone');

  String finalOfficalScoreBody(GameOfficialResults result) {
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

        return finalOfficalScoreBodyOvertimePenalty(
            resultString,
            regulationPeriodResult.score.ptsFor,
            regulationPeriodResult.score.ptsAgainst,
            overtimePeriodResult.score.ptsFor,
            overtimePeriodResult.score.ptsAgainst,
            penaltyPeriodResult.score.ptsFor,
            penaltyPeriodResult.score.ptsAgainst);
      }

      return finalOfficalScoreBodyOvertime(
          resultString,
          regulationPeriodResult.score.ptsFor,
          regulationPeriodResult.score.ptsAgainst,
          overtimePeriodResult.score.ptsFor,
          overtimePeriodResult.score.ptsAgainst);
    }
    if (result.scores.containsKey(penaltyPeriod)) {
      GameResultPerPeriod penaltyPeriodResult = result.scores[penaltyPeriod];
      return finalOfficalScoreBodyPenalty(
          resultString,
          regulationPeriodResult.score.ptsFor,
          regulationPeriodResult.score.ptsAgainst,
          penaltyPeriodResult.score.ptsFor,
          penaltyPeriodResult.score.ptsAgainst);
    }
    return gameResultOffical(resultString, regulationPeriodResult);
  }

  String finalOfficalScoreBodyOvertimePenalty(
          String resultString,
          num homeFor,
          num homeAgainst,
          num overtimeFor,
          num overtimeAgainst,
          num penaltyFor,
          num penaltyAgainst) =>
      Intl.message(
          "$resultString\nHome: $homeFor "
          "Away: $homeAgainst\n"
          "Overtime Home: $overtimeFor "
          "Away: $overtimeAgainst"
          "Penalty Home: $penaltyFor "
          "Away: $penaltyAgainst",
          args: [
            resultString,
            homeFor,
            homeAgainst,
            overtimeFor,
            overtimeAgainst,
            penaltyFor,
            penaltyAgainst
          ],
          name: 'finalOfficalScoreBodyOvertimePenalty',
          locale: locale);

  String finalOfficalScoreBodyOvertime(String resultString, num homeFor,
          num homeAgainst, num overtimeFor, num overtimeAgainst) =>
      Intl.message(
          "$resultString\nHome: $homeFor "
          "Away: $homeAgainst\n"
          "Overtime Home: $overtimeFor "
          "Away: $overtimeAgainst",
          args: [
            resultString,
            homeFor,
            homeAgainst,
            overtimeFor,
            overtimeAgainst,
          ],
          name: 'finalOfficalScoreBodyOvertime',
          locale: locale);

  String finalOfficalScoreBodyPenalty(String resultString, num homeFor,
          num homeAgainst, num penaltyFor, num penaltyAgainst) =>
      Intl.message(
          "$resultString\nHome: $homeFor "
          "Away: $homeAgainst\n"
          "Penalty Home: $penaltyFor "
          "Away: $penaltyAgainst",
          args: [
            resultString,
            homeFor,
            homeAgainst,
            penaltyFor,
            penaltyAgainst
          ],
          name: 'finalOfficalScoreBodyPenalty',
          locale: locale);

  String finalScoreBody(num ptsFor, num ptsAgainst, String result) {
    return Intl.message(
        'Do you want to set $ptsFor $ptsAgainst $result as the final score?',
        desc: 'Start game dialofg body text',
        args: [
          ptsFor,
          ptsAgainst,
          result,
        ],
        name: 'finalScoreBody',
        locale: locale);
  }

  String fixScore(GameLog log) =>
      fixScoreBreakout(log.score.ptsFor, log.score.ptsAgainst);
  String fixScoreBreakout(num ptsFor, num ptsAgainst) =>
      Intl.message("Fix score: $ptsFor - $ptsAgainst",
          args: [ptsFor, ptsAgainst], name: 'fixScoreBreakout', locale: locale);

  String followPlayer(String player) => Intl.message("Follow $player",
      args: [player], name: 'followPlayer', locale: locale);

  String gameAddressArriveAt(String arriveAt, String address) =>
      Intl.message('Arrive by $arriveAt\n$address',
          desc: 'Game address in game list with arrive by',
          args: [arriveAt, address],
          name: 'gameAddressArriveAt',
          locale: locale);

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
        return tie;
    }
    return unknown;
  }

  String gameresult(GameResult result) {
    switch (result) {
      case GameResult.Unknown:
        return unknown;
      case GameResult.Win:
        return win;
      case GameResult.Tie:
        return tie;
      case GameResult.Loss:
        return loss;
    }
    return unknown;
  }

  String gameResultOffical(
          String resultString, GameResultPerPeriod regulationPeriodResult) =>
      gameResultOfficalBreakout(
          resultString,
          regulationPeriodResult.score.ptsFor,
          regulationPeriodResult.score.ptsAgainst);
  String gameResultOfficalBreakout(
          String resultString, num ptsFor, num ptsAgainst) =>
      Intl.message(
          "$resultString\nHome: $ptsFor "
          "Away: $ptsAgainst",
          args: [resultString, ptsFor, ptsAgainst],
          locale: locale,
          name: 'gameResultOfficalBreakout');

  String gametitle(
      String time, String endTime, String tzShortName, String opponent) {
    if (endTime != null) {
      if (tzShortName != null) {
        return gameTitleSharedEndShort(time, endTime, tzShortName);
      }
      return gameTitleSharedEnd(time, endTime);
    }
    if (tzShortName != null) {
      return gameTitleSharedEnd(time, tzShortName);
    }
    return gameTitleSharedTime(time);
  }

  String gameTitleSharedEndShort(
          String time, String endTime, String tzShortName) =>
      Intl.message('$time - $endTime ($tzShortName)',
          desc: 'Game title in game list',
          locale: locale,
          args: [time, endTime, tzShortName],
          name: 'gameTitleSharedEndShort');
  String gameTitleSharedEnd(String time, String endTime) =>
      Intl.message('$time - $endTime',
          desc: 'Game title in game list',
          locale: locale,
          args: [time, endTime],
          name: 'gameTitleSharedEnd');
  String gameTitleSharedShort(String time, String tzShortName) =>
      Intl.message('$time ($tzShortName)',
          desc: 'Game title in game list',
          locale: locale,
          args: [time, tzShortName],
          name: 'gameTitleSharedShort');
  String gameTitleSharedTime(String time) => Intl.message('$time',
      desc: 'Game title in game list',
      locale: locale,
      args: [time],
      name: 'gameTitleSharedTime');

  String gameTitleNow(
      String time, String endTime, String tzShortName, String opponent) {
    if (endTime != null) {
      if (tzShortName != null) {
        return gameTitleNowSharedEndShort(time, endTime, tzShortName);
      }
      return gameTitleNowSharedEnd(time, endTime);
    }
    if (tzShortName != null) {
      return gameTitleNowSharedEnd(time, tzShortName);
    }
    return gameTitleNowSharedTime(time);
  }

  String gameTitleNowSharedEndShort(
          String time, String endTime, String tzShortName) =>
      Intl.message('NOW! $time - $endTime ($tzShortName)',
          desc: 'Game title in game list',
          locale: locale,
          args: [time, endTime, tzShortName],
          name: 'gameTitleNowSharedEndShort');
  String gameTitleNowSharedEnd(String time, String endTime) =>
      Intl.message('NOW! $time - $endTime',
          desc: 'Game title in game list',
          locale: locale,
          args: [time, endTime],
          name: 'gameTitleNowSharedEnd');
  String gameTitleNowSharedShort(String time, String tzShortName) =>
      Intl.message('NOW! $time ($tzShortName)',
          desc: 'Game title in game list',
          locale: locale,
          args: [time, tzShortName],
          name: 'gameTitleNowSharedShort');
  String gameTitleNowSharedTime(String time) => Intl.message('NOW! $time',
      desc: 'Game title in game list',
      locale: locale,
      args: [time],
      name: 'gameTitleNowSharedTime');

  String gameTitleShared(String time, String endTime, String tzShortName) {
    if (endTime != null) {
      if (tzShortName != null) {
        return gameTitleSharedEndShort(time, endTime, tzShortName);
      }
      return gameTitleSharedEnd(time, endTime);
    }
    if (tzShortName != null) {
      return gameTitleSharedEnd(time, tzShortName);
    }
    return gameTitleSharedTime(time);
  }

  String gameTitleVs(GameSharedData game, String oppponent) {
    switch (game.type) {
      case EventType.Game:
        return gameTitleVsGame(opponent);
      case EventType.Event:
        return gameTitleVsEvent;
      case EventType.Practice:
        return gameTitleVsPractice;
    }
    return unknown;
  }

  String gameTitleVsGame(String opponent) => Intl.message('Game vs $opponent',
      desc: 'Game details title for the screen',
      args: [opponent],
      name: 'gameTitleVsGame',
      locale: locale);

  String get gameTitleVsEvent => Intl.message('Event',
      desc: 'Event details title for the screen', locale: locale);

  String get gameTitleVsPractice => Intl.message('Practice',
      desc: 'Practice details title for the screen', locale: locale);

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
        return penalty;
      case GamePeriodType.Break:
        return periodNameBreak;
      case GamePeriodType.OvertimeBreak:
        return periodNameOvertimeBreak;
    }
    return unknown;
  }

  String invitedBy(String by) => Intl.message('By $by',
      desc: 'Who did the invite to this team/player',
      args: [by],
      name: 'invitedBy',
      locale: locale);

  String get invitedToTeam => Intl.message('Invited to team',
      desc: 'The user that is invited to the team', locale: locale);

  String invitedToTeamWithName(String name) => Intl.message('$name (Invited)',
      desc: 'Player name with the invited tag',
      args: [name],
      name: 'invitedToTeamWithName',
      locale: locale);

  String invitedPeople(int num) => Intl.message("Invited: $num",
      args: [num], locale: locale, name: 'invitedPeople');

  String madeEventType(int points) => Intl.message(
        "$points",
        args: [points],
        desc: "+num points",
        locale: locale,
        name: 'madeEventType',
      );

  String missedEventType(int points) => Intl.message(
        "Miss $points",
        args: [points],
        desc: "missed num points",
        name: 'missedEventType',
        locale: locale,
      );

  String nameAndTeam(String teamName, String playerName) {
    return Intl.message("$teamName $playerName",
        desc: "Format for name and player for the team",
        args: [teamName, playerName],
        name: 'nameAndTeam',
        locale: locale);
  }

  String numberOfTeamsForPlayer(int num) => Intl.plural(num,
      zero: "No teams",
      one: "One team",
      other: "$num teams",
      desc: "Number of teams associated with this player",
      args: [num],
      name: 'numberOfTeamsForPlayer',
      locale: locale);

  String numberOfUserForPlayer(int num) => Intl.plural(num,
      one: "One user",
      other: "$num users",
      desc: "Number of user associated with this player",
      args: [num],
      name: 'numberOfUserForPlayer',
      locale: locale);

  String onlyScore(GameScore score) =>
      onlyScoreBreakout(score.ptsFor, score.ptsAgainst);

  String onlyScoreBreakout(num ptsFor, num ptsAgainst) =>
      Intl.message("$ptsFor - $ptsAgainst",
          args: [ptsFor, ptsAgainst], name: 'onlyScoreBreakout');

  String opponentSeason(String opponentName, String seasonName) =>
      Intl.message("$opponentName - $seasonName",
          desc: "Shows the opponent and season",
          args: [opponentName, seasonName],
          name: 'opponentSeason');

  String opponentwinrecord(
      Opponent opponent, String seasonUid, String seasonName) {
    WinRecord rec = opponent.record[seasonUid];
    if (rec == null) {
      rec = WinRecord((b) => b
        ..loss = 0
        ..win = 0
        ..tie = 0);
    }
    return opponentWinRecordBreakout(rec.win, rec.loss, rec.tie);
  }

  String opponentWinRecordBreakout(num win, num loss, num tie) =>
      Intl.message('Win: ${win} Loss: ${loss} Tie: ${tie}',
          desc: 'Win record for an opponent for this season',
          args: [win, loss, tie],
          name: 'opponentWinRecordBreakout');

  String pendingInvites(int num) => Intl.message('Pending Invites: $num',
      desc: 'Header showing the number of pending invites',
      args: [num],
      name: 'pendingInvites');

  String periodEnd(String periodName) => Intl.message(
        "End of $periodName",
        args: [periodName],
        desc: "End of period",
        name: 'periodEnd',
        locale: locale,
      );

  String periodName(GamePeriod period) {
    switch (period.type) {
      case GamePeriodType.Regulation:
        if (period.periodNumber > 0) {
          return periodNameRegulationNumber(period.periodNumber);
        }
        return periodNameRegulation;
      case GamePeriodType.Break:
        return periodNameBreak;
      case GamePeriodType.OvertimeBreak:
        return periodNameOvertimeBreak;
      case GamePeriodType.Overtime:
        if (period.periodNumber > 0) {
          return periodNameOvertimeNumber(period.periodNumber);
        }
        return periodNameOvertime;
      case GamePeriodType.Penalty:
        return penalty;
    }
    return unknown;
  }

  String get periodNameRegulation => Intl.message("Regulation",
      locale: locale, desc: 'Header for the regulation period');
  String periodNameRegulationNumber(num periodNumber) =>
      Intl.message("Regulation $periodNumber",
          args: [periodNumber],
          name: 'periodNameRegulationNumber',
          locale: locale,
          desc: 'Header for the regulation period with number');
  String get periodNameOvertime => Intl.message("Overtime",
      locale: locale, desc: 'Header for the overtime period');
  String periodNameOvertimeNumber(num periodNumber) =>
      Intl.message("Overtime $periodNumber",
          args: [periodNumber],
          name: 'periodNameOvertimeNumber',
          locale: locale,
          desc: 'Header for the overtime period with number');

  String periodstart(GameLog period) {
    switch (period.period.type) {
      case GamePeriodType.Regulation:
        return periodStartRegulation(period);
      case GamePeriodType.OvertimeBreak:
        return periodStartOvertimeBreak(period);
      case GamePeriodType.Break:
        return periodStartBreak(period);
      case GamePeriodType.Overtime:
        return periodStartOvertime(period);
      case GamePeriodType.Penalty:
        return periodStartPenalty(period);
    }
    return unknown;
  }

  String periodStartRegulation(GameLog period) => periodStartRegulationBreakout(
        period.period.periodNumber,
        period.score.ptsFor,
        period.score.ptsAgainst,
      );
  String periodStartRegulationBreakout(
          num periodNumber, num ptsFor, num ptsAgainst) =>
      Intl.message("Start period $periodNumber Score: $ptsFor - $ptsAgainst",
          args: [periodNumber, ptsFor, ptsAgainst],
          name: 'periodStartRegulationBreakout');

  String periodStartPenalty(GameLog period) => periodStartPenaltyBreakout(
        period.score.ptsFor,
        period.score.ptsAgainst,
      );
  String periodStartPenaltyBreakout(num ptsFor, num ptsAgainst) =>
      Intl.message("Start penalty Score: $ptsFor - $ptsAgainst",
          args: [ptsFor, ptsAgainst], name: 'periodStartPenaltyBreakout');

  String periodStartOvertime(GameLog period) => periodStartOvertimeBreakout(
      period.period.periodNumber, period.score.ptsFor, period.score.ptsAgainst);
  String periodStartOvertimeBreakout(
          num periodNumber, num ptsFor, num ptsAgainst) =>
      Intl.message("Start overtime $periodNumber Score: $ptsFor - $ptsAgainst",
          args: [periodNumber, ptsFor, ptsAgainst],
          name: 'periodStartOvertimeBreakout');

  String periodStartBreak(GameLog period) =>
      periodStartBreakBreakout(period.score.ptsFor, period.score.ptsAgainst);
  String periodStartBreakBreakout(num ptsFor, num ptsAgainst) =>
      Intl.message("Start break Score: $ptsFor - $ptsAgainst",
          args: [ptsFor, ptsAgainst], name: 'periodStartBreakBreakout');

  String periodStartOvertimeBreak(GameLog period) =>
      periodStartOvertimeBreakBreakout(
          period.score.ptsFor, period.score.ptsAgainst);
  String periodStartOvertimeBreakBreakout(num ptsFor, num ptsAgainst) =>
      Intl.message("Start overtime break Score: $ptsFor - $ptsAgainst",
          args: [ptsFor, ptsAgainst], name: 'periodStartOvertimeBreakBreakout');

  String periodStart(String periodName) => Intl.message(
        "Start of $periodName",
        args: [periodName],
        name: 'periodStart',
        desc: "Start of period",
        locale: locale,
      );

  String periodstop(GameLog period) {
    switch (period.period.type) {
      case GamePeriodType.Regulation:
        return periodStopRegulation(period);
      case GamePeriodType.Break:
        return periodStopBreak(period);
      case GamePeriodType.OvertimeBreak:
        return periodStopOvertimeBreak(period);
      case GamePeriodType.Overtime:
        return periodStopOvertime(period);
      case GamePeriodType.Penalty:
        return periodStopPenalty(period);
    }
    return unknown;
  }

  String get searching => Intl.message("Searching...",
      desc:
          'The searching text in the search box when the search is inprogress.',
      locale: locale);

  String periodStopRegulation(GameLog period) => periodStopRegulationBreakout(
      period.period.periodNumber, period.score.ptsFor, period.score.ptsAgainst);

  String periodStopRegulationBreakout(
          num periodNumber, num ptsFor, num ptsAgainst) =>
      Intl.message("Stop period $periodNumber Score: $ptsFor - $ptsAgainst",
          desc: 'the stop for the regulation perod in the logs',
          args: [periodNumber, ptsFor, ptsAgainst],
          name: 'periodStopRegulationBreakout');

  String periodStopBreak(GameLog period) =>
      periodStopBreakBreakout(period.score.ptsFor, period.score.ptsAgainst);

  String periodStopBreakBreakout(num ptsFor, num ptsAgainst) =>
      Intl.message("Stop break Score: $ptsFor - $ptsAgainst",
          desc: 'the stop for the regulation break in the logs',
          args: [ptsFor, ptsAgainst],
          name: 'periodStopBreakBreakout');

  String periodStopOvertimeBreak(GameLog period) =>
      periodStopOvertimeBreakBreakout(
          period.score.ptsFor, period.score.ptsAgainst);

  String periodStopOvertimeBreakBreakout(num ptsFor, num ptsAgainst) =>
      Intl.message("Stop overttime break Score: $ptsFor - $ptsAgainst",
          desc: 'the stop for the overtime break in the logs',
          args: [ptsFor, ptsAgainst],
          name: 'periodStopOvertimeBreakBreakout');

  String periodStopOvertime(GameLog period) => periodStopOvertimeBreakout(
      period.period.periodNumber, period.score.ptsFor, period.score.ptsAgainst);

  String periodStopOvertimeBreakout(
          num periodNumber, num ptsFor, num ptsAgainst) =>
      Intl.message("Stop overttime $periodNumber Score: $ptsFor - $ptsAgainst",
          desc: 'the stop for the overtime  in the logs',
          args: [periodNumber, ptsFor, ptsAgainst],
          name: 'periodStopOvertimeBreakout');

  String periodStopPenalty(GameLog period) =>
      periodStopPenaltyBreakout(period.score.ptsFor, period.score.ptsAgainst);

  String periodStopPenaltyBreakout(num ptsFor, num ptsAgainst) =>
      Intl.message("Stop penalty Score: $ptsFor - $ptsAgainst",
          desc: 'the stop for the penalty period in the logs',
          args: [ptsFor, ptsAgainst],
          name: 'periodStopPenaltyBreakout');

  String playerInviteDesc(String name) => Intl.message(
      'This will follow $name and allow you to see which games they are in and '
      'all the teams they are in.  Please setup your relationship with the '
      'player and save.',
      desc: 'Long description of the player invite accept path.',
      locale: locale,
      name: "playerInviteDesc",
      args: [name]);

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

  String resultInProgress(GameResultSharedDetails result) {
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
        return resultInProgressOvertimePenalty(
            finalScore.score.ptsFor,
            finalScore.score.ptsAgainst,
            overtimeScore.score.ptsFor,
            overtimeScore.score.ptsAgainst,
            penaltyScore.score.ptsFor,
            penaltyScore.score.ptsAgainst);
      }
      return resultInProgressOvertime(
          finalScore.score.ptsFor,
          finalScore.score.ptsAgainst,
          overtimeScore.score.ptsFor,
          overtimeScore.score.ptsAgainst);
    }

    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return resultInProgressPenalty(
          finalScore.score.ptsFor,
          finalScore.score.ptsAgainst,
          penaltyScore.score.ptsFor,
          penaltyScore.score.ptsAgainst);
    }
    return resultInProgressRegulation(
        finalScore.score.ptsFor, finalScore.score.ptsAgainst);
  }

  String resultInProgressOvertimePenalty(
          num ptsFor,
          num ptsAgainst,
          num overtimeFor,
          num overtimeAgainst,
          num penaltyFor,
          num penaltyAgainst) =>
      Intl.message(
          'Playing ${ptsFor} - ${ptsAgainst} '
          '(Overtime ${overtimeFor} - ${overtimeAgainst})'
          '(Penalty ${penaltyFor} - ${penaltyAgainst})',
          args: [
            ptsFor,
            ptsAgainst,
            overtimeFor,
            overtimeAgainst,
            penaltyFor,
            penaltyAgainst
          ],
          name: 'resultInProgressOvertimePenalty',
          desc: 'InProgress result details with penalty shootout');

  String resultInProgressOvertime(
          num ptsFor, num ptsAgainst, num overtimeFor, num overtimeAgainst) =>
      Intl.message(
          'Playing ${ptsFor} - ${ptsAgainst} '
          '(Overtime ${overtimeFor} - ${overtimeAgainst})',
          args: [ptsFor, ptsAgainst, overtimeFor, overtimeAgainst],
          name: 'resultInProgressOvertime',
          desc: 'InProgress result details in overtime');

  String resultInProgressPenalty(
          num ptsFor, num ptsAgainst, num penaltyFor, num penaltyAgainst) =>
      Intl.message(
          'Playing ${ptsFor} - ${ptsAgainst} (Penalty ${penaltyFor} - ${penaltyAgainst})',
          args: [ptsFor, ptsAgainst, penaltyFor, penaltyAgainst],
          name: 'resultInProgressPenalty',
          desc: 'InProgress result details with penalty shootout');

  String resultInProgressRegulation(num ptsFor, num ptsAgainst) =>
      Intl.message('Playing $ptsFor - $ptsAgainst',
          args: [ptsFor, ptsAgainst],
          name: 'resultInProgressRegulation',
          desc: 'InProgress result details');

  String resultLoss(GameResultSharedDetails result) {
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
        return resultLossOvertimePenalty(
            finalScore.score.ptsFor,
            finalScore.score.ptsAgainst,
            overtimeScore.score.ptsFor,
            overtimeScore.score.ptsAgainst,
            penaltyScore.score.ptsFor,
            penaltyScore.score.ptsAgainst);
      }
      return resultLossOvertime(
          finalScore.score.ptsFor,
          finalScore.score.ptsAgainst,
          overtimeScore.score.ptsFor,
          overtimeScore.score.ptsAgainst);
    }

    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return resultLossPenalty(
          finalScore.score.ptsFor,
          finalScore.score.ptsAgainst,
          penaltyScore.score.ptsFor,
          penaltyScore.score.ptsAgainst);
    }
    return resultLossRegulation(
        finalScore.score.ptsFor, finalScore.score.ptsAgainst);
  }

  String resultLossOvertimePenalty(num ptsFor, num ptsAgainst, num overtimeFor,
          num overtimeAgainst, num penaltyFor, num penaltyAgainst) =>
      Intl.message(
          'Loss ${ptsFor} - ${ptsAgainst} '
          '(Overtime ${overtimeFor} - ${overtimeAgainst})'
          '(Penalty ${penaltyFor} - ${penaltyAgainst})',
          args: [
            ptsFor,
            ptsAgainst,
            overtimeFor,
            overtimeAgainst,
            penaltyFor,
            penaltyAgainst
          ],
          name: 'resultLossOvertimePenalty',
          desc: 'Loss result details with penalty shootout');

  String resultLossOvertime(
          num ptsFor, num ptsAgainst, num overtimeFor, num overtimeAgainst) =>
      Intl.message(
          'Loss $ptsFor - $ptsAgainst '
          '(Overtime $overtimeFor - $overtimeAgainst)',
          args: [ptsFor, ptsAgainst, overtimeFor, overtimeAgainst],
          name: 'resultLossOvertime',
          desc: 'Loss result details in overtime');

  String resultLossPenalty(
          num ptsFor, num ptsAgainst, num penaltyFor, num penaltyAgainst) =>
      Intl.message(
          'Loss $ptsFor - $ptsAgainst (Penalty $penaltyFor - $penaltyAgainst)',
          args: [ptsFor, ptsAgainst, penaltyFor, penaltyAgainst],
          name: 'resultLossPenalty',
          desc: 'Loss result details with penalty shootout');

  String resultLossRegulation(num ptsFor, num ptsAgainst) =>
      Intl.message('Loss $ptsFor - $ptsAgainst',
          args: [ptsFor, ptsAgainst],
          name: 'resultLossRegulation',
          desc: 'Loss result details');

  String resultTie(GameResultSharedDetails result) {
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
        return resultTieOvertimePenalty(
            finalScore.score.ptsFor,
            finalScore.score.ptsAgainst,
            overtimeScore.score.ptsFor,
            overtimeScore.score.ptsAgainst,
            penaltyScore.score.ptsFor,
            penaltyScore.score.ptsAgainst);
      }
      return resultTieOvertime(
          finalScore.score.ptsFor,
          finalScore.score.ptsAgainst,
          overtimeScore.score.ptsFor,
          overtimeScore.score.ptsAgainst);
    }

    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return resultTiePenalty(
          finalScore.score.ptsFor,
          finalScore.score.ptsAgainst,
          penaltyScore.score.ptsFor,
          penaltyScore.score.ptsAgainst);
    }
    return resultTieRegulation(
        finalScore.score.ptsFor, finalScore.score.ptsAgainst);
  }

  String resultTieOvertimePenalty(num ptsFor, num ptsAgainst, num overtimeFor,
          num overtimeAgainst, num penaltyFor, num penaltyAgainst) =>
      Intl.message(
          'Tie ${ptsFor} - ${ptsAgainst} '
          '(Overtime ${overtimeFor} - ${overtimeAgainst})'
          '(Penalty ${penaltyFor} - ${penaltyAgainst})',
          args: [
            ptsFor,
            ptsAgainst,
            overtimeFor,
            overtimeAgainst,
            penaltyFor,
            penaltyAgainst
          ],
          name: 'resultTieOvertimePenalty',
          desc: 'Tie result details with penalty shootout');

  String resultTieOvertime(
          num ptsFor, num ptsAgainst, num overtimeFor, num overtimeAgainst) =>
      Intl.message(
          'Tie ${ptsFor} - ${ptsAgainst} '
          '(Overtime ${overtimeFor} - ${overtimeAgainst})',
          args: [ptsFor, ptsAgainst, overtimeFor, overtimeAgainst],
          name: 'resultTieOvertime',
          desc: 'Tie result details in overtime');

  String resultTiePenalty(
          num ptsFor, num ptsAgainst, num penaltyFor, num penaltyAgainst) =>
      Intl.message(
          'Tie ${ptsFor} - ${ptsAgainst} (Penalty ${penaltyFor} - ${penaltyAgainst})',
          args: [ptsFor, ptsAgainst, penaltyFor, penaltyAgainst],
          name: 'resultTiePenalty',
          desc: 'Tie result details with penalty shootout');

  String resultTieRegulation(num ptsFor, num ptsAgainst) =>
      Intl.message('Tie $ptsFor - $ptsAgainst',
          args: [ptsFor, ptsAgainst],
          name: 'resultTieRegulation',
          desc: 'Tie result details');

  String resultWin(GameResultSharedDetails result) {
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
        return resultWinOvertimePenalty(
            finalScore.score.ptsFor,
            finalScore.score.ptsAgainst,
            overtimeScore.score.ptsFor,
            overtimeScore.score.ptsAgainst,
            penaltyScore.score.ptsFor,
            penaltyScore.score.ptsAgainst);
      }
      return resultWinOvertime(
          finalScore.score.ptsFor,
          finalScore.score.ptsAgainst,
          overtimeScore.score.ptsFor,
          overtimeScore.score.ptsAgainst);
    }

    if (result.penaltyResult != null) {
      GameResultPerPeriod penaltyScore = result.penaltyResult;
      return resultWinPenalty(
          finalScore.score.ptsFor,
          finalScore.score.ptsAgainst,
          penaltyScore.score.ptsFor,
          penaltyScore.score.ptsAgainst);
    }
    return resultWinRegulation(
        finalScore.score.ptsFor, finalScore.score.ptsAgainst);
  }

  String resultWinOvertimePenalty(num ptsFor, num ptsAgainst, num overtimeFor,
          num overtimeAgainst, num penaltyFor, num penaltyAgainst) =>
      Intl.message(
          'Win ${ptsFor} - ${ptsAgainst} '
          '(Overtime ${overtimeFor} - ${overtimeAgainst})'
          '(Penalty ${penaltyFor} - ${penaltyAgainst})',
          args: [
            ptsFor,
            ptsAgainst,
            overtimeFor,
            overtimeAgainst,
            penaltyFor,
            penaltyAgainst
          ],
          name: 'resultWinOvertimePenalty',
          desc: 'Win result details with penalty shootout');

  String resultWinOvertime(
          num ptsFor, num ptsAgainst, num overtimeFor, num overtimeAgainst) =>
      Intl.message(
          'Win ${ptsFor} - ${ptsAgainst} '
          '(Overtime ${overtimeFor} - ${overtimeAgainst})',
          args: [ptsFor, ptsAgainst, overtimeFor, overtimeAgainst],
          name: 'resultWinOvertime',
          desc: 'Win result details in overtime');

  String resultWinPenalty(
          num ptsFor, num ptsAgainst, num penaltyFor, num penaltyAgainst) =>
      Intl.message(
          'Win ${ptsFor} - ${ptsAgainst} (Penalty ${penaltyFor} - ${penaltyAgainst})',
          args: [ptsFor, ptsAgainst, penaltyFor, penaltyAgainst],
          name: 'resultWinPenalty',
          desc: 'Win result details with penalty shootout');

  String resultWinRegulation(num ptsFor, num ptsAgainst) =>
      Intl.message('Win ${ptsFor} - ${ptsAgainst}',
          args: [ptsFor, ptsAgainst],
          name: 'resultWinRegulation',
          desc: 'Win result details');

  String roleInGame(RoleInTeam role) {
    switch (role) {
      case RoleInTeam.Player:
        return roleInGamePlayer;
      case RoleInTeam.Coach:
        return roleInGameCoach;
      case RoleInTeam.NonPlayer:
        return roleInGameNonPlayer;
    }
    return unknown;
  }

  String get roleInGamePlayer =>
      Intl.message("Player", desc: "Player role in the team");

  String get roleInGameCoach =>
      Intl.message("Coach", desc: "Coach role in the team");

  String get roleInGameNonPlayer =>
      Intl.message("Non Player", desc: "Non Player role in the team");

  String seasonSummary(SeasonPlayerSummary summary) {
    return seasonSummaryExpanded(summary.basketballSummary.points,
        summary.basketballSummary.blocks, summary.basketballSummary.steals);
  }

  String seasonSummaryExpanded(int points, int blocks, int steals) {
    return Intl.message(
      "Pts $points Blks $blocks Stls $steals",
      desc: "Subtitle to markt he season as current",
      args: [points, blocks, steals],
      name: 'seasonSummaryExpanded',
      locale: locale,
    );
  }

  String sportName(Sport sport) {
    switch (sport) {
      case Sport.Basketball:
        return sportNameBasketball;
      case Sport.Softball:
        return sportNameSoftball;
      case Sport.Soccer:
        return sportNameSoccer;
      case Sport.Other:
        return sportNameOther;
      case Sport.None:
        return sportNameNone;
    }
    return unknown;
  }

  String get sportNameBasketball => Intl.message('Basketball',
      desc: 'Name for the item in a drop down for basketball');

  String get sportNameSoftball => Intl.message('Softball',
      desc: 'Name for the item in a drop down for softball');

  String get sportNameSoccer => Intl.message('Soccer',
      desc: 'Name for the item in a drop down for soccer');

  String get sportNameOther => Intl.message('Other sport',
      desc: 'Name for the item in a drop down for other as the sport type');

  String get sportNameNone => Intl.message('None',
      desc: 'Name for the item in a drop down for none as the sport type');

  String teamAndSeason(String teamName, String seasonName) {
    return Intl.message("Team $teamName\nSeason $seasonName",
        args: [teamName, seasonName], name: 'teamAndSeason');
  }

  String teamNumbers(int num) {
    return Intl.message("${num} club teams",
        desc: 'How many teams in the club', args: [num], name: 'teamNumbers');
  }

  String titleWith(String str) {
    return Intl.message(
      'Team Fuse ($str)',
      desc: 'Title for the Team Fuse application with some context',
      args: [str],
      name: 'titleWith',
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
        return trainingTitleEndShortName(time, endTime, tzShortName);
      }
      return trainingTitleEnd(time, endTime);
    }
    if (tzShortName != null) {
      return trainingTitleShortName(time, tzShortName);
    }
    return trainingTitleTime(time);
  }

  String trainingTitleEndShortName(
          String time, String endTime, String tzShortName) =>
      Intl.message('Practice $time - $endTime ($tzShortName)',
          desc: 'Training title in game list',
          args: [time, endTime, tzShortName],
          name: 'trainingTitleEndShortName');

  String trainingTitleEnd(String time, String endTime) =>
      Intl.message('Practice $time - $endTime',
          desc: 'Training title in game list',
          args: [time, endTime],
          name: 'trainingTitleEnd');

  String trainingTitleShortName(String time, String tzShortName) =>
      Intl.message('Practice $time ($tzShortName)',
          desc: 'Training title in game list',
          args: [time, tzShortName],
          name: 'trainingTitleShortName');

  String trainingTitleTime(String time) => Intl.message('Practice $time',
      desc: 'Training title in game list',
      args: [time],
      name: 'trainingTitleTime');

  String trainingTitleNow(String time, String endTime, String tzShortName) {
    if (endTime != null) {
      if (tzShortName != null) {
        return trainingTitleNowEndShortName(time, endTime, tzShortName);
      }
      return trainingTitleNowEnd(time, endTime);
    }
    if (tzShortName != null) {
      return trainingTitleNowShortName(time, tzShortName);
    }
    return trainingTitleNowTime(time);
  }

  String trainingTitleNowEndShortName(
          String time, String endTime, String tzShortName) =>
      Intl.message('NOW! Practice $time - $endTime ($tzShortName)',
          desc: 'Training title in game list',
          args: [time, endTime, tzShortName],
          name: 'trainingTitleNowEndShortName');

  String trainingTitleNowEnd(String time, String endTime) =>
      Intl.message('NOW! Practice $time - $endTime',
          desc: 'Training title in game list',
          args: [time, endTime],
          name: 'trainingTitleNowEnd');

  String trainingTitleNowShortName(String time, String tzShortName) =>
      Intl.message('NOW! Practice $time ($tzShortName)',
          desc: 'Training title in game list',
          args: [time, tzShortName],
          name: 'trainingTitleNowShortName');

  String trainingTitleNowTime(String time) =>
      Intl.message('NOW! Practice $time',
          desc: 'Training title in game list',
          args: [time],
          name: 'trainingTitleNowTime');

  String verifyExplanation(String email) {
    return Intl.message(
      'Email address $email needs to be verified, please check your email or resend the verification details.',
      desc: 'Button to resend the email to verify their email address',
      name: 'verifyExplanation',
      args: [email],
    );
  }

  String wearUniform(String wear) => Intl.message('Wear $wear',
      desc: 'Wear uniform in a game desc', args: [wear], name: 'wearUniform');

  String winRecord(WinRecord record) =>
      winRecordBreakout(record.win, record.loss, record.tie);

  String winRecordBreakout(num win, num loss, num tie) =>
      Intl.message('Win: ${win} Loss: ${loss} Tie: ${tie}',
          desc: 'Win record for a team',
          name: 'winRecordBreakout',
          args: [win, loss, tie]);

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
