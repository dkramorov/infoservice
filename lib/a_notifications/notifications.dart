import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:http/http.dart' as http;

import '../helpers/log.dart';
import '../helpers/phone_mask.dart';
import '../settings.dart';

/* Простое уведомление с большой картинкой,
картинка появялется только если потянуть вниз за уведомление,
чтобы развернуть его
*/
Future<void> createSimpleNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 4,
      channelKey: 'basic_channel',
      title: 'simple notification',
      body: 'test simple notification',
      bigPicture: 'asset://assets/notification_map.png',
      notificationLayout: NotificationLayout.BigPicture,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'Answer',
        label: 'Answer',
      ),
      NotificationActionButton(
        key: 'Cancel',
        label: 'Cancel',
      ),
    ],
  );
}

Future<void> createChatNotification(Map<String, String> data) async {
  String title = 'Новое сообщение';
  String displayName = data['sender'] ?? '';
  if (data['displayName'] != null && data['displayName'] != '') {
    displayName = data['displayName']!;
  }
  String body = 'Сообщение от $displayName';
  if (data['body'] != null && data['body'] != '') {
    title = body;
    body = data['body']!;
  }
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 5,
      channelKey: 'normal_channel',
      title: title,
      body: body,
      payload: data,
      wakeUpScreen: true,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'Answer',
        label: 'Answer',
      ),
      NotificationActionButton(
        key: 'Cancel',
        label: 'Cancel',
      ),
    ],
  );
}

Future<void> sendPush(String credentialsHash, String myPhone, String toPhone,
    {String action = 'chat', String text = '', bool onlyData = false}) async {
  /* Отправка push-data */
  final uri = Uri.parse('https://$JABBER_SERVER$JABBER_NOTIFY_ENDPOINT');
  final data = <String, dynamic>{
    'additional_data': {
      'action': action,
    },
    'name': myPhone,
    'toJID': cleanPhone(toPhone),
    'fromJID': cleanPhone(myPhone),
    'credentials': credentialsHash,
  };
  if (text != '') {
    data['body'] = text;
  }
  if (onlyData) {
    data['only_data'] = true;
  }
  Log.i('sendPush', 'params ${data.toString()}, url $uri');
  var response = await http.post(
    uri,
    body: jsonEncode(data),
  ).timeout(
    const Duration(seconds: 5),
    onTimeout: () {
      Log.i('sendPush',
          'notification TIMEOUT');
      return http.Response('Error', 408); // Request Timeout response status code
    },
  );
  Log.i('sendPush',
      'notification response ${response.statusCode}, ${response.body.toString()}');
}

Future<void> sendGroupPush(String credentialsHash, String myPhone, String toGroupJid,
    {String text = '', bool onlyData = false}) async {
  /* Отправка push-data батчем */
  final uri = Uri.parse('https://$JABBER_SERVER$JABBER_NOTIFY_BATCH_ENDPOINT');
  final data = <String, dynamic>{
    'additional_data': {
      'action': 'chat',
    },
    'name': myPhone,
    'toGroupJid': toGroupJid,
    'fromJID': cleanPhone(myPhone),
    'credentials': credentialsHash,
  };
  if (text != '') {
    data['body'] = text;
  }
  if (onlyData) {
    data['only_data'] = true;
  }
  Log.i('sendGroupPush', 'params ${data.toString()}');
  var response = await http.post(
    uri,
    body: jsonEncode(data),
  ).timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      Log.i('sendGroupPush',
          'notification TIMEOUT');
      return http.Response('Error', 408); // Request Timeout response status code
    },
  );
  Log.i('sendGroupPush',
      'notification response ${response.statusCode}, ${response.body.toString()}');
}
