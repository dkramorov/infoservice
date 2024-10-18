import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_login_yandex_updated/flutter_login_yandex.dart';
import 'package:http/http.dart' as http;
import 'package:infoservice/helpers/phone_mask.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../a_notifications/telegram_bot.dart';
import '../models/user_settings_model.dart';
import '../services/jabber_manager.dart';
import '../services/shared_preferences_manager.dart';
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
  final appInfo = await PackageInfo.fromPlatform();
  final appVersion = '${appInfo.version} : ${appInfo.buildNumber}';
  final queryParameters = {
    'action': 'update_token',
    'phone': login,
    'token': token,
    'platform': Platform.operatingSystem,
    'version': appVersion,
  };
  if (apnsToken != null) {
    queryParameters['apns_token'] = apnsToken;
  }
  final uri = Uri.https(JABBER_SERVER, JABBER_REG_ENDPOINT, queryParameters);
  Log.i('sendToken query', uri.toString());
  //Log.i('token', token);
  Log.i('queryParameters', queryParameters.toString());
  var response = await http.get(uri);
  Log.i('sendToken response status', '${response.statusCode}');
  if (response.statusCode == 200) {
    var decoded = json.decode(response.body);
    bool debugOn = false;
    if (decoded['state'] != null) {
      List<dynamic> states = decoded['state'];
      for (int i=0; i<states.length; i++) {
        if (states[i] == 10) {
          // Включена отладка
          debugOn = true;
        }
      }
    }
    // Вкл/выкл отладки
    SharedPreferences prefs =
    await SharedPreferencesManager.getSharedPreferences();
    await prefs.setBool(DEBUG_ON, debugOn);
    Log.i('sendToken response', '${decoded.toString()}, debugOn=$debugOn');
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
  Map<String, dynamic> params = {
    'only_data': false,
    'additional_data': {
      'action': 'call',
    },
    'name': fromName,
    'toJID': cleanPhone(toPhone),
    'fromJID': cleanPhone(fromPhone),
    'credentials': credentialsHash,
  };
  var response = await http.post(
    uri,
    headers: {
      // HttpHeaders.authorizationHeader: 'Basic xxxxxxx',
      //'Content-Type': 'image/jpeg',
    },
    body: jsonEncode(params),
  );
  Log.d(
      'sendCallPush',
      '$uri, ${response.statusCode}, params ${params.toString()}'
  );
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
      const Duration(seconds: 3),
      onTimeout: () {
        return http.Response(
            'Error', 408); // Request Timeout response status code
        // throw Exception('duration timeout');
      },
    );
    //Log.d('checkInternetConnection', 'resp: ${resp.statusCode}');
    if (resp.statusCode == 200) {
      return true;
    }
  } catch (ex) {
    Log.d('checkInternetConnection', 'ERROR: $ex');
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

Future<Map<String, dynamic>> requestsGetJson(String url,
    {String authHeader = ''}) async {
  Map<String, String> headers = {};
  if (authHeader.isNotEmpty) {
    headers[HttpHeaders.authorizationHeader] = authHeader;
  }
  var req = await http.get(Uri.parse(url), headers: headers);
  if (req.statusCode != 200 && req.statusCode != 201) {
    Log.e('requestsGetJson', 'status ${req.statusCode}, ${req.body}');
    return {};
  }
  Log.i('requestsGetJson', '$url, status ${req.statusCode}');
  return jsonDecode(req.body);
}

Future<Map<String, dynamic>> requestPutFile(String url, File file) async {
  var response = await http
      .put(
    Uri.parse(url),
    headers: {
      // HttpHeaders.authorizationHeader: 'Basic xxxxxxx',
      //'Content-Type': 'image/jpeg',
    },
    body: await file.readAsBytes(),
  )
      .timeout(
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
    Log.i(
        'sendNames2ServerSimple', 'response ${response.statusCode}, $decoded');
  } catch (ex) {
    Log.e('sendNames2ServerSimple', 'response ${response.statusCode}: $ex');
  }
}

Future<void> sendNames2ServerFile(String filePath,
    String jid, String credentialsHash) async {
  /* Отправляем контакты на сервер tar.gz архивом
  */
  final uri = Uri.https(JABBER_SERVER, JABBER_CONTACTS_ENDPOINT);
  //final uri = Uri.parse('http://192.168.88.5:8000$JABBER_CONTACTS_ENDPOINT');
  var request = http.MultipartRequest('POST', uri);
  request.fields['JID'] = cleanPhone(jid);
  request.fields['credentials'] = credentialsHash;
  Log.d('sendNames2ServerFile', '$uri, ${request.fields.toString()}');
  request.files.add(await http.MultipartFile.fromPath(
    'file',
    filePath,
  ));
  final response = await request.send();
  Log.d('sendNames2ServerFile', '$uri, ${response.statusCode}');

  final streamedResp = await http.Response.fromStream(response);
  var decoded = json.decode(streamedResp.body);
  Log.d('sendNames2ServerFile', 'response: ${decoded.toString()}');
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
  var response = await http
      .post(
    uri,
    headers: {
      // HttpHeaders.authorizationHeader: 'Basic xxxxxxx',
      //'Content-Type': 'image/jpeg',
    },
    body: jsonEncode(data),
  )
      .timeout(
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

Future<void> sendAnalyticsEvent(
    String eventName, Map<String, dynamic> parameters) async {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Map<String, dynamic> newParams = {};
  // Не все параметры хотим давать в аналитику
  parameters.forEach((key, value) {
    if (key == 'passwd') {
      return;
    }
    newParams[key] = value;
  });

  await analytics.logEvent(
    name: eventName,
    parameters: newParams,
  );
  Log.i('sendAnalyticsEvent', '$eventName, ${newParams.toString()}');
}

Future<Map<String, dynamic>> yandexOauth() async {
  final flutterLoginYandexPlugin = FlutterLoginYandex();
  final response = await flutterLoginYandexPlugin.signIn();
  Map<String?, dynamic> oauthToken = Map<String?, dynamic>.from(response!);
  String token = oauthToken['token'] ?? '';
  if (token.isNotEmpty) {
    final userInfo = await requestsGetJson(
      'https://login.yandex.ru/info?&format=json',
      authHeader: 'OAuth $token',
    );
    userInfo['token'] = token;
    return userInfo;
  }
  return {};
}

Future<http.Response> postRequest(
    String endpoint,
    Map<String, dynamic> data,
    Map<String, String> headers) async {
  /* Post запрос */
  const tag = 'postRequest';
  Uri uri = Uri.https(JABBER_SERVER, endpoint);
  //uri = Uri.http('192.168.88.5:8000', endpoint); // test
  Log.d(tag, '${uri.toString()}, ${data.toString()}');
  if (headers['Content-Type'] == null) {
    headers['Content-Type'] = 'application/json';
  }
  http.Response response = await http
      .post(
    uri,
    headers: headers,
    body: jsonEncode(data),
  )
      .timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      return http.Response(
          'Error', 408); // Request Timeout response status code
    },
  );
  Log.d(tag, '$uri, ${response.statusCode}');
  try {
    var decoded = json.decode(response.body);
    Log.i(tag, 'response ${response.statusCode}, $decoded');
  } catch (ex) {
    Log.e(tag, 'response ${response.statusCode}: $ex');
  }
  return response;
}

Future<Map<String, dynamic>> getSharedContacts(String withPhone) async {
  Map<String, dynamic> result = {};
  UserSettingsModel? userSettings = await UserSettingsModel().getUser();
  if (userSettings != null) {
    http.Response resp = await postRequest(
        '/jabber/shared_contacts/',
        {
          'credentials': userSettings.credentialsHash,
          'phone': userSettings.phone,
          'with_phone': withPhone,
        },
        {},
    );
    if (resp.statusCode == 200) {
      result = jsonDecode(resp.body);
    }
  }
  return result;
}
