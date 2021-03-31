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

  /// If the message has been read.
  static const MessageReadState Read = _$Read;

  /// If the message is unread.
  static const MessageReadState Unread = _$Unread;

  /// If the message has been archied.
  static const MessageReadState Archived = _$Archived;

  /// Create the state from the name.
  const MessageReadState._(String name) : super(name);

  /// The values of the read stats.
  static BuiltSet<MessageReadState> get values => _$MessageReadStateValues;

  /// Get the value of the state from the string.
  static MessageReadState valueOf(String name) =>
      _$MessageReadStateValueOf(name);
}

///
/// Recipient for the message.
///
abstract class MessageRecipient
    implements Built<MessageRecipient, MessageRecipientBuilder> {
  /// The uid of the message.
  @nullable
  String get uid;

  /// Who sent you the message.
  String get fromUid;

  /// The playerUid associated with the message.
  @BuiltValueField(wireName: playerIdId)
  String get playerId;

  /// The userid the message was sent to.
  @BuiltValueField(wireName: userIdId)
  String get userId;

  /// The messageId that has all the message details.
  @nullable
  @BuiltValueField(wireName: messageIdId)
  String get messageId;

  /// The time the message was sent at.
  @BuiltValueField(wireName: sentAtId)
  Timestamp get sentAt;

  /// The current state of this message.
  @BuiltValueField(wireName: stateId)
  MessageReadState get state;

  /// The time the message was sent at in the local time.
  @memoized
  TZDateTime get tzSentAt {
    return TZDateTime.fromMillisecondsSinceEpoch(
        local, sentAt.millisecondsSinceEpoch);
  }

  MessageRecipient._();

  /// Factory to make the message.
  factory MessageRecipient([Function(MessageRecipientBuilder b) updates]) =
      _$MessageRecipient;

  /// The stateId Field.
  static const String stateId = 'state';

  /// The sendAtId field.
  static const String sentAtId = 'sentAt';

  /// The messageId field.
  static const String messageIdId = 'messageId';

  /// The playerId field.
  static const String playerIdId = 'playerId';

  /// The userId field.
  static const String userIdId = 'userId';

  /// Serialize the message recipient.
  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(MessageRecipient.serializer, this);
  }

  /// Create a message recipient from the on the wire format.
  static MessageRecipient fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(
        MessageRecipient.serializer, jsonData);
  }

  /// The serializer to use.
  static Serializer<MessageRecipient> get serializer =>
      _$messageRecipientSerializer;
}

///
/// Actual data in the message.
///
abstract class Message implements Built<Message, MessageBuilder> {
  /// The uid for the message.
  @nullable
  String get uid;

  /// The user that sent the message.
  String get fromUid;

  /// The team the message is associated with.
  String get teamUid;

  /// The subject of the message.
  String get subject;

  /// The time the message was sent.
  @BuiltValueField(wireName: timeSentId)
  Timestamp get timeSent;

  /// The recipients of the message.
  @BuiltValueField(wireName: recipientsId)
  BuiltMap<String, MessageRecipient> get recipients;

  Message._();

  /// The factory to make the message.
  factory Message([Function(MessageBuilder b) updates]) = _$Message;

  /// The time the message was sent as in the local timezone.
  @memoized
  TZDateTime get tzTimeSent {
    return TZDateTime.fromMillisecondsSinceEpoch(
        local, timeSent.millisecondsSinceEpoch);
  }

  /// The timeSentId field.
  static const String timeSentId = 'timeSent';

  /// The bodyId field.
  static const String bodyId = 'body';

  /// The recipientsId field.
  static const String recipientsId = 'recipients';

  /// Serializes the message to a mapping.
  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(Message.serializer, this);
  }

  /// Deserailize the message from a map.
  static Message fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(Message.serializer, jsonData);
  }

  /// The serializer to use for the class.
  static Serializer<Message> get serializer => _$messageSerializer;
}
