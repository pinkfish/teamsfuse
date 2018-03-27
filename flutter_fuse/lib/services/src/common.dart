String getString(dynamic data) {
  if (data == null) {
    return '';
  }
  return data;
}

bool getBool(dynamic data) {
  if (data == null) {
    return false;
  }
  return data;
}

num getNum(dynamic data) {
  if (data == null) {
    return 0;
  }
  return data;
}

// shared keys.
const String NAME = 'name';
const String ARRIVEEARLY = 'arriveEarly';
const String NOTES = 'notes';
const String ADDED = 'added';
const String PHOTOURL = 'photourl';

// Collection definitions for firestore.
const String MESSAGES_COLLECTION = "Messages";
const String MESSAGE_RECIPIENTS_COLLECTION = "MessageRecipients";
const String TEAMS_COLLECTION = "Teams";
const String GAMES_COLLECTION = "Games";
const String SEASONS_COLLECTION = "Seasons";
const String OPPONENT_COLLECTION = "Opponents";
const String INVITE_COLLECTION = "Invites";
const String PLAYERS_COLLECTION = "Players";

enum UpdateReason { Delete, Update }

