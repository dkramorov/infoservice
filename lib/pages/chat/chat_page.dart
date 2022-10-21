import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:chat_composer/chat_composer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infoservice/models/dialpad_model.dart';
import 'package:xmpp_plugin/ennums/xmpp_connection_state.dart';
import 'package:xmpp_plugin/error_response_event.dart';
import 'package:xmpp_plugin/models/chat_state_model.dart';
import 'package:xmpp_plugin/models/connection_event.dart';
import 'package:xmpp_plugin/models/message_model.dart';
import 'package:xmpp_plugin/models/present_mode.dart';
import 'package:xmpp_plugin/success_response_event.dart';
import 'package:xmpp_plugin/xmpp_plugin.dart';
import 'package:http/http.dart' as http;

import '../../a_notifications/notifications.dart';
import '../../helpers/log.dart';
import '../../helpers/phone_mask.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../sip_ua/dialpadscreen.dart';
import '../../widgets/chat/voice_message.dart';

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

class _ChatScreenState extends State<ChatScreen> implements DataChangeEvents {
  static const String TAG = 'ChatScreen';

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  List<ChatMessage> messages = [];
  late StreamSubscription<bool>? jabberSubscription;
  late ChatUser friend;
  late ChatUser me;
  bool isRecording = false;
  final ImagePicker imagePicker = ImagePicker();

  final List<String> mediaTypes = [
    MediaType.file.toString(),
    MediaType.image.toString(),
    MediaType.video.toString(),
    MediaType.audio.toString(),
  ];

