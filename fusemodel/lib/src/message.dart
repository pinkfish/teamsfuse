import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:timezone/timezone.dart';

import 'serializer.dart';

part 'message.g.dart';

///
/// Current read/unread state of the message
///
class MessageState extends EnumClass {
  static Serializer<MessageState> get serializer => _$messageStateSerializer;

  static const MessageState Read = _$Read;
  static const MessageState Unread = _$Unread;
  static const MessageState Archived = _$Archived;

  const MessageState._(String name) : super(name);

  static BuiltSet<MessageState> get values => _$MessageStateValues;

  static MessageState valueOf(String name) => _$MessageStateValueOf(name);
}

///
/// Recipient for the message.
///
abstract class MessageRecipient
    implements Built<MessageRecipient, MessageRecipientBuilder> {
  @nullable
  String get uid;
  String get playerId;
  String get userId;
  @nullable
  String get messageId;
  @nullable
  num get sentAt;
  MessageState get state;

  MessageRecipient._();
  factory MessageRecipient([updates(MessageRecipientBuilder b)]) =
      _$MessageRecipient;

  static const String STATE = 'state';
  static const String SENTAT = 'sentAt';
  static const String MESSAGEID = 'messageId';
  static const String PLAYERID = 'playerId';
  static const String USERID = 'userId';

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(MessageRecipient.serializer, this);
  }

  static MessageRecipient fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(MessageRecipient.serializer, jsonData);
  }

  static Serializer<MessageRecipient> get serializer =>
      _$messageRecipientSerializer;
}

///
/// Actual data in the message.
///
abstract class Message implements Built<Message, MessageBuilder> {
  @nullable
  String get uid;
  String get fromUid;
  String get teamUid;
  String get subject;

  @nullable
  num get timeSent;
  @nullable
  num get fetched;
  @nullable
  num get lastSeen;
  BuiltMap<String, MessageRecipient> get recipients;

  Message._();
  factory Message([updates(MessageBuilder b)]) = _$Message;

  TZDateTime get tzTimeSent {
    return new TZDateTime.fromMillisecondsSinceEpoch(local, timeSent);
  }

  static const String TIMESENT = 'timeSent';
  static const String BODY = 'body';
  static const String RECIPIENTS = 'recipients';

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Message.serializer, this);
  }

  static Message fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(Message.serializer, jsonData);
  }

  static Serializer<Message> get serializer => _$messageSerializer;
}
