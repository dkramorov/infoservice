import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:infoservice/db/settings_db.dart';
import 'package:infoservice/models/bg_tasks_model.dart';
import 'package:infoservice/models/user_settings_model.dart';
import 'package:infoservice/services/shared_preferences_manager.dart';
import 'package:infoservice/services/update_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../a_notifications/notifications.dart';
import '../helpers/log.dart';
import '../helpers/network.dart';
import '../helpers/phone_mask.dart';
import '../models/chat_message_model.dart';
import '../models/contact_model.dart';
import '../models/roster_model.dart';
import '../settings.dart';
import 'contacts_manager.dart';
import 'jabber_manager.dart';

Future<FlutterBackgroundService> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      foregroundServiceNotificationId: 999,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  service.startService();
  return service;
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  const String tag = 'BG_MANAGER';
  const int stopServiceAfterPausedSec = 20;
  Timer? lifecycleTimer;
  //DartPluginRegistrant.ensureInitialized(); =>
  /* flutter_background_service_android` threw an error: Exception:
     This class should only be used in the main isolate (UI App).
     The app may not function as expected until you remove this plugin from pubspec.yaml
  */

  Future<void> stopXMPP() async {
    await JabberManager().stop();
    await JabberManager.flutterXmpp?.stop();
    await JabberManager.flutterXmpp?.potestua();
    JabberManager().setStopFlag(true); // DEPRECATED?
    JabberManager().stopMainTimer = true;
    //JabberManager().dispose();
    JabberManager().connectionStatus = 'Disconnected';
  }

  // BackgroundService.java шлет нотификации updateNotificationInfo
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
      print('--- service setAsForeground ---');
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      print('--- service setAsBackground ---');
    });
  }

  cancelLifecycleTimer() {
    if (lifecycleTimer != null) {
      lifecycleTimer?.cancel();
      lifecycleTimer = null;
    }
  }

  service.on('lifecycleResumed').listen((event) async {
    JabberManager.appState = AppLifecycleState.resumed;
    cancelLifecycleTimer();
    await JabberManager().init();
  });

  service.on('lifecyclePaused').listen((event) async {
    // Если сервис в паузе больше stopServiceAfterPausedSec секунд, прекращаем суету
    JabberManager.appState = AppLifecycleState.paused;
    cancelLifecycleTimer();
    Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      lifecycleTimer = t;
      if (JabberManager.appState == AppLifecycleState.resumed) {
        cancelLifecycleTimer();
        print('Stoping lifecycle timer because app is resumed');
      }
      if (t.tick > stopServiceAfterPausedSec) {
        cancelLifecycleTimer();
        print('+++ Stopping xmpp after paused time ${t.tick} +++');
        await stopXMPP();
      }
    });
  });

  service.on('stopService').listen((event) async {
    await stopXMPP();
    await service.stopSelf();
    print('--- service stopService ---');
  });

  // Принудительное удаление пользователя (тест)
  // await UserSettingsModel().dropAllRows();

  Future.delayed(Duration.zero, () async {
    try {
      // Предварительно удаляем при старте сервиса все задачи
      //await BGTasksModel().dropAllRows();

      // Сбрасываем для пользователя статус
      UserSettingsModel? user = await UserSettingsModel().getUser();
      if (user != null) {
        await user.updatePartial(user.id, {'isXmppRegistered': 0});
      }
    } catch (ex, stack) {
      Log.e(tag, stack.toString());
      Log.e(tag, ex.toString());
    }

    await JabberManager().init();
    await AppMetrica.activate(const AppMetricaConfig(YANDEX_METRIKA_KEY));
  });

  Future.delayed(Duration.zero, () async {
    UpdateManager updateManager = UpdateManager();
    updateManager.init();
  });

  Timer.periodic(const Duration(seconds: 1), (Timer t) async {
    if (BGTasksModel.bgTimerTaskRunning) {
      Log.d(tag, 'previous task still running ${BGTasksModel.prev.toString()}');
      if (BGTasksModel.prev == null) {
        BGTasksModel.bgTimerTaskRunning = false;
      }
    } else {
      try {
        await backgroundJob();
      } catch (ex, stacktrace) {
        Log.d(tag, '[EXCEPTION]: ${ex.toString()}');
        Log.d(tag, stacktrace.toString());
      }
    }
  });
}

