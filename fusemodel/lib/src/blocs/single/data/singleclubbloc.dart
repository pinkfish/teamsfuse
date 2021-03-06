import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../serializer.dart';

part 'singleclubbloc.g.dart';

///
/// The type of the club bloc state.
///
class SingleClubBlocStateType extends EnumClass {
  /// Serializer for the bluc bloc state type.
  static Serializer<SingleClubBlocStateType> get serializer =>
      _$singleClubBlocStateTypeSerializer;

  /// Unitialized club bloc.
  static const SingleClubBlocStateType Uninitialized = _$uninitialized;

  /// Loaded club bloc.
  static const SingleClubBlocStateType Loaded = _$loaded;

  /// Deleted state for the club.
  static const SingleClubBlocStateType Deleted = _$deleted;

  /// Save failed for the club.
  static const SingleClubBlocStateType SaveFailed = _$saveFailed;

  /// Saving for the club.
  static const SingleClubBlocStateType Saving = _$saving;

  /// Saveing is done for the club.
  static const SingleClubBlocStateType SaveDone = _$saveDone;

  const SingleClubBlocStateType._(String name) : super(name);

  static BuiltSet<SingleClubBlocStateType> get values => _$values;

  static SingleClubBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the singleClub bloc.  It tracks all the
/// exciting singleClub stuff.
///
@BuiltValue(instantiable: false)
abstract class SingleClubState {
  /// The club for this bloc.
  @nullable
  Club get club;

  /// The type of the state.
  SingleClubBlocStateType get type;

  /// If the teams have been loaded.
  @BuiltValueField(serialize: false)
  bool get loadedTeams;

  /// The loaded teams.
  @BuiltValueField(serialize: false)
  BuiltList<Team> get teams;

  /// The invites have been loaded.
  @BuiltValueField(serialize: false)
  bool get loadedInvites;

  /// The loaded invites
  @BuiltValueField(serialize: false)
  BuiltList<InviteToClub> get invites;

  /// If the coaches have been loaded.
  @BuiltValueField(serialize: false)
  bool get loadedCoaches;

  /// The coaches that are loaded.
  @BuiltValueField(serialize: false)
  BuiltList<Coach> get coaches;

  /// The invites have been loaded.
  @BuiltValueField(serialize: false)
  bool get loadedNewsItems;

  /// The loaded invites
  @BuiltValueField(serialize: false)
  BuiltList<NewsItem> get newsItems;

  /// The loaded invites
  @BuiltValueField(serialize: false)
  BuiltMap<num, BuiltList<NewsItem>> get extraNewsItems;

  static SingleClubStateBuilder fromState(
      SingleClubState state, SingleClubStateBuilder builder) {
    return builder
      ..club = state.club?.toBuilder()
      ..teams = state.teams.toBuilder()
      ..invites = state.invites.toBuilder()
      ..extraNewsItems = state.extraNewsItems.toBuilder()
      ..loadedInvites = state.loadedInvites
      ..loadedCoaches = state.loadedCoaches
      ..loadedNewsItems = state.loadedNewsItems
      ..newsItems = state.newsItems.toBuilder()
      ..coaches = state.coaches.toBuilder();
  }

  static void initializeStateBuilder(SingleClubStateBuilder b) => b
    ..loadedTeams = false
    ..loadedCoaches = false
    ..loadedNewsItems = false
    ..loadedInvites = false;

  Map<String, dynamic> toMap();
}

///
/// The singleClub loaded from the database.
///
abstract class SingleClubLoaded
    implements
        SingleClubState,
        Built<SingleClubLoaded, SingleClubLoadedBuilder> {
  SingleClubLoaded._();
  factory SingleClubLoaded([void Function(SingleClubLoadedBuilder) updates]) =
      _$SingleClubLoaded;

  static SingleClubLoadedBuilder fromState(SingleClubState state) {
    return SingleClubState.fromState(state, SingleClubLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleClubLoadedBuilder b) {
    SingleClubState.initializeStateBuilder(b);

    b.type = SingleClubBlocStateType.Loaded;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleClubLoaded.serializer, this);
  }

  static SingleClubLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleClubLoaded.serializer, jsonData);
  }

  static Serializer<SingleClubLoaded> get serializer =>
      _$singleClubLoadedSerializer;
}

