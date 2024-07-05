import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:infoservice/models/roster_model.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xmpp_plugin/models/message_model.dart';

import '../db/chat_db.dart';
import '../db/tables.dart';
import '../helpers/dialogs.dart';
import '../helpers/log.dart';
import '../helpers/phone_mask.dart';
import '../pages/chat/utils.dart';
import '../services/jabber_manager.dart';
import '../widgets/chat/messages_widgets.dart';
import 'abstract_model.dart';

/* Сообщения для повторной отправки
*/

class PendingMessageModel extends AbstractModel {
  static const String tag = 'PendingMessageModel';

  @override
  Future<Database> openDB() async {
    //print('___openChatDB___');
    return await openChatDB();
  }

  Key key = UniqueKey();

  int? id; // null if we need new row
  int? time; // 1674893403756
  String? uid;

  String getTableName() {
    return tablePendingMessageModel;
  }

  @override
  String get tableName => getTableName();

  PendingMessageModel({
    this.id,
    this.time,
    this.uid,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time,
      'uid': uid,
    };
  }

  /* Перегоняем данные из базы в модельку */
  PendingMessageModel toModel(Map<String, dynamic> dbItem) {
    return PendingMessageModel(
      id: dbItem['id'],
      time: dbItem['time'] ?? '0',
      uid: dbItem['uid'] ?? '',
    );
  }

  @override
  String toString() {
    final String table = getTableName();
    return '$table{id: $id, time: $time, uid: $uid}';
  }

  Future<List<PendingMessageModel>> getAll() async {
    final db = await openDB();
    final List<Map<String, dynamic>> messages = await db.query(
      tablePendingMessageModel,
    );
    return List.generate(messages.length, (i) {
      return toModel(messages[i]);
    });
  }

  Future<int> deleteByUid(String uid) async {
    Log.i('$tableName deleteByUid', uid);
    final db = await openDB();
    return await db.delete(
      tableName,
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

}
