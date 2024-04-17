import 'dart:ui';
import 'dart:io' show Platform;
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:infoservice/models/user_settings_model.dart';
import 'package:infoservice/pages/authorization.dart';
import 'package:infoservice/pages/chat/add2roster.dart';
import 'package:infoservice/pages/chat/chat_page.dart';
import 'package:infoservice/pages/chat/group_chat_page.dart';
import 'package:infoservice/pages/companies/companies_listing_screen.dart';
import 'package:infoservice/pages/companies/company_wizard_screen.dart';
import 'package:infoservice/pages/default_page.dart';
import 'package:infoservice/pages/new_pages/components/new_main.dart';
import 'package:infoservice/pages/register/reg_wizard_screen.dart';
import 'package:infoservice/services/bg_manager.dart';
import 'package:infoservice/services/jabber_manager.dart';
import 'package:infoservice/services/navigation_manager.dart';
import 'package:infoservice/services/sip_ua_manager.dart';
import 'package:infoservice/settings.dart';
import 'package:infoservice/sip_ua/callscreen.dart';
import 'package:infoservice/sip_ua/dialpadscreen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';

import 'a_notifications/notifications.dart';
import 'helpers/phone_mask.dart';
import 'notification_services/firebase_options.dart';

final navigatorKey = NavigationManager.instance.navigationKey;
late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool isFlutterLocalNotificationsInitialized = false;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // https://developer.huawei.com/consumer/en/doc/HMSCore-References/topic-sub-api-0000001051066122
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupFlutterNotifications();
  print("Handling a background message: ${message.data.toString()}");
  final String action = message.data['action'];
  if (action == 'call') {
    //AwesomeNotifications().createNotificationFromJsonData(message.data);

    String displayName = phoneMaskHelper(message.data['sender']);
    if (message.data['displayName'] != null && message.data['displayName'] != '') {
      displayName = message.data['displayName']!;
    }
    showCallkitIncoming(const Uuid().v4(), from: displayName);
    print('----------------------------------------');
    print('_firebaseMessagingBackgroundHandler CALL');
    print('----------------------------------------');
  }
  // Не вызываем своё уведомление
  //await generateChatNotification(message.data);
}

Future<void> generateChatNotification(Map<String, dynamic> data) async {
  final String? action = data['action'];
  if (action != null && action == 'chat') {
    createChatNotification({
      'receiver': data['receiver'] ?? '',
      'sender': data['sender'] ?? '',
      'action': action,
      'body': data['body'] ?? '',
      'displayName': data['displayName'] ?? '',
      'group': data['group'] ?? '',
    });
  } else {
    print('generateChatNotification FAILED: Bad data=$data');
  }
}

Future<void> showCallkitIncoming(String uuid, {String? from}) async {
  /*
  var params = <String, dynamic>{
    'id': uuid,
    'nameCaller': from,
    'appName': '8800 help',
    'avatar': 'https://i.pravatar.cc/100',
    'handle': 'Бесплатный sip звонок',
    // 0 - Audio Call, 1 - Video Call
    'type': 0, // callUpdate.hasVideo = data.type > 0 ? true : false
    'duration': 30000,
    'textAccept': 'Ответить',
    'textDecline': 'Отклонить',
    'textMissedCall': 'Пропущенный вызов',
    'textCallback': 'Перезвонить',
    'extra': <String, dynamic>{'userId': '1a2b3c4d'},
    'headers': <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    'android': <String, dynamic>{
      'isCustomNotification': true,
      'isShowLogo': false,
      'isShowCallback': false,
      'ringtonePath': 'system_ringtone_default',
      'backgroundColor': '#0955fa',
      'background': 'https://i.pravatar.cc/500',
      'actionColor': '#4CAF50'
    },
    'ios': <String, dynamic>{
      'iconName': 'CallKitLogo',
      'handleType': '',
      'supportsVideo': false,
      'maximumCallGroups': 2,
      'maximumCallsPerCallGroup': 1,
      'audioSessionMode': 'default',
      'audioSessionActive': true,
      'audioSessionPreferredSampleRate': 44100.0,
      'audioSessionPreferredIOBufferDuration': 0.005,
      'supportsDTMF': true,
      'supportsHolding': true,
      'supportsGrouping': false,
      'supportsUngrouping': false,
      'ringtonePath': 'system_ringtone_default'
    }
  };
  */
  CallKitParams params = CallKitParams(
      id: uuid,
      nameCaller: from,
      appName: '8800 help',
      avatar: 'https://i.pravatar.cc/100',
      handle: 'Бесплатный sip звонок',
      // 0 - Audio Call, 1 - Video Call
      type: 0, // callUpdate.hasVideo = data.type > 0 ? true : false
      duration: 30000,
      textAccept: 'Ответить',
      textDecline: 'Отклонить',
      // these do not exist for some reason. have to dive into this later
      // textMissedCall: 'Пропущенный вызов',
      // textCallback: 'Перезвонить',
      extra: <String, dynamic>{'userId': '1a2b3c4d'},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          // isShowCallback: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          backgroundUrl: 'https://i.pravatar.cc/500',
          actionColor: '#4CAF50'),
      ios: const IOSParams(
          iconName: 'CallKitLogo',
          handleType: '',
          supportsVideo: false,
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
          ringtonePath: 'system_ringtone_default'));
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

