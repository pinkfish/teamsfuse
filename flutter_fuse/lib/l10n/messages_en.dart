// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static m0(minutes) => "Arrive ${minutes} mins before games";

  static m1(ptsFor, ptsAgainst) => "${ptsFor} - ${ptsAgainst}";

  static m2(ptsFor, ptsAgainst, overtimeFor, overtimeAgainst) => "${ptsFor} - ${ptsAgainst} (Overtime ${overtimeFor} - ${overtimeAgainst})";

  static m3(ptsFor, ptsAgainst, overtimeFor, overtimeAgainst, penaltyFor, penaltyAgainst) => "${ptsFor} - ${ptsAgainst} (Overtime ${overtimeFor} - ${overtimeAgainst})(Penalty ${penaltyFor} - ${penaltyAgainst})";

  static m4(ptsFor, ptsAgainst, penaltyFor, penaltyAgainst) => "${ptsFor} - ${ptsAgainst} (Penalty ${penaltyFor} - ${penaltyAgainst})";

  static m5(teamName, season, league) => "Are you sure you want to create a team ${teamName} with a season of ${season} for the league ${league}.  This is not possible to undo?";

  static m6(teamName) => "Do you want to delete the invite to be admin for the team ${teamName}?";

  static m7(clubName) => "Do you want to delete the invite to be in the club ${clubName}?";

  static m8(playerName) => "Do you want to delete the invite to follow ${playerName}?";

  static m9(teamName, playerName) => "Do you want to delete the invite to ${teamName} for ${playerName}?";

  static m10(leagueName) => "Do you want to delete the invite to be in the league ${leagueName}?";

  static m11(leagueName, leagueTeamName) => "Do you want to delete the invite to be in the league ${leagueName} with team ${leagueTeamName}?";

  static m12(displayName) => "Delete club member ${displayName}?";

  static m13(playerName) => "Do you want to delete your connection to ${playerName}?";

  static m14(name) => "Are you sure you want to remove ${name} from the team?";

  static m15(name, rel) => "${name} (${rel})";

  static m16(time) => "NOW! Event ${time}";

  static m17(name, time) => "NOW! ${name} ${time}";

  static m18(name, time, endTime) => "NOW! ${name} ${time} - ${endTime}";

  static m19(name, time, endTime, tzShortName) => "NOW! ${name} ${time} - ${endTime}  (${tzShortName})";

  static m20(name, time, tzShortName) => "NOW! ${name} ${time} (${tzShortName})";

  static m21(time, endTime) => "NOW! Event ${time} - ${endTime}";

  static m22(time, endTime, tzShortName) => "NOW! Event ${time} - ${endTime} (${tzShortName})";

  static m23(time, tzShortName) => "NOW! Event ${time} (${tzShortName})";

  static m24(time) => "Event ${time}";

  static m25(name, time) => "${name} ${time}";

  static m26(name, time, endTime) => "${name} ${time} - ${endTime}";

  static m27(name, time, endTime, tzShortName) => "${name} ${time} - ${endTime}  (${tzShortName})";

  static m28(name, time, tzShortName) => "${name} ${time} (${tzShortName})";

  static m29(time, endTime) => "Event ${time} - ${endTime}";

  static m30(time, endTime, tzShortName) => "Event ${time} - ${endTime} (${tzShortName})";

  static m31(time, tzShortName) => "Event ${time} (${tzShortName})";

  static m32(resultString, homeFor, homeAgainst, overtimeFor, overtimeAgainst) => "${resultString}\nHome: ${homeFor} Away: ${homeAgainst}\nOvertime Home: ${overtimeFor} Away: ${overtimeAgainst}";

  static m33(resultString, homeFor, homeAgainst, overtimeFor, overtimeAgainst, penaltyFor, penaltyAgainst) => "${resultString}\nHome: ${homeFor} Away: ${homeAgainst}\nOvertime Home: ${overtimeFor} Away: ${overtimeAgainst}Penalty Home: ${penaltyFor} Away: ${penaltyAgainst}";

  static m34(resultString, homeFor, homeAgainst, penaltyFor, penaltyAgainst) => "${resultString}\nHome: ${homeFor} Away: ${homeAgainst}\nPenalty Home: ${penaltyFor} Away: ${penaltyAgainst}";

  static m35(ptsFor, ptsAgainst, result) => "Do you want to set ${ptsFor} ${ptsAgainst} ${result} as the final score?";

  static m36(player) => "Follow ${player}";

  static m37(arriveAt, address) => "Arrive by ${arriveAt}\n${address}";

  static m38(resultString, ptsFor, ptsAgainst) => "${resultString}\nHome: ${ptsFor} Away: ${ptsAgainst}";

  static m39(time, endTime, opponent) => "NOW! ${time} - ${endTime} cs ${opponent}";

  static m40(time, endTime, tzShortName, opponent) => "NOW! ${time} - ${endTime} (${tzShortName}) vs ${opponent}";

  static m41(time, tzShortName, opponent) => "NOW! ${time} (${tzShortName}) vs ${opponent}";

  static m42(time, opponent) => "NOW! ${time} vs ${opponent}";

  static m43(time, endTime, opponent) => "${time} - ${endTime} vs ${opponent}";

  static m44(time, endTime, tzShortName, opponent) => "${time} - ${endTime} (${tzShortName}) vs ${opponent}";

  static m45(time, tzShortName, opponent) => "${time} (${tzShortName}) vs ${opponent}";

  static m46(time, opponent) => "${time} vs ${opponent}";

  static m47(opponent) => "Game vs ${opponent}";

  static m48(by) => "By ${by}";

  static m49(num) => "Invited: ${num}";

  static m50(name) => "${name} (Invited)";

  static m51(points) => "${points}";

  static m52(points) => "Miss ${points}";

  static m53(teamName, playerName) => "${teamName} ${playerName}";

  static m54(num) => "${Intl.plural(num, zero: 'No teams', one: 'One team', other: '${num} teams')}";

  static m55(num) => "${Intl.plural(num, one: 'One user', other: '${num} users')}";

  static m56(ptsFor, ptsAgainst) => "${ptsFor} - ${ptsAgainst}";

  static m57(opponentName, seasonName) => "${opponentName} - ${seasonName}";

  static m58(win, loss, tie) => "Win: ${win} Loss: ${loss} Tie: ${tie}";

  static m59(num) => "Pending Invites: ${num}";

  static m60(periodName) => "End of ${periodName}";

  static m61(periodNumber) => "Overtime ${periodNumber}";

  static m62(periodNumber) => "Regulation ${periodNumber}";

  static m63(periodName) => "Start of ${periodName}";

  static m64(name) => "This will follow ${name} and allow you to see which games they are in and all the teams they are in.  Please setup your relationship with the player and save.";

  static m65(ptsFor, ptsAgainst, overtimeFor, overtimeAgainst) => "Playing ${ptsFor} - ${ptsAgainst} (Overtime ${overtimeFor} - ${overtimeAgainst})";

  static m66(ptsFor, ptsAgainst, overtimeFor, overtimeAgainst, penaltyFor, penaltyAgainst) => "Playing ${ptsFor} - ${ptsAgainst} (Overtime ${overtimeFor} - ${overtimeAgainst})(Penalty ${penaltyFor} - ${penaltyAgainst})";

  static m67(ptsFor, ptsAgainst, penaltyFor, penaltyAgainst) => "Playing ${ptsFor} - ${ptsAgainst} (Penalty ${penaltyFor} - ${penaltyAgainst})";

  static m68(ptsFor, ptsAgainst) => "Playing ${ptsFor} - ${ptsAgainst}";

  static m69(ptsFor, ptsAgainst, overtimeFor, overtimeAgainst) => "Loss ${ptsFor} - ${ptsAgainst} (Overtime ${overtimeFor} - ${overtimeAgainst})";

  static m70(ptsFor, ptsAgainst, overtimeFor, overtimeAgainst, penaltyFor, penaltyAgainst) => "Loss ${ptsFor} - ${ptsAgainst} (Overtime ${overtimeFor} - ${overtimeAgainst})(Penalty ${penaltyFor} - ${penaltyAgainst})";

  static m71(ptsFor, ptsAgainst, penaltyFor, penaltyAgainst) => "Loss ${ptsFor} - ${ptsAgainst} (Penalty ${penaltyFor} - ${penaltyAgainst})";

  static m72(ptsFor, ptsAgainst) => "Loss ${ptsFor} - ${ptsAgainst}";

  static m73(ptsFor, ptsAgainst, overtimeFor, overtimeAgainst) => "Tie ${ptsFor} - ${ptsAgainst} (Overtime ${overtimeFor} - ${overtimeAgainst})";

  static m74(ptsFor, ptsAgainst, overtimeFor, overtimeAgainst, penaltyFor, penaltyAgainst) => "Tie ${ptsFor} - ${ptsAgainst} (Overtime ${overtimeFor} - ${overtimeAgainst})(Penalty ${penaltyFor} - ${penaltyAgainst})";

  static m75(ptsFor, ptsAgainst, penaltyFor, penaltyAgainst) => "Tie ${ptsFor} - ${ptsAgainst} (Penalty ${penaltyFor} - ${penaltyAgainst})";

  static m76(ptsFor, ptsAgainst) => "Tie ${ptsFor} - ${ptsAgainst}";

  static m77(ptsFor, ptsAgainst, overtimeFor, overtimeAgainst) => "Win ${ptsFor} - ${ptsAgainst} (Overtime ${overtimeFor} - ${overtimeAgainst})";

  static m78(ptsFor, ptsAgainst, overtimeFor, overtimeAgainst, penaltyFor, penaltyAgainst) => "Win ${ptsFor} - ${ptsAgainst} (Overtime ${overtimeFor} - ${overtimeAgainst})(Penalty ${penaltyFor} - ${penaltyAgainst})";

  static m79(ptsFor, ptsAgainst, penaltyFor, penaltyAgainst) => "Win ${ptsFor} - ${ptsAgainst} (Penalty ${penaltyFor} - ${penaltyAgainst})";

  static m80(ptsFor, ptsAgainst) => "Win ${ptsFor} - ${ptsAgainst}";

  static m81(points, blocks, steals) => "Pts ${points} Blks ${blocks} Stls ${steals}";

  static m82(teamName, seasonName) => "Team ${teamName}\nSeason ${seasonName}";

  static m83(num) => "${num} club teams";

  static m84(str) => "Team Fuse (${str})";

  static m85(time, endTime) => "Practice ${time} - ${endTime}";

  static m86(time, endTime, tzShortName) => "Practice ${time} - ${endTime} (${tzShortName})";

  static m87(time, endTime) => "NOW! Practice ${time} - ${endTime}";

  static m88(time, endTime, tzShortName) => "NOW! Practice ${time} - ${endTime} (${tzShortName})";

  static m89(time, tzShortName) => "NOW! Practice ${time} (${tzShortName})";

  static m90(time) => "NOW! Practice ${time}";

  static m91(time, tzShortName) => "Practice ${time} (${tzShortName})";

  static m92(time) => "Practice ${time}";

  static m93(email) => "Email address ${email} needs to be verified, please check your email or resend the verification details.";

  static m94(wear) => "Wear ${wear}";

  static m95(win, loss, tie) => "Win: ${win} Loss: ${loss} Tie: ${tie}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "%age" : MessageLookupByLibrary.simpleMessage("%age"),
    "ADD" : MessageLookupByLibrary.simpleMessage("ADD"),
    "ADD ADMIN" : MessageLookupByLibrary.simpleMessage("ADD ADMIN"),
    "ADD CLUB" : MessageLookupByLibrary.simpleMessage("ADD CLUB"),
    "ADD DIVISON" : MessageLookupByLibrary.simpleMessage("ADD DIVISON"),
    "ADD EVENT" : MessageLookupByLibrary.simpleMessage("ADD EVENT"),
    "ADD GAME" : MessageLookupByLibrary.simpleMessage("ADD GAME"),
    "ADD INVITE" : MessageLookupByLibrary.simpleMessage("ADD INVITE"),
    "ADD MEDIA" : MessageLookupByLibrary.simpleMessage("ADD MEDIA"),
    "ADD PLAYER" : MessageLookupByLibrary.simpleMessage("ADD PLAYER"),
    "ADD RESULT" : MessageLookupByLibrary.simpleMessage("ADD RESULT"),
    "ADD SEASON" : MessageLookupByLibrary.simpleMessage("ADD SEASON"),
    "ADD TEAM" : MessageLookupByLibrary.simpleMessage("ADD TEAM"),
    "ADD TRAINING" : MessageLookupByLibrary.simpleMessage("ADD TRAINING"),
    "ALL TEAMS" : MessageLookupByLibrary.simpleMessage("ALL TEAMS"),
    "ASST" : MessageLookupByLibrary.simpleMessage("ASST"),
    "About" : MessageLookupByLibrary.simpleMessage("About"),
    "Add Admin" : MessageLookupByLibrary.simpleMessage("Add Admin"),
    "Add Coach" : MessageLookupByLibrary.simpleMessage("Add Coach"),
    "Add Divison" : MessageLookupByLibrary.simpleMessage("Add Divison"),
    "Add Game" : MessageLookupByLibrary.simpleMessage("Add Game"),
    "Add Invite" : MessageLookupByLibrary.simpleMessage("Add Invite"),
    "Add League" : MessageLookupByLibrary.simpleMessage("Add League"),
    "Add Media" : MessageLookupByLibrary.simpleMessage("Add Media"),
    "Add News" : MessageLookupByLibrary.simpleMessage("Add News"),
    "Add Player" : MessageLookupByLibrary.simpleMessage("Add Player"),
    "Add Season" : MessageLookupByLibrary.simpleMessage("Add Season"),
    "Add Team" : MessageLookupByLibrary.simpleMessage("Add Team"),
    "Add Tournament" : MessageLookupByLibrary.simpleMessage("Add Tournament"),
    "Add club member" : MessageLookupByLibrary.simpleMessage("Add club member"),
    "Add game" : MessageLookupByLibrary.simpleMessage("Add game"),
    "Add new" : MessageLookupByLibrary.simpleMessage("Add new"),
    "Administrator" : MessageLookupByLibrary.simpleMessage("Administrator"),
    "Against" : MessageLookupByLibrary.simpleMessage("Against"),
    "All Events" : MessageLookupByLibrary.simpleMessage("All Events"),
    "All Periods" : MessageLookupByLibrary.simpleMessage("All Periods"),
    "All Players" : MessageLookupByLibrary.simpleMessage("All Players"),
    "All Seasons" : MessageLookupByLibrary.simpleMessage("All Seasons"),
    "All games" : MessageLookupByLibrary.simpleMessage("All games"),
    "All teams" : MessageLookupByLibrary.simpleMessage("All teams"),
    "Archive" : MessageLookupByLibrary.simpleMessage("Archive"),
    "Archive Team" : MessageLookupByLibrary.simpleMessage("Archive Team"),
    "Archived" : MessageLookupByLibrary.simpleMessage("Archived"),
    "Archived Teams" : MessageLookupByLibrary.simpleMessage("Archived Teams"),
    "Are you sure you want to add a player with no email?" : MessageLookupByLibrary.simpleMessage("Are you sure you want to add a player with no email?"),
    "Are you sure you want to delete the news item?" : MessageLookupByLibrary.simpleMessage("Are you sure you want to delete the news item?"),
    "Arrive At" : MessageLookupByLibrary.simpleMessage("Arrive At"),
    "Assists" : MessageLookupByLibrary.simpleMessage("Assists"),
    "Attendance" : MessageLookupByLibrary.simpleMessage("Attendance"),
    "Attendance is from team" : MessageLookupByLibrary.simpleMessage("Attendance is from team"),
    "Availability" : MessageLookupByLibrary.simpleMessage("Availability"),
    "Away team won" : MessageLookupByLibrary.simpleMessage("Away team won"),
    "BLK" : MessageLookupByLibrary.simpleMessage("BLK"),
    "Basketball" : MessageLookupByLibrary.simpleMessage("Basketball"),
    "Blk" : MessageLookupByLibrary.simpleMessage("Blk"),
    "Block" : MessageLookupByLibrary.simpleMessage("Block"),
    "Blocks" : MessageLookupByLibrary.simpleMessage("Blocks"),
    "Break" : MessageLookupByLibrary.simpleMessage("Break"),
    "CAMERA" : MessageLookupByLibrary.simpleMessage("CAMERA"),
    "CHANGE ROLE" : MessageLookupByLibrary.simpleMessage("CHANGE ROLE"),
    "CLUB" : MessageLookupByLibrary.simpleMessage("CLUB"),
    "CREATE" : MessageLookupByLibrary.simpleMessage("CREATE"),
    "Change Score" : MessageLookupByLibrary.simpleMessage("Change Score"),
    "Change team" : MessageLookupByLibrary.simpleMessage("Change team"),
    "Club" : MessageLookupByLibrary.simpleMessage("Club"),
    "Club deleted" : MessageLookupByLibrary.simpleMessage("Club deleted"),
    "Coach" : MessageLookupByLibrary.simpleMessage("Coach"),
    "Coach deleted" : MessageLookupByLibrary.simpleMessage("Coach deleted"),
    "Coaches" : MessageLookupByLibrary.simpleMessage("Coaches"),
    "Coed" : MessageLookupByLibrary.simpleMessage("Coed"),
    "Contact" : MessageLookupByLibrary.simpleMessage("Contact"),
    "Contact for the opponent" : MessageLookupByLibrary.simpleMessage("Contact for the opponent"),
    "Contact phone number" : MessageLookupByLibrary.simpleMessage("Contact phone number"),
    "Copy details from" : MessageLookupByLibrary.simpleMessage("Copy details from"),
    "Create" : MessageLookupByLibrary.simpleMessage("Create"),
    "Create new" : MessageLookupByLibrary.simpleMessage("Create new"),
    "Created an account, please look in your email for the verification code.." : MessageLookupByLibrary.simpleMessage("Created an account, please look in your email for the verification code.."),
    "Current" : MessageLookupByLibrary.simpleMessage("Current"),
    "Current team season" : MessageLookupByLibrary.simpleMessage("Current team season"),
    "D/RB" : MessageLookupByLibrary.simpleMessage("D/RB"),
    "DEF RB" : MessageLookupByLibrary.simpleMessage("DEF RB"),
    "DELETE" : MessageLookupByLibrary.simpleMessage("DELETE"),
    "DELETE INVITE" : MessageLookupByLibrary.simpleMessage("DELETE INVITE"),
    "DIRECTIONS" : MessageLookupByLibrary.simpleMessage("DIRECTIONS"),
    "DONE" : MessageLookupByLibrary.simpleMessage("DONE"),
    "Def Rebound" : MessageLookupByLibrary.simpleMessage("Def Rebound"),
    "Delete" : MessageLookupByLibrary.simpleMessage("Delete"),
    "Delete Admin" : MessageLookupByLibrary.simpleMessage("Delete Admin"),
    "Delete News Item" : MessageLookupByLibrary.simpleMessage("Delete News Item"),
    "Delete Player" : MessageLookupByLibrary.simpleMessage("Delete Player"),
    "Delete admin invite" : MessageLookupByLibrary.simpleMessage("Delete admin invite"),
    "Delete game" : MessageLookupByLibrary.simpleMessage("Delete game"),
    "Delete invite" : MessageLookupByLibrary.simpleMessage("Delete invite"),
    "Delete member" : MessageLookupByLibrary.simpleMessage("Delete member"),
    "Delete opponent" : MessageLookupByLibrary.simpleMessage("Delete opponent"),
    "Delete special event" : MessageLookupByLibrary.simpleMessage("Delete special event"),
    "Delete training" : MessageLookupByLibrary.simpleMessage("Delete training"),
    "Description" : MessageLookupByLibrary.simpleMessage("Description"),
    "Detailed Description" : MessageLookupByLibrary.simpleMessage("Detailed Description"),
    "Details" : MessageLookupByLibrary.simpleMessage("Details"),
    "Details of the place" : MessageLookupByLibrary.simpleMessage("Details of the place"),
    "Division" : MessageLookupByLibrary.simpleMessage("Division"),
    "Do you want to reset the timer to zero?" : MessageLookupByLibrary.simpleMessage("Do you want to reset the timer to zero?"),
    "Do you want to start the game?" : MessageLookupByLibrary.simpleMessage("Do you want to start the game?"),
    "Don\'t Panic" : MessageLookupByLibrary.simpleMessage("Don\'t Panic"),
    "Don\'t track attendance" : MessageLookupByLibrary.simpleMessage("Don\'t track attendance"),
    "Duration" : MessageLookupByLibrary.simpleMessage("Duration"),
    "EDIT" : MessageLookupByLibrary.simpleMessage("EDIT"),
    "EDIT IMAGE" : MessageLookupByLibrary.simpleMessage("EDIT IMAGE"),
    "END" : MessageLookupByLibrary.simpleMessage("END"),
    "Edit Game" : MessageLookupByLibrary.simpleMessage("Edit Game"),
    "Edit Team" : MessageLookupByLibrary.simpleMessage("Edit Team"),
    "Email" : MessageLookupByLibrary.simpleMessage("Email"),
    "Email Preferences" : MessageLookupByLibrary.simpleMessage("Email Preferences"),
    "Email address must be of form xxx@xxx." : MessageLookupByLibrary.simpleMessage("Email address must be of form xxx@xxx."),
    "Email and/or password incorrect" : MessageLookupByLibrary.simpleMessage("Email and/or password incorrect"),
    "Email is empty." : MessageLookupByLibrary.simpleMessage("Email is empty."),
    "End timeout" : MessageLookupByLibrary.simpleMessage("End timeout"),
    "Error creating user, maybe the email address is already used" : MessageLookupByLibrary.simpleMessage("Error creating user, maybe the email address is already used"),
    "Event" : MessageLookupByLibrary.simpleMessage("Event"),
    "Everyone" : MessageLookupByLibrary.simpleMessage("Everyone"),
    "FINISH" : MessageLookupByLibrary.simpleMessage("FINISH"),
    "FORGOT PASSWORD" : MessageLookupByLibrary.simpleMessage("FORGOT PASSWORD"),
    "FOUL" : MessageLookupByLibrary.simpleMessage("FOUL"),
    "Female" : MessageLookupByLibrary.simpleMessage("Female"),
    "Final" : MessageLookupByLibrary.simpleMessage("Final"),
    "Final score" : MessageLookupByLibrary.simpleMessage("Final score"),
    "Flagrant Foul" : MessageLookupByLibrary.simpleMessage("Flagrant Foul"),
    "For" : MessageLookupByLibrary.simpleMessage("For"),
    "Foul" : MessageLookupByLibrary.simpleMessage("Foul"),
    "Foul Flagrant" : MessageLookupByLibrary.simpleMessage("Foul Flagrant"),
    "Foul Technical" : MessageLookupByLibrary.simpleMessage("Foul Technical"),
    "Fouls" : MessageLookupByLibrary.simpleMessage("Fouls"),
    "Friend" : MessageLookupByLibrary.simpleMessage("Friend"),
    "GALLERY" : MessageLookupByLibrary.simpleMessage("GALLERY"),
    "Game" : MessageLookupByLibrary.simpleMessage("Game"),
    "Game Time" : MessageLookupByLibrary.simpleMessage("Game Time"),
    "Game end" : MessageLookupByLibrary.simpleMessage("Game end"),
    "Game notes" : MessageLookupByLibrary.simpleMessage("Game notes"),
    "Games" : MessageLookupByLibrary.simpleMessage("Games"),
    "Guardian" : MessageLookupByLibrary.simpleMessage("Guardian"),
    "Guest" : MessageLookupByLibrary.simpleMessage("Guest"),
    "Home" : MessageLookupByLibrary.simpleMessage("Home"),
    "Home team won" : MessageLookupByLibrary.simpleMessage("Home team won"),
    "I know I am getting better at golf because I am hitting fewer spectators." : MessageLookupByLibrary.simpleMessage("I know I am getting better at golf because I am hitting fewer spectators."),
    "I\'ve missed more than 9000 shots in my career. I\'ve lost almost 300 games. 26 times, I\'ve been trusted to take the game winning shot and missed. I\'ve failed over and over and over again in my life. And that is why I succeed." : MessageLookupByLibrary.simpleMessage("I\'ve missed more than 9000 shots in my career. I\'ve lost almost 300 games. 26 times, I\'ve been trusted to take the game winning shot and missed. I\'ve failed over and over and over again in my life. And that is why I succeed."),
    "Import\nplayers" : MessageLookupByLibrary.simpleMessage("Import\nplayers"),
    "In progress" : MessageLookupByLibrary.simpleMessage("In progress"),
    "Information about the coach" : MessageLookupByLibrary.simpleMessage("Information about the coach"),
    "Invalid URL" : MessageLookupByLibrary.simpleMessage("Invalid URL"),
    "Invited as an Administrator" : MessageLookupByLibrary.simpleMessage("Invited as an Administrator"),
    "Invited to team" : MessageLookupByLibrary.simpleMessage("Invited to team"),
    "Invites" : MessageLookupByLibrary.simpleMessage("Invites"),
    "JOIN LEAGUE" : MessageLookupByLibrary.simpleMessage("JOIN LEAGUE"),
    "Jersey Number" : MessageLookupByLibrary.simpleMessage("Jersey Number"),
    "LOGIN" : MessageLookupByLibrary.simpleMessage("LOGIN"),
    "LOGOUT" : MessageLookupByLibrary.simpleMessage("LOGOUT"),
    "League" : MessageLookupByLibrary.simpleMessage("League"),
    "League the team is playing in" : MessageLookupByLibrary.simpleMessage("League the team is playing in"),
    "League/Tournaments" : MessageLookupByLibrary.simpleMessage("League/Tournaments"),
    "Lies, damn lies and statistics" : MessageLookupByLibrary.simpleMessage("Lies, damn lies and statistics"),
    "Load more" : MessageLookupByLibrary.simpleMessage("Load more"),
    "Loading..." : MessageLookupByLibrary.simpleMessage("Loading..."),
    "Location" : MessageLookupByLibrary.simpleMessage("Location"),
    "Loss" : MessageLookupByLibrary.simpleMessage("Loss"),
    "Male" : MessageLookupByLibrary.simpleMessage("Male"),
    "Maybe" : MessageLookupByLibrary.simpleMessage("Maybe"),
    "Me" : MessageLookupByLibrary.simpleMessage("Me"),
    "Members" : MessageLookupByLibrary.simpleMessage("Members"),
    "Message" : MessageLookupByLibrary.simpleMessage("Message"),
    "Minutes before game" : MessageLookupByLibrary.simpleMessage("Minutes before game"),
    "Minutes to arrive before game" : MessageLookupByLibrary.simpleMessage("Minutes to arrive before game"),
    "Monthly" : MessageLookupByLibrary.simpleMessage("Monthly"),
    "Must not be empty" : MessageLookupByLibrary.simpleMessage("Must not be empty"),
    "N/A" : MessageLookupByLibrary.simpleMessage("N/A"),
    "NEW" : MessageLookupByLibrary.simpleMessage("NEW"),
    "NEW MESSAGE" : MessageLookupByLibrary.simpleMessage("NEW MESSAGE"),
    "Name" : MessageLookupByLibrary.simpleMessage("Name"),
    "Name can only contain alphanumerical characters." : MessageLookupByLibrary.simpleMessage("Name can only contain alphanumerical characters."),
    "Name of the coach" : MessageLookupByLibrary.simpleMessage("Name of the coach"),
    "Name of the opponent." : MessageLookupByLibrary.simpleMessage("Name of the opponent."),
    "Need to be an administrator" : MessageLookupByLibrary.simpleMessage("Need to be an administrator"),
    "Need to have a subject" : MessageLookupByLibrary.simpleMessage("Need to have a subject"),
    "Need to select a place" : MessageLookupByLibrary.simpleMessage("Need to select a place"),
    "Need to select a role" : MessageLookupByLibrary.simpleMessage("Need to select a role"),
    "Needs Invite" : MessageLookupByLibrary.simpleMessage("Needs Invite"),
    "New Division Name" : MessageLookupByLibrary.simpleMessage("New Division Name"),
    "New Season Name" : MessageLookupByLibrary.simpleMessage("New Season Name"),
    "New player name" : MessageLookupByLibrary.simpleMessage("New player name"),
    "New player name of player in team" : MessageLookupByLibrary.simpleMessage("New player name of player in team"),
    "News" : MessageLookupByLibrary.simpleMessage("News"),
    "No Media" : MessageLookupByLibrary.simpleMessage("No Media"),
    "No Messages" : MessageLookupByLibrary.simpleMessage("No Messages"),
    "No News" : MessageLookupByLibrary.simpleMessage("No News"),
    "No account found for email or internal error occurred" : MessageLookupByLibrary.simpleMessage("No account found for email or internal error occurred"),
    "No club" : MessageLookupByLibrary.simpleMessage("No club"),
    "No coaches" : MessageLookupByLibrary.simpleMessage("No coaches"),
    "No divisions" : MessageLookupByLibrary.simpleMessage("No divisions"),
    "No event" : MessageLookupByLibrary.simpleMessage("No event"),
    "No games" : MessageLookupByLibrary.simpleMessage("No games"),
    "No games this season" : MessageLookupByLibrary.simpleMessage("No games this season"),
    "No games to display, check filters" : MessageLookupByLibrary.simpleMessage("No games to display, check filters"),
    "No invites" : MessageLookupByLibrary.simpleMessage("No invites"),
    "No leagues" : MessageLookupByLibrary.simpleMessage("No leagues"),
    "No players" : MessageLookupByLibrary.simpleMessage("No players"),
    "No repeat" : MessageLookupByLibrary.simpleMessage("No repeat"),
    "No result." : MessageLookupByLibrary.simpleMessage("No result."),
    "No seasons" : MessageLookupByLibrary.simpleMessage("No seasons"),
    "No teams" : MessageLookupByLibrary.simpleMessage("No teams"),
    "No tournaments" : MessageLookupByLibrary.simpleMessage("No tournaments"),
    "Non Player" : MessageLookupByLibrary.simpleMessage("Non Player"),
    "None" : MessageLookupByLibrary.simpleMessage("None"),
    "Not archived" : MessageLookupByLibrary.simpleMessage("Not archived"),
    "Not finished" : MessageLookupByLibrary.simpleMessage("Not finished"),
    "Not making it" : MessageLookupByLibrary.simpleMessage("Not making it"),
    "Not started" : MessageLookupByLibrary.simpleMessage("Not started"),
    "Notes for the game" : MessageLookupByLibrary.simpleMessage("Notes for the game"),
    "Notes for the training" : MessageLookupByLibrary.simpleMessage("Notes for the training"),
    "O/RB" : MessageLookupByLibrary.simpleMessage("O/RB"),
    "OFF RB" : MessageLookupByLibrary.simpleMessage("OFF RB"),
    "OPEN" : MessageLookupByLibrary.simpleMessage("OPEN"),
    "Off Rebound" : MessageLookupByLibrary.simpleMessage("Off Rebound"),
    "Official" : MessageLookupByLibrary.simpleMessage("Official"),
    "Official results don\'t match" : MessageLookupByLibrary.simpleMessage("Official results don\'t match"),
    "On changes to games/events" : MessageLookupByLibrary.simpleMessage("On changes to games/events"),
    "Opponent" : MessageLookupByLibrary.simpleMessage("Opponent"),
    "Opponents with results" : MessageLookupByLibrary.simpleMessage("Opponents with results"),
    "Opponents without results" : MessageLookupByLibrary.simpleMessage("Opponents without results"),
    "Optional" : MessageLookupByLibrary.simpleMessage("Optional"),
    "Other sport" : MessageLookupByLibrary.simpleMessage("Other sport"),
    "Overtime" : MessageLookupByLibrary.simpleMessage("Overtime"),
    "Overtime 1" : MessageLookupByLibrary.simpleMessage("Overtime 1"),
    "Overtime Break" : MessageLookupByLibrary.simpleMessage("Overtime Break"),
    "PERIOD" : MessageLookupByLibrary.simpleMessage("PERIOD"),
    "PLAYER" : MessageLookupByLibrary.simpleMessage("PLAYER"),
    "PUBLIC" : MessageLookupByLibrary.simpleMessage("PUBLIC"),
    "Parent" : MessageLookupByLibrary.simpleMessage("Parent"),
    "Password" : MessageLookupByLibrary.simpleMessage("Password"),
    "Passwords must match" : MessageLookupByLibrary.simpleMessage("Passwords must match"),
    "Pct" : MessageLookupByLibrary.simpleMessage("Pct"),
    "Penalty" : MessageLookupByLibrary.simpleMessage("Penalty"),
    "Period" : MessageLookupByLibrary.simpleMessage("Period"),
    "Period 1" : MessageLookupByLibrary.simpleMessage("Period 1"),
    "Period 2" : MessageLookupByLibrary.simpleMessage("Period 2"),
    "Period 3" : MessageLookupByLibrary.simpleMessage("Period 3"),
    "Period 4" : MessageLookupByLibrary.simpleMessage("Period 4"),
    "Period 5" : MessageLookupByLibrary.simpleMessage("Period 5"),
    "Period 6" : MessageLookupByLibrary.simpleMessage("Period 6"),
    "Period x" : MessageLookupByLibrary.simpleMessage("Period x"),
    "Personal Foul" : MessageLookupByLibrary.simpleMessage("Personal Foul"),
    "Phone Number" : MessageLookupByLibrary.simpleMessage("Phone Number"),
    "Phone number (optional)" : MessageLookupByLibrary.simpleMessage("Phone number (optional)"),
    "Photo" : MessageLookupByLibrary.simpleMessage("Photo"),
    "Place notes, ie court #" : MessageLookupByLibrary.simpleMessage("Place notes, ie court #"),
    "Player" : MessageLookupByLibrary.simpleMessage("Player"),
    "Player Name" : MessageLookupByLibrary.simpleMessage("Player Name"),
    "Player deleted" : MessageLookupByLibrary.simpleMessage("Player deleted"),
    "Player email address" : MessageLookupByLibrary.simpleMessage("Player email address"),
    "Players" : MessageLookupByLibrary.simpleMessage("Players"),
    "Please choose a gender." : MessageLookupByLibrary.simpleMessage("Please choose a gender."),
    "Please choose a password." : MessageLookupByLibrary.simpleMessage("Please choose a password."),
    "Please choose a sport." : MessageLookupByLibrary.simpleMessage("Please choose a sport."),
    "Please choose an opponent." : MessageLookupByLibrary.simpleMessage("Please choose an opponent."),
    "Please fix the items outlined in red" : MessageLookupByLibrary.simpleMessage("Please fix the items outlined in red"),
    "Points" : MessageLookupByLibrary.simpleMessage("Points"),
    "Practice" : MessageLookupByLibrary.simpleMessage("Practice"),
    "Previous Seasons" : MessageLookupByLibrary.simpleMessage("Previous Seasons"),
    "Pts" : MessageLookupByLibrary.simpleMessage("Pts"),
    "RBs" : MessageLookupByLibrary.simpleMessage("RBs"),
    "REMOVE FROM TEAM" : MessageLookupByLibrary.simpleMessage("REMOVE FROM TEAM"),
    "RESEND EMAIL" : MessageLookupByLibrary.simpleMessage("RESEND EMAIL"),
    "Rebounds" : MessageLookupByLibrary.simpleMessage("Rebounds"),
    "Regulation" : MessageLookupByLibrary.simpleMessage("Regulation"),
    "Repeat" : MessageLookupByLibrary.simpleMessage("Repeat"),
    "Reset Timer" : MessageLookupByLibrary.simpleMessage("Reset Timer"),
    "Role" : MessageLookupByLibrary.simpleMessage("Role"),
    "SAVE" : MessageLookupByLibrary.simpleMessage("SAVE"),
    "SEND" : MessageLookupByLibrary.simpleMessage("SEND"),
    "SET CLUB" : MessageLookupByLibrary.simpleMessage("SET CLUB"),
    "SET FINAL SCORE" : MessageLookupByLibrary.simpleMessage("SET FINAL SCORE"),
    "SHARE PLAYER" : MessageLookupByLibrary.simpleMessage("SHARE PLAYER"),
    "SHARE TEAM" : MessageLookupByLibrary.simpleMessage("SHARE TEAM"),
    "SKIP" : MessageLookupByLibrary.simpleMessage("SKIP"),
    "START" : MessageLookupByLibrary.simpleMessage("START"),
    "START GAME" : MessageLookupByLibrary.simpleMessage("START GAME"),
    "STATS" : MessageLookupByLibrary.simpleMessage("STATS"),
    "STL" : MessageLookupByLibrary.simpleMessage("STL"),
    "STREAM" : MessageLookupByLibrary.simpleMessage("STREAM"),
    "SUB" : MessageLookupByLibrary.simpleMessage("SUB"),
    "Save Failed" : MessageLookupByLibrary.simpleMessage("Save Failed"),
    "Searching..." : MessageLookupByLibrary.simpleMessage("Searching..."),
    "Season" : MessageLookupByLibrary.simpleMessage("Season"),
    "Season name is required" : MessageLookupByLibrary.simpleMessage("Season name is required"),
    "Seasons" : MessageLookupByLibrary.simpleMessage("Seasons"),
    "Select Media" : MessageLookupByLibrary.simpleMessage("Select Media"),
    "Select Player" : MessageLookupByLibrary.simpleMessage("Select Player"),
    "Select club" : MessageLookupByLibrary.simpleMessage("Select club"),
    "Select game" : MessageLookupByLibrary.simpleMessage("Select game"),
    "Select gender" : MessageLookupByLibrary.simpleMessage("Select gender"),
    "Select opponent" : MessageLookupByLibrary.simpleMessage("Select opponent"),
    "Select place" : MessageLookupByLibrary.simpleMessage("Select place"),
    "Select player" : MessageLookupByLibrary.simpleMessage("Select player"),
    "Select relationship" : MessageLookupByLibrary.simpleMessage("Select relationship"),
    "Select role" : MessageLookupByLibrary.simpleMessage("Select role"),
    "Select season" : MessageLookupByLibrary.simpleMessage("Select season"),
    "Select sport" : MessageLookupByLibrary.simpleMessage("Select sport"),
    "Select team" : MessageLookupByLibrary.simpleMessage("Select team"),
    "Send message" : MessageLookupByLibrary.simpleMessage("Send message"),
    "Send to yourself" : MessageLookupByLibrary.simpleMessage("Send to yourself"),
    "Sent email to your email address to reset your password" : MessageLookupByLibrary.simpleMessage("Sent email to your email address to reset your password"),
    "Sent verification email, please check your email inbox." : MessageLookupByLibrary.simpleMessage("Sent verification email, please check your email inbox."),
    "Settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "Share team" : MessageLookupByLibrary.simpleMessage("Share team"),
    "Short Description" : MessageLookupByLibrary.simpleMessage("Short Description"),
    "Shots" : MessageLookupByLibrary.simpleMessage("Shots"),
    "Sign out" : MessageLookupByLibrary.simpleMessage("Sign out"),
    "Soccer" : MessageLookupByLibrary.simpleMessage("Soccer"),
    "Softball" : MessageLookupByLibrary.simpleMessage("Softball"),
    "Special Events" : MessageLookupByLibrary.simpleMessage("Special Events"),
    "Start Game" : MessageLookupByLibrary.simpleMessage("Start Game"),
    "Start Game - Breaks" : MessageLookupByLibrary.simpleMessage("Start Game - Breaks"),
    "Stats" : MessageLookupByLibrary.simpleMessage("Stats"),
    "Steal" : MessageLookupByLibrary.simpleMessage("Steal"),
    "Steals" : MessageLookupByLibrary.simpleMessage("Steals"),
    "Stl" : MessageLookupByLibrary.simpleMessage("Stl"),
    "Stream Live" : MessageLookupByLibrary.simpleMessage("Stream Live"),
    "Subject" : MessageLookupByLibrary.simpleMessage("Subject"),
    "Substitution" : MessageLookupByLibrary.simpleMessage("Substitution"),
    "Summary" : MessageLookupByLibrary.simpleMessage("Summary"),
    "T/O" : MessageLookupByLibrary.simpleMessage("T/O"),
    "TEAM" : MessageLookupByLibrary.simpleMessage("TEAM"),
    "Team" : MessageLookupByLibrary.simpleMessage("Team"),
    "Team Fuse" : MessageLookupByLibrary.simpleMessage("Team Fuse"),
    "Team Name" : MessageLookupByLibrary.simpleMessage("Team Name"),
    "Team Selected" : MessageLookupByLibrary.simpleMessage("Team Selected"),
    "Team deleted" : MessageLookupByLibrary.simpleMessage("Team deleted"),
    "Teams" : MessageLookupByLibrary.simpleMessage("Teams"),
    "Technical Foul" : MessageLookupByLibrary.simpleMessage("Technical Foul"),
    "The email to resend the password to" : MessageLookupByLibrary.simpleMessage("The email to resend the password to"),
    "The only time you run out of chances is when you stop taking them." : MessageLookupByLibrary.simpleMessage("The only time you run out of chances is when you stop taking them."),
    "Tie" : MessageLookupByLibrary.simpleMessage("Tie"),
    "Timer count up" : MessageLookupByLibrary.simpleMessage("Timer count up"),
    "To setup a club for a team you need to be an administrator for both the club and for the team.  This will let you connect the both together.  Once connected all administrators of the club will also be administrators for the team." : MessageLookupByLibrary.simpleMessage("To setup a club for a team you need to be an administrator for both the club and for the team.  This will let you connect the both together.  Once connected all administrators of the club will also be administrators for the team."),
    "Tournament" : MessageLookupByLibrary.simpleMessage("Tournament"),
    "Track attendance" : MessageLookupByLibrary.simpleMessage("Track attendance"),
    "Training" : MessageLookupByLibrary.simpleMessage("Training"),
    "Training end" : MessageLookupByLibrary.simpleMessage("Training end"),
    "Training notes" : MessageLookupByLibrary.simpleMessage("Training notes"),
    "Training times" : MessageLookupByLibrary.simpleMessage("Training times"),
    "Turnover" : MessageLookupByLibrary.simpleMessage("Turnover"),
    "Turnovers" : MessageLookupByLibrary.simpleMessage("Turnovers"),
    "UPDATE SCORE" : MessageLookupByLibrary.simpleMessage("UPDATE SCORE"),
    "UPLOAD" : MessageLookupByLibrary.simpleMessage("UPLOAD"),
    "URL" : MessageLookupByLibrary.simpleMessage("URL"),
    "USE OFFICIAL" : MessageLookupByLibrary.simpleMessage("USE OFFICIAL"),
    "Unable to load games" : MessageLookupByLibrary.simpleMessage("Unable to load games"),
    "Uniform" : MessageLookupByLibrary.simpleMessage("Uniform"),
    "Uniform to wear" : MessageLookupByLibrary.simpleMessage("Uniform to wear"),
    "Unknown" : MessageLookupByLibrary.simpleMessage("Unknown"),
    "Until" : MessageLookupByLibrary.simpleMessage("Until"),
    "Upcoming games/events" : MessageLookupByLibrary.simpleMessage("Upcoming games/events"),
    "Upload Video" : MessageLookupByLibrary.simpleMessage("Upload Video"),
    "Use the results of the official game for this game?" : MessageLookupByLibrary.simpleMessage("Use the results of the official game for this game?"),
    "Username is empty." : MessageLookupByLibrary.simpleMessage("Username is empty."),
    "VIEW" : MessageLookupByLibrary.simpleMessage("VIEW"),
    "Verify password" : MessageLookupByLibrary.simpleMessage("Verify password"),
    "Video" : MessageLookupByLibrary.simpleMessage("Video"),
    "Weekly" : MessageLookupByLibrary.simpleMessage("Weekly"),
    "What stands in the way, becomes the way." : MessageLookupByLibrary.simpleMessage("What stands in the way, becomes the way."),
    "Where" : MessageLookupByLibrary.simpleMessage("Where"),
    "Will be there" : MessageLookupByLibrary.simpleMessage("Will be there"),
    "Win" : MessageLookupByLibrary.simpleMessage("Win"),
    "You must expect great things of yourself before you can do them." : MessageLookupByLibrary.simpleMessage("You must expect great things of yourself before you can do them."),
    "You must have some players in a season to be able to create a game." : MessageLookupByLibrary.simpleMessage("You must have some players in a season to be able to create a game."),
    "Your email address" : MessageLookupByLibrary.simpleMessage("Your email address"),
    "Your name" : MessageLookupByLibrary.simpleMessage("Your name"),
    "arriveBefore" : m0,
    "away" : MessageLookupByLibrary.simpleMessage("away"),
    "cardResultDetailsFinal" : m1,
    "cardResultDetailsOvertime" : m2,
    "cardResultDetailsOvertimeAndPenalty" : m3,
    "cardResultDetailsPenalty" : m4,
    "confirmCreateTeamForLeague" : m5,
    "confirmDeleteAsAdmin" : m6,
    "confirmDeleteClub" : m7,
    "confirmDeleteInvitePlayer" : m8,
    "confirmDeleteInviteTeam" : m9,
    "confirmDeleteLeagueAsAdmin" : m10,
    "confirmDeleteLeagueTeam" : m11,
    "confirmDeleteMember" : m12,
    "confirmDeletePlayerBreakout" : m13,
    "confirmRemoveFromTeam" : m14,
    "displayNameRelationshipBreakout" : m15,
    "eventTitleNowSpecialEvent" : m16,
    "eventTitleNowSpecialEventName" : m17,
    "eventTitleNowSpecialEventNameEndTime" : m18,
    "eventTitleNowSpecialEventNameEndTimeTimeZone" : m19,
    "eventTitleNowSpecialEventNameTimeZone" : m20,
    "eventTitleNowSpecialEventStartAndEnd" : m21,
    "eventTitleNowSpecialEventStartAndEndTimezone" : m22,
    "eventTitleNowSpecialWithTimezone" : m23,
    "eventTitleSpecialEvent" : m24,
    "eventTitleSpecialEventName" : m25,
    "eventTitleSpecialEventNameEndTime" : m26,
    "eventTitleSpecialEventNameEndTimeTimeZone" : m27,
    "eventTitleSpecialEventNameTimeZone" : m28,
    "eventTitleSpecialEventStartAndEnd" : m29,
    "eventTitleSpecialEventStartAndEndTimezone" : m30,
    "eventTitleSpecialWithTimezone" : m31,
    "finalOfficialScoreBodyOvertime" : m32,
    "finalOfficialScoreBodyOvertimePenalty" : m33,
    "finalOfficialScoreBodyPenalty" : m34,
    "finalScoreBody" : m35,
    "followPlayer" : m36,
    "gameAddressArriveAt" : m37,
    "gameResultOfficialBreakout" : m38,
    "gameTitleNowSharedEnd" : m39,
    "gameTitleNowSharedEndShort" : m40,
    "gameTitleNowSharedShort" : m41,
    "gameTitleNowSharedTime" : m42,
    "gameTitleSharedEnd" : m43,
    "gameTitleSharedEndShort" : m44,
    "gameTitleSharedShort" : m45,
    "gameTitleSharedTime" : m46,
    "gameTitleVsGame" : m47,
    "home" : MessageLookupByLibrary.simpleMessage("home"),
    "invitedBy" : m48,
    "invitedPeople" : m49,
    "invitedToTeamWithName" : m50,
    "madeEventType" : m51,
    "missedEventType" : m52,
    "nameAndTeam" : m53,
    "numberOfTeamsForPlayer" : m54,
    "numberOfUserForPlayer" : m55,
    "onlyScoreBreakout" : m56,
    "opponentSeason" : m57,
    "opponentWinRecordBreakout" : m58,
    "pendingInvites" : m59,
    "periodEnd" : m60,
    "periodNameOvertimeNumber" : m61,
    "periodNameRegulationNumber" : m62,
    "periodStartText" : m63,
    "playerInviteDesc" : m64,
    "resultInProgressOvertime" : m65,
    "resultInProgressOvertimePenalty" : m66,
    "resultInProgressPenalty" : m67,
    "resultInProgressRegulation" : m68,
    "resultLossOvertime" : m69,
    "resultLossOvertimePenalty" : m70,
    "resultLossPenalty" : m71,
    "resultLossRegulation" : m72,
    "resultTieOvertime" : m73,
    "resultTieOvertimePenalty" : m74,
    "resultTiePenalty" : m75,
    "resultTieRegulation" : m76,
    "resultWinOvertime" : m77,
    "resultWinOvertimePenalty" : m78,
    "resultWinPenalty" : m79,
    "resultWinRegulation" : m80,
    "seasonSummaryExpanded" : m81,
    "teamAndSeason" : m82,
    "teamNumbers" : m83,
    "titleWith" : m84,
    "trainingTitleEnd" : m85,
    "trainingTitleEndShortName" : m86,
    "trainingTitleNowEnd" : m87,
    "trainingTitleNowEndShortName" : m88,
    "trainingTitleNowShortName" : m89,
    "trainingTitleNowTime" : m90,
    "trainingTitleShortName" : m91,
    "trainingTitleTime" : m92,
    "verifyExplanation" : m93,
    "wearUniform" : m94,
    "winRecordBreakout" : m95
  };
}
