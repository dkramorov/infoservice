import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:infoservice/helpers/phone_mask.dart';
import 'package:path_provider/path_provider.dart';

import '../a_notifications/telegram_bot.dart';
import '../services/jabber_manager.dart';
import '../settings.dart';
import 'log.dart';

/* Отправка токена на сервер */
Future<bool> sendToken(String login, String token, {String? apnsToken}) async {
  if (login == '' || token == '') {
    String err = 'Not enough data for send token to server $login + $token';
    Log.i('sendToken', err);
    await TelegramBot().sendNotify(err);
    return false;
  }
  final queryParameters = {
    'action': 'update_token',
    'phone': login,
    'token': token,
  };
  if (apnsToken != null) {
    queryParameters['apns_token'] = apnsToken;
  }
  final uri = Uri.https(JABBER_SERVER, JABBER_REG_ENDPOINT, queryParameters);
  Log.i('sendToken query', uri.toString());
  Log.i('token', token);
  var response = await http.get(uri);
  Log.i('sendToken response', '${response.statusCode}');
  if (response.statusCode == 200) {
    return true;
  }

  String err =
      'Bad response ${response.statusCode} for send token to server $login + $token';
  await TelegramBot().sendNotify(err);

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
      'only_data': false,
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
        return http.Response(
            'Error', 408); // Request Timeout response status code
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

Future<File> getLocalFilePath(String filename) async {
  final String destFolder = await makeAppFolder();
  return File('$destFolder/$filename');
}

Future<File> downloadFile(String url, File file) async {
  var req = await http.get(Uri.parse(url));
  var bytes = req.bodyBytes;
  await file.writeAsBytes(bytes);
  Log.i('downloadFile',
      '$url download completed, status ${req.statusCode}, bytes ${bytes.length}');
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

Future<Map<String, dynamic>> requestPutFile(String url, File file) async {
  var response = await http.put(
    Uri.parse(url),
    headers: {
      // HttpHeaders.authorizationHeader: 'Basic xxxxxxx',
      //'Content-Type': 'image/jpeg',
    },
    body: await file.readAsBytes(),
  ).timeout(
    const Duration(seconds: 60),
    onTimeout: () {
      return http.Response(
          'Error', 408); // Request Timeout response status code
    },
  );
  return {
    'statusCode': response.statusCode,
    'body': response.body,
  };
}

Future<void> sendNames2Server(List<Map<String, dynamic>> contacts, String jid,
    String credentialsHash, JabberManager? xmppHelper) async {
  final uri = Uri.https(JABBER_SERVER, JABBER_CONTACTS_ENDPOINT);
  //final uri = Uri.parse('http://192.168.0.108:8000$JABBER_CONTACTS_ENDPOINT');
  Map<String, dynamic> data = {
    'JID': cleanPhone(jid),
    'credentials': credentialsHash,
    'contacts': contacts,
  };
  Log.d('sendContacts2Server', data.toString());

  String decoded = json.encode(contacts);
  String hashed = base64.encode(utf8.encode(decoded));
  Future.delayed(const Duration(seconds: 3), () async {
    await xmppHelper
        ?.setPrivateStorage('phonebook', 'hashed', {'data': hashed});
  });
  Future.delayed(const Duration(seconds: 2), () async {
    data['contacts'] = hashed;
    var response = await http.post(
      uri,
      headers: {
        // HttpHeaders.authorizationHeader: 'Basic xxxxxxx',
        //'Content-Type': 'image/jpeg',
      },
      body: jsonEncode(data),
    );
    Log.d('sendNames2Server', '$uri, ${response.statusCode}');
    try {
      var decoded = json.decode(response.body);
      Log.i('sendNames2Server', 'response ${response.statusCode}, $decoded');
    } catch (ex) {
      Log.e('sendNames2Server', 'response ${response.statusCode}: $ex');
    }
  });
}

Future<void> sendNames2ServerSimple(List<Map<String, dynamic>> contacts,
    String jid, String credentialsHash) async {
  /* Отправляем контакты на сервер, но без private storage сохранения
  */
  final uri = Uri.https(JABBER_SERVER, JABBER_CONTACTS_ENDPOINT);
  Map<String, dynamic> data = {
    'JID': cleanPhone(jid),
    'credentials': credentialsHash,
    'contacts': contacts,
  };
  Log.d('sendNames2ServerSimple', data.toString());

  String decoded = json.encode(contacts);
  String hashed = base64.encode(utf8.encode(decoded));

  data['contacts'] = hashed;
  var response = await http.post(
    uri,
    headers: {
      // HttpHeaders.authorizationHeader: 'Basic xxxxxxx',
      //'Content-Type': 'image/jpeg',
    },
    body: jsonEncode(data),
  );
  Log.d('sendNames2ServerSimple', '$uri, ${response.statusCode}');
  try {
    var decoded = json.decode(response.body);
    Log.i('sendNames2ServerSimple', 'response ${response.statusCode}, $decoded');
  } catch (ex) {
    Log.e('sendNames2ServerSimple', 'response ${response.statusCode}: $ex');
  }
}

Future<void> pushMe2GroupVCard(
    String jid, String credentialsHash, String toGroup) async {
  final uri = Uri.https(JABBER_SERVER, JABBER_GROUP_VCARD_ENDPOINT);
  //final uri = Uri.parse('http://192.168.0.108:8000$JABBER_GROUP_VCARD_ENDPOINT');
  if (toGroup.startsWith('GROUP_')) {
    toGroup = toGroup.split('GROUP_')[1];
  }
  Map<String, dynamic> data = {
    'JID': cleanPhone(jid),
    'credentials': credentialsHash,
    'to_group': toGroup,
  };
  Log.d('pushMe2GroupVCard', data.toString());
  var response = await http.post(
    uri,
    headers: {
      // HttpHeaders.authorizationHeader: 'Basic xxxxxxx',
      //'Content-Type': 'image/jpeg',
    },
    body: jsonEncode(data),
  );
  Log.d('pushMe2GroupVCard', '$uri, ${response.statusCode}');
  try {
    var decoded = json.decode(response.body);
    Log.i('pushMe2GroupVCard', 'response ${response.statusCode}, $decoded');
  } catch (ex) {
    Log.e('pushMe2GroupVCard', 'response ${response.statusCode}: $ex');
  }
}

Future<void> requestCompanyChat(
    String jid, String credentialsHash, String companyChatJid) async {
  /* Запрос чата с компанией */
  final uri = Uri.https(JABBER_SERVER, JABBER_COMPANY_ENDPOINT);
  //final uri = Uri.parse('http://192.168.0.108:8000$JABBER_COMPANY_ENDPOINT');
  Map<String, dynamic> data = {
    'JID': cleanPhone(jid),
    'credentials': credentialsHash,
    'MUC': companyChatJid,
  };
  Log.d('requestCompanyChat', data.toString());
  var response = await http.post(
    uri,
    headers: {
      // HttpHeaders.authorizationHeader: 'Basic xxxxxxx',
      //'Content-Type': 'image/jpeg',
    },
    body: jsonEncode(data),
  ).timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      return http.Response(
          'Error', 408); // Request Timeout response status code
      // throw Exception('duration timeout');
    },
  );
  Log.d('requestCompanyChat', '$uri, ${response.statusCode}');
  try {
    var decoded = json.decode(response.body);
    Log.i('requestCompanyChat', 'response ${response.statusCode}, $decoded');
  } catch (ex) {
    Log.e('requestCompanyChat', 'response ${response.statusCode}: $ex');
  }
}