Future<void> backgroundJob() async {
  const String tag = 'backgroundJob';

  // Без интернет-соединения смысла выполнять задачу нет
  SharedPreferences prefs =
      await SharedPreferencesManager.getSharedPreferences();
  bool? hasInternet = prefs.getBool('checkInternetConnection');
  if (hasInternet == null || !hasInternet) {
    Log.d(tag, 'do nothing, because internet absent');
    return;
  }

  BGTasksModel.bgTimerTaskRunning = true;
  BGTasksModel.counter += 1;
  //Log.d(tag, 'counter ${BGTasksModel.counter}');
  BGTasksModel? newTask = await BGTasksModel().getTask();
  if (newTask != null) {
    if (newTask.priority != BGTasksModel.authPriority) {
      // Без пользователя смысла выполнять такую задачу нет
      UserSettingsModel? user = await UserSettingsModel().getUser();
      if (user == null || user.isXmppRegistered == 0) {
        Log.d(tag, 'do nothing, because user not connected');
        return;
      }
    }

    BGTasksModel.prev = newTask;
    try {
      await runTaskHelper(newTask);
    } catch (e, stack) {
      Log.e(tag, stack.toString());
      Log.e(tag, e.toString());
    }
    await newTask.delete2Db();
  }
  BGTasksModel.prev = null;
  BGTasksModel.bgTimerTaskRunning = false;
}

