import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat_composer/chat_composer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infoservice/models/bg_tasks_model.dart';
import 'package:infoservice/models/dialpad_model.dart';
import 'package:infoservice/pages/chat/utils.dart';
import 'package:ionicons/ionicons.dart';
import 'package:uuid/uuid.dart';
import 'package:xmpp_plugin/models/message_model.dart';

import '../../helpers/dialogs.dart';
import '../../helpers/log.dart';
import '../../helpers/phone_mask.dart';
import '../../models/chat_message_model.dart';
import '../../models/roster_model.dart';
import '../../models/user_settings_model.dart';
import '../../services/jabber_manager.dart';
import '../../services/permissions_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../sip_ua/dialpadscreen.dart';
import '../../widgets/chat/messages_widgets.dart';

class ChatScreen extends StatefulWidget {
  static const String id = '/chat_screen/';
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  final Object? _arguments;
  const ChatScreen(this._sipHelper, this._xmppHelper, this._arguments,
      {Key? key})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const String tag = 'ChatScreen';

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
      if (friend.customProperties != null &&
          friend.customProperties!['fromPush'] != null) {
        RosterModel().getBy(me.jid ?? '', jid: friend.jid).then((result) {
          Log.d(tag,
              'PUSH logic - get roster ${result.toString()}, ${me.jid}, ${friend.jid}');
          if (result.isNotEmpty &&
              result[0].name != null &&
              result[0].name != '') {
            friend.name = result[0].name;
          }
        });
      }
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

  Future<List<ChatMessageModel>> initMamMessages() async {
    messages = [];
    Log.d(tag, 'INIT MAM MESSAGES, ${me.jid} => ${friend.jid}');
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

    for (ChatMessageModel dbMessage in mamMessages) {
      //Log.d(tag, 'messages time ${dbMessage.time}');
      MessageChat chatMessageModel =
          ChatMessageModel.convert2MessageChat(dbMessage);
      //Log.d(tag, 'chatMessageModel ${chatMessageModel.toString()}');
      ChatMessage chatMessage = ChatMessageModel.convert2ChatMessage(
          chatMessageModel,
          me,
          context: context
      );
      Log.d(tag, 'chatMessage ${chatMessage.toString()}, me ${me.toString()}');
      messages.add(chatMessage);
    }
    times = getMinMaxMessageTime();
    await showUnreadMessagesWidget();

    Future.delayed(const Duration(seconds: 2), () async {
      await markMessagesAsRead(force: true);
    });

    setState(() {});
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
    String lastMessageId = '';
    for (ChatMessage message in messages) {
      if (message.createdAt.isAfter(lastTimeMessage)) {
        lastTimeMessage = message.createdAt;
        lastMessageId = message.customProperties!['id'];
      }
    }

    String myJid = me.jid ?? '';
    List<RosterModel> rosterModels =
        await RosterModel().getBy(myJid, jid: friend.jid);
    if (rosterModels.isEmpty) {
      Log.d(tag, 'markMessagesAsRead FAILED, roster not found');
      return;
    }
    RosterModel rosterModel = rosterModels[0];
    if (rosterModel.jid == null || rosterModel.jid == '') {
      Log.d(tag, 'markMessagesAsRead FAILED, rosterModel not found');
      return;
    }

    Log.d(tag, 'markMessagesAsRead for ${friend.jid}');

    rosterModel.newMessagesCount = 0;
    rosterModel.updatePartial(rosterModel.id, {
      'newMessagesCount': 0,
      'lastReadMessageTime': lastTimeMessage.millisecondsSinceEpoch,
    });
    await UserSettingsModel().updateRosterVersion();

    // Дополнительно засылаем рецепт прочтения на отправителя
    await BGTasksModel.sendDeliveryReceiptTask({
      'jid': friend.jid,
      'lastMessageId': lastMessageId,
    });
  }

