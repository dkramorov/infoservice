import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:infoservice/pages/authorization.dart';
import 'package:infoservice/pages/chat/add2roster.dart';
import 'package:infoservice/pages/chat/chat_page.dart';
import 'package:infoservice/pages/companies/companies_listing_screen.dart';
import 'package:infoservice/pages/companies/company_wizard_screen.dart';
import 'package:infoservice/pages/default_page.dart';
import 'package:infoservice/pages/register/reg_wizard_screen.dart';
import 'package:infoservice/services/jabber_manager.dart';
import 'package:infoservice/services/sip_ua_manager.dart';
import 'package:infoservice/settings.dart';
import 'package:infoservice/sip_ua/callscreen.dart';
import 'package:infoservice/sip_ua/dialpadscreen.dart';
import 'package:uuid/uuid.dart';

import 'a_notifications/notifications.dart';
import 'helpers/phone_mask.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.data.toString()}");
  final String action = message.data['action'];
  if (action == 'chat') {
    createChatNotification({
      'receiver': message.data['receiver'],
      'sender': message.data['sender'],
      'action': message.data['action'],
    });
  } else if (action == 'call') {
    //AwesomeNotifications().createNotificationFromJsonData(message.data);
    final String from = phoneMaskHelper(message.data['sender']);
    showCallkitIncoming(const Uuid().v4(), from:from);
  }
}


Future<void> showCallkitIncoming(String uuid, {String? from}) async {
  var params = <String, dynamic>{
    'id': uuid,
    'nameCaller': from,
    'appName': '8800 help',
    'avatar': 'https://i.pravatar.cc/100',
    'handle': 'Бесплатный sip звонок',
    'type': 0,
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
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

typedef PageContentBuilder = Widget Function(
    [SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
    'resource://drawable/res_notification_app_icon',
    [
      NotificationChannel(
        //channelGroupKey: 'normal_channel_group',
        channelKey: 'normal_channel',
        channelName: 'Normal Notifications',
        channelDescription: 'Notifications for chat',
        defaultColor: PRIMARY_COLOR,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        //locked: true,
        defaultPrivacy: NotificationPrivacy.Public,
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupkey: 'basic_channel_group',
        channelGroupName: 'Basic group',
      )
    ],
  );
  Firebase.initializeApp().then((firebaseApp) {
    FirebaseMessaging.instance.getToken().then((fcmToken) async {
      print('FirebaseMessaging token: $fcmToken');
      if (fcmToken != null) {
        JabberManager.fcmToken = fcmToken;
        SIPUAManager.fcmToken = fcmToken;
      }
      //await TelegramBot().sendNotify('token received: $fcmToken');
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      print('FirebaseMessaging token: $fcmToken');
      JabberManager.fcmToken = fcmToken;
      SIPUAManager.fcmToken = fcmToken;
      //await TelegramBot().sendNotify('token received: $fcmToken');
    }).onError((err) {
      print('FirebaseMessaging error: $err');
    });
  });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final SIPUAManager _sipHelper = SIPUAManager();
  final JabberManager _xmppHelper = JabberManager();

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
    CompaniesListingScreen.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        CompaniesListingScreen(sipHelper, xmppHelper, arguments),
    CompanyWizardScreen.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        CompanyWizardScreen(sipHelper, xmppHelper, arguments),
    DialpadScreen.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        DialpadScreen(sipHelper, xmppHelper, arguments),
    CallScreenWidget.id: ([SIPUAManager? sipHelper, JabberManager? xmppHelper, Object? arguments]) =>
        CallScreenWidget(sipHelper, xmppHelper, arguments),
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
        break;
      case AppLifecycleState.inactive:
        print('-----> inactive');
        break;
      case AppLifecycleState.paused:
        print('-----> paused');
        break;
      case AppLifecycleState.resumed:
        print('-----> resumed');
        _xmppHelper.doRegister();
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
        primaryColor: PRIMARY_COLOR,
      ),
      initialRoute: DefaultPage.id,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}