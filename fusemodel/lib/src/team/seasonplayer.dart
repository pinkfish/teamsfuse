import '../common.dart';
import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';

part 'seasonplayer.g.dart';

///
/// What role the user has in the team.
///
enum RoleInTeam { Player, Coach, NonPlayer }

///
/// The player associated with the season.  This contains season specific
/// details about the player.
///
abstract class SeasonPlayer
    implements Built<SeasonPlayer, SeasonPlayerBuilder> {
  String get playerUid;
  RoleInTeam get role;
  String get jerseyNumber;
  String get position;

  SeasonPlayer._();
  factory SeasonPlayer([updates(SeasonPlayerBuilder b)]) = _$SeasonPlayer;

  static const String ROLE = 'role';
  static const String _JERSEY = 'jerseyNumber';
  static const String _POSITION = 'position';

  static SeasonPlayer fromJSON(Map<dynamic, dynamic> data) {
    SeasonPlayerBuilder builder = new SeasonPlayerBuilder();
    builder.role =
        RoleInTeam.values.firstWhere((e) => e.toString() == data[ROLE]);
    builder.position = getString(data[_POSITION]) ?? "";
    builder.jerseyNumber = getString(data[_JERSEY]) ?? "";
    return builder.build();
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[ROLE] = role.toString();
    ret[ADDED] = true;
    ret[_JERSEY] = jerseyNumber;
    ret[_POSITION] = position;
    return ret;
  }
}
