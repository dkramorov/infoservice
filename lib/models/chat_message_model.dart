import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:infoservice/helpers/date_time.dart';
import 'package:infoservice/models/roster_model.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xmpp_plugin/models/message_model.dart';

import '../db/chat_db.dart';
import '../db/tables.dart';
import '../helpers/dialogs.dart';
import '../helpers/log.dart';
import '../helpers/phone_mask.dart';
import '../pages/chat/utils.dart';
import '../services/jabber_manager.dart';
import '../widgets/chat/messages_widgets.dart';
import 'abstract_model.dart';

/* Сообщения чата
*/
enum ChatMessageIsReadSent {
  isNew, // создано
  isPending, // отправляется
  isSent, // доставлено
  isRead, // прочитано
}

class ChatMessageModel extends AbstractModel {
  static const String tag = 'ChatMessageModel';

  @override
  Future<Database> openDB() async {
    //print('___openChatDB___');
    return await openChatDB();
  }

  Key key = UniqueKey();

  int? id; // null if we need new row
  String? mid; // message id = f76f8a6c-485b-4737-b6fd-b21bdf61a5eb
  String? customText;
  String? from;
  String? to;
  String? senderJid;
  int? time; // 1674893403756
  String? type;
  String? body;
  String? msgtype;
  String? bubbleType;
  String? mediaURL;
  int? isReadSent;
  int? answered;

  String getTableName() {
    return tableChatMessageModel;
  }

  @override
  String get tableName => getTableName();

