import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:infoservice/models/user_settings_model.dart';
import 'package:logger/logger.dart';
import 'package:sip_ua/sip_ua.dart';

import '../helpers/log.dart';
import '../models/call_history_model.dart';
import '../settings.dart';

class SIPUAListener implements SipUaHelperListener {
  final SIPUAManager helper;
  static AppLifecycleState? appState;
  Call? curCall; // Пишем при callStateChanged для входящего на IOS
  SIPUAListener(this.helper) {
    helper.addSipUaHelperListener(this);
    listenCallKit();
  }

  @override
  void callStateChanged(Call call, CallState callState) {
    print(
        'SIPUAListener: callStateChanged to ${callState.state.toString()}, ${DateTime.now().toIso8601String()}');
    /* TODO: здесь надо принимать звонок с колкита? */
    switch (callState.state) {
      case CallStateEnum.PROGRESS:
        curCall = call;
        break;
      case CallStateEnum.ENDED:
      case CallStateEnum.FAILED:
        helper.stopCallKitCalls();
        curCall = null;
        break;
      default:
        break;
    }
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    print('SIPUAListener: onNewMessage');
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    print(
        'SIPUAListener: registrationStateChanged to ${state.state.toString()}');
  }

  @override
  void transportStateChanged(TransportState state) {
    print('SIPUAListener: transportStateChanged');
  }

  /* Записываем событие приехавшее от колкита */
  void saveCallKitAction(String action) {
    print('saveCallKitAction: $action');
    helper.stateCallKit = action;
    helper.stateCallKitUpdated = DateTime.now().millisecondsSinceEpoch;
  }

  void iosIncomingCallAccept() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      print('${timer.tick}');
      if ((helper.registered ?? false) && curCall != null) {
        final mediaConstraints = <String, dynamic>{
          'audio': true,
          'video': false,
        };
        navigator.mediaDevices
            .getUserMedia(mediaConstraints)
            .then((MediaStream mediaStream) {
          curCall!
              .answer(helper.buildCallOptions(true), mediaStream: mediaStream);
        });
        timer.cancel();
      } else if (!(helper.registered ?? false)) {
        helper.register();
      }
      if (timer.tick > 10) {
        print('disable timer');
        timer.cancel();
      }
    });
  }

  void listenCallKit() {
    FlutterCallkitIncoming.onEvent.listen((event) {
      switch (event!.name) {
        case CallEvent.ACTION_CALL_INCOMING:
          // TODO: received an incoming call
          saveCallKitAction('ACTION_CALL_INCOMING');
          break;
        case CallEvent.ACTION_CALL_START:
          // TODO: started an outgoing call
          // TODO: show screen calling in Flutter
          saveCallKitAction('ACTION_CALL_START');
          break;
        case CallEvent.ACTION_CALL_ACCEPT:
          // TODO: accepted an incoming call
          // TODO: show screen calling in Flutter
          saveCallKitAction('ACTION_CALL_ACCEPT');

          if (Platform.isAndroid) {
          } else if (Platform.isIOS) {
            iosIncomingCallAccept();
          }
          break;
        case CallEvent.ACTION_CALL_DECLINE:
          // TODO: declined an incoming call
          saveCallKitAction('ACTION_CALL_DECLINE');
          break;
        case CallEvent.ACTION_CALL_ENDED:
          // TODO: ended an incoming/outgoing call
          saveCallKitAction('ACTION_CALL_ENDED');
          if (Platform.isAndroid) {
          } else if (Platform.isIOS) {
            if (curCall != null) {
              curCall?.hangup();
            }
          }
          break;
        case CallEvent.ACTION_CALL_TIMEOUT:
          // TODO: missed an incoming call
          saveCallKitAction('ACTION_CALL_TIMEOUT');
          break;
        case CallEvent.ACTION_CALL_CALLBACK:
          // TODO: only Android - click action `Call back` from missed call notification
          saveCallKitAction('ACTION_CALL_CALLBACK');
          break;
        case CallEvent.ACTION_CALL_TOGGLE_HOLD:
          // TODO: only iOS
          saveCallKitAction('ACTION_CALL_TOGGLE_HOLD');
          break;
        case CallEvent.ACTION_CALL_TOGGLE_MUTE:
          // TODO: only iOS
          saveCallKitAction('ACTION_CALL_TOGGLE_MUTE');
          break;
        case CallEvent.ACTION_CALL_TOGGLE_DMTF:
          // TODO: only iOS
          saveCallKitAction('ACTION_CALL_TOGGLE_DMTF');
          break;
        case CallEvent.ACTION_CALL_TOGGLE_GROUP:
          // TODO: only iOS
          saveCallKitAction('ACTION_CALL_TOGGLE_GROUP');
          break;
        case CallEvent.ACTION_CALL_TOGGLE_AUDIO_SESSION:
          // TODO: only iOS
          saveCallKitAction('ACTION_CALL_TOGGLE_AUDIO_SESSION');
          break;
        case CallEvent.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
          // TODO: only iOS
          saveCallKitAction('ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP');
          break;
      }
    });
  }

  Future<void> call2History(String dest,
      {int? companyId,
      String name = '',
      String direction = 'outgoing',
      bool isSip = false}) async {
    UserSettingsModel? userSettings = await UserSettingsModel().getUser();
    if (userSettings != null) {
      CallHistoryModel historyRow = CallHistoryModel(
        login: userSettings.phone,
        name: name,
        time: DateTime.now().toIso8601String(),
        dest: dest,
        action: direction,
        companyId: companyId ?? 0,
        isSip: isSip ? 1 : 0,
      );
      await historyRow.insert2Db();
    }
  }

  @override
  void onNewNotify(Notify ntf) {
    // TODO: implement onNewNotify
  }
}