typedef PageContentBuilder = Widget Function(
    [SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  AwesomeNotifications().initialize(
    'resource://drawable/res_notification_app_icon',
    [
      NotificationChannel(
        //channelGroupKey: 'normal_channel_group',
        channelKey: 'normal_channel',
        channelName: 'Normal Notifications',
        channelDescription: 'Notifications for chat',
        defaultColor: tealColor,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        //locked: true,
        defaultPrivacy: NotificationPrivacy.Public,
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'basic_channel_group',
        channelGroupName: 'Basic group',
      )
    ],
  );
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((firebaseApp) async {

    if (Platform.isIOS) {
      FirebaseMessaging.instance.getAPNSToken().then((apnsToken) async {
        print('FirebaseMessaging APNS token: $apnsToken');
        if (apnsToken != null) {
          JabberManager.apnsToken = apnsToken;
          SIPUAManager.apnsToken = apnsToken;
        }
        FlutterCallkitIncoming.getDevicePushTokenVoIP().then((
            devicePushTokenVoIP) {
          print('getDevicePushTokenVoIP() => ${devicePushTokenVoIP}');
        });
      });
    }

    // creating local notifications
    await setupFlutterNotifications();

    FirebaseMessaging.instance.getToken().then((fcmToken) async {
      print('FirebaseMessaging token: $fcmToken');
      if (fcmToken != null) {
        JabberManager.fcmToken = fcmToken;
        SIPUAManager.fcmToken = fcmToken;
        await UserSettingsModel.updateToken(fcmToken);
        final _ = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      } else {
        String err = 'token not received for ${Platform.operatingSystem}';
        err += ' ${Platform.operatingSystemVersion}';
        print(err);
        //await TelegramBot().sendNotify(err);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('FirebaseMessaging onMessageOpenedApp!');
      print('Message data: ${message.data}');
      //generateChatNotification(message.data);
      if (message.data['action'] == 'chat') {
        String sender = message.data['sender'] ?? '';
        String phone = cleanPhone(sender);
        String jid = JabberManager().toJid(sender);
        String name = phoneMaskHelper(sender);
        String screenId = ChatScreen.id;
        String group = message.data['group'] ?? '';
        if (group != '') {
          screenId = GroupChatScreen.id;
          sender = group;
          phone = group;
          jid = group;
          name = group.split('@')[0];
        }

        print(NavigationManager.instance.navigationKey.currentContext);
        if (NavigationManager.instance.navigationKey.currentContext != null) {
          BuildContext ctx = NavigationManager.instance.navigationKey.currentContext!;
          const SIPUAManager? sipHelper = null;
          const JabberManager? xmppHelper = null;
          Navigator.popUntil(ctx, (route) => (route.isFirst));
          Navigator.pushNamed(ctx, screenId, arguments: {
            sipHelper,
            xmppHelper,
            ChatUser(
              id: phone,
              jid: jid,
              phone: sender,
              name: name,
              customProperties: {'fromPush': true},
            ),
          });
        }
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('FirebaseMessaging onMessage! Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
      generateChatNotification(message.data);
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      print('FirebaseMessaging token: $fcmToken');
      JabberManager.fcmToken = fcmToken;
      SIPUAManager.fcmToken = fcmToken;
      await UserSettingsModel.updateToken(fcmToken);
      //await TelegramBot().sendNotify('token received: $fcmToken');
    }).onError((err) {
      print('FirebaseMessaging error: $err');
    });
  });

  final FlutterBackgroundService service = await initializeService();
  FlutterAppBadger.removeBadge();

  if (SENTRY_ENABLED) {
    await SentryFlutter.init(
          (options) {
        options.dsn =
        'https://b2bc3c3c4bbd66293a359ff209559d41@o228487.ingest.sentry.io/4505793208254464';
        options.tracesSampleRate = 1.0;
      },
      appRunner: () => runApp(MyApp(service: service)),
    );
  } else {
    runApp(MyApp(service: service));
  }
}

class MyApp extends StatefulWidget {
  final FlutterBackgroundService? service;

  const MyApp({
    Key? key,
    this.service,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final SIPUAManager _sipHelper = SIPUAManager();
  //final JabberManager _xmppHelper = JabberManager();
  //final SIPUAManager? _sipHelper = null;
  final JabberManager? _xmppHelper = null;

  final Map<String, PageContentBuilder> routes = {
    DefaultPage.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        DefaultPage(sipHelper, xmppHelper),
    AuthScreenWidget.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        AuthScreenWidget(sipHelper, xmppHelper),
    RegWizardScreenWidget.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        RegWizardScreenWidget(sipHelper, xmppHelper),
    Add2RosterScreen.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        Add2RosterScreen(sipHelper, xmppHelper),
    ChatScreen.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        ChatScreen(sipHelper, xmppHelper, arguments),
    GroupChatScreen.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        GroupChatScreen(sipHelper, xmppHelper, arguments),
    CompaniesListingScreen.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        CompaniesListingScreen(sipHelper, xmppHelper, arguments),
    CompanyWizardScreen.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        CompanyWizardScreen(sipHelper, xmppHelper, arguments),
    DialpadScreen.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        DialpadScreen(sipHelper, xmppHelper, arguments),
    CallScreenWidget.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        CallScreenWidget(sipHelper, xmppHelper, arguments),

    // Новые странички
    NewMainPage.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        NewMainPage(sipHelper, xmppHelper, arguments),
  };

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final PageContentBuilder? pageContentBuilder = routes[name!];
    if (pageContentBuilder != null) {
      if (settings.arguments != null) {
        final Route route = MaterialPageRoute<Widget>(
            builder: (context) =>
                pageContentBuilder(_sipHelper, _xmppHelper, settings.arguments));
        return route;
      }
      final Route route = MaterialPageRoute<Widget>(
          builder: (context) => pageContentBuilder(_sipHelper, _xmppHelper));
      return route;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    JabberManager.appState = state;
    SIPUAListener.appState = state;
    switch (state) {
      case AppLifecycleState.detached:
        print('-----> detached');
        widget.service?.invoke('stopService');
        break;
      case AppLifecycleState.inactive:
        print('-----> inactive');
        break;
      case AppLifecycleState.paused:
        print('-----> paused');
        widget.service?.invoke('lifecyclePaused');
        break;
      case AppLifecycleState.hidden:
        print('-----> hidden');
        break;
      case AppLifecycleState.resumed:
        print('-----> resumed');
        widget.service?.invoke('lifecycleResumed');
        /*
        initializeService().then((success) {
          BGTasksModel.createLoginUserTask();
        });
        */
        break;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '8800.help',
      theme: ThemeData.light().copyWith(
        primaryColor: tealColor,
        textTheme: ThemeData.light().textTheme.copyWith(
          titleLarge: const TextStyle(fontSize: 14.0, fontStyle: FontStyle.normal),
        ),
      ),
      navigatorKey: NavigationManager.instance.navigationKey,
      initialRoute: DefaultPage.id,
      onGenerateRoute: _onGenerateRoute,
      builder: EasyLoading.init(),
    );
  }
}


Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  final notification = message.notification;
  print('notification: ${notification?.toMap()}');
  final android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/notification_icon',
        ),
      ),
    );
  }
}
