import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../serializer.dart';
import '../../userprofile.dart';

part 'profileblocstate.g.dart';

class ProfileBlocStateType extends EnumClass {
  static Serializer<ProfileBlocStateType> get serializer =>
      _$profileBlocStateTypeSerializer;

  static const ProfileBlocStateType Uninitialized = _$uninitialized;
  static const ProfileBlocStateType Loaded = _$loaded;

  const ProfileBlocStateType._(String name) : super(name);

  static BuiltSet<ProfileBlocStateType> get values => _$values;

  static ProfileBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the profile bloc.  It tracks all the
/// exciting profile stuff.
///
@BuiltValue(instantiable: false)
abstract class ProfileBlocState {
  @nullable
  FusedUserProfile get profile;
  ProfileBlocStateType get type;

  static ProfileBlocStateBuilder fromState(
      ProfileBlocState state, ProfileBlocStateBuilder builder) {
    return builder..profile = state.profile.toBuilder();
  }

  Map<String, dynamic> toMap();
}

///
/// The profile loaded from the database.
///
abstract class ProfileBlocLoaded
    implements
        ProfileBlocState,
        Built<ProfileBlocLoaded, ProfileBlocLoadedBuilder> {
  ProfileBlocLoaded._();
  factory ProfileBlocLoaded([void Function(ProfileBlocLoadedBuilder) updates]) =
      _$ProfileBlocLoaded;

  static ProfileBlocLoadedBuilder fromState(ProfileBlocState state) {
    return ProfileBlocState.fromState(state, ProfileBlocLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(ProfileBlocLoadedBuilder b) =>
      b..type = ProfileBlocStateType.Loaded;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(ProfileBlocLoaded.serializer, this);
  }

  static ProfileBlocLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(ProfileBlocLoaded.serializer, jsonData);
  }

  static Serializer<ProfileBlocLoaded> get serializer =>
      _$profileBlocLoadedSerializer;
}

///
/// The profile bloc that is unitialized.
///
abstract class ProfileBlocUninitialized
    implements
        ProfileBlocState,
        Built<ProfileBlocUninitialized, ProfileBlocUninitializedBuilder> {
  ProfileBlocUninitialized._();
  factory ProfileBlocUninitialized(
          [void Function(ProfileBlocUninitializedBuilder) updates]) =
      _$ProfileBlocUninitialized;

  static ProfileBlocUninitializedBuilder fromState(ProfileBlocState state) {
    return ProfileBlocState.fromState(state, ProfileBlocUninitializedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(ProfileBlocUninitializedBuilder b) =>
      b..type = ProfileBlocStateType.Uninitialized;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(ProfileBlocUninitialized.serializer, this);
  }

  static ProfileBlocUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        ProfileBlocUninitialized.serializer, jsonData);
  }

  static Serializer<ProfileBlocUninitialized> get serializer =>
      _$profileBlocUninitializedSerializer;
}
