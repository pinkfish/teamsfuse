import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../serializer.dart';
import 'seasonplayersummary.dart';

part 'seasonplayer.g.dart';

///
/// What role the user has in the team.
///
class RoleInTeam extends EnumClass {
  static Serializer<RoleInTeam> get serializer => _$roleInTeamSerializer;

  static const RoleInTeam Player = _$player;
  static const RoleInTeam Coach = _$coach;
  static const RoleInTeam NonPlayer = _$nonPlayer;

  const RoleInTeam._(String name) : super(name);

  static BuiltSet<RoleInTeam> get values => _$values;

  static RoleInTeam valueOf(String name) => _$valueOf(name);
}

///
/// The player associated with the season.  This contains season specific
/// details about the player.
///
abstract class SeasonPlayer
    implements Built<SeasonPlayer, SeasonPlayerBuilder> {
  String get playerUid;
  @BuiltValueField(wireName: ROLE)
  RoleInTeam get role;
  String get jerseyNumber;
  String get position;
  SeasonPlayerSummary get summary;

  SeasonPlayer._();
  factory SeasonPlayer([updates(SeasonPlayerBuilder b)]) = _$SeasonPlayer;

  static void _initializeBuilder(SeasonPlayerBuilder b) => b
    ..jerseyNumber = ""
    ..position = "";

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(SeasonPlayer.serializer, this);
  }

  static const String ROLE = "role";

  static SeasonPlayer fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(SeasonPlayer.serializer, jsonData);
  }

  static Serializer<SeasonPlayer> get serializer => _$seasonPlayerSerializer;
}
