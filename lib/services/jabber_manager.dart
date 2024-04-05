import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:infoservice/models/chat_message_model.dart';
import 'package:infoservice/models/companies/orgs.dart';
import 'package:infoservice/models/pending_message_model.dart';
import 'package:infoservice/models/roster_model.dart';
import 'package:infoservice/services/shared_preferences_manager.dart';

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
import '../helpers/log.dart';
import '../helpers/native_log_helper.dart';
import '../helpers/network.dart';
import '../helpers/phone_mask.dart';
import '../models/contact_model.dart';
import '../models/user_settings_model.dart';
import '../settings.dart';

class JabberManager implements DataChangeEvents {
  static final JabberManager _singleton = JabberManager._internal();
  factory JabberManager() {
    return _singleton;
  }
  JabberManager._internal();

  static const String tag = 'JabberManager';
  static const String conferenceString = '@conference.$JABBER_SERVER';
  static const String domainString = '@$JABBER_SERVER';

  static XmppConnection? flutterXmpp;
  static AppLifecycleState? appState;
  static bool enabled = true; // на время отладки можно отключать
  static Map<Object?, Object?> myVCard = {};
  static Map<String, String> unreadMessages = {};

  static String fcmToken = '';
  static String apnsToken = '';
  static Map<String, String> cacheRosterNames = {};
  static List<String> pendingRosterRows = [];
  static UserSettingsModel? user;

  bool stopFlag = false;
  bool mainTimerStarted = false;
  String connectionStatus = 'Disconnected';
  int connectedTime = 0;
  int counter = 0;

  bool get registered =>
      (connectionStatus == XmppConnectionState.authenticated.toString());

  Future<void> init() async {
    if (!enabled) {
      Log.d(tag, '--- DISABLED ---');
      loadSettings();
      return;
    }

    Log.d(tag, '--- INIT ---');
    XmppConnection.addListener(this);
    if (!mainTimerStarted) {
      mainTimerStarted = true;
      startMainTimer();
    }
    Log.d(tag, '--- INIT FINISHED ---');
  }

  Future<String> getLogin() async {
    SharedPreferences prefs =
        await SharedPreferencesManager.getSharedPreferences();
    return prefs.getString('auth_user') ?? '';
  }

  Future<String> getPasswd() async {
    SharedPreferences prefs =
        await SharedPreferencesManager.getSharedPreferences();
    return prefs.getString('password') ?? '';
  }

  String toJid(String login) {
    if (!login.endsWith('@$JABBER_SERVER')) {
      return '${cleanPhone(login)}@$JABBER_SERVER';
    }
    return login;
  }

  Future<String> getJid(
      {String? phone, bool store2sharedPreferences = false}) async {
    if (phone != null) {
      return '${cleanPhone(phone)}@$JABBER_SERVER';
    }
    SharedPreferences prefs =
        await SharedPreferencesManager.getSharedPreferences();
    String result = '${cleanPhone(await getLogin())}@$JABBER_SERVER';
    if (store2sharedPreferences) {
      prefs.setString(SharedPreferencesManager.myJid, result);
    }
    return result;
  }

  void setStopFlag(bool flag) {
    stopFlag = flag;
  }

  static bool isConference(String jid) {
    /* Проверка на наличие conference в идентификаторе */
    if (jid.endsWith(conferenceString)) {
      return true;
    }
    return false;
  }

  /* Регистрация на сип сервере */
  Future<void> doRegister() async {
    bool hasInternet = await checkInternetConnection();
    if (registered || !hasInternet) {
      return;
    }
    if (!mainTimerStarted) {
      mainTimerStarted = true;
      startMainTimer();
    }

    if (appState == AppLifecycleState.paused ||
        appState == AppLifecycleState.detached) {
      Log.d(tag, 'ignore register trigger because appState is $appState');
      return;
    }
    user = await UserSettingsModel().getUser();
    if (user == null) {
      Log.d(tag, '[ERROR]: USER IS NULL, can not start register');
      return;
    }
    await start(
      user?.jid ?? '',
      user?.passwd ?? '',
    );
  }

  Future<SharedPreferences> loadSettings() async {
    SharedPreferences prefs =
        await SharedPreferencesManager.getSharedPreferences();
    String? authUser = prefs.getString('auth_user');
    Log.d(
        tag,
        'password ${prefs.getString('password')}'
        'auth_user $authUser');
    if (authUser != null) {
      TelegramBot.userPhone = authUser;
    }
    return prefs;
  }

  Future<void> changeSettings(Map<String, dynamic> userData) async {
    setStopFlag(true);
    SharedPreferences prefs =
        await SharedPreferencesManager.getSharedPreferences();
    Log.d(tag, 'jabber changeSettings: $userData');
    prefs.setString('display_name', userData['name'] ?? '');
    prefs.setString('password', userData['passwd'] ?? '');
    prefs.setString('auth_user', userData['phone'] ?? '');

    await start(
      userData['phone'] ?? '',
      userData['passwd'] ?? '',
    );
  }

