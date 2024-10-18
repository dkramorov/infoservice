import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../db/settings_db.dart';
import '../db/tables.dart';
import '../helpers/log.dart';
import '../helpers/network.dart';
import '../helpers/phone_mask.dart';
import '../services/shared_preferences_manager.dart';
import '../settings.dart';
import 'abstract_model.dart';


/* Настройки пользователя
*/
class UserSettingsModel extends AbstractModel {
  static const String tag = 'UserSettingsModel';

  @override
  Future<Database> openDB() async {
    return await openSettingsDB();
  }

  Key key = UniqueKey();

  int? id; // null if we need new row
  String? name;
  String? photo;
  String? passwd;
  String? jid;
  String? credentialsHash;
  String? birthday;
  int? gender;
  String? email;
  String? token;
  String? phone;
  bool? isDropped;
  int? isXmppRegistered;
  int? rosterVersion;

  String getTableName() {
    return tableUserSettingsModel;
  }

  @override
  String get tableName => getTableName();

  UserSettingsModel({
    this.id,
    this.name,
    this.photo,
    this.passwd,
    this.jid,
    this.credentialsHash,
    this.birthday,
    this.gender,
    this.email,
    this.token,
    this.phone,
    this.isDropped,
    this.isXmppRegistered,
    this.rosterVersion,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'passwd': passwd,
      'jid': jid,
      'credentialsHash': credentialsHash,
      'birthday': birthday,
      'gender': gender,
      'email': email,
      'token': token,
      'phone': phone,
      'isDropped': isDropped,
      'isXmppRegistered': isXmppRegistered,
      'rosterVersion': rosterVersion,
    };
  }

  /* Перегоняем данные из базы в модельку */
  UserSettingsModel toModel(Map<String, dynamic> dbItem) {
    return UserSettingsModel(
      id: dbItem['id'],
      name: dbItem['name'],
      photo: dbItem['photo'],
      passwd: dbItem['passwd'],
      jid: dbItem['jid'],
      credentialsHash: dbItem['credentialsHash'],
      birthday: dbItem['birthday'],
      gender: dbItem['gender'],
      email: dbItem['email'],
      token: dbItem['token'],
      phone: dbItem['phone'],
      isDropped: dbItem['isDropped'] == 't' ? true : false,
      isXmppRegistered: dbItem['isXmppRegistered'],
      rosterVersion: dbItem['rosterVersion'],
    );
  }

  String getName() {
    String result = phoneMaskHelper(phone ?? '');
    if (name != null && name != '') {
      return name ?? '';
    }
    return result;
  }

  bool getRegistered() {
    if (isXmppRegistered == 1) {
      return true;
    }
    return false;
  }

  bool isEqual(UserSettingsModel other) {
    Map<String, dynamic> curUser = toMap();
    Map<String, dynamic> otherUser = other.toMap();
    List<String> keys = curUser.keys.toList();
    for (int i=0; i<keys.length; i++) {
      String key = keys[i];
      if (curUser[key] != otherUser[key]) {
        Log.d(tag, 'NotEqual for $key (${curUser[key]} != ${otherUser[key]})');
        return false;
      }
    }
    return true;
  }

  void incRosterVersion() {
    if (rosterVersion != null) {
      rosterVersion = rosterVersion! + 1;
    } else {
      rosterVersion = 1;
    }
  }

  Future<void> updateRosterVersion() async {
    /* Сразу обновление версии ростера в базе */
    UserSettingsModel? user = await getUser();
    if (user != null) {
      user.incRosterVersion();
      user.updatePartial(user.id, {'rosterVersion': user.rosterVersion});
    }
  }

  @override
  String toString() {
    final String table = getTableName();
    return '$table{id: $id, name: $name, photo: $photo, jid: $jid'
        ' credentialsHash: $credentialsHash, birthday: $birthday, birthday: $birthday,'
        ' gender: $gender, email: $email, token: $token, phone: $phone,'
        ' isDropped: $isDropped, isXmppRegistered: $isXmppRegistered,'
        ' rosterVersion: $rosterVersion}';
  }

  Future<String> getCredentialsHash() async {
    /* sha256 на логин + пароль
       для различных операций, требующих авторизации
    */
    List<int> credentials = utf8.encode('$phone$passwd');
    credentialsHash = sha256.convert(credentials).toString();
    return credentialsHash ?? '';
  }

  static Future<void> updateToken(String token) async {
    SharedPreferences prefs =
    await SharedPreferencesManager.getSharedPreferences();

    if (token == '') {
      /* Это может быть на создании пользователя при регистрации,
         токен записался в основном сервисе, а операция выполняется из фона,
         поэтому если токен есть, то пишем его в SharedPreferences,
         а здесь проверяем, если есть там, то его и берем
      */
      String? fcmToken = prefs.getString('fcmToken');
      if (fcmToken == null) {
        return;
      }
      token = fcmToken;
    }
    else {
      await prefs.setString('fcmToken', token);
    }

    UserSettingsModel? user = await UserSettingsModel().getUser();
    if (user == null) {
      return;
    }
    user.updatePartial(user.id, {'token': token});
    user.token = token;
    await sendToken(user.phone ?? '', token);
  }

  Future<UserSettingsModel?> getUser() async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
    );
    if (maps.isEmpty) {
      return null;
    }
    final Map<String, dynamic> user = maps[0];
    return toModel(user);
  }

  String getPhoto() {
    if (photo != null && photo != '' && photo != DEFAULT_AVATAR) {
      return photo!;
    }
    return DEFAULT_AVATAR;
  }

}