///
/// The singleClub bloc that is unitialized.
///
abstract class SingleClubUninitialized
    implements
        SingleClubState,
        Built<SingleClubUninitialized, SingleClubUninitializedBuilder> {
  SingleClubUninitialized._();
  factory SingleClubUninitialized(
          [void Function(SingleClubUninitializedBuilder) updates]) =
      _$SingleClubUninitialized;

  static SingleClubUninitializedBuilder fromState(SingleClubState state) {
    // Nothing set in this case, just the type and defaults.
    return SingleClubUninitializedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleClubUninitializedBuilder b) {
    SingleClubState.initializeStateBuilder(b);

    b.type = SingleClubBlocStateType.Uninitialized;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleClubUninitialized.serializer, this);
  }

  static SingleClubUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleClubUninitialized.serializer, jsonData);
  }

  static Serializer<SingleClubUninitialized> get serializer =>
      _$singleClubUninitializedSerializer;
}

///
/// The singleClub bloc that is deleted.
///
abstract class SingleClubDeleted
    implements
        SingleClubState,
        Built<SingleClubDeleted, SingleClubDeletedBuilder> {
  SingleClubDeleted._();
  factory SingleClubDeleted([void Function(SingleClubDeletedBuilder) updates]) =
      _$SingleClubDeleted;

  static SingleClubDeletedBuilder fromState(SingleClubState state) {
    // Nothing set in this case, just the type.
    return SingleClubDeletedBuilder();
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleClubDeletedBuilder b) {
    SingleClubState.initializeStateBuilder(b);

    b.type = SingleClubBlocStateType.Deleted;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleClubDeleted.serializer, this);
  }

  static SingleClubDeleted fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleClubDeleted.serializer, jsonData);
  }

  static Serializer<SingleClubDeleted> get serializer =>
      _$singleClubDeletedSerializer;
}

///
/// The singleClub bloc that has failed to save, with error.
///
abstract class SingleClubSaveFailed
    implements
        SingleClubState,
        Built<SingleClubSaveFailed, SingleClubSaveFailedBuilder> {
  /// The error associatedf with this club.
  @BuiltValueField(serialize: false)
  Object get error;

  SingleClubSaveFailed._();
  factory SingleClubSaveFailed(
          [void Function(SingleClubSaveFailedBuilder) updates]) =
      _$SingleClubSaveFailed;

  static SingleClubSaveFailedBuilder fromState(SingleClubState state) {
    return SingleClubState.fromState(state, SingleClubSaveFailedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleClubSaveFailedBuilder b) {
    SingleClubState.initializeStateBuilder(b);

    b.type = SingleClubBlocStateType.SaveFailed;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleClubSaveFailed.serializer, this);
  }

  static SingleClubSaveFailed fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SingleClubSaveFailed.serializer, jsonData);
  }

  static Serializer<SingleClubSaveFailed> get serializer =>
      _$singleClubSaveFailedSerializer;
}

///
/// The singleClub bloc that is saving.
///
abstract class SingleClubSaving
    implements
        SingleClubState,
        Built<SingleClubSaving, SingleClubSavingBuilder> {
  SingleClubSaving._();
  factory SingleClubSaving([void Function(SingleClubSavingBuilder) updates]) =
      _$SingleClubSaving;

  static SingleClubSavingBuilder fromState(SingleClubState state) {
    return SingleClubState.fromState(state, SingleClubSavingBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleClubSavingBuilder b) {
    SingleClubState.initializeStateBuilder(b);

    b.type = SingleClubBlocStateType.Saving;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleClubSaving.serializer, this);
  }

  static SingleClubSaving fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleClubSaving.serializer, jsonData);
  }

  static Serializer<SingleClubSaving> get serializer =>
      _$singleClubSavingSerializer;
}

///
/// The singleClub bloc that is saving.
///
abstract class SingleClubSaveDone
    implements
        SingleClubState,
        Built<SingleClubSaveDone, SingleClubSaveDoneBuilder> {
  SingleClubSaveDone._();
  factory SingleClubSaveDone(
          [void Function(SingleClubSaveDoneBuilder) updates]) =
      _$SingleClubSaveDone;

  static SingleClubSaveDoneBuilder fromState(SingleClubState state) {
    return SingleClubState.fromState(state, SingleClubSaveDoneBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SingleClubSaveDoneBuilder b) {
    SingleClubState.initializeStateBuilder(b);

    b.type = SingleClubBlocStateType.SaveDone;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SingleClubSaveDone.serializer, this);
  }

  static SingleClubSaveDone fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SingleClubSaveDone.serializer, jsonData);
  }

  static Serializer<SingleClubSaveDone> get serializer =>
      _$singleClubSaveDoneSerializer;
}