  Future<void> startMainTimer() async {
    //print("___timer ${mainTimer?.tick}");
    counter += 1;
    Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      t.cancel();
      bool hasInternet = await checkInternetConnection();
      SharedPreferences prefs =
          await SharedPreferencesManager.getSharedPreferences();
      await prefs.setBool('checkInternetConnection', hasInternet);
      Log.d(
          tag,
          '$counter, XMPP: is registered: $registered'
          ', stopFlag $stopFlag'
          ', connectionStatus $connectionStatus'
          ', connectedTime $connectedTime');
      if (!hasInternet) {
        if (registered) {
          // На йосе здесь await не вернет результат (видимо слушателя надо проверить)
          flutterXmpp?.logout();
        }
        startMainTimer();
        return;
      }
      if (registered) {
        connectedTime += 1;
        /* TODO: по-другому
        // Переотправка сообщений, которые потерялись
        int now = DateTime.now().millisecondsSinceEpoch;
        int longInterval = 10000;
        if (connectedTime > longInterval / 1000) {
          List<PendingMessageModel> pendingMessages =
              await PendingMessageModel().getAll();
          for (PendingMessageModel pendingMessage in pendingMessages) {
            if ((pendingMessage.time ?? 0) < (now - longInterval)) {
              ChatMessageModel chatMessage =
                  await ChatMessageModel().getByPk(pendingMessage.id ?? 0);
              if (chatMessage.id != null) {
                // Переотправка файла требует слот
                if (chatMessage.customText != null &&
                    chatMessage.customText != '') {
                  Map<String, dynamic> customText =
                      jsonDecode(chatMessage.customText!);
                  if (customText['path'] != null && customText['path'] != '') {
                    File file = File(customText['path']);
                    if (await file.exists()) {
                      String fname = file.path.split('/').last;
                      int filesize = await file.length();
                      String? putUrl = await JabberManager.flutterXmpp
                          ?.requestSlot(fname, filesize);

                      if (putUrl != null && putUrl != '') {
                        Map<String, dynamic> response =
                            await requestPutFile(putUrl, file);
                        if (response['statusCode'] == 201) {
                          Log.i(tag, 'upload success $putUrl');
                          customText = {
                            'type': chatMessage.body.toString(),
                            'url': putUrl,
                            'path': file.path,
                          };
                          chatMessage.customText = jsonEncode(customText);
                          await chatMessage.updatePartial(chatMessage.id, {
                            'customText': chatMessage.customText,
                          });
                        }
                      }
                    }
                  }
                }
                if (chatMessage.msgtype == 'groupchat') {
                  await sendGroupMessage(chatMessage.from ?? '',
                      chatMessage.to ?? '', chatMessage.body ?? '',
                      pk: chatMessage.mid ?? '',
                      now: chatMessage.time ?? 0,
                      customText: chatMessage.customText ?? '',
                      isResend: true);
                } else {
                  await sendMessage(chatMessage.from ?? '',
                      chatMessage.to ?? '', chatMessage.body ?? '',
                      pk: chatMessage.mid ?? '',
                      now: chatMessage.time ?? 0,
                      customText: chatMessage.customText ?? '',
                      isResend: true);
                }
              }
              await pendingMessage.delete2Db();
            }
          }
        }
        */
      } else {
        connectedTime = 0;
        XmppConnectionState? status = await showConnectionStatus();
        await Future.delayed(const Duration(seconds: 2));
        Log.i(tag, 'XmppConnectionState=$status');
        if (status == null || status == XmppConnectionState.disconnected || status == XmppConnectionState.failed) {
          if (await UserSettingsModel().getUser() != null) {
            await doRegister();
            await Future.delayed(const Duration(seconds: 5));
          } else {
            // Заканчиваем мучать таймер
            Log.i(tag, 'TIMER STOPPED - USER NOT FOUND');
            mainTimerStarted = false;
            return;
          }
        }
      }
      startMainTimer();
    });
  }

  Future<void> try2register() async {
    /* TODO: stopFlag=true по push-уведомлению
             или если прошло много времени и есть интернет?
    */
    if (stopFlag) {
      return;
    }
    // Чтобы не попасть в fail2ban на сервере stopFlag=true
    if (connectionStatus == XmppConnectionState.failed.toString()) {
      Log.d(
          tag, 'set stop flag, because connection state is $connectionStatus');
      setStopFlag(true);
      await stop();
      return;
    }
    // До проверки статуса у нас может быть failed,
    // после проверки disconnected/connected/authenticated
    XmppConnectionState? status = await showConnectionStatus();
    final String newConnectionStatus = status.toString();
    // Если статус другой вызываем событие, чтобы оповестить виджеты
    if (newConnectionStatus != connectionStatus) {
      connectionStatus = newConnectionStatus;
    }
    if (!registered) {
      //await doRegister();
    }
  }

  void dispose() {
    XmppConnection.removeListener(this);
  }

  Future<void> start(String myJid, String passwd) async {
    final auth = {
      'user_jid': '$myJid/${const Uuid().v4()}',
      'password': passwd,
      'host': JABBER_SERVER,
      'port': '$JABBER_PORT', // Порт обязательно строкой
      'nativeLogFilePath': NativeLogHelper.logFilePath,
      'requireSSLConnection': true,
      'autoDeliveryReceipt': true,
      'useStreamManagement': false,
      'automaticReconnection': false,
    };
    Log.d(tag, 'auth is ${auth.toString()}, $flutterXmpp');

    flutterXmpp = XmppConnection(auth);
    await flutterXmpp!.start(_onError);
    await flutterXmpp!.login();
    setStopFlag(false);
  }

  Future<void> stop() async {
    myVCard = {};
    unreadMessages = {};
    cacheRosterNames = {};
    pendingRosterRows = [];
    user = null;
    await flutterXmpp?.logout();
  }

  void _onError(Object error) {
    Log.d(tag, '--- ERROR ---\n${error.toString()}');
  }

  @override
  void onXmppError(ErrorResponseEvent errorResponseEvent) {
    Log.d(
        tag,
        'receiveEvent onXmppError: '
        '${errorResponseEvent.toErrorResponseData().toString()}');
  }

  @override
  void onSuccessEvent(SuccessResponseEvent successResponseEvent) {
    Log.d(
        tag,
        'receiveEvent successEventReceive: '
        '${successResponseEvent.toSuccessResponseData().toString()}');
  }

  @override
  void onChatMessage(MessageChat messageChat) {
    Log.d(tag, 'RC - onChatMessage: ${messageChat.toEventData()}');
    checkReceivedMessage(messageChat);
  }

  @override
  void onGroupMessage(MessageChat messageChat) {
    Log.d(tag, 'RG - onGroupMessage: ${messageChat.toEventData()}');
    checkReceivedMessage(messageChat, isGroup: true);
  }

  void checkReceivedMessage(MessageChat messageChat,
      {bool isGroup = false}) async {
    /* Получено сообщение, подпихивать имя пользователя в поток
    */
    ChatMessageModel receivedMessage =
        ChatMessageModel.convert2ChatMessageModel(messageChat);
    if (receivedMessage.body == null || receivedMessage.body!.trim() == '') {
      // TODO: это маркерные сообщения, нужно смотреть их в onNormalMessage
      Log.d(tag, 'checkReceivedMessage PASSING ${messageChat.toString()}');
      return;
    }

    if (messageChat.type == 'Ack') {
      int deleted =
          await PendingMessageModel().deleteByUid(messageChat.id ?? '');
      print("DELETED deleteByUid: $deleted");
    }

    bool isExists = await receivedMessage.isExists();
    if (!isExists) {
      await receivedMessage.insert2Db();
    }

    String from = receivedMessage.from ?? '';
    String to = receivedMessage.to ?? '';
    String rosterItem = from;
    // Пользователь должен быть заполнен, иначе как мы получаем сообщения?
    String myJid = user?.jid ?? '';
    if (from == myJid) {
      rosterItem = to;
    }

    List<RosterModel> rosterModels =
        await RosterModel().getBy(myJid, jid: rosterItem, isGroup: isGroup);
    if (rosterModels.isEmpty) {
      // Пришло сообщение, если ростера нет такого - добавляем
      Log.e(
          tag,
          '---\nRoster not found by received message: ${receivedMessage.toString()}\n'
          'with myJid: $myJid, friendJid: $rosterItem, isGroup $isGroup\n'
          '---\n');
      String phone = cleanPhone(rosterItem);
      await addMyRoster(phone, remoteAdd: false);
      rosterModels =
          await RosterModel().getBy(myJid, jid: rosterItem, isGroup: isGroup);
    }
    RosterModel rosterModel = rosterModels[0];
    int lastReadMessageTime = rosterModel.lastReadMessageTime ?? 0;
    int newMessagesCount = rosterModel.newMessagesCount ?? 0;
    int lastMessageTime = 0;
    int receivedMessageTime = 0;

    if (receivedMessage.time != null) {
      receivedMessageTime = receivedMessage.time!;
      // Если в группе мы и отправляли, тогда не надо увеличивать счетчик новых
      String phone = user?.phone ?? '';
      String messageChatFrom = messageChat.from ?? '';
      if (isGroup && messageChatFrom.endsWith(phone)) {
        // не инкрементим
      } else if (receivedMessageTime > lastReadMessageTime && myJid != from) {
        newMessagesCount += 1;
      }
    }
    if (rosterModel.lastMessageTime != null) {
      lastMessageTime = rosterModel.lastMessageTime!;
    }

    if (lastMessageTime < receivedMessageTime) {
      rosterModel.lastMessageTime = receivedMessageTime;
      rosterModel.lastMessageId = receivedMessage.mid;
      rosterModel.lastMessage = receivedMessage.body;
      rosterModel.newMessagesCount = newMessagesCount;
      // Обновляем в базе ростер
      await rosterModel.updatePartial(rosterModel.id, {
        'lastMessageTime': receivedMessageTime,
        'lastMessageId': receivedMessage.mid,
        'lastMessage': receivedMessage.body,
        'newMessagesCount': newMessagesCount,
      });
      await UserSettingsModel().updateRosterVersion();
      Log.d(
          tag,
          '---\nRECEIVED: ${receivedMessage.toString()}'
          '\nroster changed: ${rosterModel.jid}'
          '\n---');
    }
  }

  Future<void> onDeliveryAck(MessageChat messageChat) async {
    /* Получение рецепта доставки сообщения */
    Log.d(tag, 'onDeliveryReceipt: ${messageChat.toEventData()}');
    String myJid = user?.jid ?? '';

    Log.d('onDeliveryReceipt',
        'received delivery receipt <----- ${messageChat.id}');
    ChatMessageModel chatMessageModel =
        await ChatMessageModel().getByMid(messageChat.id ?? '');

    if (chatMessageModel.id == null || chatMessageModel.time == null) {
      Log.e('onDeliveryReceipt', 'mid=${messageChat.id} not found in DB');
      return;
    }
    String friendJid = chatMessageModel.to ?? '';
    if (friendJid == myJid) {
      Log.e('onDeliveryReceipt', 'to is equal myJid');
      return;
    }

    int beforeTime = chatMessageModel.time ?? 0;
    int count =
        await ChatMessageModel().setReadFlag(beforeTime, myJid, friendJid);
    if (count > 0) {
      await UserSettingsModel().updateRosterVersion();
    }
  }

  @override
  void onNormalMessage(MessageChat messageChat) {
    if (messageChat.type == 'Delivery-Ack') {
      // Подтверждение доставки
      onDeliveryAck(messageChat);
    } else {
      if (messageChat.type == 'Ack') {
        ChatMessageModel().getByMid(messageChat.id ?? '').then((msg) async {
          if (msg.id != null) {
            await PendingMessageModel(id: msg.id).delete2Db();
          }
        });
      }
      Log.d(tag, 'onNormalMessage: ${messageChat.toEventData()}');
    }
  }

  @override
  void onPresenceChange(PresentModel presentModel) {
    Log.d(tag, 'onPresenceChange ~~>>${presentModel.toJson()}');
  }

  @override
  void onChatStateChange(ChatState chatState) {
    Log.d(tag, 'onChatStateChange ~~>>$chatState');
  }

  @override
  void onConnectionEvents(ConnectionEvent connectionEvent) {
    connectionStatus = connectionEvent.type!.toString();
    Log.d(tag, 'onConnectionEvents ~~>>${connectionEvent.toJson()}');
    Log.d(tag, 'new connectionStatus=$connectionStatus, registered=$registered');

    UserSettingsModel().getUser().then((userSettings) async {
      if (userSettings != null) {
        user = userSettings;
        await userSettings.updatePartial(
            userSettings.id, {'isXmppRegistered': registered ? 1 : 0});
        if (registered) {
          await getRoster();
          await initData();
        }
      }
    });
  }

  Future<void> initData() async {
    myVCard = {};
    await getMyVCard();
    await enter2GroupsFromVCard(); // Входим в группы
    //await getUnreadMessages(); // личное хранилище
    await getLastChatHistory();
  }

  Future<dynamic> getMyMUCs() async {
    final mucs = await flutterXmpp!.getMyMUCs();
    return mucs ?? [];
  }

  Future<bool> createMUC(String groupName, bool persistent) async {
    await newMyMucGroup(groupName);
    bool resp = await flutterXmpp!.createMUC(groupName, persistent);
    Log.d(tag, 'createMUC $groupName, result $resp');
    return resp;
  }

  Future<String> joinMucGroups(List<String> allGroupsId) async {
    return await flutterXmpp!.joinMucGroups(allGroupsId);
  }

  Future<bool> joinMucGroup(String groupId) async {
    return await flutterXmpp!.joinMucGroup(groupId);
  }

  Future<void> newMyMucGroup(String newMuc) async {
    if (!registered) {
      return;
    }
    UserSettingsModel? user = await UserSettingsModel().getUser();
    if (user == null) {
      Log.e(tag, 'newMyMucGroup user absent');
      return;
    }
    String myJid = user.jid ?? '';
    String groupJid = '$newMuc$conferenceString';

    List<RosterModel> rosterModels =
        await RosterModel().getBy(myJid, jid: groupJid, isGroup: true);
    if (rosterModels.isEmpty) {
      RosterModel rosterModel =
          RosterModel(jid: groupJid, name: newMuc, ownerJid: myJid, isGroup: 1);
      int pk = await rosterModel.insert2Db();
      user.incRosterVersion();
      await user.updatePartial(user.id, {
        'rosterVersion': user.rosterVersion,
      });
      rosterModel.id = pk;
      await checkMucCompany(rosterModel);
    }
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
    UserSettingsModel? user = await UserSettingsModel().getUser();
    if (flutterXmpp != null) {
      XmppConnectionState status = await flutterXmpp!.getConnectionStatus();
      if (user != null) {
        bool isRegistered = status == XmppConnectionState.authenticated;
        if (user.isXmppRegistered != (isRegistered ? 1 : 0)) {
          await user.updatePartial(
              user.id, {'isXmppRegistered': isRegistered ? 1 : 0});
        }
      }
      return status;
    } else {
      if (user != null && user.isXmppRegistered != 0) {
        await user.updatePartial(user.id, {'isXmppRegistered': 0});
      }
    }
    return null;
  }

  Future<dynamic> getVCard(String jid) async {
    if (isConference(jid)) {
      String groupJid = '${jid.split('@')[0]}@$JABBER_SERVER';
      return await flutterXmpp?.getVCard(groupJid) ?? {};
    }
    return await flutterXmpp?.getVCard(toJid(jid)) ?? {};
  }

  Future<dynamic> getMyVCard() async {
    if (!registered) {
      return;
    }
    if (myVCard.isNotEmpty) {
      Log.d(tag, 'VCARD already received ${myVCard.toString()}');
      return myVCard;
    }
    UserSettingsModel? user = await UserSettingsModel().getUser();
    if (user != null) {
      myVCard = await flutterXmpp?.getVCard(user.jid ?? '') ?? {};
      if (myVCard['DESC'] == null) {
        myVCard['DESC'] = {};
      }
    } else {
      Log.e(tag, 'getMyVCard user absent');
    }
    return myVCard;
  }

  Future<dynamic> saveMyVCard() async {
    if (myVCard.isEmpty) {
      Log.d(tag, 'Can not save my vcard because it is empty');
      return;
    }
    return await flutterXmpp?.saveVCard(myVCard);
  }

  Future<dynamic> saveVCard(Map<Object, Object> vCard) async {
    /* Сохранять можно только свою vСard, но здесь получаем произвольный словарь */
    return await flutterXmpp?.saveVCard(vCard);
  }

  Map<String, dynamic> destAsDictHelper(Object? desc) {
    /* Получаем словарь (например, из DESC VCard) */
    Map<String, dynamic> descObj = {};
    try {
      descObj = jsonDecode(desc.toString());
    } catch (ex, stacktrace) {
      Log.d(tag, '[EXCEPTION]: ${ex.toString()}, >$desc<');
      Log.d(tag, stacktrace.toString());
    }
    return descObj;
  }

  Future<Map<String, dynamic>> getVCardDescAsDict({String jid = ''}) async {
    /* Получаем словарь из VCard['DESC'] */
    Map vcard = {};
    if (jid == '') {
      vcard = await getMyVCard() ?? {};
    } else {
      vcard = await getVCard(jid) ?? {};
    }
    return destAsDictHelper(vcard['DESC']);
  }

  Future<void> addGroup2VCard(String mucName) async {
    /* Добавляем группу в VCard и сохраняем
    */
    Map<String, dynamic> descObj = await getVCardDescAsDict();
    if (descObj['groups'] != null) {
      if (descObj['groups'][mucName] != null) {
        Log.d(tag, 'group $mucName already in VCard');
      } else {
        descObj['groups'][mucName] = 1;
      }
    } else {
      descObj['groups'] = {
        mucName: 1,
      };
    }
    // Сохраняем VCard
    JabberManager.myVCard['DESC'] = jsonEncode(descObj);
    await saveMyVCard();
  }

  Future<void> dropGroup2VCard(String mucName) async {
    /* Добавляем группу в VCard и сохраняем
    */
    Map<String, dynamic> descObj = await getVCardDescAsDict();
    if (descObj['groups'] != null) {
      if (descObj['groups'][mucName] != null) {
        descObj['groups'].remove(mucName);
      } else {
        Log.d(tag, 'group $mucName NOT in VCard');
      }
    } else {
      descObj['groups'] = {};
    }
    // Сохраняем VCard
    JabberManager.myVCard['DESC'] = jsonEncode(descObj);
    await saveMyVCard();
  }

  Future<void> enter2GroupsFromVCard() async {
    /* Выполнить вход во все группы, которые вписаны в VCard */
    if (!registered) {
      return;
    }
    Map<String, dynamic> descObj = await getVCardDescAsDict();
    if (descObj['groups'] == null) {
      Log.d(tag, 'Can not enter to groups from VCard[DESC]: Groups is null');
      return;
    }
    for (String key in descObj['groups'].keys) {
      await joinMucGroup(key);
      //await addMembersInGroup(key, [me]);
    }
  }

  Future<dynamic> getRoster() async {
    List<Object?> roster = [];
    if (registered) {
      // У нас должен быть пользователь
      UserSettingsModel? user = await UserSettingsModel().getUser();
      if (user == null) {
        Log.e(tag, '--- getRoster --- UserSettingsModel not found');
        return [];
      }
      List<RosterModel> existsRosterItems =
          await RosterModel().getByOwner(user.jid ?? '');
      Map<String, RosterModel> rosterMap = {};
      for (RosterModel rosterItem in existsRosterItems) {
        if (rosterItem.jid == null || rosterItem.jid == '') {
          await rosterItem.delete2Db();
          continue;
        }
        rosterMap[rosterItem.jid!] = rosterItem;
      }
      roster = await flutterXmpp?.getMyRosters() ?? [];
      bool isNew = false;
      for (int i = 0; i < roster.length; i++) {
        String curJid = roster[i].toString().split(':')[0];
        if (curJid != '' && rosterMap[curJid] == null) {
          await RosterModel(jid: curJid, ownerJid: user.jid).insert2Db();
          user.incRosterVersion();
          isNew = true;
        }
      }

      // Заносим в ростер группы
      Map<String, dynamic> descObj = await getVCardDescAsDict();
      if (descObj['groups'] != null) {
        for (String key in descObj['groups'].keys) {
          String groupJid = '$key$conferenceString';
          RosterModel? dbGroup = rosterMap[groupJid];
          if (dbGroup == null) {
            RosterModel newGroup = RosterModel(
              jid: groupJid,
              name: key,
              ownerJid: user.jid,
              isGroup: 1,
            );
            await newGroup.insert2Db();
          }
        }
      }

      if (isNew) {
        await user.updatePartial(user.id, {
          'rosterVersion': user.rosterVersion,
        });
      }
    }
    return roster;
  }

  static Future<void> checkMucCompany(RosterModel rosterModel) async {
    if (rosterModel.isGroup != 1 || rosterModel.jid == null) {
      return;
    }
    List<String> parts = rosterModel.jid!.split('@')[0].split('_');
    if (parts[0] != 'company' && parts[0] != 'channel') {
      return;
    }
    int orgPk = 0;
    try {
      orgPk = int.parse(parts[1]);
    } catch (ex) {
      Log.d(tag, ex.toString());
      return;
    }
    Orgs? company = await Orgs().getOrg(orgPk);
    if (company == null) {
      Log.i('checkMucCompany', 'company not found with id $orgPk');
      return;
    }
    if (rosterModel.name != company.name) {
      await rosterModel.updatePartial(rosterModel.id, {
        'name': company.name,
      });
      rosterModel.name = company.name;
    }
    Log.i('checkMucCompany', 'rosterModel is ${rosterModel.toString()}');
  }

  Future<void> getLastChatHistory() async {
    /* По каждому клоуну запрашиваем историю */
    if (!registered) {
      Log.d(tag, "getLastChatHistory NOT REGISTERED!");
      return;
    }
    if (user == null) {
      Log.d(tag, "getLastChatHistory user is null!");
      return;
    }
    int by = 100;
    int since = 0;
    final String myJid = user!.jid ?? '';
    List<RosterModel> rosterModels = await RosterModel().getByOwner(myJid);
    Log.d(tag,
        'getLastChatHistory getByOwner $myJid, roster size: ${rosterModels.length}');
    for (RosterModel rosterModel in rosterModels) {
      if (rosterModel.isGroup == 1) {
        continue;
      }
      if (rosterModel.lastMessageTime != null &&
          rosterModel.lastMessageTime! > since) {
        since = rosterModel.lastMessageTime!;
      }
      /*
      String forUser = cleanPhone(rosterModel.jid ?? '');
      int since = rosterModel.lastMessageTime ?? 0;
      if (rosterModel.lastMessageTime != null) {
        Log.d(tag,
            'getLastChatHistory for $forUser, since $since');
        await requestMamMessages(forUser,
            since: since.toString(), lastFlag: true, limit: by);
      } else {
        await requestMamMessages(forUser, lastFlag: true, limit: by);
      }
      */
    }
    await requestMamMessages('',
        since: since.toString(), lastFlag: true, limit: by);
  }

  Future<List<dynamic>?> searchUsers(String username) async {
    return await flutterXmpp?.searchUsers(username);
  }

  Future<dynamic> addMyRoster(String phone, {bool remoteAdd = true}) async {
    /* Добавление в ростер на сервере и в базе */
    if (!registered) {
      return;
    }
    UserSettingsModel? user = await UserSettingsModel().getUser();
    if (user == null) {
      Log.e(tag, 'addMyRoster user absent');
      return;
    }
    String myJid = user.jid ?? '';
    String jid = toJid(phone);
    List<RosterModel> rosterModels = await RosterModel().getBy(myJid, jid: jid);
    if (rosterModels.isEmpty) {
      RosterModel rosterModel = RosterModel(jid: jid, ownerJid: myJid);
      phone = cleanPhone(phone);
      ContactModel? contact =
          await ContactModel().getByPhone(phone);
      if (contact != null) {
        rosterModel.name = contact.displayName;
      } else {
        // Проверка по названию комании
        Orgs? org = await Orgs().getOrgByChat(phone);
        if (org != null && org.name != null && org.name != '') {
          rosterModel.name = org.name;
        }
      }
      String rosterJid = rosterModel.jid ?? '';
      if (!pendingRosterRows.contains(rosterJid) && rosterJid != '') {
        pendingRosterRows.add(rosterJid);
        await rosterModel.insert2Db();
        await UserSettingsModel().updateRosterVersion();
        if (remoteAdd) {
          await flutterXmpp?.createRoster(jid);
        }
      }
    }
  }

  Future<dynamic> dropMyRoster(RosterModel rosterModel) async {
    /* Удаление из ростера на сервере и в базе */
    if (!registered) {
      return;
    }
    await rosterModel.delete2Db();
    await UserSettingsModel().updateRosterVersion();
    await flutterXmpp?.dropRoster(toJid(rosterModel.jid ?? ''));
  }

  Future<dynamic> dropMyGroup(RosterModel rosterModel) async {
    /* Удаление из ростера группы */
    if (rosterModel.jid == null || rosterModel.isGroup != 1) {
      Log.d(tag, 'dropMyGroup FAILED with roster ${rosterModel.toString()}');
      return;
    }
    String groupId = rosterModel.jid!.split('@')[0];
    await rosterModel.delete2Db();
    await UserSettingsModel().updateRosterVersion();
    // Открепиться от MUC
    await dropGroup2VCard(groupId);
  }

  Future<void> afterSendMessage(ChatMessageModel msg) async {
    /* Действие после отправки сообщения:
       1) обновляем в ростере информацию о последем сообщении
    */
    List<RosterModel> toRosterModels =
        await RosterModel().getBy(msg.from!, jid: msg.to!);
    if (toRosterModels.isNotEmpty) {
      RosterModel toRosterModel = toRosterModels[0];
      toRosterModel.updatePartial(toRosterModel.id, {
        'lastMessageTime': msg.time!,
        'lastMessageId': msg.mid!,
        'lastMessage': msg.body!,
      });
    }
  }

  Future<ChatMessageModel> sendCustomMessage(
      String from, String to, String body, String customText,
      {String pk = '', int now = 0}) async {
    /* Отправка сообщения с использованием медиа файлов
    */
    return await sendMessage(from, to, body,
        pk: pk, now: now, customText: customText);
  }

  Future<ChatMessageModel> sendMessage(String from, String to, String body,
      {String pk = '',
      int now = 0,
      String customText = '',
      bool isResend = false}) async {
    if (JabberManager.isConference(to)) {
      Log.d(tag, 'sendMessage ERROR: $to IS conference');
      return ChatMessageModel();
    }
    if (now == 0) {
      now = DateTime.now().millisecondsSinceEpoch;
    }
    if (pk.isEmpty) {
      pk = const Uuid().v4();
    }
    String myJid = toJid(from);
    String friendJid = toJid(to);
    ChatMessageModel msg = ChatMessageModel(
      mid: pk,
      from: myJid,
      to: friendJid,
      senderJid: myJid,
      time: now,
      type: 'Message',
      body: body,
      msgtype: 'chat',
      isReadSent: ChatMessageIsReadSent.isNew.index,
    );
    if (customText.isNotEmpty) {
      // Media cообщение
      msg.customText = customText;
      await sendMessage2Db(msg, isResend: isResend);
      await flutterXmpp?.sendCustomMessage(
          msg.to!, msg.body!, msg.mid!, msg.customText!, msg.time!);
    } else {
      await sendMessage2Db(msg, isResend: isResend);
      await flutterXmpp?.sendMessage(msg.to!, msg.body!, msg.mid!, msg.time!);
    }
    return msg;
  }

  Future<void> sendMessage2Db(ChatMessageModel msg,
      {bool isResend = false}) async {
    if (isResend) {
      print('it is resend ${msg.toString()}');
      return;
    }
    int pk = await msg.insert2Db();
    await PendingMessageModel(
            id: pk, time: DateTime.now().millisecondsSinceEpoch, uid: msg.mid)
        .insert2Db();
    await afterSendMessage(msg); // Обновляем ростер
  }

  Future<ChatMessageModel> sendCustomGroupMessage(
      String from, String to, String body, String customText,
      {String pk = '', int now = 0}) async {
    return await sendGroupMessage(from, to, body,
        pk: pk, now: now, customText: customText);
  }

  Future<ChatMessageModel> sendGroupMessage(String from, String to, String body,
      {String pk = '',
      int now = 0,
      String customText = '',
      bool isResend = false}) async {
    if (!JabberManager.isConference(to)) {
      Log.d(tag, 'sendGroupMessage ERROR: $to is NOT conference');
      return ChatMessageModel();
    }
    if (now == 0) {
      now = DateTime.now().millisecondsSinceEpoch;
    }
    if (pk.isEmpty) {
      pk = const Uuid().v4();
    }

    String myJid = toJid(from);
    String friendJid = to;
    ChatMessageModel msg = ChatMessageModel(
      mid: pk,
      from: myJid,
      to: friendJid,
      senderJid: myJid,
      time: now,
      type: 'Message',
      body: body,
      msgtype: 'groupchat',
      isReadSent: ChatMessageIsReadSent.isNew.index,
    );
    if (customText.isNotEmpty) {
      // Media cообщение
      msg.customText = customText;
      await sendMessage2Db(msg, isResend: isResend);
      await flutterXmpp?.sendCustomGroupMessage(
          msg.to!, msg.body!, msg.mid!, msg.customText!, msg.time!);
    } else {
      await sendMessage2Db(msg, isResend: isResend);
      await flutterXmpp?.sendGroupMessage(
          msg.to!, msg.body!, msg.mid!, msg.time!);
    }
    return msg;
  }

  Future<void> requestMamMessages(String userJid,
      {String since = '',
      String before = '',
      int limit = 10,
      bool lastFlag = false}) async {
    /* Получение сообщений из МАМ,
       int now = DateTime.now().millisecondsSinceEpoch;
       :param userJid: пользователь с доменом, например, '${cleanPhone(phone)}@$JABBER_SERVER';
       :param since: с какого момента запрашиваем, например, now - 60 * 60 * 12 * 1000 * 300;
       :param before: по какой момент запрашиваем, например, now + 60 * 60 * 12 * 1000 * 300;
       :param limit: по сколько запрашиваем
       :param lastFlag: получить последние сообщения
    */
    if (!registered) {
      return;
    }
    await flutterXmpp?.requestMamMessages(
        userJid, since, before, limit.toString(), lastFlag);
  }

  Future<Map<String, Map<String, String>>> getPrivateStorage(
      String category, String name) async {
    Map<String, Map<String, String>> result = {};
    Map<Object?, Object?> privateStorage =
        await flutterXmpp?.getPrivateStorage(category, name) ?? {};
    for (Object? key in privateStorage.keys) {
      String curKey = key as String;
      result[curKey] = {};
      Map<Object?, Object?> subItem =
          privateStorage[key] as Map<Object?, Object?>;
      for (Object? subKey in subItem.keys) {
        String curSubKey = subKey as String;
        result[curKey]![curSubKey] = subItem[subKey] as String;
      }
    }
    return result;
  }

  Future<void> setPrivateStorage(
      String category, String name, Map<String, String> dict) async {
    /* Заменяет все ключи в личном хранилище */
    await flutterXmpp?.setPrivateStorage(category, name, dict);
  }

  Future<bool> setLastReadMessageForVCard(
    String category,
    String name,
    Map<String, String> dict,
  ) async {
    /* Обновление последних прочитанных сообщений в vcard */
    bool needUpdate = false;
    Map<String, dynamic> vcardDescObj = await getVCardDescAsDict();
    for (String key in dict.keys) {
      String newValue = dict[key] ?? '';
      String prevValue = vcardDescObj[key] ?? '';
      if (prevValue != newValue) {
        needUpdate = true;
        vcardDescObj[key] = newValue;
      }
    }
    if (needUpdate) {
      JabberManager.myVCard['DESC'] = jsonEncode(vcardDescObj);
      await saveMyVCard();
    }
    return needUpdate;
  }

  Future<bool> updatePrivateStorage(
      String category, String name, Map<String, String> dict,
      {bool force = false}) async {
    /* Обновляет ключи в личном хранилище (force=true - в обязательном порядке) */
    bool needUpdate = false;

    if (unreadMessages.isEmpty) {
      await getUnreadMessages();
    }

    Map<String, dynamic> vcardDescObj = await getVCardDescAsDict();
    for (String key in dict.keys) {
      String newValue = dict[key] ?? '';
      String prevValue = unreadMessages[key] ?? '';
      if (prevValue != newValue) {
        unreadMessages[key] = newValue;
        needUpdate = true;
        vcardDescObj[key] = newValue;
      }
    }
    if (needUpdate || force) {
      await flutterXmpp?.setPrivateStorage(category, name, unreadMessages);
      // Сохраняем VCard
      JabberManager.myVCard['DESC'] = jsonEncode(vcardDescObj);
      await saveMyVCard();
    } else {
      Log.d(tag, 'updatePrivateStorage is not neccessary');
    }
    return needUpdate;
  }

  Future<void> getUnreadMessages() async {
    /* Получение непрочитанных сообщений (таймингов) из личного хранилища
      (TODO: проверить, что в ростере обновляется lastMessageReadTime)
    */
    String category = 'unread_messages';
    String name = 'lastReadMessageTime';
    Map<String, Map<String, String>> storage =
        await getPrivateStorage(category, name);
    if (storage['$category:$name'] != null) {
      unreadMessages = storage['$category:$name']!;
    }
    Log.d(tag, 'Storage unreadMessages: $unreadMessages');
  }

  Future<void> sendDeliveryReceipt(
      String toJid, String msgId, String receiptID) async {
    await flutterXmpp?.sendDelieveryReceipt(toJid, msgId, receiptID);
  }

  static Future<void> updateChatsWithCompanyNames() async {
    // Обновление ростера по загруженным компаниям
    if (JabberManager.user == null) {
      return;
    }
    String jid = JabberManager.user!.jid ?? '';
    List<RosterModel> roster = await RosterModel().getByOwner(jid);
    for (int i = 0; i < roster.length; i++) {
      RosterModel item = roster[i];
      String itemJid = item.jid!;
      Orgs? org = await Orgs().getOrgByChat(cleanPhone(itemJid));
      if (org != null && org.name != null && org.name != '') {
        item.name = org.name;
        await item.updatePartial(item.id, {
          'name': org.name,
        });
        await UserSettingsModel().updateRosterVersion();
      }
    }
  }

}
