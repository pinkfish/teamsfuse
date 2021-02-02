import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../common.dart';
import '../serializer.dart';
import '../winrecord.dart';

part 'opponent.g.dart';

///
/// An opponent for a team with all the opponent metadata associated with it.
///
abstract class Opponent implements Built<Opponent, OpponentBuilder> {
  String get name;
  String get teamUid;
  @nullable
  String get contact;
  String get uid;
  @BuiltValueField(wireName: _LEAGUETEAMUID)
  BuiltMap<String, AddedUid> get leagueTeamUidData;
  @BuiltValueField(wireName: _SEASONS)
  BuiltMap<String, WinRecord> get record;

  Opponent._();
  factory Opponent([updates(OpponentBuilder b)]) = _$Opponent;

  static const String _SEASONS = 'seasons';
  static const String _LEAGUETEAMUID = 'leagueTeamUid';

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(OpponentBuilder b) => b..name = "none";

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(Opponent.serializer, this);
  }

  static Opponent fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(Opponent.serializer, jsonData);
  }

  static Serializer<Opponent> get serializer => _$opponentSerializer;
}
