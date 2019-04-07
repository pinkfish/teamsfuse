import '../common.dart';
import '../winrecord.dart';
import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';

part 'opponent.g.dart';

///
/// An opponent for a team with all the opponent metadata associated with it.
///
abstract class Opponent implements Built<Opponent, OpponentBuilder> {
  String get name;
  String get teamUid;
  String get contact;
  String get uid;
  BuiltList<String> get leagueTeamUid;
  BuiltMap<String, WinRecord> get record;

  Opponent._();
  factory Opponent([updates(OpponentBuilder b)]) = _$Opponent;

  static const String _CONTACT = 'contact';
  static const String _SEASONS = 'seasons';
  static const String _LEAGUETEAMUID = 'leagueTeamUid';

  static OpponentBuilder fromJSON(
      String uid, String teamUid, Map<String, dynamic> data) {
    OpponentBuilder builder = OpponentBuilder();
    builder.uid = uid;
    builder.teamUid = teamUid;
    builder.name = getString(data[NAME]);
    builder.contact = getString(data[_CONTACT]);
    if (data[_LEAGUETEAMUID] != null) {
      List<String> newLeagues = new List<String>();
      data[_LEAGUETEAMUID].forEach((dynamic key, dynamic data) {
        if (data is Map<dynamic, dynamic>) {
          if (data[ADDED]) {
            newLeagues.add(key as String);
          }
        }
      });
      builder.leagueTeamUid.addAll(newLeagues);
    }
    Map<String, WinRecord> newRecord = new Map<String, WinRecord>();
    if (data[_SEASONS] != null) {
      Map<dynamic, dynamic> innerSeason =
          data[_SEASONS] as Map<dynamic, dynamic>;
      // Load the seasons.
      innerSeason.forEach((dynamic seasonUid, dynamic value) {
        WinRecordBuilder newData =
            WinRecord.fromJSON(value as Map<dynamic, dynamic>);
        newRecord[seasonUid.toString()] = newData.build();
      });
    }
    builder.record.addAll(newRecord);
    return builder;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = name;
    ret[_CONTACT] = contact;
    Map<String, Map<String, dynamic>> fluff = <String, Map<String, dynamic>>{};
    for (String league in leagueTeamUid) {
      fluff[league] = <String, dynamic>{
        ADDED: true,
      };
    }
    ret[_LEAGUETEAMUID] = fluff;
    Map<String, dynamic> recordSection = new Map<String, dynamic>();
    record.forEach((String key, WinRecord record) {
      recordSection[key] = record.toJSON();
    });
    ret[_SEASONS] = recordSection;
    return ret;
  }
}