Future<void> runTaskHelper(BGTasksModel newTask) async {
  const String tag = 'BG_MANAGER runTaskHelper';
  Log.d(tag, 'new task ${newTask.toMap()}');
  switch (newTask.name) {
    case BGTasksModel.loginUserTaskKey:
      await JabberManager().doRegister();
      break;
    case BGTasksModel.registerUserTaskKey:
      /* Задача на регистрацию пользователя
           работу выполнит таймер в JabberManager
           здесь создаем пользователя (jid, credentialsHash)
           и обрабатывам FCM токен
      */
      Map<String, dynamic> userData = newTask.getJsonData();
      await UserSettingsModel().dropAllRows();
      UserSettingsModel newUser = UserSettingsModel(
        phone: cleanPhone(userData['login']),
        passwd: userData['passwd'],
      );
      await newUser.getCredentialsHash();
      newUser.jid = '${newUser.phone}@$JABBER_SERVER';
      await newUser.insert2Db();
      String token = JabberManager.fcmToken;
      UserSettingsModel.updateToken(token);
      await JabberManager().doRegister();
      await BGTasksModel.createCheckRegTask();
      break;

    case BGTasksModel.unregisterUserTaskKey:
      /* Задача на выход пользователя
         все херим кыбеням
      */
      await UserSettingsModel().dropAllRows();
      await RosterModel().dropAllRows();
      await ChatMessageModel().dropAllRows();
      await ContactModel().dropAllRows();
      JabberManager().setStopFlag(true);
      // На йосе здесь await не вернет результат (видимо слушателя надо проверить)
      JabberManager().stop();
      Log.d(tag, '--- JabberManager stopped');
      await BGTasksModel.createCheckRegTask();
      Log.d(tag, '--- Reg task created');
      Log.d(tag, '--- Reg task created');
      break;

    case BGTasksModel.checkRegUserTaskKey:
      /* Задача на проверку авторизации пользователя
      */
      await JabberManager().showConnectionStatus();
      break;

    case BGTasksModel.loadRosterTaskKey:
      /* Задача на получение ростера пользователя
      */
      await JabberManager().getRoster();
      break;

    case BGTasksModel.getContactsFromPhoneTaskKey:
      /* Задача на получение контактов с телефона
      */
      await ContactsManager.refreshContactsHelper();
      break;

    case BGTasksModel.dropRosterTaskKey:
      /* Задача на удаление из ростера
      */
      Map<String, dynamic> data = newTask.getJsonData();
      RosterModel? rosterModel = await RosterModel().getById(data['id']);
      if (rosterModel == null) {
        Log.e(tag, 'ERROR drop roster: id not found for $data');
        return;
      }
      if (rosterModel.isGroup == 1) {
        await JabberManager().dropMyGroup(rosterModel);
      } else {
        await JabberManager().dropMyRoster(rosterModel);
      }
      break;

    case BGTasksModel.addRosterTaskKey:
      /* Задача на добавление в ростер
      */
      Map<String, dynamic> data = newTask.getJsonData();
      String login = data['login'];

      SharedPreferences prefs =
          await SharedPreferencesManager.getSharedPreferences();

      List<dynamic>? users = await JabberManager().searchUsers(login);
      if (users != null) {
        List<String> result = [];
        bool founded = false;
        for (String user in users) {
          // С ростера может приходить [yandex_zergo01@chat.masterme.ru]
          String curUser = cleanPhone(user).split('@')[0].replaceAll('[', '');
          result.add(curUser);
          if (curUser == login) {
            founded = true;
            break;
          } else {
            Log.d(tag, 'search for add2roster, not equal $curUser=$login');
          }
        }
        Log.d(tag, 'founded=$founded, by login: $login, with result: $result');
        if (founded) {
          await JabberManager().addMyRoster(login);
          await prefs.setBool(BGTasksModel.addRosterPrefKey, true);
        } else {
          await prefs.setBool(BGTasksModel.addRosterPrefKey, false);
        }
      } else {
        await prefs.setBool(BGTasksModel.addRosterPrefKey, false);
      }
      break;

    case BGTasksModel.addMUCTaskKey:
      /* Задача на добавление в ростер MUC
      */
      Map<String, dynamic> data = newTask.getJsonData();
      String group = data['group'];

      SharedPreferences prefs =
          await SharedPreferencesManager.getSharedPreferences();
      await JabberManager().createMUC(group, true);
      await JabberManager().joinMucGroup(group);
      await JabberManager().addGroup2VCard(group);

      await prefs.setBool(BGTasksModel.addRosterPrefKey, true);
      break;

    case BGTasksModel.sendTextMessageTaskKey:
      /* Задача на отправку текстового сообщения
      */
      Map<String, dynamic> data = newTask.getJsonData();
      String text = data['text'];
      String toJid = data['to'];
      int now = data['now'];
      String pk = data['pk'];
      String fromJid = data['from'];
      if (text == '' || now == 0 || toJid == '' || pk == '' || fromJid == '') {
        Log.e(tag, 'sendTextMessageTask bad data: ${data.toString}');
        break;
      }

      String mediaType = data['mediaType'] ?? '';
      if (mediaType == 'question' || mediaType == 'answer') {
        Map<String, dynamic> customText = {
          'type': mediaType,
        };
        if (data['answer'] != null) {
          customText['answer'] = data['answer'];
        }
        await JabberManager().sendCustomMessage(
          fromJid,
          toJid,
          mediaType,
          jsonEncode(customText),
          now: now,
          pk: pk,
        );
      } else {
        await JabberManager().sendMessage(
          fromJid,
          toJid,
          text,
          now: now,
          pk: pk,
        );
      }
      if (JabberManager.user != null &&
          JabberManager.user!.credentialsHash != null) {
        await sendPush(
          JabberManager.user!.credentialsHash!,
          fromJid,
          toJid,
          onlyData: false,
          text: text,
        );
      }
      break;

    case BGTasksModel.sendDeliveryReceiptTaskKey:
      /* Задача на рецепт прочтения на отправителя
      */
      Map<String, dynamic> data = newTask.getJsonData();
      String friendJid = data['jid'];
      String lastMessageId = data['lastMessageId'];
      await JabberManager()
          .sendDeliveryReceipt(friendJid, lastMessageId, lastMessageId);
      break;

    case BGTasksModel.sendFileMessageTaskKey:
      /* Задача на отправку медиа сообщения
      */
      Map<String, dynamic> data = newTask.getJsonData();
      String toJid = data['to'];
      int now = data['now'];
      String pk = data['pk'];
      String fromJid = data['from'];
      int filesize = data['filesize'];
      String path = data['path'];
      String msgType = data['msgType'];
      String mediaType = data['mediaType'] ?? '';
      if (mediaType == '' ||
          filesize == 0 ||
          path == '' ||
          now == 0 ||
          toJid == '' ||
          pk == '' ||
          fromJid == '') {
        Log.e(tag, 'sendFileMessageTaskKey bad data: ${data.toString}');
        break;
      }
      File file = File(path);
      String fname = file.path.split('/').last;
      String? putUrl =
          await JabberManager.flutterXmpp?.requestSlot(fname, filesize);
      Log.i(tag, 'putUrl is "$putUrl"');
      /* TODO: повторный запрос слота или маркировка сообщения битым
      */
      if (putUrl != null && putUrl != '') {
        Map<String, dynamic> response = await requestPutFile(putUrl, file);
        if (response['statusCode'] == 201) {
          Log.i(tag, 'upload success $putUrl');
          Map<String, String> customText = {
            'type': mediaType,
            'url': putUrl,
            'path': file.path,
          };
          await JabberManager().sendCustomMessage(
              fromJid, toJid, mediaType, jsonEncode(customText),
              now: now, pk: pk);
          if (JabberManager.user != null &&
              JabberManager.user!.credentialsHash != null) {
            await sendPush(JabberManager.user!.credentialsHash!, fromJid, toJid,
                onlyData: false, text: msgType);
          }
        }
      }
      break;

    case BGTasksModel.sendTextGroupMessageTaskKey:
      /* Задача на отправку MUCтекстового сообщения
      */
      Map<String, dynamic> data = newTask.getJsonData();
      String text = data['text'];
      String toJid = data['to'];
      int now = data['now'];
      String pk = data['pk'];
      String fromJid = data['from'];
      if (text == '' || now == 0 || toJid == '' || pk == '' || fromJid == '') {
        Log.e(tag, 'sendTextMessageTask bad data: ${data.toString}');
        break;
      }
      await JabberManager()
          .sendGroupMessage(fromJid, toJid, text, now: now, pk: pk);
      if (JabberManager.user != null &&
          JabberManager.user!.credentialsHash != null) {
        sendGroupPush(JabberManager.user!.credentialsHash!, fromJid, toJid,
            onlyData: false, text: text);
      }
      break;

    case BGTasksModel.sendFileGroupMessageTaskKey:
      /* Задача на отправку медиа сообщения
      */
      Map<String, dynamic> data = newTask.getJsonData();
      String toJid = data['to'];
      int now = data['now'];
      String pk = data['pk'];
      String fromJid = data['from'];
      int filesize = data['filesize'];
      String path = data['path'];
      String msgType = data['msgType'];
      String mediaType = data['mediaType'] ?? '';
      if (mediaType == '' ||
          filesize == 0 ||
          path == '' ||
          now == 0 ||
          toJid == '' ||
          pk == '' ||
          fromJid == '') {
        Log.e(tag, 'sendFileMessageTaskKey bad data: ${data.toString}');
        break;
      }
      File file = File(path);
      String fname = file.path.split('/').last;
      String? putUrl =
          await JabberManager.flutterXmpp?.requestSlot(fname, filesize);

      if (putUrl != null && putUrl != '') {
        Map<String, dynamic> response = await requestPutFile(putUrl, file);
        if (response['statusCode'] == 201) {
          Log.i(tag, 'upload success $putUrl');
          Map<String, String> customText = {
            'type': mediaType,
            'url': putUrl,
          };
          await JabberManager().sendCustomGroupMessage(
              fromJid, toJid, mediaType, jsonEncode(customText),
              now: now, pk: pk);
          if (JabberManager.user != null &&
              JabberManager.user!.credentialsHash != null) {
            await sendGroupPush(
                JabberManager.user!.credentialsHash!, fromJid, toJid,
                onlyData: false, text: msgType);
          }
        }
      } else {
        // Пишем сообщение в базу
        ChatMessageModel msg = ChatMessageModel(
          mid: pk,
          from: fromJid,
          to: toJid,
          senderJid: fromJid,
          time: now,
          type: 'Message',
          body: mediaType,
          msgtype: 'groupchat',
          isReadSent: ChatMessageIsReadSent.isNew.index,
        );
        Map<String, String> customText = {
          'type': mediaType,
          'url': '',
          'path': file.path,
        };
        msg.customText = jsonEncode(customText);
        await JabberManager.sendMessage2Db(msg, isResend: false);
      }
      break;

    case BGTasksModel.checkMeInGroupVCardTaskKey:
      /* Задача на добавляения себя в VCard группы для пушей
      */
      Map<String, dynamic> data = newTask.getJsonData();
      String groupJid = data['groupJid'];
      if (JabberManager.user != null &&
          JabberManager.user!.credentialsHash != null) {
        String phone = JabberManager.user?.phone ?? '-';
        Map<String, dynamic> descObj =
            await JabberManager().getVCardDescAsDict(jid: groupJid);
        String key = 'chat_$phone';
        if (descObj['users'] == null ||
            !(descObj['users'] as List<dynamic>).contains(phone)) {
          Log.d(tag, '$key not in groupVCard DESC: $descObj');
          await pushMe2GroupVCard(
              phone, JabberManager.user!.credentialsHash ?? '', groupJid);
        }
      }
      break;

    case BGTasksModel.updateMyVCardTaskKey:
      /* Обновление VCard
      */
      Map<String, dynamic> data = newTask.getJsonData();
      Map<String, dynamic> descObj = await JabberManager().getVCardDescAsDict();
      if (data['FN'] != null && data['FN'] != '') {
        descObj['FN'] = data['FN'];
      }
      if (data['BDAY'] != null && data['BDAY'] != '') {
        descObj['BDAY'] = data['BDAY'];
      }
      if (data['EMAIL'] != null && data['EMAIL'] != '') {
        descObj['EMAIL'] = data['EMAIL'];
      }
      if (data['GENDER'] != null && data['GENDER'] != '') {
        descObj['GENDER'] = data['GENDER'];
      }
      // Сохраняем фото
      // TODO: проверка подключения (т/к фотку могут выбирать долго) - pending
      if (data['PHOTO'] != null && data['PHOTO'] != '') {
        descObj['PHOTO'] = data['PHOTO'];
        File file = File(descObj['PHOTO']);
        String fname = file.path.split('/').last;
        int filesize = await file.length();
        String? putUrl =
            await JabberManager.flutterXmpp?.requestSlot(fname, filesize);
        Log.i(tag, 'putUrl is "$putUrl"');
        if (putUrl != null && putUrl != '') {
          Map<String, dynamic> response = await requestPutFile(putUrl, file);
          if (response['statusCode'] == 201) {
            Log.i(tag, 'upload success $putUrl');
            descObj['PHOTO'] = putUrl;
          }
        }
      }
      // Сохраняем VCard
      JabberManager.myVCard['DESC'] = jsonEncode(descObj);
      await JabberManager().saveMyVCard();

      break;

    default:
      break;
  }
}
