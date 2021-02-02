import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../game/gameplayersummary.dart';
import '../serializer.dart';
import 'relationship.dart';

part 'player.g.dart';

///
/// The user part of the player, has a mapping to the relationship with the
/// player.
///
abstract class PlayerUserInternal
    implements Built<PlayerUserInternal, PlayerUserInternalBuilder> {
  bool get added;
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
  final String userUid;
  final Relationship relationship;

  PlayerUser(this.userUid, this.relationship);
}

///
/// The player associated with users and in all the various teams.
///
abstract class Player implements Built<Player, PlayerBuilder> {
  String get name;
  String get uid;
  @nullable
  String get photoUrl;
  @BuiltValueField(wireName: USERS)
  BuiltMap<String, PlayerUserInternal> get usersData;
  // The summary of the details.
  BuiltMap<String, GamePlayerSummary> get perSeason;

  @memoized
  BuiltMap<String, PlayerUser> get users =>
      BuiltMap.of(Map.fromIterable(usersData.entries,
          key: (d) => d.key,
          value: (d) => PlayerUser(d.key, d.value.relationship)));

  Player._();
  factory Player([updates(PlayerBuilder b)]) = _$Player;

  static const String USERS = 'user';

  Map<String, dynamic> toMap({bool includeUsers: false}) {
    Map<String, dynamic> ret =
        dataSerializers.serializeWith(Player.serializer, this);
    if (includeUsers) {
      return ret;
    }
    ret.remove(USERS);
    return ret;
  }

  static Player fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(Player.serializer, jsonData);
  }

  static Serializer<Player> get serializer => _$playerSerializer;
}
