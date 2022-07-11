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
  final int? id;
  final String? created;
  final String? updated;
  final bool? isActive;
  final String? phone;
  final String? version;
  final String? platform;
  final String? result;

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
        // Error
        this.status,
        this.code,
        this.message});

  @override
  String toString() {
    return 'id: $id, phone: $phone, result: $result, version: $version,'
        ' platform: $platform, created: $created, updated: $updated,'
        ' isActive: $isActive, status: $status, code: $code, message: $message';
  }

  String getMessage() {
    return message ?? 'Unknown error';
  }

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id'] as int,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
      isActive: json['is_active'] as bool?,
      phone: json['phone'] as String?,
      version: json['version'] as String?,
      platform: json['platform'] as String?,
      result: json.keys.contains('result') ? json['result'] : '',
      // Error
      status: json['status'] as String?,
      code: json['code'] as int?,
      message: json['message'] as String?,
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
    final appInfo = await PackageInfo.fromPlatform();
    final appVersion = '${appInfo.version} : ${appInfo.buildNumber}';
    final queryParameters = {
      'action': 'registration',
      'phone': login,
      'name': name,
      'passwd': passwd,
      'platform': Platform.operatingSystem,
      'version': appVersion,
    };
    final uri = Uri.https(JABBER_SERVER, JABBER_REG_ENDPOINT, queryParameters);
    Log.d(TAG, 'query: ${uri.toString()}');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      return parseResponse(response.body);
    }
    return null;
  }

  static Future<RegistrationModel?> confirmRegistration(
      String phone, String code) async {
    final queryParameters = {
      'action': 'confirm',
      'phone': phone,
      'code': code,
    };
    final uri = Uri.https(JABBER_SERVER, JABBER_REG_ENDPOINT, queryParameters);
    Log.d(TAG, 'query: ${uri.toString()}');
    var response = await http.get(uri);
    Log.d(TAG, 'status_code ${response.statusCode}, response: ${response.body}');

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
    }
    return null;
  }
}
