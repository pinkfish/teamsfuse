import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:timezone/timezone.dart';

import 'serializer/timestampserializer.dart';
import 'serializer.dart';

part 'message.g.dart';

///
/// Current read/unread state of the message
///
class MessageReadState extends EnumClass {
  static Serializer<MessageReadState> get serializer =>
      _$messageReadStateSerializer;

  static const MessageReadState Read = _$Read;
  static const MessageReadState Unread = _$Unread;
  static const MessageReadState Archived = _$Archived;

  const MessageReadState._(String name) : super(name);

  static BuiltSet<MessageReadState> get values => _$MessageReadStateValues;

  static MessageReadState valueOf(String name) =>
      _$MessageReadStateValueOf(name);
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
  Timestamp get sentAt;
  MessageReadState get state;

  @memoized
  TZDateTime get tzSentAt {
    return new TZDateTime.fromMillisecondsSinceEpoch(
        local, sentAt.millisecondsSinceEpoch);
  }

  MessageRecipient._();
  factory MessageRecipient([updates(MessageRecipientBuilder b)]) =
      _$MessageRecipient;

  static const String STATE = 'state';
  static const String SENTAT = 'sentAt';
  static const String MESSAGEID = 'messageId';
  static const String PLAYERID = 'playerId';
  static const String USERID = 'userId';

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(MessageRecipient.serializer, this);
  }

  static MessageRecipient fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(
        MessageRecipient.serializer, jsonData);
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

  Timestamp get timeSent;
  @nullable
  num get fetched;
  @nullable
  Timestamp get lastSeen;
  BuiltMap<String, MessageRecipient> get recipients;

  Message._();
  factory Message([updates(MessageBuilder b)]) = _$Message;

  @memoized
  TZDateTime get tzTimeSent {
    return new TZDateTime.fromMillisecondsSinceEpoch(
        local, timeSent.millisecondsSinceEpoch);
  }

  static const String TIMESENT = 'timeSent';
  static const String BODY = 'body';
  static const String RECIPIENTS = 'recipients';

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(Message.serializer, this);
  }

  static Message fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(Message.serializer, jsonData);
  }

  static Serializer<Message> get serializer => _$messageSerializer;
}
