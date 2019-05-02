import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:timezone/timezone.dart';

import 'common.dart';

part 'message.g.dart';

enum MessageState { Read, Unread, Archived }

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

  Map<String, dynamic> toJSON({bool forSQL = false}) {
    Map<String, dynamic> data = new Map<String, dynamic>();

    data[STATE] = state.toString();
    data[SENTAT] = sentAt;
    data[MESSAGEID] = messageId;
    data[PLAYERID] = playerId;
    if (forSQL) {
      data[USERID] = userId;
    }
    return data;
  }

  static MessageRecipientBuilder fromJSON(
      String uid, Map<String, dynamic> data) {
    MessageRecipientBuilder builder = MessageRecipientBuilder();
    builder
      ..uid = uid
      ..messageId = getString(data[MESSAGEID])
      ..playerId = getString(data[PLAYERID])
      ..userId = getString(data[USERID])
      ..sentAt = getNum(data[SENTAT])
      ..state = MessageState.values
          .firstWhere((MessageState e) => e.toString() == data[STATE]);
    return builder;
  }

  /*
  Future<void> updateState(MessageState state) {
    return UserDatabaseData.instance.updateModel.updateMessageRecipientState(this, state);
  }

  Future<void> firestoreDelete() {
    return UserDatabaseData.instance.updateModel.deleteRecipient(this);
  }
  */
}

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

  static const String _FROMIUD = 'fromUid';
  static const String _TEAMUID = 'teamUid';
  static const String TIMESENT = 'timeSent';
  static const String _SUBJECT = 'subject';
  static const String BODY = 'body';
  static const String _TIMEFETCHED = 'timeFetched';
  static const String _LASTSEEN = 'lastSeen';
  static const String RECIPIENTS = 'recipients';

  Map<String, dynamic> toJSON({bool forSQL = false}) {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data[_TEAMUID] = teamUid;
    data[_FROMIUD] = fromUid;
    data[_SUBJECT] = subject;
    data[TIMESENT] = timeSent;
    if (forSQL) {
      data[_TIMEFETCHED] = fetched;
      data[_LASTSEEN] = lastSeen;
      // Add the recipients here too.
      data[RECIPIENTS] = {};
      recipients.forEach((String id, MessageRecipient rec) {
        data[RECIPIENTS][rec.uid] = rec.toJSON(forSQL: true);
      });
    }
    return data;
  }

  static MessageBuilder fromJSON(String inputUid, Map<String, dynamic> data) {
    MessageBuilder builder = MessageBuilder();
    builder
      ..uid = inputUid
      ..teamUid = getString(data[_TEAMUID])
      ..fromUid = getString(data[_FROMIUD])
      ..timeSent = getNum(data[TIMESENT])
      ..subject = getString(data[_SUBJECT]);
    if (data.containsKey(_LASTSEEN)) {
      builder.lastSeen = data[_LASTSEEN];
    }
    if (data.containsKey(_TIMEFETCHED)) {
      builder.fetched = data[_TIMEFETCHED];
    }
    if (data.containsKey(RECIPIENTS)) {
      // From sql.
      data[RECIPIENTS].forEach((String str, Map<String, dynamic> data) {
        MessageRecipient rec = MessageRecipient.fromJSON(str, data).build();
        builder.recipients[rec.userId] = rec;
      });
    }
    return builder;
  }
}
