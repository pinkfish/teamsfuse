import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';
import 'invite.dart';

part 'invitetoclub.g.dart';

///
/// Invited to a club.
///
abstract class InviteToClub
    implements Invite, Built<InviteToClub, InviteToClubBuilder> {
  String get clubName;
  @BuiltValueField(wireName: CLUBUID)
  String get clubUid;
  bool get admin;

  static const String CLUBUID = 'clubUid';

  factory InviteToClub([void Function(InviteToClubBuilder) updates]) =
      _$InviteToClub;
  InviteToClub._();

  Map<String, dynamic> toMap({bool includeMembers}) {
    return dataSerializers.serializeWith(InviteToClub.serializer, this);
  }

  static InviteToClub fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(InviteToClub.serializer, jsonData);
  }

  static Serializer<InviteToClub> get serializer => _$inviteToClubSerializer;

  static void _initializeBuilder(InviteToClubBuilder b) =>
      b..type = InviteType.Club;
}
