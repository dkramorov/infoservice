import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:infoservice/models/dialpad_model.dart';
import 'package:record/record.dart';
import 'package:xmpp_plugin/ennums/xmpp_connection_state.dart';
import 'package:xmpp_plugin/error_response_event.dart';
import 'package:xmpp_plugin/models/chat_state_model.dart';
import 'package:xmpp_plugin/models/connection_event.dart';
import 'package:xmpp_plugin/models/message_model.dart';
import 'package:xmpp_plugin/models/present_mode.dart';
import 'package:xmpp_plugin/success_response_event.dart';
import 'package:xmpp_plugin/xmpp_plugin.dart';

import '../../a_notifications/notifications.dart';
import '../../helpers/log.dart';
import '../../helpers/phone_mask.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../sip_ua/dialpadscreen.dart';

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
  final audioRecorder = Record();

  @override
  void initState() {
    super.initState();
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
    me = ChatUser(id: cleanPhone(xmppHelper?.getLogin() ?? ''));
  }

  @override
  void dispose() {
    jabberSubscription?.cancel();
    XmppConnection.removeListener(this);
    audioRecorder.dispose();
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

  Future<void> startRecordAudio() async {
    if (await audioRecorder.hasPermission()) {
      await audioRecorder.start();
      //bool isRecording = await audioRecorder.isRecording();
    }
  }

  Future<void> stopRecordAudio() async {
    final path = await audioRecorder.stop();
    print('audioRecord file $path');
    if (path == null) {
      return;
    }
    ChatMessage msg = ChatMessage(
      createdAt: DateTime.now(),
      user: me,
      medias: [
        ChatMedia(
          url: path,
          type: MediaType.video,
          fileName: path,
        )
      ],
    );
    messages.insert(0, msg);
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
        title: Text('Чат ${phoneMaskHelper(friend.id)}'),
        backgroundColor: PRIMARY_COLOR,
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
        currentUser: me,
        inputOptions: InputOptions(
          inputDecoration: buildInputDecoration(),
          /*
          leading: [
            Listener(
              onPointerDown: (event) {
                setState(() {
                  isRecording = true;
                });
                startRecordAudio();
              },
              onPointerUp: (event) {
                setState(() {
                  isRecording = false;
                });
                stopRecordAudio();
              },
              child: IconButton(
                icon: (const Icon(Icons.mic)),
                onPressed: () {},
                color: isRecording ? Colors.red : Colors.grey,
              ),
            ),
          ],
          */
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
                only_data: true);
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
        customProperties: {'id': messageChat.id},
        // Для отправленных руками тут 0 (не история)
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            int.parse(messageChat.time.toString())));

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
    Log.d(TAG, 'receiveEvent onNormalMessage: ${messageChat.toString()}');
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
}
