
class MessageEvent {
  String? id;
  String? customText;
  String? from;
  String? to;
  String? senderJid;
  String? time;
  String? type;
  String? body;
  String? msgtype;
  String? bubbleType;
  String? mediaURL;
  String? presenceType;
  String? presenceMode;
  String? chatStateType;
  int? isReadSent;

  MessageEvent({
    this.id,
    this.customText,
    this.from,
    this.to,
    this.senderJid,
    this.time,
    this.type,
    this.body,
    this.msgtype,
    this.bubbleType,
    this.mediaURL,
    this.presenceType,
    this.presenceMode,
    this.chatStateType,
    this.isReadSent,
  });

  Map<String, dynamic> toEventData() {
    return {
      'id': id,
      'customText': customText,
      'from': from,
      'to': to,
      'senderJid': senderJid,
      'time': time,
      'type': type,
      'body': body,
      'msgtype': msgtype,
      'bubbleType': bubbleType,
      'mediaURL': mediaURL,
      'presenceType': presenceType,
      'presenceMode': presenceMode,
      'isReadSent': isReadSent,
      'chatStateType': chatStateType,

    };
  }

  factory MessageEvent.fromJson(dynamic eventData) {
    return MessageEvent(
      id: eventData['id'] ?? '',
      customText: eventData['customText'] ?? '',
      from: eventData['from'] ?? '',
      to: eventData['to'] ?? '',
      senderJid: eventData['senderJid'] ?? '',
      time: eventData['time'] ?? '0',
      isReadSent: eventData['isReadSent'] ?? 0,
      type: eventData['type'] ?? '',
      body: eventData['body'] ?? '',
      msgtype: eventData['msgtype'] ?? '',
      bubbleType: eventData['bubbleType'] ?? '',
      mediaURL: eventData['mediaURL'] ?? '',
      presenceType: eventData['presenceType'] ?? '',
      presenceMode: eventData['presenceMode'] ?? '',
      chatStateType: eventData['chatStateType'] ?? '',
    );
  }
}
