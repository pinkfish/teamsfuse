import 'common.dart';

///
/// The profile data for users in the system
///
class FusedUserProfile {
  final String displayName;
  final String email;
  final String phoneNumber;
  final bool emailUpcomingGame;
  final bool emailOnUpdates;
  final bool notifyOnlyForGames;
  final String uid;

  FusedUserProfile(this.uid,
      {this.displayName,
      this.email,
      this.phoneNumber,
      this.emailUpcomingGame = false,
      this.emailOnUpdates = false,
      this.notifyOnlyForGames = true});

  FusedUserProfile.copy(FusedUserProfile copy)
      : uid = copy.uid,
        displayName = copy.displayName,
        email = copy.email,
        phoneNumber = copy.phoneNumber,
        emailOnUpdates = copy.emailOnUpdates,
        emailUpcomingGame = copy.emailUpcomingGame,
        notifyOnlyForGames = copy.notifyOnlyForGames;

  /// Load from the json
  FusedUserProfile.fromJSON(String uid, Map<String, dynamic> data)
      : uid = uid,
        displayName = data[_NAME],
        email = data[_EMAIL],
        phoneNumber = data[_PHONE],
        emailOnUpdates = getBool(data[_EMAIL_ON_UPDATES]),
        emailUpcomingGame = getBool(data[_EMAIL_UPCOMING]),
        notifyOnlyForGames = getBool(data[_ONLY_FOR_GAMES] ?? true);

  /// Copy with specific things changed.
  FusedUserProfile copyWith(
      {String uid,
      String email,
      String displayName,
      String phoneNumber,
      bool emailNewEvents,
      bool emailUpcomingGames}) {
    return new FusedUserProfile(uid ?? this.uid,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        emailOnUpdates: emailNewEvents ?? this.emailOnUpdates,
        emailUpcomingGame: emailUpcomingGames ?? this.emailUpcomingGame);
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
