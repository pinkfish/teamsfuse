import 'common.dart';

///
/// The division is the sub-section of the tournament or league.
///
class Division {
  String name;
  String uid;
  String leagueUid;

  ///
  /// This is a user id.  Admins of the tournemtn/league itself are also
  /// admins for each divisjon.  Each division can also have it's own
  /// admin.
  ///
  List<String> admins;

  static const String LEAGUEUID = "leagueUid";
  static const String ADMINS = "admins";

  ///
  /// Convrt this division into the format to use to send over the wire.
  ///
  Map<String, dynamic> toJson({bool includeMembers = false}) {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret[NAME] = name;
    ret[LEAGUEUID] = leagueUid;
    if (includeMembers) {
      for (String adminUid in admins) {
        ret[ADMINS + "." + adminUid] = {
          ADDED: true,
        };
      }
    }
    return ret;
  }

  ///
  /// Load this from the wire format.
  ///
  Division.fromJson(String myUid, Map<String, dynamic> data) {
    uid = myUid;
    name = data[NAME];
    leagueUid = data[LEAGUEUID];
    admins = [];
    for (String adminUid in data[ADMINS].keys) {
      Map<dynamic, dynamic> inner = data[ADMINS][adminUid];
      if (inner[ADDED]) {
        admins.add(adminUid);
      }
    }
  }
}
