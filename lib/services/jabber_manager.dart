import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xmpp_plugin/ennums/xmpp_connection_state.dart';
import 'package:xmpp_plugin/error_response_event.dart';
import 'package:xmpp_plugin/models/chat_state_model.dart';
import 'package:xmpp_plugin/models/connection_event.dart';
import 'package:xmpp_plugin/models/message_model.dart';
import 'package:xmpp_plugin/models/present_mode.dart';
import 'package:xmpp_plugin/success_response_event.dart';
import 'package:uuid/uuid.dart';

import 'package:xmpp_plugin/xmpp_plugin.dart';

import '../a_notifications/telegram_bot.dart';
import '../helpers/native_log_helper.dart';
import '../helpers/network.dart';
import '../helpers/phone_mask.dart';
import '../settings.dart';

class JabberStream {
  StreamController<bool> regController = StreamController<bool>.broadcast();
  Stream<bool> get registration => regController.stream.asBroadcastStream();
  void registrationChanged(bool reg) {
    regController.add(reg);
  }

  void close() {
    regController.close();
  }
}

class JabberManager implements DataChangeEvents {
  static XmppConnection? flutterXmpp;
  static AppLifecycleState? appState;
  late SharedPreferences preferences;
  late Timer mainTimer;
  static bool enabled = true; // на время отладки можно отключать
  static Map<Object?, Object?> myVCard = {};

  int checkRegisterTimer = 5;
  int updateTokenTimer = 1;
  bool stopFlag = false;
  static String fcmToken = '';
  static String apnsToken = '';

  static int lastRosterFetchTime = 0;
  static int rosterFetchInterval = 15 * 60 * 1000;

  List<MessageChat> events = [];
  List<PresentModel> presentMo = [];
  String connectionStatus = 'Disconnected';

  bool get registered =>
      (connectionStatus == XmppConnectionState.authenticated.toString());

  late JabberStream jabberStream;

  JabberManager() {
    if (!enabled) {
      print('--- JabberManager DISABLED ---');
      loadSettings();
      return;
    }
    XmppConnection.addListener(this);
    jabberStream = JabberStream();
    loadSettings().then((prefs) {
      doRegister();
      startMainTimer();
    });
  }

  String getLogin() {
    return preferences.getString('auth_user') ?? '';
  }

  String getPasswd() {
    return preferences.getString('password') ?? '';
  }

  String getJid({String? phone}) {
    if (phone != null) {
      return '${cleanPhone(phone)}@$JABBER_SERVER';
    }
    return '${cleanPhone(getLogin())}@$JABBER_SERVER';
  }

  void setStopFlag(bool flag) {
    stopFlag = flag;
  }

  /* Debug print */
  static void doprintln(String msg) {
    print(msg);
  }

  static bool isConference(String jid) {
    /* Проверка на наличие conference в идентификаторе */
    if (jid.endsWith('@conference.$JABBER_SERVER')) {
      return true;
    }
    return false;
  }

  /* Регистрация на сип сервере */
  void doRegister() {
    if (registered) {
      return;
    }

    if (appState == AppLifecycleState.paused ||
        appState == AppLifecycleState.detached) {
      doprintln('ignore register trigger because appState is $appState');
      return;
    }

    if ((preferences.getString('password') != null) &&
        (preferences.getString('auth_user') != null)) {
      doprintln('try register');
      doprintln(
          '${preferences.getString('auth_user')!}, ${preferences.getString('password')!}, $connectionStatus ');
      start(
        preferences.getString('auth_user')!,
        preferences.getString('password')!,
      );
    }
  }

  Future<SharedPreferences> loadSettings() async {
    preferences = await SharedPreferences.getInstance();
    String? authUser = preferences.getString('auth_user');
    doprintln('password ${preferences.getString('password')}');
    doprintln('auth_user $authUser');
    if (authUser != null) {
      TelegramBot.userPhone = authUser;
    }
    return preferences;
  }

  void changeSettings(Map<String, dynamic> userData) {
    setStopFlag(true);

    doprintln('jabber changeSettings: $userData');
    preferences.setString('display_name', userData['name'] ?? '');
    preferences.setString('password', userData['passwd'] ?? '');
    preferences.setString('auth_user', userData['phone'] ?? '');

    start(
      userData['phone'] ?? '',
      userData['passwd'] ?? '',
    );
  }

