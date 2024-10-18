import 'dart:async';
import 'package:flutter/material.dart';

import 'package:sip_ua/sip_ua.dart';
import '../../../services/sip_ua_manager.dart';
import '../../app_asset_lib.dart';
import '../../../navigation/custom_app_bar_button.dart';
import '../../themes.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import '../../gl.dart';
import '../../../widgets/phone_call_button.dart';

class CallPage extends StatefulWidget {
  const CallPage({
    super.key,
    required this.sip,
    required this.phone,
  });
  final SIPUAManager sip;
  final String phone;
  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late Timer _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
    //  String _currentUuid =;
    makeCallToPhoneNumber(widget.phone);
    if (mounted) setState(() {});
  }

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
              CustomAppBarButton(),
            ],
          ),
        ),
      ),
      body: Container(
        color: white,
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(top: 6, bottom: 16),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  width: 1,
                  color: borderPrimary,
                ),
              ),
              child: Image.network(
                  "https://sun6-21.userapi.com/s/v1/ig2/6nBCZiIVxXgCQ4iTX9g_JXKu-uB12fl6IArEM_PeaAQHmqENhV7W5-QwOAHKf32oUGFb4Ttj5NvZDV2hJ2BVr1ef.jpg?size=2007x2008&quality=96&crop=149,76,2007,2008&ava=1"),
            ),
            Text(
              "Звонок",
              style: TextStyle(
                fontSize: 18,
                fontWeight: w400,
                color: gray100,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.phone,
              style: TextStyle(
                fontSize: 20,
                fontWeight: w500,
                color: black,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              formatTime(_secondsElapsed),
              style: TextStyle(
                fontSize: 14,
                fontWeight: w400,
                color: gray100,
              ),
            ),
            const Spacer(flex: 7),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PhoneCallButton(
                      asset: AssetLib.micro,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 30),
                    PhoneCallButton(
                      asset: AssetLib.number,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 30),
                    PhoneCallButton(
                      asset: AssetLib.volumeFull,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PhoneCallButton(
                      asset: AssetLib.pause,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 30),
                    PhoneCallButton(
                      asset: AssetLib.closeCallButton,
                      backgroundColor: const Color.fromRGBO(230, 36, 36, 1),
                      onPressed: () async {
                        stopSipCall();
                        await FlutterCallkitIncoming.endAllCalls()
                            .then((value) {
                          Navigator.pop(context);
                        });
                      },
                    ),
                    const SizedBox(width: 30),
                    PhoneCallButton(
                      asset: AssetLib.phoneAndCall,
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  final SIPUAManager _sipManager = SIPUAManager();

  Future<void> makeCallToPhoneNumber(String phoneNumber) async {
    UaSettings settings = UaSettings();

    settings.webSocketUrl = sipWss;
    settings.webSocketSettings.extraHeaders = {};
    settings.webSocketSettings.allowBadCertificate = false;

    // Телефон очищаем от всех символов
    settings.authorizationUser = myPhone;

    settings.uri = '${settings.authorizationUser}@$sipDomain';
    settings.password = pass;
    //settings.displayName = displayName;
    // Не надо, чтобы во from подставлялась всякая херь
    settings.displayName = settings.authorizationUser;
    settings.userAgent = '${settings.authorizationUser}_$jabberServer';
    settings.dtmfMode = DtmfMode.RFC2833;

    _sipManager.start(settings);
    // Проверяем, зарегистрирован ли клиент SIP
    if (!_sipManager.isRegistered) {
      // Попытка регистрации клиента SIP
      _sipManager.register();
      // После попытки регистрации, ждем некоторое время и проверяем снова
      await Future.delayed(const Duration(
          seconds:
              5)); // Подождем 5 секунд, можно изменить время ожидания по усмотрению
      if (!_sipManager.isRegistered) {
        print('Failed to register SIP client');
        return;
      }
    }

    // Инициируем звонок
    _sipManager.call(phoneNumber, voiceonly: true);
  }

  void stopSipCall() {
    _sipManager.stop();
    _sipManager.stopCallKitCalls().then((value) {
      Navigator.pop(context);
    });
    // _sipManager.unregister();
  }
}
