import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../serializer.dart';

part 'clubblocstate.g.dart';

class ClubBlocStateType extends EnumClass {
  static Serializer<ClubBlocStateType> get serializer =>
      _$clubBlocStateTypeSerializer;

  static const ClubBlocStateType Uninitialized = _$uninitialized;
  static const ClubBlocStateType Loaded = _$loaded;

  const ClubBlocStateType._(String name) : super(name);

  static BuiltSet<ClubBlocStateType> get values => _$values;

  static ClubBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the club bloc.  It tracks all the
/// exciting club stuff.
///
@BuiltValue(instantiable: false)
abstract class ClubState {
  BuiltMap<String, Club> get clubs;
  ClubBlocStateType get type;

  // Don't save this stuff
  @BuiltValueField(serialize: false)
  bool get loadedFirestore;
  @BuiltValueField(serialize: false)
  bool get loadedTeams;
  @BuiltValueField(serialize: false)
  BuiltMap<String, Iterable<Team>> get teams;

  static ClubStateBuilder fromState(ClubState state, ClubStateBuilder builder) {
    return builder
      ..clubs = state.clubs.toBuilder()
      ..loadedFirestore = state.loadedFirestore
      ..loadedTeams = state.loadedTeams
      ..teams = state.teams.toBuilder();
  }

  static void initializeStateBuilder(ClubStateBuilder b) => b
    ..loadedTeams = false
    ..loadedFirestore = false;

  Map<String, dynamic> toMap();
}

///
/// The club loaded from the database.
///
abstract class ClubLoaded
    implements ClubState, Built<ClubLoaded, ClubLoadedBuilder> {
  ClubLoaded._();
  factory ClubLoaded([void Function(ClubLoadedBuilder) updates]) = _$ClubLoaded;

  static ClubLoadedBuilder fromState(ClubState state) {
    return ClubState.fromState(state, ClubLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(ClubLoadedBuilder b) {
    ClubState.initializeStateBuilder(b);

    b.type = ClubBlocStateType.Loaded;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(ClubLoaded.serializer, this);
  }

  static ClubLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(ClubLoaded.serializer, jsonData);
  }

  static Serializer<ClubLoaded> get serializer => _$clubLoadedSerializer;
}

///
/// The club bloc that is unitialized.
///
abstract class ClubUninitialized
    implements ClubState, Built<ClubUninitialized, ClubUninitializedBuilder> {
  ClubUninitialized._();
  factory ClubUninitialized([void Function(ClubUninitializedBuilder) updates]) =
      _$ClubUninitialized;

  static ClubUninitializedBuilder fromState(ClubState state) {
    return ClubState.fromState(state, ClubUninitializedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(ClubUninitializedBuilder b) {
    ClubState.initializeStateBuilder(b);

    b.type = ClubBlocStateType.Uninitialized;
  }

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(ClubUninitialized.serializer, this);
  }

  static ClubUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(ClubUninitialized.serializer, jsonData);
  }

  static Serializer<ClubUninitialized> get serializer =>
      _$clubUninitializedSerializer;
}