  GlobalKey key = GlobalKey();
  TextEditingController chatComposerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (JabberManager.enabled) {
      jabberSubscription =
          xmppHelper?.jabberStream.registration.listen((isRegistered) {
        if (isRegistered) {
          initMamMessages();
        }
      });
      XmppConnection.addListener(this);
      List args = (widget._arguments as Set).toList();
      for (Object? arg in args) {
        if (arg is ChatUser) {
          friend = arg;
          Log.d(TAG, '---> chat with ${friend.id}');
          initMamMessages();
          break;
        }
      }
    }
    me = ChatUser(id: cleanPhone(xmppHelper?.getLogin() ?? ''));
  }

  @override
  void dispose() {
    jabberSubscription?.cancel();
    XmppConnection.removeListener(this);
    super.dispose();
  }

  void initMamMessages() {
    messages = [];
    xmppHelper?.requestMamMessages(friend.id, limit: 20, lastFlag: true);
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

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> sendChatFile(String? path, MediaType mediaType) async {
    if (path == null || path == '') {
      Log.d(TAG, 'NULL picked file');
      return;
    }
    File file = File(path);
    bool isExists = await file.exists();
    if (!isExists) {
      Log.d(TAG, 'file not exists $path');
      return;
    }
    int filesize = await file.length();
    if (filesize <= 0) {
      Log.d(TAG, 'file zero size $path');
      return;
    }
    Log.d(TAG, 'picked file ${file.path}');

    ChatMessage msg = ChatMessage(
      createdAt: DateTime.now(),
      user: me,
      medias: [
        ChatMedia(
          url: file.path,
          type: mediaType,
          fileName: file.path,
          isUploading: true,
        )
      ],
    );
    // Добавляем в очередь на загрузку файла
    // по createdAt + fileName сменим isUploading: false
    setState(() {
      // update messages
      messages.insert(0, msg);
    });

    String? putUrl =
        await JabberManager.flutterXmpp?.requestSlot(file.path, filesize);

    if (putUrl != null) {
      final uri = Uri.parse(putUrl);
      var response = await http.put(
        uri,
        headers: {
          // HttpHeaders.authorizationHeader: 'Basic xxxxxxx',
          //'Content-Type': 'image/jpeg',
        },
        body: await file.readAsBytes(),
      );

      if (response.statusCode == 201) {
        // TODO: Отложенное действие - отправляем сообщение, когда загрузится?
        Log.i(TAG, 'upload success $putUrl');
        Map<String, String> customText = {
          'type': mediaType.toString(),
          'url': putUrl,
        };
        msg.customProperties ??= {};
        String? pk = await xmppHelper?.sendCustomMessage(
            friend.id, mediaType.toString(), jsonEncode(customText));
        setState(() {
          msg.customProperties!['id'] = pk;
          msg.medias![0].isUploading = false;
          msg.medias![0].url = putUrl;
          msg.medias![0].customProperties = {
            'widget': VoiceMessage(
              audioSrc: putUrl,
              played: false,
              me: true,
            ),
          };
        });
        String msgType = 'Отправлен файл';
        if (mediaType == MediaType.image) {
          msgType = 'Отправлено фото';
        } else if (mediaType == MediaType.audio) {
          msgType = 'Отпрвлено аудио-сообщение';
        } else if (mediaType == MediaType.video) {
          msgType = 'Отправлено видео-сообщение';
        }
        sendPush(xmppHelper?.credentialsHash() ?? '',
            xmppHelper?.getLogin() ?? '', friend.id,
            only_data: true, text: msgType);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ошибка отправки файла'
              'Не удалось загрузить файл, код ответа сервера ${response.statusCode}'),
        ));
        Log.e(TAG,
            '[ERROR]: upload ${file.path} failed, ${response.body.toString()}');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ошибка отправки файла'
            'Попробуйте переименовать файл, используя латинские буквы'),
      ));
      Log.e(TAG, 'slotUrl error');
    }
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
  void onChatMessage(MessageChat messageChat) {
    Log.d(TAG,
        'receiveEvent onChatMessage: ${messageChat.toEventData().toString()}');
    if (messageChat.body == null || messageChat.body!.isEmpty) {
      return;
    }
    // Если сообщение уже в списке, тогда пропускаем его
    for (ChatMessage message in messages) {
      if (messageChat.id == message.customProperties!['id']) {
        return;
      }
    }
    Log.d(TAG, 'onChatMessage not in list');
    final String phone = cleanPhone(messageChat.senderJid ?? '');
    ChatUser u = ChatUser(id: phone, firstName: phoneMaskHelper(phone));
    if (phone == me.id) {
      u = ChatUser(id: phone, firstName: phoneMaskHelper(phone));
    }
    ChatMessage msg = ChatMessage(
        text: messageChat.body ?? '',
        user: u,
        customProperties: {'id': messageChat.id, 'me': phone == me.id},
        medias: [],
        // Для отправленных руками тут 0 (не история)
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            int.parse(messageChat.time.toString())));

    if (messageChat.customText != null && mediaTypes.contains(msg.text)) {
      MediaType mediaType = MediaType.parse(msg.text);
      try {
        Map<String, dynamic> customText = jsonDecode(messageChat.customText!);
        msg.text = '';
        // TODO: заглушку
        String url = customText['url'] ?? '';
        msg.medias!.add(ChatMedia(
          url: url,
          type: mediaType,
          fileName: url.split('/').last,
          customProperties: {
            if (mediaType == MediaType.audio)
              'widget': VoiceMessage(
                audioSrc: url,
                played: false,
                me: phone == me.id,
              ),
          },
        ));
      } catch (err) {
        Log.e(TAG, 'ERROR decode customText in message ${err.toString()}');
      }
    }
    setState(() {
      messages.insert(0, msg);
      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  @override
  void onChatStateChange(ChatState chatState) {
    Log.d(TAG, 'receiveEvent onChatStateChange: ${chatState.toString()}');
  }

  @override
  void onConnectionEvents(ConnectionEvent connectionEvent) {
    Log.d(TAG, 'receiveEvent connectionEvent: ${connectionEvent.toString()}');
    if (connectionEvent.type == XmppConnectionState.authenticated) {
      messages = [];
      initMamMessages();
    }
  }

  @override
  void onGroupMessage(MessageChat messageChat) {
    Log.d(TAG, 'receiveEvent onGroupMessage: ${messageChat.toString()}');
  }

  @override
  void onNormalMessage(MessageChat messageChat) {
    //Log.d(TAG, 'receiveEvent onNormalMessage: ${messageChat.toEventData().toString()}');
  }

  @override
  void onPresenceChange(PresentModel message) {
    Log.d(TAG, 'receiveEvent onPresenceChange: ${message.toString()}');
  }

  @override
  void onSuccessEvent(SuccessResponseEvent successResponseEvent) {
    Log.d(TAG,
        'receiveEvent onSuccessEvent: ${successResponseEvent.toSuccessResponseData().toString()}');
  }

  @override
  void onXmppError(ErrorResponseEvent errorResponseEvent) {
    Log.d(TAG,
        'receiveEvent onXmppError: ${errorResponseEvent.toErrorResponseData().toString()}');
  }

  void sendTextMessage(String? text) {
    if (text == null) {
      return;
    }
    ChatMessage m = ChatMessage(
      createdAt: DateTime.now(),
      user: me,
    );
    m.customProperties ??= {};
    String t = text.trim();
    if (t.isEmpty) {
      return;
    }
    m.text = t;
    xmppHelper?.sendMessage(friend.id, t).then((String pk) {
      m.customProperties!['id'] = pk;
      setState(() {
        messages.insert(0, m);
      });
      print('----------- ${xmppHelper?.credentialsHash()}');
      sendPush(xmppHelper?.credentialsHash() ?? '',
          xmppHelper?.getLogin() ?? '', friend.id,
          only_data: true, text: text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Чат ${phoneMaskHelper(friend.id)}'),
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
                DialpadModel(phone: friend.id, isSip: true, startCall: true),
              });
            },
          ),
        ],
      ),
      body: DashChat(
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
          onReceiveText: (str) {
            setState(() {
              chatComposerController.text = '';
              sendTextMessage(str);
            });
          },
          onRecordEnd: (path) async {
            print('audioRecord file $path');
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
          m.customProperties ??= {};
          String text = m.text.trim();
          if (text.isEmpty) {
            return;
          }
          m.text = text;
          xmppHelper?.sendMessage(friend.id, m.text).then((String pk) {
            m.customProperties!['id'] = pk;
            setState(() {
              messages.insert(0, m);
            });
            sendPush(xmppHelper?.credentialsHash() ?? '',
                xmppHelper?.getLogin() ?? '', friend.id,
                only_data: true, text: text);
          });
        },
        messages: messages,
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