  void startMainTimer() {
    mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //doprintln('${timer.tick}');
      checkRegisterTimer -= 1;
      if (checkRegisterTimer < 0) {
        checkRegisterTimer = 10;
        doprintln(
            'XMPP: is registered: $registered, stopFlag $stopFlag, connectionStatus $connectionStatus');
        if (stopFlag) {
          return;
        }

        // Чтобы не попасть в fail2ban джабы, надо стопнуть попытки
        if (connectionStatus == XmppConnectionState.failed.toString()) {
          doprintln(
              'set stop flag, because connection state is $connectionStatus');
          setStopFlag(true);
          return;
        }
        // До проверки статуса у нас может быть failed,
        // после проверки disconnected/connected/authenticated
        showConnectionStatus().then((status) {
          final String newConnectionStatus = status.toString();
          // Если статус другой вызываем событие, чтобы оповестить виджеты
          if (newConnectionStatus != connectionStatus) {
            connectionStatus = newConnectionStatus;
            jabberStream.registrationChanged(registered);
          }
          if (!registered) {
            doRegister();
          } else {
            updateTokenTimer -= 1;
            if (updateTokenTimer < 0) {
              updateTokenTimer = 600;
              sendToken(preferences.getString('auth_user') ?? '', fcmToken,
                      apnsToken: apnsToken)
                  .then((sent) {
                if (sent) {
                  updateTokenTimer = 3600;
                } else {
                  updateTokenTimer = 10;
                }
              });
            }
          }
        });
      }
    });
  }

  void dispose() {
    XmppConnection.removeListener(this);
  }

  Future<void> start(String login, String passwd) async {
    final String authUser = getJid(phone:login);
    updateTokenTimer = 1;

    final auth = {
      'user_jid': '$authUser/${const Uuid().v4()}',
      'password': passwd,
      'host': JABBER_SERVER,
      'port': '$JABBER_PORT', // Порт обязательно строкой
      'nativeLogFilePath': NativeLogHelper.logFilePath,
      'requireSSLConnection': true,
      'autoDeliveryReceipt': true,
      'useStreamManagement': false,
      'automaticReconnection': true,
    };
    doprintln('auth is ${auth.toString()}, $flutterXmpp');

    flutterXmpp = XmppConnection(auth);
    await flutterXmpp!.start(_onError);
    await flutterXmpp!.login();
    setStopFlag(false);
  }

  Future<void> stop() async {
    myVCard = {};
    await flutterXmpp?.logout();
  }

  void _onError(Object error) {
    doprintln('----- ERROR ${error.toString()}');
  }

  @override
  void onXmppError(ErrorResponseEvent errorResponseEvent) {
    doprintln(
        'receiveEvent onXmppError: ${errorResponseEvent.toErrorResponseData().toString()}');
  }

  @override
  void onSuccessEvent(SuccessResponseEvent successResponseEvent) {
    doprintln(
        'receiveEvent successEventReceive: ${successResponseEvent.toSuccessResponseData().toString()}');
  }

  @override
  void onChatMessage(MessageChat messageChat) {
    events.add(messageChat);
    doprintln('R - onChatMessage: ${messageChat.toEventData()}');
  }

  @override
  void onGroupMessage(MessageChat messageChat) {
    events.add(messageChat);
    doprintln('onGroupMessage: ${messageChat.toEventData()}');
  }

  @override
  void onNormalMessage(MessageChat messageChat) {
    events.add(messageChat);
    doprintln('onNormalMessage: ${messageChat.toEventData()}');
  }

  @override
  void onPresenceChange(PresentModel presentModel) {
    presentMo.add(presentModel);
    doprintln('onPresenceChange ~~>>${presentModel.toJson()}');
  }

  @override
  void onChatStateChange(ChatState chatState) {
    doprintln('onChatStateChange ~~>>$chatState');
  }

  @override
  void onConnectionEvents(ConnectionEvent connectionEvent) {
    connectionStatus = connectionEvent.type!.toString();
    doprintln('onConnectionEvents ~~>>${connectionEvent.toJson()}');
    jabberStream.registrationChanged(
        connectionEvent.type == XmppConnectionState.authenticated);
    // Выполняем вход во все группы, которые у нас есть
    if (connectionEvent.type == XmppConnectionState.authenticated) {
      lastRosterFetchTime = 0;
      enter2GroupsFromVCard();
    }
  }

  Future<dynamic> getMyMUCs() async {
    final mucs = await flutterXmpp!.getMyMUCs();
    return mucs ?? [];
  }

  Future<bool> createMUC(String groupName, bool persistent) async {
    bool resp = await flutterXmpp!.createMUC(groupName, persistent);
    doprintln('createMUC $groupName, result $resp');
    return resp;
  }

  Future<String> joinMucGroups(List<String> allGroupsId) async {
    return await flutterXmpp!.joinMucGroups(allGroupsId);
  }

  Future<bool> joinMucGroup(String groupId) async {
    return await flutterXmpp!.joinMucGroup(groupId);
  }

  Future<void> addMembersInGroup(String groupName, List<String> members) async {
    await flutterXmpp!.addMembersInGroup(groupName, members);
  }

  Future<void> addAdminsInGroup(
      String groupName, List<String> adminMembers) async {
    await flutterXmpp!.addAdminsInGroup(groupName, adminMembers);
  }

  Future<void> addOwner(String groupName, List<String> membersJid) async {
    await flutterXmpp!.addOwner(groupName, membersJid);
  }

  Future<List<dynamic>> getMembers(String groupName) async {
    return await flutterXmpp!.getMembers(groupName);
  }

  Future<List<dynamic>> getAdmins(String groupName) async {
    return await flutterXmpp!.getAdmins(groupName);
  }

  Future<List<dynamic>> getOwners(String groupName) async {
    return await flutterXmpp!.getOwners(groupName);
  }

  Future<int> getOnlineMemberCount(String groupName) async {
    return await flutterXmpp!.getOnlineMemberCount(groupName);
  }

  Future<void> removeMember(String groupName, List<String> membersJid) async {
    await flutterXmpp!.removeMember(groupName, membersJid);
  }

  Future<void> removeAdmin(String groupName, List<String> membersJid) async {
    await flutterXmpp!.removeAdmin(groupName, membersJid);
  }

  Future<void> removeOwner(String groupName, List<String> membersJid) async {
    await flutterXmpp!.removeOwner(groupName, membersJid);
  }

  Future<String> getLastSeen(String userJid) async {
    return await flutterXmpp!.getLastSeen(userJid);
  }

  Future<void> changePresenceType(presenceType, presenceMode) async {
    await flutterXmpp!.changePresenceType(presenceType, presenceMode);
  }

  Future<XmppConnectionState?> showConnectionStatus() async {
    if (flutterXmpp != null) {
      XmppConnectionState status = await flutterXmpp!.getConnectionStatus();
      return status;
    }
    return null;
  }

  Future<dynamic> getVCard(String phone) async {
    return await flutterXmpp?.getVCard(getJid(phone: phone)) ?? {};
  }

  Future<dynamic> getMyVCard() async {
    if (myVCard.isNotEmpty) {
      doprintln('VCARD already received ${myVCard.toString()}');
      return myVCard;
    }
    myVCard = await flutterXmpp?.getVCard(getJid()) ?? {};
    return myVCard;
  }

  Future<dynamic> saveMyVCard() async {
    if (myVCard.isEmpty) {
      doprintln('Can not save my vcard because it is empty');
      return;
    }
    return await flutterXmpp?.saveVCard(myVCard);
  }

  Future<dynamic> saveVCard(Map<Object, Object> vCard) async {
    /* Сохранять можно только свою vСard, но здесь получаем произвольный словарь */
    return await flutterXmpp?.saveVCard(vCard);
  }

  Future<Map<String, dynamic>> getVCardDescAsDict() async {
    await getMyVCard();
    Map<String, dynamic> descObj = {};
    try {
      descObj = jsonDecode(JabberManager.myVCard['DESC'].toString());
    } catch (ex, stacktrace) {
      doprintln('[EXCEPTION]: ${ex.toString()}');
      doprintln(stacktrace.toString());
    }
    return descObj;
  }

  Future<void> group2VCard(String newMuc) async {
    /* Добавляем группу в VCard и сохраняем
       TODO: предусмотреть случай, если с двух устройств будет это делаться (перетрет)
    */
    Map<String, dynamic> descObj = await getVCardDescAsDict();
    if (descObj['groups'] != null) {
      if (descObj['groups'][newMuc] != null) {
        doprintln('group $newMuc already in VCard');
      } else {
        descObj['groups'][newMuc] = 1;
      }
    } else {
      descObj['groups'] = {
        newMuc: 1,
      };
    }
    // Сохраняем VCard
    JabberManager.myVCard['DESC'] = jsonEncode(descObj);
    await saveMyVCard();
  }

  Future<void> enter2GroupsFromVCard() async {
    /* Выполнить вход во все группы, которые вписаны в VCard */
    Map<String, dynamic> descObj = await getVCardDescAsDict();
    if (descObj['groups'] == null) {
      doprintln('Can not enter to groups from VCard[DESC]: Groups is null');
      return;
    }
    for (String key in descObj['groups'].keys) {
      await joinMucGroup(key);
    }
    ;
  }

  Future<dynamic> getRoster() async {
    final roster = await flutterXmpp?.getMyRosters();
    return roster ?? [];
  }

  Future<dynamic> add2Roster(String phone) async {
    await flutterXmpp?.createRoster(getJid(phone: phone));
  }

  Future<dynamic> dropFromRoster(String phone) async {
    await flutterXmpp?.dropRoster(getJid(phone: phone));
  }

  Future<String> sendCustomMessage(
      String to, String body, String customText) async {
    /* Отправка сообщения с использованием медиа файлов */
    int now = DateTime.now().millisecondsSinceEpoch;
    String pk = const Uuid().v4();
    await flutterXmpp?.sendCustomMessage(getJid(phone: to), body, pk, customText, now);
    return pk;
  }

  Future<String> sendMessage(String to, String body) async {
    int now = DateTime.now().millisecondsSinceEpoch;
    String pk = const Uuid().v4();
    await flutterXmpp?.sendMessage(getJid(phone: to), body, pk, now);
    return pk;
  }

  Future<String> sendCustomGroupMessage(
      String to, String body, String customText) async {
    if (!JabberManager.isConference(to)) {
      doprintln('sendCustomGroupMessage ERROR: $to without conference');
      return '';
    }
    int now = DateTime.now().millisecondsSinceEpoch;
    String pk = const Uuid().v4();
    await flutterXmpp?.sendCustomGroupMessage(to, body, pk, customText, now);
    return pk;
  }

  Future<String> sendGroupMessage(String to, String body) async {
    if (!JabberManager.isConference(to)) {
      doprintln('sendGroupMessage ERROR: $to without conference');
      return '';
    }
    int now = DateTime.now().millisecondsSinceEpoch;
    String pk = const Uuid().v4();
    await flutterXmpp?.sendGroupMessage(to, body, pk, now);
    return pk;
  }

  Future<void> requestMamMessages(String userJid,
      {String since = '',
      String before = '',
      int limit = 10,
      bool lastFlag = false}) async {
    /* Получение сообщений из МАМ,
       lastFlag: получить последние сообщения
    */
    if (!registered) {
      return;
    }
    // userJid должен быть полным - с доменом
    //String userJid = '${cleanPhone(phone)}@$JABBER_SERVER';

    /*
    int now = DateTime.now().millisecondsSinceEpoch;
    int longAgo = now - 60 * 60 * 12 * 1000 * 300;
    int farAway = now + 60 * 60 * 12 * 1000 * 300;

    int requestSince = since ?? longAgo;
    int requestBefore = before ?? farAway;
    print('requestMamMessages: $userJid, ${DateTime.fromMillisecondsSinceEpoch(longAgo)} - ${DateTime.fromMillisecondsSinceEpoch(farAway)}');
    await flutterXmpp?.requestMamMessages(userJid, longAgo.toString(),
        farAway.toString(), limit.toString(), lastFlag);

    */
    await flutterXmpp?.requestMamMessages(
        userJid, since, before, limit.toString(), lastFlag);
  }

  /* sha256 на логин + пароль
     для различных операций, требующих авторизации
  */
  String credentialsHash() {
    String login = cleanPhone(getLogin());
    List<int> credentials = utf8.encode(login + getPasswd());
    return sha256.convert(credentials).toString();
  }
}
