import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../game/gameplayersummary.dart';
import '../serializer.dart';
import 'playertype.dart';
import 'relationship.dart';

part 'player.g.dart';

///
/// The user part of the player, has a mapping to the relationship with the
/// player.
///
abstract class PlayerUserInternal
    implements Built<PlayerUserInternal, PlayerUserInternalBuilder> {
  /// If the player has been added.
  bool get added;

  /// The relationship with the usser.
  Relationship get relationship;

  PlayerUserInternal._();
  factory PlayerUserInternal([updates(PlayerUserInternalBuilder b)]) =
      _$PlayerUserInternal;

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(PlayerUserInternal.serializer, this);
  }

  static PlayerUserInternal fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(
        PlayerUserInternal.serializer, jsonData);
  }

  static Serializer<PlayerUserInternal> get serializer =>
      _$playerUserInternalSerializer;
}

///
/// Externally visible version of this data.
///
class PlayerUser {
  /// The user id for the person associated with the player.
  final String userUid;

  /// The relationship the user has with the player.
  final Relationship relationship;

  /// The constructore for the player user connection.
  PlayerUser(this.userUid, this.relationship);
}

///
/// The player associated with users and in all the various teams.
///
abstract class Player implements Built<Player, PlayerBuilder> {
  /// Name of the player.
  String get name;

  /// uid for the player.
  String get uid;

  /// The uid of the opponent
  @nullable
  String get opponentUid;

  /// The uid of the team the opponent is in.
  @nullable
  String get teamUid;

  /// The uid of the game.
  @nullable
  String get gameUid;

  /// The type of the player.
  PlayerType get playerType;

  /// Url to get the photo from
  @nullable
  String get photoUrl;

  /// The users that are associated with this player.
  @BuiltValueField(wireName: usersField)
  BuiltMap<String, PlayerUserInternal> get usersData;

  /// The summary of the games per season.
  BuiltMap<String, GamePlayerSummary> get perSeason;

  /// If this player has their data visible to the public.
  bool get isPublic;

  /// The users in a nice useful format merged from the internal data.
  @memoized
  BuiltMap<String, PlayerUser> get users =>
      BuiltMap.of(Map.fromIterable(usersData.entries,
          key: (d) => d.key,
          value: (d) => PlayerUser(d.key, d.value.relationship)));

  Player._();

  /// Factory to create the player.
  factory Player([updates(PlayerBuilder b)]) = _$Player;

  static void _initializeBuilder(PlayerBuilder b) => b
    ..isPublic = false
    ..playerType = PlayerType.player;

  /// The name of the field to serialize for the user data.
  static const String usersField = 'user';

  /// Serialize the player.
  Map<String, dynamic> toMap({bool includeUsers: false}) {
    Map<String, dynamic> ret =
        dataSerializers.serializeWith(Player.serializer, this);
    if (includeUsers) {
      return ret;
    }
    ret.remove(usersField);
    return ret;
  }

  /// Deserialize the player.
  static Player fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(Player.serializer, jsonData);
  }

  /// The serializer to use for the player.
  static Serializer<Player> get serializer => _$playerSerializer;
}
