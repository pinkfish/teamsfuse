import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../common.dart';
import '../serializer.dart';

part 'coach.g.dart';

///
/// Keeps track of the coach information for the club.  This will be the
/// details about the coach in the contect of the specific club.
///
abstract class Coach implements Built<Coach, CoachBuilder> {
  /// Uid for the coach
  String get uid;

  /// Name of the coach
  String get name;

  /// The photo to display for the coach
  @nullable
  String get photoUrl;

  /// Some text describing what the coach is about.
  String get about;

  /// The uid of the club to lookup.
  String get clubUid;

  Coach._();
  factory Coach([updates(CoachBuilder b)]) => _$Coach((b) => b..about = "");

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(CoachBuilder b) => b..about = "";

  Map<String, dynamic> toMap({bool includeMembers}) =>
      dataSerializers.serializeWith(Coach.serializer, this);

  static Coach fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(Coach.serializer, jsonData);
  }

  static Serializer<Coach> get serializer => _$coachSerializer;
}
