import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:chat_composer/chat_composer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infoservice/pages/chat/utils.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:xmpp_plugin/models/message_model.dart';

import '../../helpers/dialogs.dart';
import '../../helpers/log.dart';
import '../../helpers/phone_mask.dart';
import '../../models/bg_tasks_model.dart';
import '../../models/chat_message_model.dart';
import '../../models/companies/orgs.dart';
import '../../models/roster_model.dart';
import '../../models/user_settings_model.dart';
import '../../services/jabber_manager.dart';
import '../../services/shared_preferences_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../widgets/chat/messages_widgets.dart';

class GroupChatScreen extends StatefulWidget {
  static const String id = '/group_chat_screen/';

  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  final Object? _arguments;
  const GroupChatScreen(this._sipHelper, this._xmppHelper, this._arguments,
      {Key? key})
      : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  static const String tag = 'GroupChatScreen';

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  List<ChatMessage> messages = [];
  late ChatUser friend;
  UserSettingsModel? userSettings;
  ChatUser me = ChatUser(
    id: '',
    jid: '',
    phone: '',
    name: '',
  );
  bool isRecording = false;
  final ImagePicker imagePicker = ImagePicker();
  late Map<String, dynamic> groupVCard = {};
  late bool isChannel = false;
  Timer? updateTimer;
  int rosterVersion = 0;
  bool inUpdateTimer = false;

  TextEditingController chatComposerController = TextEditingController();

