class MessageChat {
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
  int? isReadSent;
  int? answered;

  MessageChat({
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
    this.isReadSent,
    this.answered,
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
      'isReadSent': isReadSent,
      'answered': answered,
    };
  }

  @override
  String toString() {
    String result = '';
    toEventData().forEach((final String key, final value) {
      result += '$key=$value; ';
    });
    return result;
  }

  factory MessageChat.fromJson(dynamic eventData) {
    return MessageChat(
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
      answered: eventData['answered'] ?? 0,
    );
  }
}