  ChatMessageModel({
    this.id,
    this.mid,
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

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mid': mid,
      'customText': customText,
      'fromJid': from,
      'toJid': to,
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

  /* Перегоняем данные из базы в модельку */
  ChatMessageModel toModel(Map<String, dynamic> dbItem) {
    return ChatMessageModel(
      id: dbItem['id'],
      mid: dbItem['mid'],
      customText: dbItem['customText'] ?? '',
      from: dbItem['fromJid'] ?? '',
      to: dbItem['toJid'] ?? '',
      senderJid: dbItem['senderJid'] ?? '',
      time: dbItem['time'] ?? '0',
      type: dbItem['type'] ?? '',
      body: dbItem['body'] ?? '',
      msgtype: dbItem['msgtype'] ?? '',
      bubbleType: dbItem['bubbleType'] ?? '',
      mediaURL: dbItem['mediaURL'] ?? '',
      isReadSent: dbItem['isReadSent'] ?? 0,
      answered: dbItem['answered'] ?? 0,
    );
  }

  static ChatMessageModel convert2ChatMessageModel(MessageChat messageChat) {
    /* MessageChat (сообщение xmpp) => ChatMessageModel (модель базы) */
    ChatMessageModel chatMessageModel = ChatMessageModel(
      mid: messageChat.id,
      customText: messageChat.customText ?? '',
      // упрощаем 89148959223@chat.masterme.ru/b194c194-bff7-4c90-9c62-d24cf97f3670
      from: (messageChat.from ?? '').split('/')[0],
      to: (messageChat.to ?? '').split('/')[0],
      senderJid: messageChat.senderJid ?? '',
      time: int.parse(messageChat.time ?? '0'),
      type: messageChat.type ?? '',
      body: messageChat.body ?? '',
      msgtype: messageChat.msgtype ?? '',
      bubbleType: messageChat.bubbleType ?? '',
      mediaURL: messageChat.mediaURL ?? '',
      isReadSent: messageChat.isReadSent ?? 0,
      answered: messageChat.answered ?? 0,
    );
    return chatMessageModel;
  }

  static MessageChat convert2MessageChat(ChatMessageModel chatMessageModel) {
    /* ChatMessageModel (модель базы) => MessageChat (сообщение xmpp) */
    MessageChat messageChat = MessageChat(
      id: chatMessageModel.mid,
      customText: chatMessageModel.customText,
      from: chatMessageModel.from,
      to: chatMessageModel.to,
      senderJid: chatMessageModel.senderJid,
      time: chatMessageModel.time.toString(),
      type: chatMessageModel.type,
      body: chatMessageModel.body,
      msgtype: chatMessageModel.msgtype,
      bubbleType: chatMessageModel.bubbleType,
      mediaURL: chatMessageModel.mediaURL,
      isReadSent: chatMessageModel.isReadSent,
      answered: chatMessageModel.answered,
    );
    return messageChat;
  }

  static String messageForRoster(ChatMessageModel model) {
    /* Сообщение для ростера (текст последнего сообщения) */
    if (model.body == MediaType.answer.toString() ||
        model.body == MediaType.question.toString()) {
      try {
        Map<String, dynamic> customText = jsonDecode(model.customText ?? '{}');
        if (customText['type'] == MediaType.question.toString()) {
          return 'Запрос разрешения для сравнения общих контактов';
        } else if (customText['type'] == MediaType.answer.toString()) {
          if (customText['answer'] != null && customText['answer']) {
            return 'Разрешено сравнение общих контактов ';
          }
          return 'Отклонено сравнение общих контактов ';
        }
      } catch (ex) {
        Log.d(tag, '[ERROR]: ${ex.toString()}');
      }
    }
    return model.body ?? '---';
  }

  static ChatMessage convert2ChatMessage(
    MessageChat messageChat,
    ChatUser me, {
    String setFromName = '',
    bool disableAnswer = false,
    BuildContext? context,
  }) {
    /* MessageChat (сообщение xmpp) => ChatMessage (виджет)
       Для групп надо смотреть по senderJid кто заслал и вытаскивать имя
    */
    String sender = messageChat.senderJid ?? '';
    String senderJid = sender.split('/')[0];
    // Фикс на группу
    if (sender.contains('${JabberManager.conferenceString}/')) {
      senderJid = '${sender.split('/')[1]}${JabberManager.conferenceString}';
    }
    String phone = cleanPhone(senderJid);
    if (setFromName.isNotEmpty) {
      phone = setFromName;
    }
    ChatUser chatUser = ChatUser(
        id: phone, jid: senderJid, name: phone, phone: phoneMaskHelper(phone));

    bool isMe = phone == me.id;
    if (isMe) {
      chatUser = me;
    } else {
      String jid = '$phone${JabberManager.domainString}';
      RosterModel? rosterModel = RosterModel.prefetchedModels[jid];
      if (rosterModel != null) {
        chatUser.name = rosterModel.name ?? chatUser.phone;
      }
    }

    ChatMessage chatMessage = ChatMessage(
        text: messageChat.body ?? '',
        user: chatUser,
        customProperties: {
          'id': messageChat.id,
          'me': isMe,
          'icon': const Icon(Ionicons.checkmark_done_outline),
        },
        medias: [],
        status: messageChat.isReadSent == 2
            ? MessageStatus.received
            : MessageStatus.pending,
        createdAt: timestamp2Datetime(int.parse(messageChat.time.toString())));

    if (messageChat.customText != null &&
        CHAT_MEDIA_TYPES.contains(chatMessage.text)) {
      MediaType mediaType = MediaType.parse(chatMessage.text);
      try {
        Map<String, dynamic> customText = jsonDecode(messageChat.customText!);
        chatMessage.text = '';
        // TODO: заглушку
        String url = customText['url'] ?? '';
        if (url == '') {
          if (customText['path'] != null && customText['path'] != '') {
            url = customText['path'];
          }
        }
        Map<String, dynamic> customProperties = {};
        if (mediaType == MediaType.audio) {
          customProperties['widget'] = VoiceMessage(
            audioSrc: url,
            played: false,
            me: phone == me.id,
            createdAt: chatMessage.createdAt,
            readStatus: chatMessage.status,
          );
        } else if (mediaType == MediaType.file) {
          customProperties['widget'] = FileMessage(
            fileSrc: url,
            me: phone == me.id,
            createdAt: chatMessage.createdAt,
            readStatus: chatMessage.status,
          );
        } else if (mediaType == MediaType.image) {
          customProperties['onTap'] = () {
            if (context == null) {
              Log.d(tag, 'YOU HAVE TO OVERWRITE by self onTap method');
            } else {
              launchInWebViewOrVC(url, context);
            }
          };
        } else if (mediaType == MediaType.question) {
          customProperties['widget'] = QuestionMessage(
            me: phone == me.id,
            senderJid: senderJid,
            createdAt: chatMessage.createdAt,
            disabled: messageChat.answered == 1 ? true : disableAnswer,
            mid: messageChat.id ?? '',
          );
        } else if (mediaType == MediaType.answer) {
          customProperties['widget'] = AnswerMessage(
            me: phone == me.id,
            answer: customText['answer'],
            createdAt: chatMessage.createdAt,
            readStatus: chatMessage.status,
          );
        }
        chatMessage.medias!.add(ChatMedia(
          url: url,
          type: mediaType,
          fileName: url.split('/').last,
          customProperties: customProperties,
        ));
      } catch (err) {
        Log.e(tag, 'ERROR decode customText in message ${err.toString()}');
      }
    }
    return chatMessage;
  }

  Future<int> setReadFlag(
      int beforeTime, String myJid, String friendJid) async {
    /* Все сообщения до этого времении (включительно) считать прочитанными */
    final db = await openDB();
    List whereArgs = [beforeTime, myJid, friendJid, friendJid, myJid];

    int result = await db.update(
      tableChatMessageModel,
      {'isReadSent': 2},
      where:
          'isReadSent!=2 AND time<=? AND ((fromJid=? AND toJid=?) OR (fromJid=? AND toJid=?))',
      whereArgs: whereArgs,
    );
    Log.i(
        tableChatMessageModel,
        'setReadFlag me: $myJid, friend $friendJid, time: $beforeTime; '
        'count $result');
    return result;
  }

  Future<bool> isExists() async {
    if (time == null || time == 0 || body == null || body?.trim() == '') {
      Log.e(
          tag,
          'FAILED check isExists with time $time and mid $mid, '
          'BODY: $body, NOT SAVED');
      return true;
    }
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableChatMessageModel,
      where: 'mid=? AND time=?',
      whereArgs: [mid, time],
    );
    return maps.isEmpty ? false : true;
  }

  Future<ChatMessageModel> getByPk(int pk) async {
    final db = await openDB();
    final List<Map<String, dynamic>> messages = await db.query(
      tableChatMessageModel,
      where: 'id=?',
      whereArgs: [pk],
    );
    if (messages.isEmpty) {
      return ChatMessageModel();
    }
    return toModel(messages[0]);
  }

  Future<ChatMessageModel> getByMid(String mid) async {
    final db = await openDB();
    final List<Map<String, dynamic>> messages = await db.query(
      tableChatMessageModel,
      where: 'mid=?',
      whereArgs: [mid],
    );
    if (messages.isEmpty) {
      return ChatMessageModel();
    }
    return toModel(messages[0]);
  }

  Future<List<ChatMessageModel>> getByMids(List<String> idsMessages) async {
    final db = await openDB();
    String params = '0';
    for (String msgId in idsMessages) {
      params += ', "$msgId"';
    }
    final List<Map<String, dynamic>> messages = await db.query(
      tableChatMessageModel,
      where: 'mid IN ($params)',
    );
    return List.generate(messages.length, (i) {
      return toModel(messages[i]);
    });
  }

  Future<List<ChatMessageModel>> getByReadFlag(List<String> idsMessages) async {
    final db = await openDB();
    String params = '0';
    for (String msgId in idsMessages) {
      params += ', "$msgId"';
    }
    final List<Map<String, dynamic>> messages = await db.query(
      tableChatMessageModel,
      where: 'mid IN ($params) AND isReadSent=2',
    );
    return List.generate(messages.length, (i) {
      return toModel(messages[i]);
    });
  }

  Future<List<ChatMessageModel>> getNotSentMessages(String myJid) async {
    /* Неотправленные сообщения? */
    final db = await openDB();
    final List<Map<String, dynamic>> messages = await db.query(
      tableChatMessageModel,
      where: 'fromJid=? AND isReadSent=0',
      whereArgs: [myJid],
    );
    return List.generate(messages.length, (i) {
      return toModel(messages[i]);
    });
  }

  Future<List<ChatMessageModel>> getMessages(String myJid, String friendJid,
      {int limit = 100, int offset = 0, String orderBy = 'time DESC'}) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableChatMessageModel,
      where: 'toJid IN (?,?) AND fromJid IN (?,?)',
      whereArgs: [myJid, friendJid, myJid, friendJid],
      limit: limit,
      offset: offset,
      orderBy: orderBy, // И сортируем последними вперед
    );
    return List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
  }

  Future<List<ChatMessageModel>> getMessagesAfter(
      String myJid, String friendJid,
      {int after = 0}) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableChatMessageModel,
      where: 'toJid IN (?,?) AND fromJid IN (?,?) and time>?',
      whereArgs: [myJid, friendJid, myJid, friendJid, after],
    );
    return List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
  }

  Future<ChatMessageModel?> getAnswers(
      String myJid, String friendJid, String msgType) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableChatMessageModel,
      where: 'msgtype=? AND toJid IN (?,?) AND fromJid IN (?,?)',
      whereArgs: [msgType, myJid, friendJid, myJid, friendJid],
      orderBy: 'time DESC',
      limit: 1,
    );
    for (int i = 0; i < maps.length; i++) {
      return toModel(maps[i]);
    }
    return null;
  }
}
