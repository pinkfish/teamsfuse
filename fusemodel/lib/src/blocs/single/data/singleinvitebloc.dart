import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../serializer.dart';

part 'singleinvitebloc.g.dart';

///
/// The type of the invite bloc state.
///
class SingleInviteBlocStateType extends EnumClass {
  static Serializer<SingleInviteBlocStateType> get serializer =>
      _$singleInviteBlocStateTypeSerializer;

  static const SingleInviteBlocStateType Uninitialized = _$uninitialized;
  static const SingleInviteBlocStateType Loaded = _$loaded;
  static const SingleInviteBlocStateType Deleted = _$deleted;
  static const SingleInviteBlocStateType SaveFailed = _$saveFailed;
  static const SingleInviteBlocStateType Saving = _$saving;
  static const SingleInviteBlocStateType SaveDone = _$saveDone;

  const SingleInviteBlocStateType._(String name) : super(name);

  static BuiltSet<SingleInviteBlocStateType> get values => _$values;

  static SingleInviteBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the singleInvite bloc.  It tracks all the
/// exciting singleInvite stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleInviteState {
  @nullable
  Invite get invite;

  SingleInviteBlocStateType get type;

  static SingleInviteStateBuilder fromState(
      SingleInviteState state, SingleInviteStateBuilder builder) {
    return builder..invite = state.invite;
  }

  static void initializeStateBuilder(SingleInviteStateBuilder b) {}

  Map<String, dynamic> toMap();
}

///
/// The singleInvite loaded from the database.
///
abstract class SingleInviteLoaded
    implements
        SingleInviteState,
        Built<SingleInviteLoaded, SingleInviteLoadedBuilder> {
  SingleInviteLoaded._();
  factory SingleInviteLoaded(
          [void Function(SingleInviteLoadedBuilder) updates]) =
      _$SingleInviteLoaded;

  static SingleInviteLoadedBuilder fromState(SingleInviteState state) {
    return SingleInviteState.fromState(state, SingleInviteLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no invites loaded.
  static void _initializeBuilder(SingleInviteLoadedBuilder b) {
    SingleInviteState.initializeStateBuilder(b);

    b..type = SingleInviteBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleInviteLoaded.serializer, this);
  }

  static SingleInviteLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleInviteLoaded.serializer, jsonData);
  }

  static Serializer<SingleInviteLoaded> get serializer =>
      _$singleInviteLoadedSerializer;
}

///
/// The singleInvite bloc that is unitialized.
///
abstract class SingleInviteUninitialized
    implements
        SingleInviteState,
        Built<SingleInviteUninitialized, SingleInviteUninitializedBuilder> {
  SingleInviteUninitialized._();
  factory SingleInviteUninitialized(
          [void Function(SingleInviteUninitializedBuilder) updates]) =
      _$SingleInviteUninitialized;

  static SingleInviteUninitializedBuilder fromState(SingleInviteState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleInviteUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no invites loaded.
  static void _initializeBuilder(SingleInviteUninitializedBuilder b) {
    SingleInviteState.initializeStateBuilder(b);

    b..type = SingleInviteBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleInviteUninitialized.serializer, this);
  }

  static SingleInviteUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleInviteUninitialized.serializer, jsonData);
  }

  static Serializer<SingleInviteUninitialized> get serializer =>
      _$singleInviteUninitializedSerializer;
}

///
/// The singleInvite bloc that is unitialized.
///
abstract class SingleInviteDeleted
    implements
        SingleInviteState,
        Built<SingleInviteDeleted, SingleInviteDeletedBuilder> {
  SingleInviteDeleted._();
  factory SingleInviteDeleted(
          [void Function(SingleInviteDeletedBuilder) updates]) =
      _$SingleInviteDeleted;

  static SingleInviteDeletedBuilder fromState(SingleInviteState state) {
    // Nothing set in this case, just the type.
    return SingleInviteDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no invites loaded.
  static void _initializeBuilder(SingleInviteDeletedBuilder b) {
    SingleInviteState.initializeStateBuilder(b);

    b..type = SingleInviteBlocStateType.Deleted;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleInviteDeleted.serializer, this);
  }

  static SingleInviteDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleInviteDeleted.serializer, jsonData);
  }

  static Serializer<SingleInviteDeleted> get serializer =>
      _$singleInviteDeletedSerializer;
}

///
/// The singleInvite bloc that is unitialized.
///
abstract class SingleInviteSaveFailed
    implements
        SingleInviteState,
        Built<SingleInviteSaveFailed, SingleInviteSaveFailedBuilder> {
  @BuiltValueField(serialize: false)
  Object get error;

  SingleInviteSaveFailed._();
  factory SingleInviteSaveFailed(
          [void Function(SingleInviteSaveFailedBuilder) updates]) =
      _$SingleInviteSaveFailed;

  static SingleInviteSaveFailedBuilder fromState(SingleInviteState state) {
    return SingleInviteState.fromState(state, SingleInviteSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no invites loaded.
  static void _initializeBuilder(SingleInviteSaveFailedBuilder b) {
    SingleInviteState.initializeStateBuilder(b);

    b..type = SingleInviteBlocStateType.SaveFailed;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleInviteSaveFailed.serializer, this);
  }

  static SingleInviteSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleInviteSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleInviteSaveFailed> get serializer =>
      _$singleInviteSaveFailedSerializer;
}

///
/// The singleInvite bloc that is unitialized.
///
abstract class SingleInviteSaving
    implements
        SingleInviteState,
        Built<SingleInviteSaving, SingleInviteSavingBuilder> {
  SingleInviteSaving._();
  factory SingleInviteSaving(
          [void Function(SingleInviteSavingBuilder) updates]) =
      _$SingleInviteSaving;

  static SingleInviteSavingBuilder fromState(SingleInviteState state) {
    return SingleInviteState.fromState(state, SingleInviteSavingBuilder());
  }

  /// Defaults for the state.  Always default to no invites loaded.
  static void _initializeBuilder(SingleInviteSavingBuilder b) {
    SingleInviteState.initializeStateBuilder(b);

    b..type = SingleInviteBlocStateType.Saving;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleInviteSaving.serializer, this);
  }

  static SingleInviteSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleInviteSaving.serializer, jsonData);
  }

  static Serializer<SingleInviteSaving> get serializer =>
      _$singleInviteSavingSerializer;
}

///
/// The singleInvite bloc that is saving.
///
abstract class SingleInviteSaveDone
    implements
        SingleInviteState,
        Built<SingleInviteSaveDone, SingleInviteSaveDoneBuilder> {
  SingleInviteSaveDone._();
  factory SingleInviteSaveDone(
          [void Function(SingleInviteSaveDoneBuilder) updates]) =
      _$SingleInviteSaveDone;

  static SingleInviteSaveDoneBuilder fromState(SingleInviteState state) {
    return SingleInviteState.fromState(state, SingleInviteSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no invites loaded.
  static void _initializeBuilder(SingleInviteSaveDoneBuilder b) {
    SingleInviteState.initializeStateBuilder(b);

    b..type = SingleInviteBlocStateType.SaveDone;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleInviteSaveDone.serializer, this);
  }

  static SingleInviteSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleInviteSaveDone.serializer, jsonData);
  }

  static Serializer<SingleInviteSaveDone> get serializer =>
      _$singleInviteSaveDoneSerializer;
}
