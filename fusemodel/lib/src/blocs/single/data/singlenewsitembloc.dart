import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../serializer.dart';

part 'singlenewsitembloc.g.dart';

///
/// The type of the newsItem bloc state.
///
class SingleNewsItemBlocStateType extends EnumClass {
  static Serializer<SingleNewsItemBlocStateType> get serializer =>
      _$singleNewsItemBlocStateTypeSerializer;

  static const SingleNewsItemBlocStateType Uninitialized = _$uninitialized;
  static const SingleNewsItemBlocStateType Loaded = _$loaded;
  static const SingleNewsItemBlocStateType Deleted = _$deleted;
  static const SingleNewsItemBlocStateType SaveFailed = _$saveFailed;
  static const SingleNewsItemBlocStateType Saving = _$saving;
  static const SingleNewsItemBlocStateType SaveDone = _$saveDone;

  const SingleNewsItemBlocStateType._(String name) : super(name);

  static BuiltSet<SingleNewsItemBlocStateType> get values => _$values;

  static SingleNewsItemBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the singleNewsItem bloc.  It tracks all the
/// exciting singleNewsItem stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleNewsItemState {
  /// The newsItem for this bloc.
  @nullable
  NewsItem get newsItem;

  /// The type of the state.
  SingleNewsItemBlocStateType get type; 

  static SingleNewsItemStateBuilder fromState(
      SingleNewsItemState state, SingleNewsItemStateBuilder builder) {
    return builder..coach = state.coach?.toBuilder();
  }

  static void initializeStateBuilder(SingleNewsItemStateBuilder b) => b
  ;

  Map<String, dynamic> toMap();
}

///
/// The singleNewsItem loaded from the database.
///
abstract class SingleNewsItemLoaded
    implements
        SingleNewsItemState,
        Built<SingleNewsItemLoaded, SingleNewsItemLoadedBuilder> {
  SingleNewsItemLoaded._();
  factory SingleNewsItemLoaded(
      [void Function(SingleNewsItemLoadedBuilder) updates]) =
  _$SingleNewsItemLoaded;

  static SingleNewsItemLoadedBuilder fromState(SingleNewsItemState state) {
    return SingleNewsItemState.fromState(
        state, SingleNewsItemLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleNewsItemLoadedBuilder b) {
    SingleNewsItemState.initializeStateBuilder(b);

    b..type = SingleNewsItemBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleNewsItemLoaded.serializer, this);
  }

  static SingleNewsItemLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleNewsItemLoaded.serializer, jsonData);
  }

  static Serializer<SingleNewsItemLoaded> get serializer =>
      _$singleNewsItemLoadedSerializer;
}

///
/// The singleNewsItem bloc that is unitialized.
///
abstract class SingleNewsItemUninitialized
    implements
        SingleNewsItemState,
        Built<SingleNewsItemUninitialized,
            SingleNewsItemUninitializedBuilder> {
  SingleNewsItemUninitialized._();
  factory SingleNewsItemUninitialized(
      [void Function(SingleNewsItemUninitializedBuilder) updates]) =
  _$SingleNewsItemUninitialized;

  static SingleNewsItemUninitializedBuilder fromState(
      SingleNewsItemState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleNewsItemUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleNewsItemUninitializedBuilder b) {
    SingleNewsItemState.initializeStateBuilder(b);

    b..type = SingleNewsItemBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleNewsItemUninitialized.serializer, this);
  }

  static SingleNewsItemUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleNewsItemUninitialized.serializer, jsonData);
  }

  static Serializer<SingleNewsItemUninitialized> get serializer =>
      _$singleNewsItemUninitializedSerializer;
}

