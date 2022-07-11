import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:infoservice/helpers/phone_mask.dart';
import 'package:path_provider/path_provider.dart';

import '../a_notifications/telegram_bot.dart';
import '../settings.dart';
import 'log.dart';

/* Отправка токена на сервер */
Future<bool> sendToken(String login, String token) async {
  if (login == '' || token == '') {
    Log.i(
        'sendToken', 'Not enough data for send token to server $login + $token');
    return false;
  }
  final queryParameters = {
    'action': 'update_token',
    'phone': login,
    'token': token,
  };
  final uri = Uri.https(JABBER_SERVER, JABBER_REG_ENDPOINT, queryParameters);
  Log.i('sendToken query', uri.toString());
  var response = await http.get(uri);
  Log.i('sendToken response', '${response.statusCode}');
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

/* Отправка push-data */
Future<void> sendCallPush(String toPhone, String fromPhone, String fromName,
    String credentialsHash) async {
  final uri = Uri.parse('https://$JABBER_SERVER$JABBER_NOTIFY_ENDPOINT');
  var response = await http.post(
    uri,
    headers: {
      // HttpHeaders.authorizationHeader: 'Basic xxxxxxx',
      //'Content-Type': 'image/jpeg',
    },
    body: jsonEncode(<String, dynamic>{
      'only_data': true,
      'additional_data': {
        'action': 'call',
      },
      'name': fromName,
      'toJID': cleanPhone(toPhone),
      'fromJID': cleanPhone(fromPhone),
      'credentials': credentialsHash,
    }),
  );
  Log.d('sendCallPush', '$uri, ${response.statusCode}');
  try {
    var decoded = json.decode(response.body);
    Log.i('sendCallPush', 'response ${response.statusCode}');
    await TelegramBot().sendNotify(
        'Notification msg: ${response.statusCode}=>${const JsonEncoder.withIndent('  ').convert(decoded)}');
  } catch (ex) {
    Log.e('sendCallPush', 'response ${response.statusCode}: $ex');
    await TelegramBot().sendNotify(
        'Notification msg: ${response.statusCode}=>${response.body.toString()}');
  }
}

Future<bool> checkInternetConnection() async {
  final uri = Uri.https(JABBER_SERVER, '/my_ip/');
  try {
    final resp = await http.post(uri).timeout(
      const Duration(seconds: 1),
      onTimeout: () {
        return http.Response('Error', 408); // Request Timeout response status code
        // throw Exception('duration timeout');
      },
    );
    Log.i('jabber server response', '${resp.statusCode}');
    if (resp.statusCode == 200) {
      return true;
    }
  } catch (ex) {
    Log.i('no internet', '$ex');
  }
  return false;
}

Future<String> makeAppFolder() async {
  final directory = await getApplicationDocumentsDirectory();
  final String destFolder = '${directory.path}/$APP_FOLDER';
  await Directory(destFolder).create();
  return destFolder;
}

Future<File> downloadFile(String url, File file) async {
  var req = await http.get(Uri.parse(url));
  var bytes = req.bodyBytes;
  await file.writeAsBytes(bytes);
  Log.i('downloadFile', '$url download completed, status ${req.statusCode}, bytes ${bytes.length}');
  return file;
}

Future<Map<String, dynamic>> requestsGetJson(String url) async {
  var req = await http.get(Uri.parse(url));
  if (req.statusCode != 200) {
    Log.e('requestsGetJson', 'status ${req.statusCode}, ${req.body}');
    return {};
  }
  return jsonDecode(req.body);
}