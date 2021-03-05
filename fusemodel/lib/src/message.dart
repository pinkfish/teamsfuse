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
  String get fromUid;
  @BuiltValueField(wireName: playerIdId)
  String get playerId;
  @BuiltValueField(wireName: userIdId)
  String get userId;
  @nullable
  @BuiltValueField(wireName: messageIdId)
  String get messageId;
  @BuiltValueField(wireName: sentAtId)
  Timestamp get sentAt;
  @BuiltValueField(wireName: stateId)
  MessageReadState get state;

  @memoized
  TZDateTime get tzSentAt {
    return TZDateTime.fromMillisecondsSinceEpoch(
        local, sentAt.millisecondsSinceEpoch);
  }

  MessageRecipient._();
  factory MessageRecipient([Function(MessageRecipientBuilder b) updates]) =
      _$MessageRecipient;

  static const String stateId = 'state';
  static const String sentAtId = 'sentAt';
  static const String messageIdId = 'messageId';
  static const String playerIdId = 'playerId';
  static const String userIdId = 'userId';

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

  @BuiltValueField(wireName: timeSentId)
  Timestamp get timeSent;
  @nullable
  num get fetched;
  @nullable
  Timestamp get lastSeen;
  @BuiltValueField(wireName: recipientsId)
  BuiltMap<String, MessageRecipient> get recipients;

  Message._();
  factory Message([Function(MessageBuilder b) updates]) = _$Message;

  @memoized
  TZDateTime get tzTimeSent {
    return TZDateTime.fromMillisecondsSinceEpoch(
        local, timeSent.millisecondsSinceEpoch);
  }

  static const String timeSentId = 'timeSent';
  static const String bodyId = 'body';
  static const String recipientsId = 'recipients';

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(Message.serializer, this);
  }

  static Message fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(Message.serializer, jsonData);
  }

  static Serializer<Message> get serializer => _$messageSerializer;
}
