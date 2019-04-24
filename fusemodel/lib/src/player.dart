import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import 'common.dart';

part 'player.g.dart';

enum Relationship { Me, Parent, Guardian, Friend }

///
/// The user part of the player, has a mapping to the relationship with the
/// player.
///
abstract class PlayerUser implements Built<PlayerUser, PlayerUserBuilder> {
  String get userUid;
  Relationship get relationship;

  PlayerUser._();
  factory PlayerUser([updates(PlayerUserBuilder b)]) = _$PlayerUser;

  static const String _RELATIONSHIP = 'relationship';

  static PlayerUserBuilder fromJSON(Map<dynamic, dynamic> data) {
    PlayerUserBuilder builder = PlayerUserBuilder();
    builder.relationship = Relationship.values.firstWhere(
        (e) => e.toString() == data[_RELATIONSHIP],
        orElse: () => Relationship.Friend);
    return builder;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = new Map<String, dynamic>();

    data[_RELATIONSHIP] = relationship.toString();
    data[ADDED] = true;
    return data;
  }
}

///
/// The player associated with users and in all the various teams.
///
abstract class Player implements Built<Player, PlayerBuilder> {
  String get name;
  String get uid;
  String get photoUrl;
  BuiltMap<String, PlayerUser> get users;

  Player._();
  factory Player([updates(PlayerBuilder b)]) = _$Player;

  static const String USERS = 'user';

  static PlayerBuilder fromJSON(String playerUid, Map<String, dynamic> data) {
    PlayerBuilder builder = PlayerBuilder();
    builder
      ..uid = playerUid
      ..name = data[NAME]
      ..photoUrl = data[PHOTOURL];

    Map<dynamic, dynamic> usersData = data[USERS] as Map<dynamic, dynamic>;
    if (usersData != null) {
      usersData.forEach((dynamic key, dynamic data) {
        if (data != null) {
          PlayerUserBuilder mapToUser =
              PlayerUser.fromJSON(data as Map<dynamic, dynamic>);
          mapToUser.userUid = key.toString();
          builder.users[key.toString()] = mapToUser.build();
        }
      });
    }
    return builder;
  }

  Map<String, dynamic> toJSON({bool includeUsers: false}) {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = getString(name);
    ret[PHOTOURL] = getString(photoUrl);
    if (includeUsers) {
      Map<String, dynamic> userOut = new Map<String, dynamic>();
      users.forEach((String uid, PlayerUser players) {
        userOut[uid] = players.toJSON();
      });
      ret[USERS] = userOut;
    }
    return ret;
  }

  /*
  void dispose() {
    _subscriptions?.forEach((StreamSubscription<dynamic> sub) {
      sub.cancel();
    });
    _subscriptions = null;
    _controller?.close();
    _controller = null;
    _invites?.clear();
    _invites = null;
  }*/

  /*
  Future<void> updateFirestore({bool includeUsers = false}) async {
    return UserDatabaseData.instance.updateModel
        .updateFirestorePlayer(this, includeUsers);
  }

  Future<Uri> updateImage(File imgFile) async {
    return UserDatabaseData.instance.updateModel
        .updatePlayerImage(this, imgFile);
  }
  */

  // Send an invite to a user for this season and team.
  /*
  Future<void> inviteUser({String email}) async {
    return UserDatabaseData.instance.updateModel
        .inviteUserToPlayer(this, email: normalizeEmail(email));
  }
  */

  /*
  Stream<List<InviteToPlayer>> get inviteStream {
    if (_stream == null) {
      _controller = new StreamController<List<InviteToPlayer>>();
      _stream = _controller.stream.asBroadcastStream();
    }
    // Do an async query.
    _doInviteQuery();
    return _stream;
  }

  List<InviteToPlayer> get cachedInvites => _invites;
  */

  /*
  Future<void> removeFirebaseUser(String userId) {
    return UserDatabaseData.instance.updateModel
        .removeUserFromPlayer(this, userId);
  }


  void setInvites(List<InviteToPlayer> invites) {
    _invites = invites;
    _controller.add(invites);
  }


  Future<void> _doInviteQuery() async {
    await for (Iterable<InviteToPlayer> invites in UserDatabaseData
        .instance.updateModel
        .getInviteForPlayerStream(this)) {
      _invites = invites;
    }
  }
  */

}
