import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_fuse/i10n/messages_all.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:math';

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

  Random randomNum = Random.secure();

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

  String get logout {
    return Intl.message(
      'Logout',
      name: 'Logout button text',
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

  String verifyexplanation(String email) {
    return Intl.message(
      'Email address $email needs to be verified, please check your email or resend the verification details.',
      name: 'Button to resend the email to verify their email address',
    );
  }

  String get errorcreatinguser {
    return Intl.message(
        "Error creating user, maybe the email address is already used");
  }

  String get createnew {
    return Intl.message(
      'Create new',
      name: 'Create new account button text',
    );
  }

  String get addteam {
    return Intl.message("Add team", name: "Add a new team button");
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

  String get nogamesthisseason {
    return Intl.message('No games this season',
        desc: 'No games played this season, but some in a previous season');
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

  String get emailonupdates {
    return Intl.message("On changes to games/events",
        name: 'Switch text for emailing on updates');
  }

  String get emailonupcoming {
    return Intl.message("Upcoming games/events",
        name: 'Switch text for emailing on upcoming games');
  }

  String get emailheader {
    return Intl.message("Email Preferences");
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

  String get seasonhint {
    return Intl.message(
      'Current team season',
      name: 'Hint for the season text box',
    );
  }

  String get seasonselect {
    return Intl.message(
      'Select season',
      name: 'Select Season',
      desc: 'Title for the select season marker',
    );
  }

  String get playerselect {
    return Intl.message("Player", name: "Label for the player drop down");
  }

  String get playerselecthint {
    return Intl.message("Select player",
        name: "Label for the player drop down");
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

  String get placesnotes {
    return Intl.message('Place notes, ie court #');
  }

  String get placesnoteshint {
    return Intl.message('Details of the place');
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

  String get seasonrequired {
    return Intl.message("Season name is required",
        name: "The error text when the season name is required");
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

  String get addseason {
    return Intl.message('Add Season', name: 'Add a season to the team');
  }

  String get opponentwithresult {
    return Intl.message('Opponents with results');
  }

  String get importplayers {
    return Intl.message('Import players',
        name: 'Import players from previous season');
  }

  String get opponentwithnoresult {
    return Intl.message('Opponents without results');
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

  String opponentseason(Opponent opponent, String seasonName) {
    return Intl.message("${opponent.name} - $seasonName",
        name: "Shows the opponent and season");
  }

  String opponentwinrecord(
      Opponent opponent, String seasonUid, String seasonName) {
    WinRecord rec = opponent.record[seasonUid];
    if (rec == null) {
      rec = new WinRecord();
    }
    return Intl.message('Win: ${rec.win} Loss: ${rec.loss} Tie: ${rec.tie}',
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
    return Intl.message('Share user');
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
    if (invite is InviteToTeam) {
      InviteToTeam inviteTeam = invite;
      return Intl.message(
          'Do you want to delete the invite to ${inviteTeam.teamName} for ${inviteTeam.playerName}',
          name: 'Text to delete the invite to the team in the alert dialog.');
    }
    if (invite is InviteToPlayer) {
      InviteToPlayer invitePlayer = invite;
      return Intl.message(
          'Do you want to delete the invite to follow ${invitePlayer.playerName}',
          name: 'Text to delete the invite to the team in the alert dialog.');
    }
    return unknown;
  }

  String deletegame(Game game) {
    switch (game.type) {
      case EventType.Game:
        return Intl.message("Delete game");
      case EventType.Practice:
        return Intl.message("Delete training");
      case EventType.Event:
        return Intl.message("Delete special event");
    }
    return unknown;
  }

  String confirmdeleteplayer(Player player) {
    return Intl.message(
        "Do you want to delete your connection to ${player.name}?",
        desc: 'Text to confirm asking if the players wants to be delete');
  }

  String nameandteam(Team team, Player player) {
    return Intl.message("${team.name} ${player.name}",
        desc: "Format for name and player for the team");
  }

  String numberofuserforplayer(int num) {
    return Intl.message("$num users associated",
        desc: "Number of users associated with this player");
  }

  String invitedemail(InviteToPlayer invite) {
    return Intl.message("${invite.email} to follow",
        desc: "Message for invited to follow the specific player");
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

  String get relationshipselect {
    return Intl.message("Select relationship",
        name: "Label to select the relatiobship from a drop down");
  }

  String resultwin(GameResultDetails result) {
    GameResultPerPeriod finalScore;
    GamePeriod finalReg = new GamePeriod(type: GamePeriodType.Regulation);
    if (result.scores.containsKey(finalReg)) {
      finalScore = result.scores[finalReg];
    } else {
      finalScore = new GameResultPerPeriod(
          period: finalReg, score: new GameScore(ptsFor: 0, ptsAgainst: 0));
    }
    GamePeriod penaltyPeriod = new GamePeriod(type: GamePeriodType.Penalty);
    if (result.scores.containsKey(penaltyPeriod)) {
      GameResultPerPeriod penaltyScore = result.scores[penaltyPeriod];
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

  String resultloss(GameResultDetails result) {
    GameResultPerPeriod finalScore;
    GamePeriod finalReg = new GamePeriod(type: GamePeriodType.Regulation);
    if (result.scores.containsKey(finalReg)) {
      finalScore = result.scores[finalReg];
    } else {
      finalScore = new GameResultPerPeriod(
          period: new GamePeriod(type: GamePeriodType.Regulation),
          score: new GameScore(ptsFor: 0, ptsAgainst: 0));
    }
    GamePeriod penaltyPeriod = new GamePeriod(type: GamePeriodType.Penalty);
    if (result.scores.containsKey(penaltyPeriod)) {
      GameResultPerPeriod penaltyScore = result.scores[penaltyPeriod];
      return Intl.message(
          'Loss ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} (Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          name: 'Win result details',
          desc: 'Win result details with penalty shootout');
    }
    return Intl.message(
        'Loss ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
        name: 'Loss result details',
        desc: 'Loss result details');
  }

  String resulttie(GameResultDetails result) {
    GameResultPerPeriod finalScore;
    GamePeriod finalReg = new GamePeriod(type: GamePeriodType.Regulation);
    if (result.scores.containsKey(finalReg)) {
      finalScore = result.scores[finalReg];
    } else {
      finalScore = new GameResultPerPeriod(
          period: new GamePeriod(type: GamePeriodType.Regulation),
          score: new GameScore(ptsFor: 0, ptsAgainst: 0));
    }
    return Intl.message(
        'Tie ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
        name: 'Tie result details',
        desc: 'Tie result details');
  }

  String resultinprogress(GameResultDetails result) {
    GameResultPerPeriod finalScore;
    GamePeriod finalReg = new GamePeriod(type: GamePeriodType.Regulation);
    if (result.scores.containsKey(finalReg)) {
      finalScore = result.scores[finalReg];
    } else {
      finalScore = new GameResultPerPeriod(
          period: new GamePeriod(type: GamePeriodType.Regulation),
          score: new GameScore(ptsFor: 0, ptsAgainst: 0));
    }
    GamePeriod penaltyPeriod = new GamePeriod(type: GamePeriodType.Penalty);
    if (result.scores.containsKey(penaltyPeriod)) {
      GameResultPerPeriod penaltyScore = result.scores[penaltyPeriod];
      return Intl.message(
          'In progress ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst} (Penalty ${penaltyScore.score.ptsFor} - ${penaltyScore.score.ptsAgainst})',
          name: 'In progress result details',
          desc: 'Win result details with penalty shootout');
    }
    return Intl.message(
        'In progress ${finalScore.score.ptsFor} - ${finalScore.score.ptsAgainst}',
        name: 'In progress result details',
        desc: 'In progress result details');
  }

  String onlyscore(GameScore score) {
    return Intl.message("${score.ptsFor} - ${score.ptsAgainst}");
  }

  String periodstart(GameLog period) {
    switch (period.period.type) {
      case GamePeriodType.Regulation:
        return "Start period ${period.period.periodNumber} Score:  ${period.score.ptsFor} - ${period.score.ptsAgainst}";
      case GamePeriodType.OvertimeBreak:
        return "Start overtime period ${period.period.periodNumber} Score: ${period.score.ptsFor} - ${period.score.ptsAgainst}";
      case GamePeriodType.Break:
        return "Start period ${period.period.periodNumber} Score: ${period.score.ptsFor} - ${period.score.ptsAgainst}";
      case GamePeriodType.Overtime:
        return "Start overtime Score: ${period.score.ptsFor} - ${period.score.ptsAgainst}";
      case GamePeriodType.Penalty:
        return "Start penalty Score: ${period.score.ptsFor} - ${period.score.ptsAgainst}";
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

  String gametitlevs(Game game, String oppponent) {
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

  String get forpts {
    return Intl.message("For",
        desc:
            "Title to the spinner for showing points for in the results screen");
  }

  String get againstpts {
    return Intl.message("Against",
        desc:
            "Title to the spinner for showing points against in the results screen");
  }

  String get updatescorebutton {
    return Intl.message("Update Score",
        desc: "Title to the button to update the score results screen");
  }

  String get finishgamebutton {
    return Intl.message("Finish",
        desc:
            "Text for the button to finish the game in the update score screen");
  }

  String get timercountup {
    return Intl.message("Timer count up");
  }

  String get duration {
    return Intl.message("Duration");
  }

  String get choosedivisions {
    return Intl.message("Start Game - Breaks");
  }

  String followplayer(String player) {
    return Intl.message("Follow $player");
  }

  String gameinprogress(GameInProgress val) {
    switch (val) {
      case GameInProgress.InProgress:
        return Intl.message("In progress", desc: "Game is in progress");
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

  String get resettimer {
    return Intl.message("Reset Timer");
  }

  String get resettimerbody {
    return Intl.message("Do you want to reset the timer to zero?");
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
    return Intl.message('CHANGE ROLE',
        desc: 'Button to change the role of the member of the team');
  }

  String get deleteplayer {
    return Intl.message('REMOVE FROM TEAM',
        desc: 'Button to change the remove a member from the team');
  }

  String get deleteopponent {
    return Intl.message('Delete opponent',
        desc: 'Title to the alert dialog to delete an opponent from the team');
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

  String get invite {
    return Intl.message('Invites',
        desc: 'Title for the screen with the list of current invites');
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
        desc:
            'Title for the drop down to say select place if nothing is selected');
  }

  String get trainingend {
    return Intl.message('Training end',
        desc: 'Title for the time drop down to choose the training end time');
  }

  String get deletebuttontext {
    return Intl.message('DELETE', desc: 'Button text to delete an iteam');
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

  String eventtitle(
      String time, String name, String endTime, String tzShortName) {
    if (name != null && name.isNotEmpty) {
      if (endTime != null) {
        if (tzShortName != null) {
          return Intl.message('$name $time - $endTime ($tzShortName)',
              desc: 'Special event title in game list');
        }
        return Intl.message('$name $time - $endTime',
            desc: 'Special event title in game list');
      }
      if (tzShortName != null) {
        return Intl.message('$name $time ($tzShortName)',
            desc: 'Special event title in game list');
      }
      return Intl.message('$name $time',
          desc: 'Special event title in game list');
    }
    if (endTime != null) {
      if (tzShortName != null) {
        return Intl.message('Event $time - $endTime ($tzShortName)',
            desc: 'Special event title in game list');
      }
      return Intl.message('Event $time - $endTime',
          desc: 'Special event title in game list');
    }
    if (tzShortName != null) {
      return Intl.message('Event $time ($tzShortName)',
          desc: 'Special event title in game list');
    }
    return Intl.message('Event $time',
        desc: 'Special event title in game list');
  }

  String eventtitlenow(
      String time, String name, String endTime, String tzShortName) {
    if (name != null && name.isNotEmpty) {
      if (endTime != null) {
        if (tzShortName != null) {
          return Intl.message('NOW! $name $time - $endTime ($tzShortName)',
              desc: 'Special event title in game list');
        }
        return Intl.message('NOW! $name $time - $endTime',
            desc: 'Special event title in game list');
      }
      if (tzShortName != null) {
        return Intl.message('NOW! $name $time ($tzShortName)',
            desc: 'Special event title in game list');
      }
      return Intl.message('NOW! $name $time',
          desc: 'Special event title in game list');
    }
    if (endTime != null) {
      if (tzShortName != null) {
        return Intl.message('NOW! Event $time - $endTime ($tzShortName)',
            desc: 'Special event title in game list');
      }
      return Intl.message('NOW! Event $time - $endTime',
          desc: 'Special event title in game list');
    }
    if (tzShortName != null) {
      return Intl.message('NOW! Event $time ($tzShortName)',
          desc: 'Special event title in game list');
    }
    return Intl.message('NOW! Event $time',
        desc: 'Special event title in game list');
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

  String get verifyemailsent {
    return Intl.message(
        "Sent verification email, please check your email inbox.",
        desc:
            "Confirmation message after requesting the email verification code");
  }

  String get createdaccount {
    return Intl.message(
        "Created an account, please look in your email for the verification code..",
        desc:
            "Confirmation message after requesting the email verification code");
  }

  String get verifyemailerror {
    return Intl.message("No account found for email or internal error occured");
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

  String gameaddressarriveat(String arriveAt, String address) {
    return Intl.message('Arrive by $arriveAt\n$address',
        desc: 'Game address in game list with arrive by');
  }

  String get players {
    return Intl.message('Players',
        desc: 'Title in the bottom navigation tab for players');
  }

  String playerinvitedesc(String name) {
    return Intl.message(
        'This will follow $name and allow you to see which games they are in and ' +
            'all the teams they are in.  Please setup your relationship with the ' +
            'player and save.',
        desc: 'Long description of the player invite accept path.');
  }

  String get directionsbuttons {
    return Intl.message('DIRECTIONS');
  }

  String get addresultbutton {
    return Intl.message('ADD RESULT');
  }

  QuoteAndAuthor quoteforsaving(int quoteId) {
    switch (quoteId % 4) {
      case 0:
        return new QuoteAndAuthor(
            quote: Intl.message("Lies, Damn Lies and Statistics"),
            author: Intl.message("Mark Twain"));
      case 1:
        return new QuoteAndAuthor(
            quote: Intl.message(
                "I've missed more than 9000 shots in my career. "
                "I've lost almost 300 games. 26 times, "
                "I've been trusted to take the game winning shot and missed. "
                "I've failed over and over and over again in my life. "
                "And that is why I succeed."),
            author: Intl.message("Michael Jordan"));
      case 2:
        return new QuoteAndAuthor(
          quote: Intl.message(
              "I know I am getting better at golf because I am hitting fewer spectators."),
          author: Intl.message("Gerald R. Ford"),
        );
      default:
        return new QuoteAndAuthor(
            quote: Intl.message("Don't Panic"),
            author: Intl.message("Douglas Adams"));
    }
  }
}

class QuoteAndAuthor {
  String quote;
  String author;
  QuoteAndAuthor({this.quote, this.author});
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