class SIPUAManager extends SIPUAHelper {
  static const String tag = 'SIPUAManager';
  late SIPUAListener listener;
  late Timer mainTimer;
  static bool enabled = true; // на время отладки можно отключать
  int checkRegisterTimer = 5;
  int updateTokenTimer = 1;
  bool stopFlag = false;
  static String fcmToken = '';
  static String apnsToken = '';

  int stateCallKitUpdated = 0;
  String stateCallKit = '';

  bool get isRegistered {
    return registered ?? false;
  }

  void setStopFlag(bool flag) {
    stopFlag = flag;
  }

  SIPUAManager() {
    if (!enabled) {
      Log.d(tag, '--- SIPUAManager DISABLED ---');
      return;
    }
    loggingLevel = Level.error;
    listener = SIPUAListener(this);
    doRegister();
    startMainTimer();
  }

  void startMainTimer() {
    mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //doprint('${timer.tick}');
      checkRegisterTimer -= 1;
      if (checkRegisterTimer < 0) {
        checkRegisterTimer = 10;
        Log.d(tag, 'SIP: is registered: $isRegistered, stopFlag $stopFlag');
        if (stopFlag) {
          return;
        }
        if (!isRegistered) {
          doRegister();
        }
      }
    });
  }

  /* Регистрация на сип сервере */
  void doRegister() {
    if (isRegistered) {
      return;
    }
    UserSettingsModel().getUser().then((userSettings) {
      if (userSettings != null) {
        Log.d(tag, 'try register (${userSettings.phone}/${userSettings.passwd}...');
        saveSettings(
          webSocketUrl: SIP_WSS,
          extraHeaders: {},
          authorizationUser: userSettings.phone ?? '',
          password: userSettings.passwd ?? '',
          displayName: userSettings.phone ?? '',
        );
      }
    });
  }

  void saveSettings({
    required String webSocketUrl,
    required Map<String, String> extraHeaders,
    required String authorizationUser,
    required String password,
    required String displayName,
  }) {
    UaSettings settings = UaSettings();

    settings.webSocketUrl = webSocketUrl;
    settings.webSocketSettings.extraHeaders = extraHeaders;
    settings.webSocketSettings.allowBadCertificate = false;

    // Телефон очищаем от всех символов
    settings.authorizationUser = authorizationUser;

    settings.uri = '${settings.authorizationUser}@$SIP_DOMAIN';
    settings.password = password;
    //settings.displayName = displayName;
    // Не надо, чтобы во from подставлялась всякая херь
    settings.displayName = settings.authorizationUser;
    settings.userAgent = '${settings.authorizationUser}_$JABBER_SERVER';
    settings.dtmfMode = DtmfMode.RFC2833;

    /* Токенов может быть много, поэтому лучше серверный вариант с токенами и регистрацией
    FirebaseMessaging.instance.getToken().then((token) {
      settings.registerParams.extraContactUriParams = {'fcm_token': token};
      print('FirebaseMessaging.instance.getToken: $token');
    });
    */
    updateTokenTimer = 1;
    setStopFlag(false);
    start(settings);
  }

  Future<Map<String, dynamic>> checkCallKitCall() async {
    // check current call from pushkit if possible
    // https://github.com/hiennguyen92/flutter_callkit_incoming/commit/9cb0434e18af8a768209d6fa4d2d1e090a355081
    var calls = await FlutterCallkitIncoming.activeCalls();
    print(calls);
    if (calls is String) {
      final jsonData = jsonDecode(calls);
      calls = jsonData;
    }
    if (calls.isNotEmpty) {
      print('Active call DATA: $calls, ${calls[0]['id']}');
      return {
        calls[0]['id']: calls[0],
      };
    } else {
      print('checkCurrentCall: There are no calls');
    }
    return {};
  }

  Future<void> stopCallKitCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }

/*
  static Future<void> saveCallTime(int duration) async {
    if (CallScreenLogic.historyRow == null ||
        CallScreenLogic.historyRow.id == null) {
      return;
    }
    CallScreenLogic.historyRow.updatePartial(CallScreenLogic.historyRow.id, {
      'duration': duration,
    });
    CallScreenLogic.historyRow = null;
  }
*/

  /* Вывод времени в формате 00:00 */
  String calcCallTime(int callTime) {
    Duration duration = Duration(seconds: callTime);
    String result = [duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');
    return result;
  }
}
