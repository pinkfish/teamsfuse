import 'common.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart';

enum MessageState { Read, Unread, Archived }

class MessageRecipient {
  String uid;
  String playerId;
  String userId;
  String name;
  String messageId;
  num sentAt;
  MessageState state = MessageState.Unread;

  MessageRecipient({this.playerId, this.name, this.state});

  static const String STATE = 'state';
  static const String SENTAT = 'sentAt';
  static const String MESSAGEID = 'messageId';
  static const String PLAYERID = 'playerId';
  static const String USERID = 'userId';

  Map<String, dynamic> toJSON({bool forSQL = false}) {
    Map<String, dynamic> data = new Map<String, dynamic>();

    data[NAME] = name;
    data[STATE] = state.toString();
    data[SENTAT] = sentAt;
    data[MESSAGEID] = messageId;
    data[PLAYERID] = playerId;
    if (forSQL) {
      data[USERID] = userId;
    }
    return data;
  }

  void fromJSON(String uid, Map<String, dynamic> data) {
    this.uid = uid;
    name = getString(data[NAME]);
    messageId = getString(data[MESSAGEID]);
    playerId = getString(data[PLAYERID]);
    userId = getString(data[USERID]);
    sentAt = getNum(data[SENTAT]);
    state = MessageState.values
        .firstWhere((MessageState e) => e.toString() == data[STATE]);
  }

  void updateMessageState(MessageState state) async {
    DocumentReference doc = Firestore.instance
        .collection(MESSAGE_RECIPIENTS_COLLECTION)
        .document(this.uid);
    await doc.updateData({STATE: state.toString()});
  }

  void deleteRecipient() async {
    DocumentReference doc = Firestore.instance
        .collection(MESSAGE_RECIPIENTS_COLLECTION)
        .document(this.uid);
    await doc.delete();
  }
}

class Message {
  String uid;
  String fromUid;
  String fromName;
  String teamUid;
  // Need a rich text section for the message itself.
  bool messagesLoaded = false;
  String message;
  String subject;

  num timeSent;
  num fetched;
  num lastSeen;
  Map<String, MessageRecipient> recipients;

  TZDateTime get tzTimeSent {
    return new TZDateTime.fromMillisecondsSinceEpoch(local, timeSent);
  }

  static const String _FROMIUD = 'fromUid';
  static const String _FROMNAME = 'fromName';
  static const String _TEAMUID = 'teamUid';
  static const String TIMESENT = 'timeSent';
  static const String _SUBJECT = 'subject';
  static const String _BODY = 'body';
  static const String _TIMEFETCHED = 'timeFetched';
  static const String _LASTSEEN = 'lastSeen';
  static const String _RECIPIENTS = 'recipients';

  Map<String, dynamic> toJSON(
      {bool includeMessage = false, bool forSQL = false}) {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data[_TEAMUID] = teamUid;
    data[_FROMIUD] = fromUid;
    data[_FROMNAME] = fromName;
    data[_SUBJECT] = subject;
    if (includeMessage) {
      data[_BODY] = message;
    }
    data[TIMESENT] = timeSent;
    if (forSQL) {
      data[_TIMEFETCHED] = fetched;
      data[_LASTSEEN] = lastSeen;
      // Add the recipients here too.
      data[_RECIPIENTS] = {};
      recipients.forEach((String id, MessageRecipient rec) {
        data[_RECIPIENTS][rec.uid] = rec.toJSON(forSQL: true);
      });
    }
    return data;
  }

  void fromJSON(String inputUid, Map<String, dynamic> data) {
    uid = inputUid;
    teamUid = getString(data[_TEAMUID]);
    fromUid = getString(data[_FROMIUD]);
    fromName = getString(data[_FROMNAME]);
    message = getString(data[_BODY]);
    timeSent = getNum(data[TIMESENT]);
    subject = getString(data[_SUBJECT]);
    if (data.containsKey(_LASTSEEN)) {
      lastSeen = data[_LASTSEEN];
    }
    if (data.containsKey(_TIMEFETCHED)) {
      fetched = data[_TIMEFETCHED];
    }
    if (data.containsKey(_RECIPIENTS)) {
      // From sql.
      this.recipients = {};
      data[_RECIPIENTS].forEach((String str, Map<String, dynamic> data) {
        MessageRecipient rec = new MessageRecipient();
        rec.fromJSON(str, data);
        this.recipients[rec.userId] = rec;
      });
    }
  }

  Future<void> updateFirestore() async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection("Messages");
    if (uid == '' || uid == null) {
      // Add the game.
      DocumentReference doc = await ref.add(toJSON(includeMessage: true));
      this.timeSent = new DateTime.now().millisecondsSinceEpoch;
      this.uid = doc.documentID;
      // Add the message body.
      DocumentReference messageRef = Firestore.instance
          .collection(MESSAGES_COLLECTION)
          .document(uid)
          .getCollection(MESSAGES_COLLECTION)
          .document(uid);
      // Add in the recipients collection.
      await Future.forEach(recipients.keys, (String str) async {
        MessageRecipient rec = recipients[str];
        rec.messageId = this.uid;
        rec.sentAt = new DateTime.now().millisecondsSinceEpoch;
        DocumentReference recRef = await Firestore.instance
            .collection(MESSAGE_RECIPIENTS_COLLECTION)
            .add(rec.toJSON());
        rec.uid = recRef.documentID;
        return rec.uid;
      });
      Map<String, dynamic> messageData = {};
      messageData[_BODY] = message;
      await messageRef.setData(messageData);
    } else {
      // Update the message.
      await ref.document(uid).updateData(toJSON(includeMessage: false));
    }
  }

  Future<String> loadMessage() async {
    DocumentReference ref = Firestore.instance
        .collection("Messages")
        .document(uid)
        .getCollection(_BODY)
        .document(uid);
    DocumentSnapshot snap = await ref.get();
    if (snap.exists) {
      message = snap.data[_BODY];
      messagesLoaded = true;
      return message;
    }
    return null;
  }
}
