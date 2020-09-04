import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../serializer.dart';
import '../../team.dart';

part 'seasonblocstate.g.dart';

class SeasonBlocStateType extends EnumClass {
  static Serializer<SeasonBlocStateType> get serializer =>
      _$seasonBlocStateTypeSerializer;

  static const SeasonBlocStateType Uninitialized = _$uninitialized;
  static const SeasonBlocStateType Loaded = _$loaded;

  const SeasonBlocStateType._(String name) : super(name);

  static BuiltSet<SeasonBlocStateType> get values => _$values;

  static SeasonBlocStateType valueOf(String name) => _$valueOf(name);
}

///
/// The base state for the season bloc.  It tracks all the
/// exciting season stuff.
///
@BuiltValue(instantiable: false)
abstract class SeasonState {
  BuiltMap<String, Season> get seasons;
  SeasonBlocStateType get type;

  // Don't save this stuff.
  @BuiltValueField(serialize: false)
  bool get loadedFirestore;

  static SeasonStateBuilder fromState(
      SeasonState state, SeasonStateBuilder builder) {
    return builder
      ..seasons = state.seasons.toBuilder()
      ..loadedFirestore = state.loadedFirestore;
  }

  static void initializeStateBuilder(SeasonStateBuilder b) =>
      b..loadedFirestore = false;

  Map<String, dynamic> toMap();
}

///
/// The season loaded from the database.
///
abstract class SeasonLoaded
    implements SeasonState, Built<SeasonLoaded, SeasonLoadedBuilder> {
  SeasonLoaded._();
  factory SeasonLoaded([void Function(SeasonLoadedBuilder) updates]) =
      _$SeasonLoaded;

  static SeasonLoadedBuilder fromState(SeasonState state) {
    return SeasonState.fromState(state, SeasonLoadedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SeasonLoadedBuilder b) {
    SeasonState.initializeStateBuilder(b);

    b..type = SeasonBlocStateType.Loaded;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SeasonLoaded.serializer, this);
  }

  static SeasonLoaded fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SeasonLoaded.serializer, jsonData);
  }

  static Serializer<SeasonLoaded> get serializer => _$seasonLoadedSerializer;
}

///
/// The season bloc that is unitialized.
///
abstract class SeasonUninitialized
    implements
        SeasonState,
        Built<SeasonUninitialized, SeasonUninitializedBuilder> {
  SeasonUninitialized._();
  factory SeasonUninitialized(
          [void Function(SeasonUninitializedBuilder) updates]) =
      _$SeasonUninitialized;

  static SeasonUninitializedBuilder fromState(SeasonState state) {
    return SeasonState.fromState(state, SeasonUninitializedBuilder());
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(SeasonUninitializedBuilder b) {
    SeasonState.initializeStateBuilder(b);

    b..type = SeasonBlocStateType.Uninitialized;
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SeasonUninitialized.serializer, this);
  }

  static SeasonUninitialized fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        SeasonUninitialized.serializer, jsonData);
  }

  static Serializer<SeasonUninitialized> get serializer =>
      _$seasonUninitializedSerializer;
}
