import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../../fusemodel.dart';
import '../../serializer.dart';

part 'singlenewsitembloc.g.dart';

///
/// The type of the newsItem bloc state.
///
class SingleNewsItemBlocStateType extends EnumClass {
  /// The serialized for the news item.
  static Serializer<SingleNewsItemBlocStateType> get serializer =>
      _$singleNewsItemBlocStateTypeSerializer;

  /// The type for the bloc of uninitialized.
  static const SingleNewsItemBlocStateType Uninitialized = _$uninitialized;

  /// The type for the bloc of loaded.
  static const SingleNewsItemBlocStateType Loaded = _$loaded;

  /// The type for the bloc of deleted.
  static const SingleNewsItemBlocStateType Deleted = _$deleted;

  /// The type for the bloc of saveFailed, this is a temporary state.
  static const SingleNewsItemBlocStateType SaveFailed = _$saveFailed;

  /// The type for the bloc of saving, this is a temporary state.
  static const SingleNewsItemBlocStateType Saving = _$saving;

  /// The type for the bloc of save done, this is a temporary state.
  static const SingleNewsItemBlocStateType SaveDone = _$saveDone;

  const SingleNewsItemBlocStateType._(String name) : super(name);

  /// The values of this enaum.
  static BuiltSet<SingleNewsItemBlocStateType> get values => _$values;

  /// Get the value of an item given a string.
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

  /// Creates a basic state from a previous state.
  static SingleNewsItemStateBuilder fromState(
      SingleNewsItemState state, SingleNewsItemStateBuilder builder) {
    return builder..newsItem = state.newsItem?.toBuilder();
  }

  /// Initializes the builder based on incoming data.
  static void initializeStateBuilder(SingleNewsItemStateBuilder b) => b;

  /// Serialize the state.
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

  /// Create a new loaded state.
  factory SingleNewsItemLoaded(
          [void Function(SingleNewsItemLoadedBuilder) updates]) =
      _$SingleNewsItemLoaded;

  /// Build a loaded state from the existing state.
  static SingleNewsItemLoadedBuilder fromState(SingleNewsItemState state) {
    return SingleNewsItemState.fromState(state, SingleNewsItemLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleNewsItemLoadedBuilder b) {
    SingleNewsItemState.initializeStateBuilder(b);

    b.type = SingleNewsItemBlocStateType.Loaded;
  }

  /// Serialize the state.
  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleNewsItemLoaded.serializer, this);
  }

  /// Deserialize the state.
  static SingleNewsItemLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleNewsItemLoaded.serializer, jsonData);
  }

  /// The serializer to use for this class.
  static Serializer<SingleNewsItemLoaded> get serializer =>
      _$singleNewsItemLoadedSerializer;
}

///
/// The singleNewsItem bloc that is unitialized.
///
abstract class SingleNewsItemUninitialized
    implements
        SingleNewsItemState,
        Built<SingleNewsItemUninitialized, SingleNewsItemUninitializedBuilder> {
  SingleNewsItemUninitialized._();

  /// Create an uninitialized state.
  factory SingleNewsItemUninitialized(
          [void Function(SingleNewsItemUninitializedBuilder) updates]) =
      _$SingleNewsItemUninitialized;

  /// Make an uninitialized state from the base state.
  static SingleNewsItemUninitializedBuilder fromState(
      SingleNewsItemState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleNewsItemUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleNewsItemUninitializedBuilder b) {
    SingleNewsItemState.initializeStateBuilder(b);

    b.type = SingleNewsItemBlocStateType.Uninitialized;
  }

  /// Serialize the state.
  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(
        SingleNewsItemUninitialized.serializer, this);
  }

  /// Deserialize the state.
  static SingleNewsItemUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleNewsItemUninitialized.serializer, jsonData);
  }

  /// The serializer to use for the state.
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

  /// Create the deleted state.
  factory SingleNewsItemDeleted(
          [void Function(SingleNewsItemDeletedBuilder) updates]) =
      _$SingleNewsItemDeleted;

  /// Create a new deleted state from the existing state.  Clears everything.
  static SingleNewsItemDeletedBuilder fromState(SingleNewsItemState state) {
    // Nothing set in this case, just the type.
    return SingleNewsItemDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleNewsItemDeletedBuilder b) {
    SingleNewsItemState.initializeStateBuilder(b);

    b.type = SingleNewsItemBlocStateType.Deleted;
  }

  /// Serialize the state.
  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleNewsItemDeleted.serializer, this);
  }

  /// Deserialize the state.
  static SingleNewsItemDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleNewsItemDeleted.serializer, jsonData);
  }

  /// The serializer to use for the state.
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

  /// Create a new save failed from the existing state, filling in the existing
  /// data for the state.
  factory SingleNewsItemSaveFailed(
          [void Function(SingleNewsItemSaveFailedBuilder) updates]) =
      _$SingleNewsItemSaveFailed;

  ///
  /// Create a save failed item from the state, filling in the existing
  /// details about the state.
  ///
  static SingleNewsItemSaveFailedBuilder fromState(SingleNewsItemState state) {
    return SingleNewsItemState.fromState(
        state, SingleNewsItemSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleNewsItemSaveFailedBuilder b) {
    SingleNewsItemState.initializeStateBuilder(b);

    b.type = SingleNewsItemBlocStateType.SaveFailed;
  }

  /// Serialize the state.
  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleNewsItemSaveFailed.serializer, this);
  }

  /// Deserialize the state.
  static SingleNewsItemSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleNewsItemSaveFailed.serializer, jsonData);
  }

  /// The serializer to use for the state.
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

  /// The factory to create the saving state.
  factory SingleNewsItemSaving(
          [void Function(SingleNewsItemSavingBuilder) updates]) =
      _$SingleNewsItemSaving;

  ///
  /// Create a saving item from the state, filling in the existing
  /// details about the state.
  ///
  static SingleNewsItemSavingBuilder fromState(SingleNewsItemState state) {
    return SingleNewsItemState.fromState(state, SingleNewsItemSavingBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleNewsItemSavingBuilder b) {
    SingleNewsItemState.initializeStateBuilder(b);

    b.type = SingleNewsItemBlocStateType.Saving;
  }

  /// Serialize the state.
  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleNewsItemSaving.serializer, this);
  }

  /// Deserialize the state.
  static SingleNewsItemSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleNewsItemSaving.serializer, jsonData);
  }

  /// The serializer to use for the state.
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

  /// The factoiry to create the save done state.
  factory SingleNewsItemSaveDone(
          [void Function(SingleNewsItemSaveDoneBuilder) updates]) =
      _$SingleNewsItemSaveDone;

  ///
  /// Create a save done item from the state, filling in the existing
  /// details about the state.
  ///
  static SingleNewsItemSaveDoneBuilder fromState(SingleNewsItemState state) {
    return SingleNewsItemState.fromState(
        state, SingleNewsItemSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleNewsItemSaveDoneBuilder b) {
    SingleNewsItemState.initializeStateBuilder(b);

    b.type = SingleNewsItemBlocStateType.SaveDone;
  }

  /// Serialize the state.
  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleNewsItemSaveDone.serializer, this);
  }

  /// Deserialize the state.
  static SingleNewsItemSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleNewsItemSaveDone.serializer, jsonData);
  }

  /// The serializer to use for the state.
  static Serializer<SingleNewsItemSaveDone> get serializer =>
      _$singleNewsItemSaveDoneSerializer;
}
