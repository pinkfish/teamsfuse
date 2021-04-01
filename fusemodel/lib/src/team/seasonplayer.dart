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
  /// The uid for the player.
  String get playerUid;

  /// The role the player has in the season/
  @BuiltValueField(wireName: roleField)
  RoleInTeam get role;

  /// The jersey number for the player in the season/
  @BuiltValueField(wireName: jerseyNumberField)
  String get jerseyNumber;

  /// The summary for the data associated with the season
  SeasonPlayerSummary get summary;

  /// If th4 user is public.
  @BuiltValueField(wireName: isPublicField)
  bool get isPublic;

  /// Overqall added flag.
  bool get added;

  SeasonPlayer._();

  /// Factory to make the season player.
  factory SeasonPlayer([Function(SeasonPlayerBuilder b) updates]) =
      _$SeasonPlayer;

  static void _initializeBuilder(SeasonPlayerBuilder b) => b
    ..jerseyNumber = ''
    ..isPublic = false
    ..added = true;

  /// Serialize the season player.
  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(SeasonPlayer.serializer, this);
  }

  /// The role in season field name.
  static const String roleField = 'role';

  /// The jersey number field name.
  static const String jerseyNumberField = 'jerseyNumber';

  /// The isPublic field name.
  static const String isPublicField = 'isPublic';

  /// Create the season player from the serialized data.
  static SeasonPlayer fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(SeasonPlayer.serializer, jsonData);
  }

  /// The serializer for the data.
  static Serializer<SeasonPlayer> get serializer => _$seasonPlayerSerializer;
}
