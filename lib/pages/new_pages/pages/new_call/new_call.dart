import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infoservice/widgets/phone_call_button.dart';
import '../../../../services/sip_ua_manager.dart';
import '../../../app_asset_lib.dart';
import '../../../back_button_custom.dart';
import '../../../themes.dart';

import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

import '../call_page.dart';

class NewCall extends StatefulWidget {
  const NewCall({super.key});

  @override
  State<NewCall> createState() => _NewCallState();
}

class _NewCallState extends State<NewCall> {
  String phone = "";
  late final Uuid _uuid;
  String? _currentUuid;
  String textEvents = "";
  @override
  void initState() {
    super.initState();
    _uuid = const Uuid();
    _currentUuid = "";
    textEvents = "";
    initCurrentCall();
    listenerEvent(onEvent);
    if (mounted) setState(() {});
  }

  void _addDigit(String digit) {
    if (phone.length < 11) {
      setState(() {
        phone += digit;
        // if (phone.length == 4) _checkPinAndNavigate();
      });
    }
  }

  void _removeLastDigit() {
    if (phone.isNotEmpty) {
      setState(() {
        phone = phone.substring(0, phone.length - 1);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future startCall(String phone) async {
    CallKitParams params = CallKitParams(
        id: const Uuid().v4(),
        nameCaller: phone,
        handle: phone,
        type: 1,
        extra: <String, dynamic>{'userId': '1a2b3c4d'},
        ios: const IOSParams(handleType: 'generic'));
    await FlutterCallkitIncoming.startCall(params);
  }

  Future call() async {
    CallKitParams callKitParams = CallKitParams(
      id: const Uuid().v4(),
      nameCaller: "",
      appName: 'Callkit',
      avatar: 'https://i.pravatar.cc/100',
      handle: phone,
      type: 0,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      duration: 30000,
      extra: <String, dynamic>{'userId': '1a2b3c4d'},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          backgroundUrl: 'https://i.pravatar.cc/500',
          actionColor: '#4CAF50',
          textColor: '#ffffff',
          incomingCallNotificationChannelName: "Incoming Call",
          missedCallNotificationChannelName: "Missed Call",
          isShowCallID: false),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }

  String formatPhoneNumber(String phoneNumber) {
    // Удаляем все нечисловые символы
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Если номер не соответствует ожидаемой длине, возвращаем исходный текст
    if (cleanedNumber.length != 11) {
      return phoneNumber;
    }

    // Форматируем номер в соответствии с требуемым форматом
    return '${cleanedNumber.substring(0, 1)} ${cleanedNumber.substring(1, 4)} ${cleanedNumber.substring(4, 7)} ${cleanedNumber.substring(7, 9)} ${cleanedNumber.substring(9)}';
  }

  Widget buildDigitButton(String text, VoidCallback onTap) {
    final size = MediaQuery.of(context).size;
    final isFinger = text == "finger";
    final isDelete = text == "delete";

    return InkWell(
      onTap: onTap,
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
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
      body: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            formatPhoneNumber(phone),
            style: TextStyle(
              fontSize: 32,
              fontWeight: w500,
              color: black,
            ),
          ),
          const Spacer(flex: 5),
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
              // if (widget.sms)
              //   SizedBox(
              //     width: size.width * 0.33,
              //     height: size.width * 0.15,
              //   ),
              buildDigitButton("0", () => _addDigit("0")),
              buildDigitButton("delete", _removeLastDigit),
            ],
          ),
          const SizedBox(height: 24),
          PhoneCallButton(
            asset: AssetLib.phoneCallButton,
            backgroundColor: (phone.length == 11) ? blue : white,
            assetColor: (phone.length == 11)
                ? white
                : const Color.fromRGBO(189, 193, 199, 1),
            onPressed: (phone.length < 11)
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) =>
                            CallPage(sip: SIPUAManager(), phone: phone),
                      ),
                    );
                  },
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Future<void> requestNotificationPermission() async {
    await FlutterCallkitIncoming.requestNotificationPermission({
      "rationaleMessagePermission":
          "Notification permission is required, to show notification.",
      "postNotificationMessageRequired":
          "Notification permission is required, Please allow notification permission from setting."
    });
  }