  @override
  void dispose() {
    if (updateTimer != null) {
      updateTimer?.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    List args = (widget._arguments as Set).toList();
    for (Object? arg in args) {
      if (arg is ChatUser) {
        friend = arg;
        Log.d(tag, '---> chat with ${friend.id}');
        isChannel = friend.id.startsWith('channel_');
        break;
      }
    }

    Future.delayed(Duration.zero, () async {
      await initMe();
      if (friend.jid == null) {
        Log.e(tag, 'initState error - friend.jid is null');
        return;
      }
      if (me.id == '') {
        Log.e(tag, 'initState error - me is null');
        return;
      }
      await checkCompany();
      await loadMamMessages();
      // Запрашиваем VCard чтобы узнать какие сообщения он прочитал
      //await getMessagesStatuses();
      //await markMessagesAsRead(); // TODO: c задержкой нужно

      await checkNewMessages();
      await startTimer();
    });
  }

  Future<void> startTimer() async {
    updateTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      if (inUpdateTimer) {
        Log.i(tag, 'inUpdateTimer');
        return;
      } else {
        await checkNewMessages();
      }
    });
  }

  Future<void> checkNewMessages() async {
    inUpdateTimer = true;
    userSettings = await UserSettingsModel().getUser();
    if (userSettings != null) {
      int newRosterVersion = userSettings!.rosterVersion ?? 0;
      //Log.d(tag, 'compare rosterVersions: $newRosterVersion, ${rosterVersion}');
      if (newRosterVersion > rosterVersion) {
        rosterVersion = newRosterVersion;
        await loadMamMessages();
      }
      // Обновление флагов для прочитанных сообщений
      await updateReadMessages();
    }
    inUpdateTimer = false;
  }

  Future<void> updateReadMessages() async {
    if (messages.isEmpty) {
      return;
    }
    String myJid = me.jid ?? '';
    List<String> idsMessages = [];
    List<String> idsMediaMessages = [];

    for (int i = 0; i < messages.length; i++) {
      ChatMessage message = messages[i];
      if (message.user.jid == myJid &&
          message.status != MessageStatus.received) {
        idsMessages.add(message.customProperties!['id']);
      }
      if (message.medias != null &&
          message.medias!.isNotEmpty &&
          message.medias![0].isUploading) {
        idsMediaMessages.add(message.customProperties!['id']);
      }
    }
    if (idsMessages.isEmpty) {
      return;
    }
    bool needUpdate = false;
    List<ChatMessageModel> readMessages =
    await ChatMessageModel().getByReadFlag(idsMessages);
    print(
        '----readMessages- ${readMessages.toString()}, ${idsMessages.toString()}');
    for (ChatMessageModel messageModel in readMessages) {
      for (ChatMessage message in messages) {
        print('${message.customProperties!['id']}, ${messageModel.mid}');
        if (message.customProperties!['id'] == messageModel.mid) {
          needUpdate = true;
          message.status = MessageStatus.received;
          break;
        }
      }
    }
    List<ChatMessageModel> mediaMessages =
    await ChatMessageModel().getByMids(idsMediaMessages);
    print(
        '----mediaMessages- ${mediaMessages.toString()}, ${idsMediaMessages.toString()}');
    for (ChatMessageModel messageModel in mediaMessages) {
      for (ChatMessage message in messages) {
        print('${message.customProperties!['id']}, ${messageModel.mid}');
        if (message.customProperties!['id'] == messageModel.mid) {
          needUpdate = true;

          Map<String, dynamic> customJson = {};

          //message.status = MessageStatus.received;
          message.medias![0].isUploading = false;

          MediaType mediaType = MediaType.custom;
          if (messageModel.customText != null &&
              CHAT_MEDIA_TYPES.contains(messageModel.body)) {
            mediaType = MediaType.parse(messageModel.body ?? '');
            if ([MediaType.audio, MediaType.file, MediaType.image]
                .contains(mediaType) &&
                messageModel.customText != null) {
              customJson = jsonDecode(messageModel.customText ?? '{}');
            }
          }

          if (mediaType == MediaType.audio) {
            Log.d(tag, 'audio found: ${messageModel.toString()}');
            message.medias![0].url = messageModel.mediaURL!;
            message.medias![0].fileName =
                messageModel.mediaURL!.split('/').last;
            message.medias![0].customProperties = {
              'widget': VoiceMessage(
                audioSrc: customJson['url'],
                played: false,
                me: myJid == message.user.jid ? true : false,
                createdAt: message.createdAt,
                readStatus: message.status,
              ),
            };
          } else if (mediaType == MediaType.file) {
            Log.d(tag, 'file found: ${messageModel.toString()}');
            message.medias![0].url = messageModel.mediaURL!;
            message.medias![0].fileName =
                messageModel.mediaURL!.split('/').last;
            message.medias![0].customProperties = {
              'widget': FileMessage(
                fileSrc: customJson['url'],
                me: true,
                createdAt: message.createdAt,
                readStatus: message.status,
              ),
            };
          } else if (mediaType == MediaType.image) {
            message.medias![0].customProperties = {
              'onTap': () {
                Log.d(tag, 'image clicked: ${messageModel.toString()}');
                if (customJson['url'] != null) {
                  launchInWebViewOrVC(customJson['url'], context);
                }
              },
            };
          }
          break;
        }
      }
    }
    if (needUpdate) {
      setState(() {});
    }
  }

  Future<void> initMe() async {
    userSettings = await UserSettingsModel().getUser();
    if (userSettings == null) {
      Log.e(tag, 'initState user is null');
      return;
    }
    String phone = phoneMaskHelper(userSettings!.phone ?? '');
    me = ChatUser(
      id: userSettings!.phone ?? '',
      jid: userSettings!.jid ?? '',
      phone: userSettings!.phone,
      name: phone,
    );
    /*
      jabberMsgDeliveredSubscription =
          xmppHelper?.jabberStream.msgStream.listen((msgId) {
        int deliveredBefore = 0;
        for (ChatMessage msg in messages) {
          if (msg.customProperties!['id'] == msgId) {
            // Нужно все сообщения, которые ранее тоже промаркировать как прочитанные в этом случае
            deliveredBefore = msg.createdAt.millisecondsSinceEpoch;

            // Медиа файлы - сразу перезапрос сообщений
            if (msg.medias != null) {
              for (ChatMedia chatMedia in msg.medias!) {
                if (chatMedia.customProperties!['widget'] != null) {
                  if (chatMedia.customProperties!['widget'] is FileMessage ||
                      chatMedia.customProperties!['widget'] is VoiceMessage) {
                    Future.delayed(const Duration(seconds: 1), () async {
                      await initMamMessages();
                    });
                    return;
                  }
                }
              }
            }
            break;
          }
        }
        if (deliveredBefore > 0) {
          for (ChatMessage msg in messages) {
            if (msg.createdAt.millisecondsSinceEpoch > deliveredBefore) {
              continue;
            }
            msg.status = MessageStatus.received;
          }
          setState(() {});
        }
      });
    */
  }

  Future<void> checkCompany() async {
    List<String> comparts = friend.jid!.split('_');
    try {
      int orgPk = int.parse(comparts[1]);
      // Ищем компанию
      Orgs? company = await Orgs().getOrg(orgPk);
      if (company != null) {
        if (friend.name != company.name && mounted) {
          setState(() {
            friend.name = company.name;
          });
        }
      }
    } catch (ex, stack) {
      Log.d(tag, ex.toString());
      //Log.d(tag, stack.toString());
    }

    String myJid = me.jid ?? '';
    List<RosterModel> rosterModels =
        await RosterModel().getBy(myJid, jid: friend.jid, isGroup: true);
    if (rosterModels.isEmpty) {
      // Если нету в ростере модели, пробуем присоединиться
      String newMuc = friend.jid!.split('@')[0];

      await showLoading();
      SharedPreferences prefs =
          await SharedPreferencesManager.getSharedPreferences();
      await prefs.remove(BGTasksModel.addRosterPrefKey);
      BGTasksModel.addMUCTask({
        'group': newMuc,
      });
      Future.delayed(Duration.zero, () async {
        updateTimer =
            Timer.periodic(const Duration(seconds: 1), (Timer t) async {
          await checkNewGroup(newMuc);
        });
      });
    }
  }

  Future<void> checkNewGroup(String newMuc) async {
    SharedPreferences prefs =
        await SharedPreferencesManager.getSharedPreferences();
    bool? addMUCResult = prefs.getBool(BGTasksModel.addRosterPrefKey);
    if (addMUCResult != null) {
      if (addMUCResult) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Группа $newMuc добавлена'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Группа $newMuc не найдена'),
            ),
          );
        }
        Future.delayed(Duration.zero, () async {
          Navigator.pop(context);
        });
      }
      await prefs.remove(BGTasksModel.addRosterPrefKey);
      updateTimer?.cancel();
    }
  }

  Future<List<ChatMessageModel>> initMamMessages() async {
    messages = [];
    Log.d(tag, 'INIT MAM MESSAGES');
    return await ChatMessageModel()
        .getMessages(me.jid ?? '', friend.jid ?? '', limit: 50, offset: 0);
  }

  Future<void> loadMamMessages() async {
    //await ChatMessageModel().dropAllRows();
    List<ChatMessageModel> mamMessages = [];
    Map<String, int> times = {};
    if (messages.isNotEmpty) {
      times = getMinMaxMessageTime();
      Log.d(tag, 'receiving messages after $times');
      mamMessages = await ChatMessageModel().getMessagesAfter(
          me.jid ?? '', friend.jid ?? '',
          after: times['max'] ?? 0);
    } else {
      mamMessages = await initMamMessages();
    }
    if (mamMessages.isEmpty) {
      return;
    }

    String setFromName = '';
    if (isChannel) {
      setFromName = friend.name ?? friend.id;
    }

    for (ChatMessageModel dbMessage in mamMessages) {
      Log.d(tag, 'messages time ${dbMessage.time}');
      MessageChat chatMessageModel =
      ChatMessageModel.convert2MessageChat(dbMessage);
      ChatMessage chatMessage = ChatMessageModel.convert2ChatMessage(
          chatMessageModel, me,
          setFromName: setFromName,
          context: context);
      messages.add(chatMessage);
    }
    times = getMinMaxMessageTime();
    Future.delayed(const Duration(seconds: 1), () async {
      // Запрашиваем VCard чтобы добавиться туда для пушей
      await checkMeInGroupVCard();
    });
    Future.delayed(const Duration(seconds: 2), () async {
      await markMessagesAsRead(force: true);
    });

    setState(() {});
  }

  Future<void> checkMeInGroupVCard() async {
    if (isChannel) {
      return;
    }
    await BGTasksModel.checkMeInGroupVCardTask({
      'groupJid': friend.id,
    });

    /*
    Map<String, dynamic> descObj =
        await xmppHelper?.getVCardDescAsDict(jid: groupJid) ?? {};
    String key = 'chat_${me.id}';
    if (descObj['users'] == null ||
        !(descObj['users'] as List<dynamic>).contains(me.id)) {
      Log.d(tag, '$key not in groupVCard DESC: $descObj');

      String myJid = 'TODO jid'; //xmppHelper?.getJid() ?? '';
      String credentialsHash =
          'TODO: credentialsHash'; // xmppHelper?.credentialsHash() ?? '';
      await pushMe2GroupVCard(myJid, credentialsHash, friend.id);
    }
    */


    /* TODO: для группового чата нет таких данных
    int lastMessageTime = int.parse(descObj[key] ?? '0');
    // Мы получили последнее время, надо обновить все сообщения,
    // которые меньше этого времени как прочитанные
    int marked = await ChatMessageModel()
        .setReadFlag(lastMessageTime, me.jid!, friend.jid!);
    if (marked > 0) {
      // TODO: обновить сообщения т/к промаркерованы прочитанными
    }
    */
  }

  Future<void> markMessagesAsRead({bool force = false}) async {
    if (!mounted) {
      Log.d(tag, 'markMessagesAsRead FAILED, because not mounted');
      return;
    }
    if (friend.jid == null || messages.isEmpty) {
      Log.d(tag, 'markMessagesAsRead FAILED, because we are not ready');
      return;
    }

    DateTime lastTimeMessage = DateTime(1970, 1, 1);
    for (ChatMessage message in messages) {
      if (message.createdAt.isAfter(lastTimeMessage)) {
        lastTimeMessage = message.createdAt;
      }
    }

    String myJid = me.jid ?? '';
    List<RosterModel> rosterModels =
        await RosterModel().getBy(myJid, jid: friend.jid, isGroup: true);
    if (rosterModels.isEmpty || !mounted) {
      Log.d(tag, 'markMessagesAsRead FAILED, roster model not found');
      return;
    }
    RosterModel rosterModel = rosterModels[0];
    if (rosterModel.jid == null || rosterModel.jid == '') {
      Log.d(
          tag,
          'markMessagesAsRead FAILED, because rosterModel not found ' +
              'for ${rosterModel.toString()}');
      return;
    }
    Log.d(tag, 'markMessagesAsRead for ${friend.jid}');
    /*
    bool needUpdate = await xmppHelper?.updatePrivateStorage(
            'unread_messages',
            'lastReadMessageTime',
            {'chat_group_$confId': '${lastTimeMessage.millisecondsSinceEpoch}'},
            force: force) ??
        false;
    if (needUpdate) {
      // Дополнительно засылаем рецепт прочтения на отправителя
      // TODO: на йосе VCard не переполучается каждый раз
      Log.d(tag, 'send delivery receipt -----> ${friend.jid}, $lastMessageId');
      xmppHelper?.sendDeliveryReceipt(
          friend.jid!, lastMessageId, lastMessageId);
    }
    */
    rosterModel.newMessagesCount = 0;
    await rosterModel.updatePartial(rosterModel.id, {
      'newMessagesCount': 0,
      'lastReadMessageTime': lastTimeMessage.millisecondsSinceEpoch,
    });
    await UserSettingsModel().updateRosterVersion();
  }

  int? getLastMessageTime() {
    int? firstMessage;
    if (messages.isNotEmpty) {
      firstMessage = messages[0].createdAt.millisecondsSinceEpoch;
      for (ChatMessage message in messages) {
        if (message.createdAt.millisecondsSinceEpoch < firstMessage!) {
          firstMessage = message.createdAt.millisecondsSinceEpoch;
        }
      }
    }
    return firstMessage;
  }

  Map<String, int> getMinMaxMessageTime() {
    int minMessageTime = 0;
    int maxMessageTime = 0;
    if (messages.isNotEmpty) {
      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      minMessageTime = messages.last.createdAt.millisecondsSinceEpoch;
      maxMessageTime = messages.first.createdAt.millisecondsSinceEpoch;
    }
    return {
      'min': minMessageTime,
      'max': maxMessageTime,
    };
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> sendChatFile(String? path, MediaType mediaType) async {
    if (path == null || path == '') {
      Log.d(tag, 'NULL picked file');
      return;
    }
    File file = File(path);
    bool isExists = await file.exists();
    if (!isExists) {
      Log.d(tag, 'file not exists $path');
      return;
    }
    int filesize = await file.length();
    if (filesize <= 0) {
      Log.d(tag, 'file zero size $path');
      return;
    }
    Log.d(tag, 'picked file ${file.path}');

    ChatMessage m = ChatMessage(
      createdAt: DateTime.now(),
      user: me,
      medias: [
        ChatMedia(
          url: file.path,
          type: mediaType,
          fileName: file.path,
          isUploading: true,
          customProperties: {},
        ),
      ],
      status: MessageStatus.pending,
    );
    m.customProperties = {
      'id': const Uuid().v4(),
      'me': true,
      'icon': const Icon(Ionicons.checkmark_done_outline),
    };
    String msgType = 'Отправлен файл';
    if (mediaType == MediaType.image) {
      msgType = 'Отправлено фото';
      m.medias![0].isUploading = false;
      m.medias![0].customProperties = {
        'onTap': () {
          launchInWebViewOrVC(file.path, context);
        }
      };
    } else if (mediaType == MediaType.audio) {
      msgType = 'Отправлено аудио-сообщение';
      m.medias![0].isUploading = false;
      m.medias![0].customProperties = {
        'widget': VoiceMessage(
          audioSrc: file.path,
          played: false,
          me: true,
          createdAt: m.createdAt,
          readStatus: m.status,
        ),
      };
    } else if (mediaType == MediaType.video) {
      msgType = 'Отправлено видео-сообщение';
      m.medias![0].isUploading = false;
    } else if (mediaType == MediaType.file) {
      m.medias![0].isUploading = false;
      m.medias![0].customProperties = {
        'widget': FileMessage(
          fileSrc: file.path,
          me: true,
          createdAt: m.createdAt,
          readStatus: m.status,
          localPath: file.path,
        )
      };
    }

    setState(() {
      messages.insert(0, m);
    });

    Map<String, dynamic> data = {
      'from': userSettings!.jid,
      'filesize': filesize,
      'path': file.path, // File file = File(path);
      'mediaType': mediaType.toString(),
      'to': friend.jid,
      'now': m.createdAt.millisecondsSinceEpoch,
      'pk': m.customProperties!['id'],
      'msgType': msgType,
    };
    await BGTasksModel.sendFileGroupMessageTask(data);
  }

  InputDecoration buildInputDecoration() {
    /* Стилизация поля для ввода сообщения */
    return InputDecoration(
      isDense: true,
      hintText: 'Написать сообщение...',
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.only(
        left: 18,
        top: 10,
        bottom: 10,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(
          width: 0,
          style: BorderStyle.none,
        ),
      ),
    );
  }

  Future<void> sendTextMessage(String? text) async {
    /* Отправка текстового сообщения */
    if (text == null) {
      return;
    }
    ChatMessage m = ChatMessage(
      createdAt: DateTime.now(),
      user: me,
    );
    m.customProperties = {
      'id': const Uuid().v4(),
    };
    String t = text.trim();
    if (t.isEmpty) {
      return;
    }
    m.text = t;
    setState(() {
      messages.insert(0, m);
    });
    // Ставим задачу
    Map<String, dynamic> data = {
      'from': userSettings!.jid,
      'text': m.text,
      'to': friend.jid,
      'now': m.createdAt.millisecondsSinceEpoch,
      'pk': m.customProperties!['id'],
    };
    await BGTasksModel.sendTextGroupMessageTask(data);
    // Пишем в базу
    ChatMessageModel msg = JabberManager.createChatMessageModel(
      data['from'],
      data['to'],
      data['text'],
      now: data['now'],
      pk: data['pk'],
      msgType: 'groupchat',
    );
    await JabberManager.sendMessage2Db(msg);
  }

  Widget alternativeInput() {
    /* Выводим виджет отправки сообщения,
       если у нас канал - не выводим
    */
    if (isChannel) {
      return Container();
    }
    return ChatComposer(
      controller: chatComposerController,
      sendButtonBackgroundColor: tealColor,
      maxRecordLength: const Duration(seconds: 300),
      padding: Platform.isIOS
          ? const EdgeInsets.only(bottom: 25.0, left: 5.0, right: 5.0)
          : const EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
      textFieldDecoration: const InputDecoration(
        hintText: 'Ваше сообщение...',
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
      onReceiveText: (str) {
        setState(() {
          chatComposerController.text = '';
          sendTextMessage(str);
        });
      },
      onRecordEnd: (path) async {
        await sendChatFile(path, MediaType.audio);
      },
      textPadding: EdgeInsets.zero,
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Icon(
          Icons.insert_emoticon_outlined,
          size: 25,
          color: Colors.grey,
        ),
        onPressed: () {},
      ),
      actions: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            Icons.attach_file_rounded,
            size: 25,
            color: Colors.grey,
          ),
          onPressed: () async {
            FilePickerResult? file = await FilePicker.platform.pickFiles();
            await sendChatFile(file?.files.single.path, MediaType.file);
          },
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            Icons.image_rounded,
            size: 25,
            color: Colors.grey,
          ),
          onPressed: () async {
            final XFile? image =
                await imagePicker.pickImage(source: ImageSource.gallery);
            await sendChatFile(image?.path, MediaType.image);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isChannel
            ? Text('Канал ${friend.getName()}')
            : Text('Чат ${friend.getName()}'),
        backgroundColor: tealColor,
        actions: [],
      ),
      body: DashChat(
        alternative: alternativeInput(),
        currentUser: me,
        onSend: (ChatMessage m) {
          // Not used, see alternative: ChatComposer
        },
        messages: messages,
        messageOptions: chatMessageOptions,
        messageListOptions: MessageListOptions(
          onLoadEarlier: () async {
            // Будем грузить только если уже загружены сообщения (и занят экран)
            await Future.delayed(const Duration(seconds: 1), () async {
              int? lastMessageTime = getLastMessageTime();
              if (lastMessageTime != null) {
                await xmppHelper?.requestMamMessages(friend.id,
                    before: lastMessageTime.toString(), lastFlag: true);
              }
            });
          },
        ),
      ),
    );
  }
}
