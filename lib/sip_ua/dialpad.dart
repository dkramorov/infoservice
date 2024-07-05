import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:infoservice/helpers/model_utils.dart';
import 'package:infoservice/helpers/phone_mask.dart';
import 'package:infoservice/models/dialpad_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sip_ua/sip_ua.dart';

import '../a_notifications/notifications.dart';
import '../helpers/network.dart';
import '../models/user_settings_model.dart';
import '../pages/app_asset_lib.dart';
import '../pages/authorization.dart';
import '../pages/back_button_custom.dart';
import '../pages/themes.dart';
import '../services/jabber_manager.dart';
import '../services/sip_ua_manager.dart';
import '../settings.dart';
import '../widgets/action_button.dart';
import '../widgets/phone_call_button.dart';
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

  String _dest = '';
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
    _textController!.text = _dest;
    setState(() {});

    if (dialpadModel != null && dialpadModel!.startCall) {
      Future.delayed(Duration.zero, () {
        _handleCall(context);
      });
    }
  }

  Future<Widget?> _handleCall(BuildContext context,
      [bool voiceonly = true]) async {
    //var dest = _textController?.text;
    final dest = _dest;
    if (dest.isEmpty) {
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
        UserSettingsModel? user = await UserSettingsModel().getUser();
        if (user != null) {
          await sendCallPush(
              dest,
              user.phone ?? '',
              user.name ?? '',
              user.credentialsHash ?? '',
          );
        }
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
    String name = await getRosterNameByPhone(xmppHelper, dest);
    sipHelper?.listener.call2History(dest,
        name: name, companyId: dialpadModel?.company?.id, isSip: isSip);

    sipHelper!.call(to, voiceonly: voiceonly, mediaStream: mediaStream);
    _preferences.setString('dest', dest);
    int companyId = 0;
    if (dialpadModel != null && dialpadModel!.company != null && dialpadModel!.company!.id != null) {
      companyId = dialpadModel!.company!.id!;
    }
    _preferences.setInt('company_id', companyId);

    return null;
  }

  void _handleNum(String number) {
    setState(() {
      _textController!.text += number;
    });
  }

  Widget buildDigitButton(String text, VoidCallback onTap) {
    final size = MediaQuery.of(context).size;
    final isFinger = text == 'finger';
    final isDelete = text == 'delete';

    return InkWell(
      onTap: onTap,
      onLongPress: () {
        if (isDelete) {
          _removeLastDigit(deleteAll: true);
        }
      },
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: size.width * 0.33,
        height: size.width * 0.15,
        color: transparent,
        child: Center(
          child: isDelete
              ? SvgPicture.asset(AssetLib.remove)
              : Text(
            text,
            style: isFinger || isDelete
                ? null
                : TextStyle(
              fontSize: 24,
              fontWeight: w400,
              color: black,
            ),
          ),
        ),
      ),
    );
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

  void _addDigit(String digit) {
    if (_dest.length < 11) {
      setState(() {
        _dest += digit;
      });
    }
  }

  void _removeLastDigit({bool deleteAll = false}) {
    if (_dest.isNotEmpty) {
      setState(() {
        if (deleteAll) {
          _dest = '';
        } else {
          _dest = _dest.substring(0, _dest.length - 1);
        }
      });
    }
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
    //createSimpleNotification();
  }

  List<Widget> _buildDialPad({size=300}) {
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
      const Spacer(flex: 3),
      Text(
        phoneMaskHelper(_dest),
        style: TextStyle(
          fontSize: 32,
          fontWeight: w500,
          color: black,
        ),
      ),
      const Spacer(flex: 3),
      Wrap(
        runSpacing: size.width * 0.05,
        children: [
          for (int i = 1; i <= 9; i++)
            buildDigitButton(
              i.toString(),
                  () => _addDigit(i.toString()),
            ),

          SizedBox(
            width: size.width * 0.33,
            height: size.width * 0.15,
          ),

          buildDigitButton('0', () => _addDigit('0')),
          buildDigitButton('delete', _removeLastDigit),
        ],
      ),
      const SizedBox(height: 24),
      PhoneCallButton(
        asset: AssetLib.phoneCallButton,
        backgroundColor: (_dest.length == 11) ? blue : white,
        assetColor: (_dest.length == 11)
            ? white
            : const Color.fromRGBO(189, 193, 199, 1),
        onPressed: (_dest.length < 11)
            ? null
            : () {
          _handleCall(context, true);
          /* Вызывается callscreen.dart из callStateChanged на defaultPage */
        },
      ),
      const Spacer(flex: 3),
    ];
    /* /// Старый вариант
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
    */
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      /* Некуда назад уходить
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        surfaceTintColor: transparent,
        backgroundColor: white,
        title: Container(
          width: size.width - 32,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: white,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppBarButtonCustom(),
            ],
          ),
        ),
      ),
      */
      body: isRegistered ? Column(
        children: _buildDialPad(size:size),
      ) : Center(
          child: RoundedButtonWidget(
              text: const Text('Вход / Регистрация'),
              minWidth: 200.0,
              onPressed: () {
                Navigator.pushNamed(context, AuthScreenWidget.id);
              }),
      ),
    );
    /* /// Старый вариант
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
    */
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

  @override
  void onNewNotify(Notify ntf) {
    // TODO: implement onNewNotify
  }
}