  Future<dynamic> initCurrentCall() async {
    await requestNotificationPermission();
    //check current call from pushkit if possible
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        print('DATA: $calls');
        _currentUuid = calls[0]['id'];
        return calls[0];
      } else {
        _currentUuid = "";
        return null;
      }
    }
  }

  Future<void> makeFakeCallInComing() async {
    await Future.delayed(const Duration(seconds: 10), () async {
      _currentUuid = _uuid.v4();

      final params = CallKitParams(
        id: _currentUuid,
        nameCaller: 'Hien Nguyen',
        appName: 'Callkit',
        avatar: 'https://i.pravatar.cc/100',
        handle: '0123456789',
        type: 0,
        duration: 30000,
        textAccept: 'Accept',
        textDecline: 'Decline',
        missedCallNotification: const NotificationParams(
          showNotification: true,
          isShowCallback: true,
          subtitle: 'Missed call',
          callbackText: 'Call back',
        ),
        extra: <String, dynamic>{'userId': '1a2b3c4d'},
        headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
        android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          backgroundUrl: 'assets/test.png',
          actionColor: '#4CAF50',
          textColor: '#ffffff',
          incomingCallNotificationChannelName: 'Incoming Call',
          missedCallNotificationChannelName: 'Missed Call',
        ),
        ios: const IOSParams(
          iconName: 'CallKitLogo',
          handleType: '',
          supportsVideo: true,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100.0,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: true,
          supportsHolding: true,
          supportsGrouping: false,
          supportsUngrouping: false,
          ringtonePath: 'system_ringtone_default',
        ),
      );
      await FlutterCallkitIncoming.showCallkitIncoming(params);
    });
  }

  Future<void> endCurrentCall() async {
    initCurrentCall();
    await FlutterCallkitIncoming.endCall(_currentUuid!);
  }

  Future<void> startOutGoingCall() async {
    _currentUuid = _uuid.v4();
    final params = CallKitParams(
      id: _currentUuid,
      nameCaller: phone,
      handle: phone,
      type: 1,
      extra: <String, dynamic>{'userId': '1a2b3c4d'},
      ios: const IOSParams(handleType: 'number'),
    );
    await FlutterCallkitIncoming.startCall(params);
  }

  Future<void> activeCalls() async {
    var calls = await FlutterCallkitIncoming.activeCalls();
    log(calls.toString());
  }

  Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }

  Future<void> getDevicePushTokenVoIP() async {
    var devicePushTokenVoIP =
        await FlutterCallkitIncoming.getDevicePushTokenVoIP();
    print(devicePushTokenVoIP);
  }

  Future<void> listenerEvent(void Function(CallEvent) callback) async {
    try {
      // Слушаем события Flutter CallKit Incoming
      FlutterCallkitIncoming.onEvent.listen((event) async {
        print('Received event: $event');
        // Обрабатываем различные события
        switch (event!.event) {
          case Event.actionCallIncoming:
            // Обработка входящего звонка
            print('Incoming call from: ${event.body}');
            break;
          case Event.actionCallStart:
            // Звонок начат
            print('Outgoing call started');
            break;
          case Event.actionCallAccept:
            // Звонок принят
            print('Call accepted');
            break;
          case Event.actionCallDecline:
            // Звонок отклонен
            print('Call declined');
            break;
          case Event.actionCallEnded:
            // Звонок завершен
            print('Call ended');
            break;
          case Event.actionCallTimeout:
            // Пропущенный звонок (звонок не был принят вовремя)
            print('Missed call');
            break;
          case Event.actionCallCallback:
            // Нажата кнопка "Call back" на уведомлении о пропущенном звонке (только для Android)
            print('Clicked call back button from missed call notification');
            break;
          case Event.actionDidUpdateDevicePushTokenVoip:
            print('Device VoIP token updated: ${event.body}');
            break;
          case Event.actionCallToggleHold:
            // Обработка переключения удержания звонка (только для iOS)
            print('Call hold toggled');
            break;
          case Event.actionCallToggleMute:
            // Обработка переключения звука в звонке (только для iOS)
            print('Call mute toggled');
            break;
          case Event.actionCallToggleDmtf:
            // Обработка переключения DTMF в звонке (только для iOS)
            print('DTMF toggled');
            break;
          case Event.actionCallToggleGroup:
            // Обработка переключения группы звонков (только для iOS)
            print('Call group toggled');
            break;
          case Event.actionCallToggleAudioSession:
            // Обработка переключения аудиосессии звонка (только для iOS)
            print('Audio session toggled');
            break;
          case Event.actionCallCustom:
            // Обработка пользовательского события звонка
            print('Custom call event: ${event.body}');
            break;
        }
        // Вызываем переданный callback с полученным событием
        callback(event);
      });
    } on Exception catch (e) {
      // Обработка исключений, если необходимо
      print('Error listening to events: $e');
    }
  }

  //check with https://webhook.site/#!/2748bc41-8599-4093-b8ad-93fd328f1cd2
  // Future<void> requestHttp(content) async {
  //   get(Uri.parse(
  //       'https://webhook.site/2748bc41-8599-4093-b8ad-93fd328f1cd2?data=$content'));
  // }

  void onEvent(CallEvent event) {
    if (!mounted) return;
    setState(() {
      textEvents += '---\n${event.toString()}\n';
    });
  }
}
