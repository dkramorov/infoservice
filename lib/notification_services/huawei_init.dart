/*
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:huawei_push/huawei_push.dart' as huawei;
import 'package:infoservice/models/user_settings_model.dart';
import 'package:infoservice/notification_services/show_result.dart';
import 'package:infoservice/services/jabber_manager.dart';
import 'package:infoservice/services/sip_ua_manager.dart';

@pragma('vm:entry-point')
void backgroundMessageCallback(huawei.RemoteMessage remoteMessage) async {
  String? data = remoteMessage.data;
  if (data != null) {
    debugPrint(
      'Background message is received, sending local notification.',
    );
    huawei.Push.localNotification(
      <String, String>{
        huawei.HMSLocalNotificationAttr.TITLE:
            '[Headless] DataMessage Received',
        huawei.HMSLocalNotificationAttr.MESSAGE: data,
      },
    );
  } else {
    debugPrint(
      'Background message is received. There is no data in the message.',
    );
  }
}

mixin HuaweiServiceMixin<T extends StatefulWidget> on State<T> {
  // huawei token
  String _token = '';

  Future<void> initHuaweiPlatformState() async {
    if (!mounted) return;
    // If you want auto init enabled, after getting user agreement call this method.
    await huawei.Push.setAutoInitEnabled(true);

    huawei.Push.getTokenStream.listen(
      _onTokenEvent,
      onError: _onTokenError,
    );
    huawei.Push.getIntentStream.listen(
      _onNewIntent,
      onError: _onIntentError,
    );
    huawei.Push.onNotificationOpenedApp.listen(
      _onNotificationOpenedApp,
    );

    final dynamic initialNotification =
        await huawei.Push.getInitialNotification();
    _onNotificationOpenedApp(initialNotification);

    final String? intent = await huawei.Push.getInitialIntent();
    _onNewIntent(intent);

    huawei.Push.onMessageReceivedStream.listen(
      _onMessageReceived,
      onError: _onMessageReceiveError,
    );
    huawei.Push.getRemoteMsgSendStatusStream.listen(
      _onRemoteMessageSendStatus,
      onError: _onRemoteMessageSendError,
    );

    bool backgroundMessageHandler =
        await huawei.Push.registerBackgroundMessageHandler(
      backgroundMessageCallback,
    );
    debugPrint(
      'backgroundMessageHandler registered: $backgroundMessageHandler',
    );
  }

  void removeBackgroundMessageHandler() async {
    await huawei.Push.removeBackgroundMessageHandler();
  }

  void _onTokenEvent(String token) async {
    _token = token;
    showResult('TokenEvent', _token);
    // FCM токен заменить на HMS
    JabberManager.fcmToken = _token;
    SIPUAManager.fcmToken = _token;
    await UserSettingsModel.updateToken(_token);
    print('\x1B[33mJabberManager.fcmToken:${JabberManager.fcmToken}\x1B[0m');
    print('\x1B[33mSIPUAManager.fcmToken:${SIPUAManager.fcmToken}\x1B[0m');
  }

  void _onTokenError(Object error) {
    PlatformException e = error as PlatformException;
    showResult('TokenErrorEvent', e.message!);
  }

  void _onMessageReceived(huawei.RemoteMessage remoteMessage) {
    // Здесь можно провернуть всю ту же логику, что и на Firebase, но нужно подписать пользователя
    String? data = remoteMessage.data;
    print('Message data: ${remoteMessage.data}');
    if (data != null) {
      huawei.Push.localNotification(
        <String, String>{
          huawei.HMSLocalNotificationAttr.TITLE: 'DataMessage Received',
          huawei.HMSLocalNotificationAttr.MESSAGE: data,
        },
      );
      showResult('onMessageReceived', 'Data: $data');
    } else {
      showResult('onMessageReceived', 'No data is present.');
    }
  }

  void _onMessageReceiveError(Object error) {
    showResult('onMessageReceiveError', error.toString());
  }

  void _onRemoteMessageSendStatus(String event) {
    showResult('RemoteMessageSendStatus', 'Status: $event');
  }

  void _onRemoteMessageSendError(Object error) {
    PlatformException e = error as PlatformException;
    showResult('RemoteMessageSendError', 'Error: $e');
  }

  void _onNewIntent(String? intentString) {
    // For navigating to the custom intent page (deep link) the custom
    // intent that sent from the push kit console is:
    // app://app2
    intentString = intentString ?? '';
    if (intentString != '') {
      showResult('CustomIntentEvent: ', intentString);
      List<String> parsedString = intentString.split('://');
      if (parsedString[1] == 'app2') {
        SchedulerBinding.instance.addPostFrameCallback(
          (Duration timeStamp) {
            // Если требуется специльный кейс
            // Navigator.of(context).push(
            //   MaterialPageRoute<dynamic>(
            //     builder: (BuildContext context) => const DefaultPage(),
            //   ),
            // );
          },
        );
      }
    }
  }

  void _onIntentError(Object err) {
    PlatformException e = err as PlatformException;
    debugPrint('Error on intent stream: $e');
  }

  void _onNotificationOpenedApp(dynamic initialNotification) {
    if (initialNotification != null) {
      showResult('onNotificationOpenedApp', initialNotification.toString());
    }
  }
}
*/