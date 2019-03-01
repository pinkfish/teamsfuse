import 'common.dart';
import 'package:timezone/timezone.dart';
import 'userdatabasedata.dart';
import 'dart:async';

enum MessageState { Read, Unread, Archived }

class MessageRecipient {
  String uid;
  String playerId;
  String userId;
  String messageId;
  num sentAt;
  MessageState state = MessageState.Unread;

  MessageRecipient({this.playerId, this.state});

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

  MessageRecipient.fromJSON(String uid, Map<String, dynamic> data) {
    this.uid = uid;
    messageId = getString(data[MESSAGEID]);
    playerId = getString(data[PLAYERID]);
    userId = getString(data[USERID]);
    sentAt = getNum(data[SENTAT]);
    state = MessageState.values
        .firstWhere((MessageState e) => e.toString() == data[STATE]);
  }

  Future<void> updateState(MessageState state) {
    return UserDatabaseData.instance.updateModel.updateMessageRecipientState(this, state);
  }

  Future<void> firestoreDelete() {
    return UserDatabaseData.instance.updateModel.deleteRecipient(this);
  }
}

class Message {
  String uid;
  String fromUid;
  String teamUid;
  // Need a rich text section for the message itself.
  bool messagesLoaded = false;
  String message;
  String subject;

  num timeSent;
  num fetched;
  num lastSeen;
  Map<String, MessageRecipient> recipients;

  Message(
      {this.uid,
      this.fromUid,
      this.teamUid,
      this.messagesLoaded,
      this.message,
      this.fetched,
      this.lastSeen,
      this.timeSent,
      this.recipients});

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

  Map<String, dynamic> toJSON(
      {bool includeMessage = false, bool forSQL = false}) {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data[_TEAMUID] = teamUid;
    data[_FROMIUD] = fromUid;
    data[_SUBJECT] = subject;
    if (includeMessage) {
      data[BODY] = message;
    }
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

  Message.fromJSON(String inputUid, Map<String, dynamic> data) {
    uid = inputUid;
    teamUid = getString(data[_TEAMUID]);
    fromUid = getString(data[_FROMIUD]);
    message = getString(data[BODY]);
    timeSent = getNum(data[TIMESENT]);
    subject = getString(data[_SUBJECT]);
    if (data.containsKey(_LASTSEEN)) {
      lastSeen = data[_LASTSEEN];
    }
    if (data.containsKey(_TIMEFETCHED)) {
      fetched = data[_TIMEFETCHED];
    }
    if (data.containsKey(RECIPIENTS)) {
      // From sql.
      this.recipients = {};
      data[RECIPIENTS].forEach((String str, Map<String, dynamic> data) {
        MessageRecipient rec = new MessageRecipient.fromJSON(str, data);
        this.recipients[rec.userId] = rec;
      });
    }
  }

  Future<void> updateFirestore() {
    return UserDatabaseData.instance.updateModel.updateFirestoreMessage(this);
  }

  Future<String> loadMessage(Message mess) {
    return UserDatabaseData.instance.updateModel.loadMessage(mess);
  }
}
