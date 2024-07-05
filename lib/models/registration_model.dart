import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/log.dart';
import '../settings.dart';

class RegistrationModel {
  static const TAG = 'RegistrationModel';
  static const int CODE_PASSWD_CHANGED = 10090;
  static const int CODE_REGISTRATION_SUCCESS = 0;
  static const int CODE_ERROR = -1;
  static const int TOO_MANY_ATTEMPTS = 429;
  final int? id;
  final String? created;
  final String? updated;
  final bool? isActive;
  final String? phone;
  final String? version;
  final String? platform;
  final String? result;
  final bool? isSimpleReg;

  // Error
  String? status;
  int? code;
  String? message;

  RegistrationModel(
      {this.id,
      this.created,
      this.updated,
      this.isActive,
      this.phone,
      this.version,
      this.platform,
      this.result,
      this.isSimpleReg,
      // Error
      this.status,
      this.code,
      this.message});

  @override
  String toString() {
    return 'id: $id, phone: $phone, result: $result, version: $version,'
        ' platform: $platform, created: $created, updated: $updated,'
        ' isActive: $isActive, status: $status, code: $code, message: $message'
        ' isSimpleReg: $isSimpleReg';
  }

  String getMessage() {
    return message ?? 'Unknown error';
  }

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id'],
      created: json['created'],
      updated: json['updated'],
      isActive: json['is_active'],
      phone: json['phone'],
      version: json['version'],
      platform: json['platform'],
      result: json.keys.contains('result') ? json['result'] : '',
      isSimpleReg: json['simple_reg'],
      // Error
      status: json['status'],
      code: json['code'],
      message: json['message'],
    );
  }

  static RegistrationModel parseResponse(String responseBody) {
    //final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    //return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
    final parsed = jsonDecode(responseBody);
    return RegistrationModel.fromJson(parsed);
  }

  static Future<RegistrationModel?> requestRegistration(
      String login, String name, String passwd) async {
    /* Регистрация - 200=регистрация, 201=упрощенная регистрация */
    final appInfo = await PackageInfo.fromPlatform();
    final appVersion = '${appInfo.version} : ${appInfo.buildNumber}';
    final queryParameters = {
      'action': 'registration',
      'phone': login,
      'name': name,
      'passwd': passwd,
      'platform': Platform.operatingSystem,
      'version': appVersion,
      // При отсутствии активных регистраций
      // будет регистрация по последним цифрам входящего
      'simple_reg': '1',
    };
    final uri = Uri.https(JABBER_SERVER, JABBER_REG_ENDPOINT, queryParameters);
    Log.d(TAG, 'query: ${uri.toString()}');
    var response = await http.get(uri);
    // 201 - упрощенная регистрация (по последним цифрам входящего)
    // 401 - слишком частые обращения
    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 429) {
      return parseResponse(response.body);
    }
    return null;
  }

  static Future<RegistrationModel?> confirmRegistration(
      String phone, String code, bool isSimpleReg) async {
    /* Подтверждение регистрации - 200=регистрация, 201=смена пароля */
    final queryParameters = {
      'action': 'confirm',
      'phone': phone,
      'code': code,
    };
    // Упрощенная регистрация
    if (isSimpleReg) {
      queryParameters['simple_reg'] = '1';
    }
    final uri = Uri.https(JABBER_SERVER, JABBER_REG_ENDPOINT, queryParameters);
    Log.d(TAG, 'query: ${uri.toString()}');
    var response = await http.get(uri);
    Log.d(
        TAG, 'status_code ${response.statusCode}, response: ${response.body}');

    if (response.statusCode == 200) {
      RegistrationModel registrationModel = parseResponse(response.body);
      Log.d(TAG, 'parsedResponse: $registrationModel');
      if (registrationModel.phone != null) {
        registrationModel.status = 'success';
        registrationModel.code = CODE_REGISTRATION_SUCCESS;
        registrationModel.message = 'Регистрация успешно завершена';
        return registrationModel;
      } else {
        return RegistrationModel(
          status: 'error',
          code: CODE_ERROR,
          message: 'Неправильно введен код подтверждения',
        );
      }
    } else if (response.statusCode == 201) {
      // Сменили пароль
      return RegistrationModel(
        status: 'success',
        code: CODE_PASSWD_CHANGED,
        message: 'Пароль изменен',
      );
    } else if (response.statusCode == 429) {
      // Лимит попыток ввода кода
      return RegistrationModel(
        status: 'error',
        code: TOO_MANY_ATTEMPTS,
        message: 'Слишком много неуспешных попыток ввода кода подтверждения, повторите регистрацию через полчаса',
      );
    } else if (response.statusCode == 401) {
      // Неправльный код
      return RegistrationModel(
        status: 'error',
        code: CODE_ERROR,
        message: 'Неправильно введен код подтверждения',
      );
    }
    return null;
  }
}
