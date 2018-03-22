enum MessageState { Read, Unread }


class Message {
  String fromUid;
  String fromName;
  String teamUid;
  // Need a rich text section for the message itself.

  num timeSent;
}