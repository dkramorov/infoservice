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
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 5,
      channelKey: 'normal_channel',
      title: 'Новое сообщение',
      body: 'Сообщение от ${data['sender']}',
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

/* Отправка push-data */
Future<void> sendPush(String credentialsHash, String myPhone, String toPhone,
    {String action = 'chat', String text = '', bool only_data = false}) async {
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
  if (only_data) {
    data['only_data'] = true;
  }
  Log.i('sendCallPush', 'params ${data.toString()}');
  var response = await http.post(
    uri,
    body: jsonEncode(data),
  );
  Log.i('sendCallPush',
      'notification response ${response.statusCode}, ${response.body.toString()}');
  try {
    var decoded = json.decode(response.body);
    //await TelegramBot().sendNotify(
    //    'Notification msg: ${response.statusCode}=>${const JsonEncoder.withIndent('  ').convert(decoded)}');
  } catch (ex) {
    //await TelegramBot().sendNotify(
    //    'Notification msg: ${response.statusCode}=>${response.body.toString()}');
    print(ex);
  }
}