///
/// The singleNewsItem bloc that is deleted.
///
abstract class SingleNewsItemDeleted
    implements
        SingleNewsItemState,
        Built<SingleNewsItemDeleted, SingleNewsItemDeletedBuilder> {
  SingleNewsItemDeleted._();
  factory SingleNewsItemDeleted(
      [void Function(SingleNewsItemDeletedBuilder) updates]) =
  _$SingleNewsItemDeleted;

  static SingleNewsItemDeletedBuilder fromState(SingleNewsItemState state) {
    // Nothing set in this case, just the type.
    return SingleNewsItemDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleNewsItemDeletedBuilder b) {
    SingleNewsItemState.initializeStateBuilder(b);

    b..type = SingleNewsItemBlocStateType.Deleted;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleNewsItemDeleted.serializer, this);
  }

  static SingleNewsItemDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleNewsItemDeleted.serializer, jsonData);
  }

  static Serializer<SingleNewsItemDeleted> get serializer =>
      _$singleNewsItemDeletedSerializer;
}

///
/// The singleNewsItem bloc that has failed to save, with error.
///
abstract class SingleNewsItemSaveFailed
    implements
        SingleNewsItemState,
        Built<SingleNewsItemSaveFailed, SingleNewsItemSaveFailedBuilder> {
  /// The error associatedf with this newsItem.
  @BuiltValueField(serialize: false)
  Object get error;

  SingleNewsItemSaveFailed._();
  factory SingleNewsItemSaveFailed(
      [void Function(SingleNewsItemSaveFailedBuilder) updates]) =
  _$SingleNewsItemSaveFailed;

  static SingleNewsItemSaveFailedBuilder fromState(
      SingleNewsItemState state) {
    return SingleNewsItemState.fromState(
        state, SingleNewsItemSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleNewsItemSaveFailedBuilder b) {
    SingleNewsItemState.initializeStateBuilder(b);

    b..type = SingleNewsItemBlocStateType.SaveFailed;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleNewsItemSaveFailed.serializer, this);
  }

  static SingleNewsItemSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleNewsItemSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleNewsItemSaveFailed> get serializer =>
      _$singleNewsItemSaveFailedSerializer;
}

///
/// The singleNewsItem bloc that is saving.
///
abstract class SingleNewsItemSaving
    implements
        SingleNewsItemState,
        Built<SingleNewsItemSaving, SingleNewsItemSavingBuilder> {
  SingleNewsItemSaving._();
  factory SingleNewsItemSaving(
      [void Function(SingleNewsItemSavingBuilder) updates]) =
  _$SingleNewsItemSaving;

  static SingleNewsItemSavingBuilder fromState(SingleNewsItemState state) {
    return SingleNewsItemState.fromState(
        state, SingleNewsItemSavingBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleNewsItemSavingBuilder b) {
    SingleNewsItemState.initializeStateBuilder(b);

    b..type = SingleNewsItemBlocStateType.Saving;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleNewsItemSaving.serializer, this);
  }

  static SingleNewsItemSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleNewsItemSaving.serializer, jsonData);
  }

  static Serializer<SingleNewsItemSaving> get serializer =>
      _$singleNewsItemSavingSerializer;
}

///
/// The singleNewsItem bloc that is saving.
///
abstract class SingleNewsItemSaveDone
    implements
        SingleNewsItemState,
        Built<SingleNewsItemSaveDone, SingleNewsItemSaveDoneBuilder> {
  SingleNewsItemSaveDone._();
  factory SingleNewsItemSaveDone(
      [void Function(SingleNewsItemSaveDoneBuilder) updates]) =
  _$SingleNewsItemSaveDone;

  static SingleNewsItemSaveDoneBuilder fromState(SingleNewsItemState state) {
    return SingleNewsItemState.fromState(
        state, SingleNewsItemSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleNewsItemSaveDoneBuilder b) {
    SingleNewsItemState.initializeStateBuilder(b);

    b..type = SingleNewsItemBlocStateType.SaveDone;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleNewsItemSaveDone.serializer, this);
  }

  static SingleNewsItemSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleNewsItemSaveDone.serializer, jsonData);
  }

  static Serializer<SingleNewsItemSaveDone> get serializer =>
      _$singleNewsItemSaveDoneSerializer;
}
