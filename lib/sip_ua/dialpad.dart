import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:infoservice/models/dialpad_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sip_ua/sip_ua.dart';

import '../a_notifications/notifications.dart';
import '../helpers/network.dart';
import '../pages/authorization.dart';
import '../services/jabber_manager.dart';
import '../services/sip_ua_manager.dart';
import '../settings.dart';
import '../widgets/action_button.dart';
import '../widgets/rounded_button_widget.dart';

class DialPadWidget extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  final DialpadModel? dialpadModel;
  const DialPadWidget(this._sipHelper, this._xmppHelper,
      {this.dialpadModel, Key? key})
      : super(key: key);

  @override
  _MyDialPadWidget createState() => _MyDialPadWidget();
}

class _MyDialPadWidget extends State<DialPadWidget>
    implements SipUaHelperListener {
  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;
  DialpadModel? get dialpadModel => widget.dialpadModel;

  String? _dest;
  TextEditingController? _textController;
  late SharedPreferences _preferences;

  String? receivedMsg;
  bool get isRegistered => sipHelper?.registered ?? false;

  @override
  void dispose() {
    sipHelper!.removeSipUaHelperListener(this);
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    receivedMsg = '';
    sipHelper!.addSipUaHelperListener(this);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _preferences = await SharedPreferences.getInstance();
    _dest = _preferences.getString('dest') ?? '';
    if (dialpadModel != null) {
      _dest = dialpadModel!.phone;
      // TODO: isSip
    }
    _textController = TextEditingController(text: _dest);
    _textController!.text = _dest!;
    setState(() {});

    if (dialpadModel != null && dialpadModel!.startCall) {
      Future.delayed(Duration.zero, () {
        _handleCall(context);
      });
    }
  }

  Future<Widget?> _handleCall(BuildContext context,
      [bool voiceonly = true]) async {
    var dest = _textController?.text;
    if (dest == null || dest.isEmpty) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Target is empty.'),
            content: const Text('Please enter a SIP URI or username!'),
            actions: [
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return null;
    }

    String to = 'sip:$dest@$SIP_DOMAIN';
    bool isSip = dialpadModel != null && dialpadModel!.isSip;
    if (isSip) {
      to = 'sip:app_$dest@$SIP_DOMAIN';
      Future.delayed(const Duration(seconds: 2), () async {
        await sendCallPush(
            dest,
            _preferences.getString('auth_user') ?? '',
            _preferences.getString('display_name') ?? '',
            sipHelper?.credentialsHash() ?? '');
      });
    }

    final mediaConstraints = <String, dynamic>{'audio': true, 'video': false};

    MediaStream mediaStream;

    if (kIsWeb && !voiceonly) {
      mediaStream =
          await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      mediaConstraints['video'] = false;
      MediaStream userStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      mediaStream.addTrack(userStream.getAudioTracks()[0], addToNative: true);
    } else {
      mediaConstraints['video'] = false;
      mediaStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    }
    // Втыкаем в историю исходящий
    sipHelper?.listener
        .call2History(dest, companyId: dialpadModel?.company?.id, isSip: isSip);

    sipHelper!.call(to, voiceonly: voiceonly, mediaStream: mediaStream);
    _preferences.setString('dest', dest);

    return null;
  }

  void _handleBackSpace([bool deleteAll = false]) {
    var text = _textController!.text;
    if (text.isNotEmpty) {
      setState(() {
        text = deleteAll ? '' : text.substring(0, text.length - 1);
        _textController!.text = text;
      });
    }
    // Тест на уведомление по бэкспейсу
    createSimpleNotification();
  }

  void _handleNum(String number) {
    setState(() {
      _textController!.text += number;
    });
  }

  List<Widget> _buildNumPad() {
    var labels = [
      [
        {'1': ''},
        {'2': 'abc'},
        {'3': 'def'}
      ],
      [
        {'4': 'ghi'},
        {'5': 'jkl'},
        {'6': 'mno'}
      ],
      [
        {'7': 'pqrs'},
        {'8': 'tuv'},
        {'9': 'wxyz'}
      ],
      [
        {'*': ''},
        {'0': '+'},
        {'#': ''}
      ],
    ];

    return labels
        .map((row) => Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row
                    .map((label) => ActionButton(
                          title: label.keys.first,
                          subTitle: label.values.first,
                          onPressed: () => _handleNum(label.keys.first),
                          number: true,
                        ))
                    .toList())))
        .toList();
  }

  List<Widget> _buildDialPad() {
    if (!isRegistered) {
      return [
        RoundedButtonWidget(
            text: const Text('Вход / Регистрация'),
            minWidth: 200.0,
            onPressed: () {
              Navigator.pushNamed(context, AuthScreenWidget.id);
            })
      ];
    }

    return [
      SizedBox(
          width: 360,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 360,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 24, color: Colors.black54),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      controller: _textController,
                    )),
              ])),
      SizedBox(
          width: 300,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildNumPad())),
      SizedBox(
          width: 300,
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionButton(
                    icon: Icons.videocam,
                    onPressed: () => _handleCall(context),
                  ),
                  ActionButton(
                    icon: Icons.dialer_sip,
                    fillColor: tealColor,
                    onPressed: () => _handleCall(context, true),
                  ),
                  ActionButton(
                    icon: Icons.keyboard_arrow_left,
                    onPressed: () => _handleBackSpace(),
                    onLongPress: () => _handleBackSpace(true),
                  ),
                ],
              )))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Align(
          alignment: const Alignment(0, 0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                      child: Text(
                    'Статус: ${EnumHelper.getName(sipHelper!.registerState.state)}',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold),
                  )),
                ),
                /*
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Center(
                      child: Text(
                    'Сообщение: $receivedMsg',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  )),
                ),
                */
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildDialPad(),
                ),
              ])),
    ]);
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    setState(() {});
  }

  @override
  void transportStateChanged(TransportState state) {}

  @override
  void callStateChanged(Call call, CallState callState) {
    /*
    if (mounted && callState.state == CallStateEnum.CALL_INITIATION) {
      Navigator.pushNamed(context, CallScreenWidget.id, arguments: {
        sipHelper,
        xmppHelper,
        call,
      });
    }
    */
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    //Save the incoming message to DB
    String? msgBody = msg.request.body as String?;
    setState(() {
      receivedMsg = msgBody;
    });
  }
}
