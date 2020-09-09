import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../invite.dart';
import '../../serializer.dart';

part 'inviteblocstate.g.dart';

class InviteBlocStateType extends EnumClass {
  static Serializer<InviteBlocStateType> get serializer =>
      _$inviteBlocStateTypeSerializer;

  static const InviteBlocStateType Uninitialized = _$uninitialized;
  static const InviteBlocStateType Loaded = _$loaded;

  const InviteBlocStateType._(String name) : super(name);

  static BuiltSet<InviteBlocStateType> get values => _$values;

  static InviteBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the invite bloc.  It tracks all the
/// exciting invite stuff.
///
@BuiltValue(instantiable: false)
abstract class InviteState {
  BuiltMap<String, Invite> get invites;
  InviteBlocStateType get type;

  // Don't save this stuff
  @BuiltValueField(serialize: false)
  bool get loadedFirestore;

  static InviteStateBuilder fromState(
      InviteState state, InviteStateBuilder builder) {
    return builder
      ..invites = state.invites.toBuilder()
      ..loadedFirestore = false;
  }

  static void initializeStateBuilder(InviteStateBuilder b) =>
      b..loadedFirestore = false;

  Map<String, dynamic> toMap();
}

///
/// The invite loaded from the database.
///
abstract class InviteLoaded
    implements InviteState, Built<InviteLoaded, InviteLoadedBuilder> {
  InviteLoaded._();
  factory InviteLoaded([void Function(InviteLoadedBuilder) updates]) =
      _$InviteLoaded;

  static InviteLoadedBuilder fromState(InviteState state) {
    return InviteState.fromState(state, InviteLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no invites loaded.
  static void _initializeBuilder(InviteLoadedBuilder b) {
    InviteState.initializeStateBuilder(b);

    b..type = InviteBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(InviteLoaded.serializer, this);
  }

  static InviteLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(InviteLoaded.serializer, jsonData);
  }

  static Serializer<InviteLoaded> get serializer => _$inviteLoadedSerializer;
}

///
/// The invite bloc that is unitialized.
///
abstract class InviteUninitialized
    implements
        InviteState,
        Built<InviteUninitialized, InviteUninitializedBuilder> {
  InviteUninitialized._();
  factory InviteUninitialized(
          [void Function(InviteUninitializedBuilder) updates]) =
      _$InviteUninitialized;

  static InviteUninitializedBuilder fromState(InviteState state) {
    return InviteState.fromState(state, InviteUninitializedBuilder());
  }

  /// Defaults for the state.  Always default to no invites loaded.
  static void _initializeBuilder(InviteUninitializedBuilder b) {
    InviteState.initializeStateBuilder(b);

    b..type = InviteBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(InviteUninitialized.serializer, this);
  }

  static InviteUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        InviteUninitialized.serializer, jsonData);
  }

  static Serializer<InviteUninitialized> get serializer =>
      _$inviteUninitializedSerializer;
}
