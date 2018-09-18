///
/// Used to get data from a json blob, makes sure it is actually a string.
///
String getString(dynamic data) {
  if (data == null) {
    return '';
  }
  return data;
}

///
/// Gets a boolean from a json blob, has a default value if null.
///
bool getBool(dynamic data, {bool defaultValue = false}) {
  if (data == null) {
    return defaultValue;
  }
  return data;
}

///
/// Gets a number from a json blob, has a default value if null or the string
/// is not a number.
///
num getNum(dynamic data, {num defaultValue = 0}) {
  if (data == null) {
    return defaultValue;
  }
  if (data is String) {
    num val = num.tryParse(data);
    if (val == null) {
      return defaultValue;
    }
    return val;
  }
  return data;
}

// shared keys.
const String NAME = 'name';
const String ARRIVALTIME = 'arrivalTime';
const String NOTES = 'notes';
const String ADDED = 'added';
const String PHOTOURL = 'photourl';

// Collection definitions for firestore.
/// Messages collection in firestore.
const String MESSAGES_COLLECTION = "Messages";
const String MESSAGE_RECIPIENTS_COLLECTION = "MessageRecipients";
const String TEAMS_COLLECTION = "Teams";
const String GAMES_COLLECTION = "Games";
const String GAMES_SHARED_COLLECTION = "GamesShared";
const String SEASONS_COLLECTION = "Seasons";
const String OPPONENT_COLLECTION = "Opponents";
const String INVITE_COLLECTION = "Invites";
const String PLAYERS_COLLECTION = "Players";
const String GAME_LOG_COLLECTION = "Logs";
const String USER_DATA_COLLECTION = "UserData";
const String CLUB_COLLECTION = "Clubs";
const String LEAGUE_COLLECTON = "League";
const String TOURNAMENT_TEAM_COLLECTON = "TeamLeague";
const String LEAGUE_DIVISION_COLLECTION = "LeagueDivision";
const String LEAGUE_SEASON_COLLECTION = "LeagueSeason";
const String LEAGUE_TEAM_COLLECTION = "LeagueTeam";

/// The reason for the update.
enum UpdateReason { Delete, Update }

/// Handles a yes/no/unset setup.
enum Tristate { Yes, No, Unset }

///
/// Class to handle turning email into a normalized setup.
///
class _EmailStuff {
  _EmailStuff({this.plus = false, this.dot = false, this.alias});

  bool plus;
  bool dot;
  String alias;

  @override
  String toString() {
    return '_EmailStuff{plus: $plus, dot: $dot, alias: $alias}';
  }
}

Map<String, _EmailStuff> _emailProviders = {
  "gmail.com": new _EmailStuff(plus: true, dot: true),
  "googlemail.com": new _EmailStuff(plus: true, dot: true, alias: "gmail.com"),
  "hotmail.com": new _EmailStuff(plus: true, dot: false),
  "live.com": new _EmailStuff(plus: true, dot: true),
  "outlook.com": new _EmailStuff(plus: true, dot: false),
};

///
/// Normalizes the input email address to make it consistent and comparable.
///
String normalizeEmail(String eMail) {
  const String PLUS_ONLY = r"\+.*$";
  const String DOT_ONLY = r"\.";
  String email = eMail.toLowerCase();
  List<String> emailParts = email.split("@");

  if (emailParts.length != 2) {
    return email;
  }

  String username = emailParts[0];
  String domain = emailParts[1];

  if (_emailProviders.containsKey(domain)) {
    print('Frogm 2 ' + _emailProviders[domain].toString());
    if (_emailProviders[domain].dot) {
      username = username.replaceAll(DOT_ONLY, "");
    }
    if (_emailProviders[domain].plus) {
      username = username.replaceFirst(PLUS_ONLY, "");
    }
    if (_emailProviders[domain].alias != null) {
      domain = _emailProviders[domain].alias;
    }
  }
  print('Frog');

  return username + '@' + domain;
}
