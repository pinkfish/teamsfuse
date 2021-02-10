import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializer.dart';

part 'common.g.dart';

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
const String GAME_EVENT_COLLECTION = "GameEvents";
const String GAME_LOG_COLLECTION = "Logs";
const String GAMES_SHARED_COLLECTION = "GamesShared";
const String SEASONS_COLLECTION = "Seasons";
const String OPPONENT_COLLECTION = "Opponents";
const String MEDIA_COLLECTION = "Media";
const String INVITE_COLLECTION = "Invites";
const String PLAYERS_COLLECTION = "Players";
const String USER_DATA_COLLECTION = "UserData";
const String CLUB_COLLECTION = "Clubs";
const String COACH_COLLECTION = "Coaches";
const String LEAGUE_COLLECTON = "League";
const String LEAGUE_DIVISION_COLLECTION = "LeagueDivision";
const String LEAGUE_SEASON_COLLECTION = "LeagueSeason";
const String LEAGUE_TEAM_COLLECTION = "LeagueTeam";

/// The reason for the update.
enum UpdateReason { Delete, Update }

/// Handles a yes/no/unset setup.
class Tristate extends EnumClass {
  static Serializer<Tristate> get serializer => _$tristateSerializer;

  static const Tristate Yes = _$yes;
  static const Tristate No = _$no;
  static const Tristate Unset = _$unset;

  const Tristate._(String name) : super(name);

  static BuiltSet<Tristate> get values => _$tristateValues;

  static Tristate valueOf(String name) => _$tristateValueOf(name);
}

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

/// The sport the team is involved in
class Sport extends EnumClass {
  static Serializer<Sport> get serializer => _$sportSerializer;

  static const Sport Basketball = _$basketball;
  static const Sport Softball = _$softball;
  static const Sport Soccer = _$soccer;
  static const Sport Other = _$other;
  static const Sport None = _$none;

  const Sport._(String name) : super(name);

  static BuiltSet<Sport> get values => _$sportValues;

  static Sport valueOf(String name) => _$sportValueOf(name);
}

/// The gender associated with the team.
class Gender extends EnumClass {
  static Serializer<Gender> get serializer => _$genderSerializer;

  static const Gender Female = _$female;
  static const Gender Male = _$mole;
  static const Gender Coed = _$coed;
  static const Gender NA = _$nA;

  const Gender._(String name) : super(name);

  static BuiltSet<Gender> get values => _$genderValues;

  static Gender valueOf(String name) => _$genderValueOf(name);
}

///
/// Tracks if the section is added (or not).  Used to handle memberships.
///
abstract class AddedUid implements Built<AddedUid, AddedUidBuilder> {
  bool get added;

  AddedUid._();
  factory AddedUid([void Function(AddedUidBuilder) updates]) = _$AddedUid;

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(AddedUidBuilder b) => b..added = true;

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(AddedUid.serializer, this);
  }

  static AddedUid fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(AddedUid.serializer, jsonData);
  }

  static Serializer<AddedUid> get serializer => _$addedUidSerializer;
}

///
/// Class to track added and admin for clubs and other places this is
/// needed.
///
abstract class AddedOrAdmin
    implements Built<AddedOrAdmin, AddedOrAdminBuilder> {
  bool get admin;
  bool get added;

  AddedOrAdmin._();
  factory AddedOrAdmin([void Function(AddedOrAdminBuilder) updates]) =
      _$AddedOrAdmin;

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(AddedOrAdminBuilder b) => b
    ..added = true
    ..admin = false;

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(AddedOrAdmin.serializer, this);
  }

  static AddedOrAdmin fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(AddedOrAdmin.serializer, jsonData);
  }

  static Serializer<AddedOrAdmin> get serializer => _$addedOrAdminSerializer;
}
