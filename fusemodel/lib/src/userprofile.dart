import 'package:built_value/built_value.dart';

import 'common.dart';

part 'userprofile.g.dart';

///
/// The profile data for users in the system
///
abstract class FusedUserProfile
    implements Built<FusedUserProfile, FusedUserProfileBuilder> {
  String get displayName;
  String get email;
  String get phoneNumber;
  bool get emailUpcomingGame;
  bool get emailOnUpdates;
  bool get notifyOnlyForGames;
  @nullable
  String get uid;

  FusedUserProfile._();
  factory FusedUserProfile([updates(FusedUserProfileBuilder b)]) =
      _$FusedUserProfile;

  /// Load from the json
  static FusedUserProfileBuilder fromJSON(
      String uid, Map<String, dynamic> data) {
    return FusedUserProfileBuilder()
      ..uid = uid
      ..displayName = data[_NAME]
      ..email = data[_EMAIL]
      ..phoneNumber = data[_PHONE]
      ..emailOnUpdates = getBool(data[_EMAIL_ON_UPDATES])
      ..emailUpcomingGame = getBool(data[_EMAIL_UPCOMING])
      ..notifyOnlyForGames = getBool(data[_ONLY_FOR_GAMES]) ?? true;
  }

  /// The initials for the user.
  String initials() {
    return displayName.splitMapJoin(" ",
        onNonMatch: (String str) => str.substring(0, 1));
  }

  static const String _NAME = "name";
  static const String _EMAIL = "email";
  static const String _PHONE = "phone";
  static const String _EMAIL_UPCOMING = "emailUpcoming";
  static const String _EMAIL_ON_UPDATES = "emailOnUpdates";
  static const String _ONLY_FOR_GAMES = "notifyOnlyForGames";
  static const String TOKENS = "tokens";

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_NAME] = displayName;
    ret[_EMAIL] = email;
    ret[_PHONE] = phoneNumber;
    ret[_EMAIL_ON_UPDATES] = emailOnUpdates ?? false;
    ret[_EMAIL_UPCOMING] = emailUpcomingGame ?? false;
    ret[_ONLY_FOR_GAMES] = notifyOnlyForGames ?? true;
    return ret;
  }

  String toString() {
    return "UserProfile [$displayName $email $phoneNumber Upcoming: $emailUpcomingGame Updates: $emailOnUpdates]";
  }
}