  Future<void> showUnreadMessagesWidget() async {
    /* Показывает виджет непрочитанных сообщений */
    if (messages.isEmpty) {
      Log.d(tag, 'showUnreadMessagesWidget not ready, empty messages');
      return;
    }
    List<RosterModel> rosterModels =
        await RosterModel().getBy(me.jid!, jid: friend.jid);
    if (rosterModels.isEmpty) {
      Log.d(tag, 'showUnreadMessagesWidget not ready, roster not found');
      return;
    }
    RosterModel rosterModel = rosterModels[0];
    int newMessagesCount = rosterModel.newMessagesCount ?? 0;

    newMessagesCount -= 1;
    if (newMessagesCount <= 0 || newMessagesCount > messages.length) {
      Log.d(tag, 'showUnreadMessagesWidget not needed');
      return;
    }

    ChatMessage message = messages[newMessagesCount];
    messages.insert(
        newMessagesCount,
        ChatMessage(
          customProperties: {
            'id': '-999',
          },
          createdAt: message.createdAt,
          user: me,
          medias: [
            ChatMedia(
              url: '',
              type: MediaType.custom,
              fileName: '',
              customProperties: {
                'widget': Container(
                  color: Colors.grey.shade300,
                  width: double.infinity,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Text('Непрочитанные сообщения',
                        style: TextStyle(color: Colors.grey)),
                  ),
                )
              },
            ),
          ],
        ));

    Future.delayed(const Duration(seconds: 4), () {
      int ind = -999;
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].customProperties!['id'] == '-999') {
          ind = i;
          break;
        }
      }
      if (ind >= 0) {
        setState(() {
          messages.removeAt(ind);
        });
      }
    });
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

  Future<void> sendTextMessage(String? text) async {
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
    Map<String, dynamic> data = {
      'from': userSettings!.jid,
      'text': m.text,
      'to': friend.jid,
      'now': m.createdAt.millisecondsSinceEpoch,
      'pk': m.customProperties!['id'],
    };
    await BGTasksModel.sendTextMessageTask(data);
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
    await BGTasksModel.sendFileMessageTask(data);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Чат ${friend.getName()}'),
        backgroundColor: tealColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.phone,
            ),
            onPressed: () {
              Navigator.pushNamed(context, DialpadScreen.id, arguments: {
                sipHelper,
                xmppHelper,
                // в DialPadModel нужно передавать телефон без домена
                DialpadModel(
                    phone: cleanPhone(friend.id.split('@')[0]), isSip: true, startCall: true),
              });
            },
          ),
        ],
      ),
      body: DashChat(
        /* При flutter_background_service плагин регистрируется дважды

ERROR during registerWithRegistrar: flutterSoundPlayerManager != nil
ERROR during registerWithRegistrar: flutterSoundRecorderManager != nil

plugins/flutter_sound_lite/ios/Classes/FlutterSoundRecorderManager.mm

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar
{
        FlutterMethodChannel* aChannel = [FlutterMethodChannel methodChannelWithName:@"com.dooboolab.flutter_sound_recorder"
                                        binaryMessenger:[registrar messenger]];
        if (flutterSoundRecorderManager != nil) {
                NSLog(@"ERROR during registerWithRegistrar: flutterSoundRecorderManager != nil");
                return; // <---- THIS prevent second register plugin
                }
...
        */
        alternative: ChatComposer(
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
          onReceiveText: (str) async {
            setState(() {
              chatComposerController.text = '';
            });
            await sendTextMessage(str);
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
                bool granted =
                    await PermissionsManager().checkPermissions('storage');
                if (!granted) {
                  if (!await PermissionsManager()
                      .requestPermissions('storage')) {
                    return;
                  }
                }
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
        ),
        currentUser: me,
        inputOptions: InputOptions(
          inputDecoration: buildInputDecoration(),
          trailing: [
            Listener(
              onPointerDown: (event) {},
              onPointerUp: (event) {},
              child: IconButton(
                icon: (const Icon(Icons.mic)),
                onPressed: () {},
                color: isRecording ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
        onSend: (ChatMessage m) {
          // Not used, see alternative: ChatComposer
          /*
          m.customProperties ??= {};
          String text = m.text.trim();
          if (text.isEmpty) {
            return;
          }
          m.text = text;
          xmppHelper
              ?.sendMessage(friend.id, m.text)
              .then((ChatMessageModel newMsg) {
            m.customProperties!['id'] = newMsg.mid;
            setState(() {
              messages.insert(0, m);
            });
            sendPush(xmppHelper?.credentialsHash() ?? '',
                xmppHelper?.getLogin() ?? '', friend.id,
                only_data: true, text: text);
          });
          */
        },
        messages: messages,
        messageOptions: chatMessageOptions,
        messageListOptions: MessageListOptions(
          onLoadEarlier: () async {
            // Будем грузить только если уже загружены сообщения (и занят экран)
            await Future.delayed(const Duration(seconds: 1), () async {
              int? lastMessageTime = getMinMaxMessageTime()['min'];
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
