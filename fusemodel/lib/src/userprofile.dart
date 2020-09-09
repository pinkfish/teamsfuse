import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializer.dart';

part 'userprofile.g.dart';

///
/// The profile data for users in the system
///
abstract class FusedUserProfile
    implements Built<FusedUserProfile, FusedUserProfileBuilder> {
  String get displayName;
  String get email;
  @nullable
  String get phoneNumber;
  bool get emailUpcomingGame;
  bool get emailOnUpdates;
  bool get notifyOnlyForGames;
  String get uid;

  FusedUserProfile._();
  factory FusedUserProfile([updates(FusedUserProfileBuilder b)]) =
      _$FusedUserProfile;

  /// The initials for the user.
  String initials() {
    return displayName.splitMapJoin(" ",
        onNonMatch: (String str) => str.substring(0, 1));
  }

  String toString() {
    return "UserProfile [$displayName $email $phoneNumber Upcoming: $emailUpcomingGame Updates: $emailOnUpdates]";
  }

  static const String TOKENS = "tokens";

  static void _initializeBuilder(FusedUserProfileBuilder b) => b
    ..emailUpcomingGame = true
    ..emailOnUpdates = true
    ..notifyOnlyForGames = false;

  /// Load from the json
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(FusedUserProfile.serializer, this);
  }

  static FusedUserProfile fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(FusedUserProfile.serializer, jsonData);
  }

  static Serializer<FusedUserProfile> get serializer =>
      _$fusedUserProfileSerializer;
}
