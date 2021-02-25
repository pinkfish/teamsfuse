import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../serializer.dart';

part 'singlemessagebloc.g.dart';

///
/// The type of the message bloc state.
///
class SingleMessageBlocStateType extends EnumClass {
  static Serializer<SingleMessageBlocStateType> get serializer =>
      _$singleMessageBlocStateTypeSerializer;

  static const SingleMessageBlocStateType Uninitialized = _$uninitialized;
  static const SingleMessageBlocStateType Loaded = _$loaded;
  static const SingleMessageBlocStateType Deleted = _$deleted;
  static const SingleMessageBlocStateType SaveFailed = _$saveFailed;
  static const SingleMessageBlocStateType Saving = _$saving;
  static const SingleMessageBlocStateType SaveDone = _$saveDone;
  static const SingleMessageBlocStateType SingleMessageChange =
      _$singleMessageChange;

  const SingleMessageBlocStateType._(String name) : super(name);

  static BuiltSet<SingleMessageBlocStateType> get values => _$values;

  static SingleMessageBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the singleMessage bloc.  It tracks all the
/// exciting singleMessage stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleMessageState {
  @nullable
  Message get message;
  @BuiltValueField(serialize: false)
  bool get loadedBody;
  @nullable
  String get body;

  SingleMessageBlocStateType get type;

  static SingleMessageStateBuilder fromState(
      SingleMessageState state, SingleMessageStateBuilder builder) {
    return builder
      ..message = state.message?.toBuilder()
      ..body = state.body
      ..loadedBody = state.loadedBody;
  }

  static void initializeStateBuilder(SingleMessageStateBuilder b) =>
      b..loadedBody = false;

  Map<String, dynamic> toMap();
}

///
/// The singleMessage loaded from the database.
///
abstract class SingleMessageLoaded
    implements
        SingleMessageState,
        Built<SingleMessageLoaded, SingleMessageLoadedBuilder> {
  SingleMessageLoaded._();
  factory SingleMessageLoaded(
          [void Function(SingleMessageLoadedBuilder) updates]) =
      _$SingleMessageLoaded;

  static SingleMessageLoadedBuilder fromState(SingleMessageState state) {
    return SingleMessageState.fromState(state, SingleMessageLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no messages loaded.
  static void _initializeBuilder(SingleMessageLoadedBuilder b) {
    SingleMessageState.initializeStateBuilder(b);

    b..type = SingleMessageBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleMessageLoaded.serializer, this);
  }

  static SingleMessageLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleMessageLoaded.serializer, jsonData);
  }

  static Serializer<SingleMessageLoaded> get serializer =>
      _$singleMessageLoadedSerializer;
}

///
/// The singleMessage bloc that is unitialized.
///
abstract class SingleMessageUninitialized
    implements
        SingleMessageState,
        Built<SingleMessageUninitialized, SingleMessageUninitializedBuilder> {
  SingleMessageUninitialized._();
  factory SingleMessageUninitialized(
          [void Function(SingleMessageUninitializedBuilder) updates]) =
      _$SingleMessageUninitialized;

  static SingleMessageUninitializedBuilder fromState(SingleMessageState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleMessageUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no messages loaded.
  static void _initializeBuilder(SingleMessageUninitializedBuilder b) {
    SingleMessageState.initializeStateBuilder(b);

    b..type = SingleMessageBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleMessageUninitialized.serializer, this);
  }

  static SingleMessageUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleMessageUninitialized.serializer, jsonData);
  }

  static Serializer<SingleMessageUninitialized> get serializer =>
      _$singleMessageUninitializedSerializer;
}

///
/// The singleMessage bloc that is unitialized.
///
abstract class SingleMessageDeleted
    implements
        SingleMessageState,
        Built<SingleMessageDeleted, SingleMessageDeletedBuilder> {
  SingleMessageDeleted._();
  factory SingleMessageDeleted(
          [void Function(SingleMessageDeletedBuilder) updates]) =
      _$SingleMessageDeleted;

  static SingleMessageDeletedBuilder fromState(SingleMessageState state) {
    // Nothing set in this case, just the type.
    return SingleMessageDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no messages loaded.
  static void _initializeBuilder(SingleMessageDeletedBuilder b) {
    SingleMessageState.initializeStateBuilder(b);

    b..type = SingleMessageBlocStateType.Deleted;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleMessageDeleted.serializer, this);
  }

  static SingleMessageDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleMessageDeleted.serializer, jsonData);
  }

  static Serializer<SingleMessageDeleted> get serializer =>
      _$singleMessageDeletedSerializer;
}

///
/// The singleMessage bloc that is unitialized.
///
abstract class SingleMessageSaveFailed
    implements
        SingleMessageState,
        Built<SingleMessageSaveFailed, SingleMessageSaveFailedBuilder> {
  @BuiltValueField(serialize: false)
  Object get error;

  SingleMessageSaveFailed._();
  factory SingleMessageSaveFailed(
          [void Function(SingleMessageSaveFailedBuilder) updates]) =
      _$SingleMessageSaveFailed;

  static SingleMessageSaveFailedBuilder fromState(SingleMessageState state) {
    return SingleMessageState.fromState(
        state, SingleMessageSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no messages loaded.
  static void _initializeBuilder(SingleMessageSaveFailedBuilder b) {
    SingleMessageState.initializeStateBuilder(b);

    b..type = SingleMessageBlocStateType.SaveFailed;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleMessageSaveFailed.serializer, this);
  }

  static SingleMessageSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleMessageSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleMessageSaveFailed> get serializer =>
      _$singleMessageSaveFailedSerializer;
}

///
/// The singleMessage bloc that is unitialized.
///
abstract class SingleMessageSaving
    implements
        SingleMessageState,
        Built<SingleMessageSaving, SingleMessageSavingBuilder> {
  SingleMessageSaving._();
  factory SingleMessageSaving(
          [void Function(SingleMessageSavingBuilder) updates]) =
      _$SingleMessageSaving;

  static SingleMessageSavingBuilder fromState(SingleMessageState state) {
    return SingleMessageState.fromState(state, SingleMessageSavingBuilder());
  }

  /// Defaults for the state.  Always default to no messages loaded.
  static void _initializeBuilder(SingleMessageSavingBuilder b) {
    SingleMessageState.initializeStateBuilder(b);

    b..type = SingleMessageBlocStateType.Saving;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleMessageSaving.serializer, this);
  }

  static SingleMessageSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleMessageSaving.serializer, jsonData);
  }

  static Serializer<SingleMessageSaving> get serializer =>
      _$singleMessageSavingSerializer;
}

///
/// The singleMessage bloc that is saving.
///
abstract class SingleMessageSaveDone
    implements
        SingleMessageState,
        Built<SingleMessageSaveDone, SingleMessageSaveDoneBuilder> {
  SingleMessageSaveDone._();
  factory SingleMessageSaveDone(
          [void Function(SingleMessageSaveDoneBuilder) updates]) =
      _$SingleMessageSaveDone;

  static SingleMessageSaveDoneBuilder fromState(SingleMessageState state) {
    return SingleMessageState.fromState(state, SingleMessageSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no messages loaded.
  static void _initializeBuilder(SingleMessageSaveDoneBuilder b) {
    SingleMessageState.initializeStateBuilder(b);

    b..type = SingleMessageBlocStateType.SaveDone;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleMessageSaveDone.serializer, this);
  }

  static SingleMessageSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleMessageSaveDone.serializer, jsonData);
  }

  static Serializer<SingleMessageSaveDone> get serializer =>
      _$singleMessageSaveDoneSerializer;
}
