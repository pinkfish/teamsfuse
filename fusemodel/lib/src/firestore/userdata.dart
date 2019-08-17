import 'package:built_value/built_value.dart';
import 'package:fusemodel/fusemodel.dart';

part 'userdata.g.dart';

///
/// Wrapped around the uaerdata into the firestore stuff.
///
abstract class UserData implements Built<UserData, UserDataBuilder> {
  String get email;
  String get uid;
  @nullable
  String get password;
  bool get isEmailVerified;
  @nullable
  FusedUserProfile get profile;
  UserData._();
  factory UserData([updates(UserDataBuilder b)]) = _$UserData;

  @override
  String toString() {
    return "UserData [$email $password $uid $profile]";
  }
}
