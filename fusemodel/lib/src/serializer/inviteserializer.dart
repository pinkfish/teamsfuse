import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

import '../invite/invite.dart';

///
/// Deserialize the invite types correctly.
///
class InviteSerializer implements StructuredSerializer<Invite> {
  @override
  Invite deserialize(Serializers serializers, Iterable serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      if (key == Invite.typeField) {
        // Deserialize the invite type.
        InviteType type = InviteType.values
            .firstWhere((InviteType ty) => ty.toString() == value);
        switch (type) {
          case InviteType.Admin:
            return (InviteAsAdmin.serializer
                    as StructuredSerializer<InviteAsAdmin>)
                .deserialize(serializers, serialized);
          case InviteType.Player:
            return (InviteToPlayer.serializer
                    as StructuredSerializer<InviteToPlayer>)
                .deserialize(serializers, serialized);
            case InviteType.LeagueTeam:
            return (InviteToLeagueTeam.serializer
                    as StructuredSerializer<InviteToLeagueTeam>)
                .deserialize(serializers, serialized);
          case InviteType.LeagueAdmin:
            return (InviteToLeagueAsAdmin.serializer
                    as StructuredSerializer<InviteToLeagueAsAdmin>)
                .deserialize(serializers, serialized);
          case InviteType.Club:
            return (InviteToClub.serializer
                    as StructuredSerializer<InviteToClub>)
                .deserialize(serializers, serialized);
          default:
            throw ArgumentError('Unknow invite type $type');
        }
      }
    }
    throw ArgumentError('Unknow invite type');
  }

  @override
  Iterable serialize(Serializers serializers, Invite object,
      {FullType specifiedType = FullType.unspecified}) {
    // TODO: implement serialize
    return null;
  }

  @override
  Iterable<Type> get types => [Invite];

  @override
  String get wireName => "Invite";
}
