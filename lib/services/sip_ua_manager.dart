import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'package:sip_ua/sip_ua.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../a_notifications/telegram_bot.dart';
import '../helpers/network.dart';
import '../helpers/phone_mask.dart';
import '../models/call_history_model.dart';
import '../settings.dart';

class SIPUAListener implements SipUaHelperListener {
  final SIPUAManager helper;
  static AppLifecycleState? appState;
  SIPUAListener(this.helper) {
    helper.addSipUaHelperListener(this);
    listenCallKit();
  }

  @override
  void callStateChanged(Call call, CallState callState) {
    print('SIPUAListener: callStateChanged');

    switch (callState.state) {
      case CallStateEnum.ENDED:
      case CallStateEnum.FAILED:
        helper.stopCallKitCalls();
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
    print('SIPUAListener: registrationStateChanged');
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
          break;
        case CallEvent.ACTION_CALL_DECLINE:
          // TODO: declined an incoming call
          saveCallKitAction('ACTION_CALL_DECLINE');
          break;
        case CallEvent.ACTION_CALL_ENDED:
          // TODO: ended an incoming/outgoing call
          saveCallKitAction('ACTION_CALL_ENDED');
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
      String direction = 'outgoing',
      bool isSip = false}) async {
    CallHistoryModel historyRow = CallHistoryModel(
      login: helper.getLogin(),
      time: DateTime.now().toIso8601String(),
      dest: dest,
      action: direction,
      companyId: companyId ?? 0,
      isSip: isSip ? 1 : 0,
    );
    await historyRow.insert2Db();
  }
}

class SIPUAManager extends SIPUAHelper {
  late SIPUAListener listener;
  late SharedPreferences preferences;
  late Timer mainTimer;
  int checkRegisterTimer = 10;
  int updateTokenTimer = 1;
  bool stopFlag = false;
  static String fcmToken = '';

  int stateCallKitUpdated = 0;
  String stateCallKit = '';

  String getLogin() {
    return preferences.getString('auth_user') ?? '';
  }

  void setStopFlag(bool flag) {
    stopFlag = flag;
  }

  SIPUAManager() {
    listener = SIPUAListener(this);
    loadSettings().then((prefs) {
      doRegister();
      startMainTimer();
    });
  }

  void startMainTimer() {
    mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //doprint('${timer.tick}');
      checkRegisterTimer -= 1;
      if (checkRegisterTimer < 0) {
        checkRegisterTimer = 10;
        doprint('SIP: is registered: ${registered!}, stopFlag $stopFlag');
        if (stopFlag) {
          return;
        }
        if (registered! == false) {
          doRegister();
        } else if (registered!) {
          updateTokenTimer -= 1;
          if (updateTokenTimer < 0) {
            updateTokenTimer = 600;
            sendToken(preferences.getString('auth_user') ?? '', fcmToken)
                .then((sent) {
              if (sent) {
                updateTokenTimer = 3600;
              } else {
                updateTokenTimer = 10;
              }
            });
          }
        }
      }
    });
  }

  /* Регистрация на сип сервере */
  void doRegister() {
    if (registered! == true) {
      return;
    }
    if ((preferences.getString('password') != null) &&
        (preferences.getString('auth_user') != null)) {
      doprint('try register');
      doprint(preferences.getString('auth_user')!);
      doprint(preferences.getString('password')!);

      final String authUser = preferences.getString('auth_user') ?? '';
      saveSettings(
        webSocketUrl: SIP_WSS,
        extraHeaders: {},
        authorizationUser: authUser,
        password: preferences.getString('password')!,
        displayName: authUser,
      );
    }
  }

  /* Debug print */
  void doprint(String msg) {
    print(msg);
  }

  /* sha256 на логин + пароль
     для различных операций, требующих авторизации
  */
  String credentialsHash() {
    String login = cleanPhone(preferences.getString('auth_user') ?? '');
    String passwd = cleanPhone(preferences.getString('password') ?? '');
    List<int> credentials = utf8.encode(login + passwd);
    return sha256.convert(credentials).toString();
  }

  Future<SharedPreferences> loadSettings() async {
    preferences = await SharedPreferences.getInstance();
    String? authUser = preferences.getString('auth_user');
    doprint('password ${preferences.getString('password')}');
    doprint('auth_user $authUser');
    if (authUser != null) {
      TelegramBot.userPhone = authUser;
    }
    return preferences;
  }

  void changeSettings(Map<String, dynamic> userData) {
    setStopFlag(true);
    stop();
    doprint('sip changeSettings: $userData');
    preferences.setString('password', userData['passwd'] ?? '');
    preferences.setString('auth_user', userData['phone'] ?? '');

    saveSettings(
      webSocketUrl: SIP_WSS,
      extraHeaders: {},
      authorizationUser: userData['phone'] ?? '',
      password: userData['passwd'] ?? '',
      displayName: userData['name'] ?? '',
    );
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
    settings.authorizationUser = cleanPhone(authorizationUser);

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
    //check current call from pushkit if possible
    // https://github.com/hiennguyen92/flutter_callkit_incoming/commit/9cb0434e18af8a768209d6fa4d2d1e090a355081
    var calls = await FlutterCallkitIncoming.activeCalls();
    print(calls);
    if (calls is String) {
      final jsonData = jsonDecode(calls);
      calls = jsonData;
    }
    if (calls.isNotEmpty) {
      print('Active call DATA: $calls, ${calls[0]['id']}');
      return calls[0];
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
