import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fusemodel/src/team/team.dart';

import '../club.dart';
import '../serializer.dart';
import '../winrecord.dart';
import 'seasonplayer.dart';

part 'season.g.dart';

///
/// Season details for the team.
///
abstract class Season implements Built<Season, SeasonBuilder> {
  /// Name of the season.
  String get name;

  /// The uid of the season.
  String get uid;

  /// The uid of the team.
  @BuiltValueField(wireName: TEAMUID)
  String get teamUid;

  /// The record of the season.
  WinRecord get record;

  /// The data associated with the players.
  @BuiltValueField(wireName: PLAYERS)
  BuiltMap<String, SeasonPlayer> get playersData;

  /// The users setup for the season.
  @BuiltValueField(wireName: USER)
  BuiltMap<String, BuiltMap<String, bool>> get users;

  /// If this season is publicaly visible.
  bool get isPublic;

  Season._();
  factory Season([Function(SeasonBuilder b) updates]) = _$Season;

  static void _initializeBuilder(SeasonBuilder b) => b..isPublic = false;

  Map<String, dynamic> toMap({bool includePlayers = false}) {
    Map<String, dynamic> ret =
        dataSerializers.serializeWith(Season.serializer, this);
    if (includePlayers) {
      return ret;
    }

    ret.remove(PLAYERS);
    return ret;
  }

  static Season fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(Season.serializer, jsonData);
  }

  static Serializer<Season> get serializer => _$seasonSerializer;

  static const String TEAMUID = 'teamUid';
  static const String PLAYERS = 'players';
  // Used for indexing the invisible user field that has permissions.
  static const String USER = 'users';

  @memoized
  BuiltList<SeasonPlayer> get players => BuiltList.from(playersData.values);

  ///
  /// Is the current user an admin for this season
  ///
  bool isAdmin(Map<String, Team> teams, Club club) {
    //Find the team and check there.
    if (teams.containsKey(teamUid)) {
      return teams[teamUid].isAdmin(club);
    }
    return false;
  }
}
