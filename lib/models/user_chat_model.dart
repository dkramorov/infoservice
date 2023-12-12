import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db/chat_db.dart';
import '../db/tables.dart';
import '../helpers/phone_mask.dart';
import '../settings.dart';
import 'abstract_model.dart';


/* Пользователи чата в базе данных
*/
class UserChatModel extends AbstractModel {

  @override
  Future<Database> openDB() async {
    return openChatDB();
  }

  Key key = UniqueKey();

  int? id; // null if we need new row
  String? login;
  String? passwd;
  int? lastLogin;
  String? photo;
  String? photoUrl;
  String? birthday;
  int? gender;
  String? email;
  String? name;
  String? status;
  String? time;
  String? msg;
  int? dropPersonalData;

  String getTableName() {
    return tableUserChatModel;
  }

  @override
  String get tableName => getTableName();

  UserChatModel({
    this.id,
    this.login,
    this.passwd,
    this.lastLogin,
    this.photo,
    this.photoUrl,
    this.birthday,
    this.gender,
    this.email,
    this.name,
    this.status,
    this.time,
    this.msg,
    this.dropPersonalData,
  });

  String getName() {
    return name ?? getLogin();
  }

  String getLogin() {
    String username = cleanPhone(login ?? '');
    if (username.length != 11) {
      return username;
    }
    String phone = phoneMaskHelper(username);
    return phone;
  }

  Future<String> getPhoto({Function? ifDownloaded}) async {
    /* Возвращает аватарку нашего пользователя
       ifDownloaded вызывается после обновления
    */
    if (photo != null && photo != '') {
      if (!File(photo!).existsSync()) {
        //downloadPhoto(ifDownloaded: ifDownloaded);
        return DEFAULT_AVATAR;
      }
      return photo!;
    }
    return DEFAULT_AVATAR;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'login': login,
      'passwd': passwd,
      'lastLogin': lastLogin,
      'photo': photo,
      'photoUrl': photoUrl,
      'birthday': birthday,
      'gender': gender,
      'email': email,
      'name': name,
      'status': status,
      'time': time,
      'msg': msg,
      'dropPersonalData': dropPersonalData,
    };
  }

  /* Перегоняем данные из базы в модельку */
  UserChatModel toModel(Map<String, dynamic> dbItem) {
    return UserChatModel(
      id: dbItem['id'],
      login: dbItem['login'],
      passwd: dbItem['passwd'],
      lastLogin: dbItem['lastLogin'],
      photo: dbItem['photo'],
      photoUrl: dbItem['photoUrl'],
      birthday: dbItem['birthday'],
      gender: dbItem['gender'],
      email: dbItem['email'],
      name: dbItem['name'],
      status: dbItem['status'],
      time: dbItem['time'],
      msg: dbItem['msg'],
      dropPersonalData: dbItem['dropPersonalData'],
    );
  }

  @override
  String toString() {
    final String table = getTableName();
    return '$table{id: $id, login: $login, passwd: $passwd, dropPersonalData: $dropPersonalData'
        ' lastLogin: $lastLogin, photo: $photo, photoUrl: $photoUrl, birthday: $birthday,'
        ' gender: $gender, email: $email, name: $name, status: $status, time: $time, msg: $msg}';
  }

  Future<UserChatModel?> getByLogin(String userLogin) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableUserChatModel,
      where: 'login = ?',
      whereArgs: [userLogin],
    );
    if (maps.isEmpty) {
      return null;
    }
    final Map<String, dynamic> user = maps[0];
    return toModel(user);
  }

  Future<List<UserChatModel>> getAllUsers(
      {int? limit, int? offset}) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableUserChatModel,
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
  }

}
