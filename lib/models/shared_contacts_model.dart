import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../db/settings_db.dart';
import '../db/tables.dart';
import '../helpers/date_time.dart';
import '../helpers/log.dart';
import '../helpers/network.dart';
import '../helpers/phone_mask.dart';
import '../services/shared_preferences_manager.dart';
import '../settings.dart';
import 'abstract_model.dart';
import 'chat_message_model.dart';

/* Общие контакты с другом
*/
class SharedContactsRequestModel extends AbstractModel {
  static const String tag = 'SharedContactsRequestModel';

  @override
  Future<Database> openDB() async {
    return await openSettingsDB();
  }

  Key key = UniqueKey();

  int? id; // null if we need new row
  String? date;
  String? ownerJid;
  String? friendJid;
  String? answer;

  String getTableName() {
    return tableSharedContactsRequestModel;
  }

  @override
  String get tableName => getTableName();

  SharedContactsRequestModel({
    this.id,
    this.date,
    this.ownerJid,
    this.friendJid,
    this.answer,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'owner_jid': ownerJid,
      'friend_jid': friendJid,
      'answer': answer,
    };
  }

  /* Перегоняем данные из базы в модельку */
  SharedContactsRequestModel toModel(Map<String, dynamic> dbItem) {
    return SharedContactsRequestModel(
      id: dbItem['id'],
      date: dbItem['date'],
      ownerJid: dbItem['owner_jid'],
      friendJid: dbItem['friend_jid'],
      answer: dbItem['answer'],
    );
  }

  Future<SharedContactsRequestModel?> getById(int pk) async {
    final db = await openDB();
    String where = 'id=?';
    List<Object?> whereArgs = [pk];
    final List<Map<String, dynamic>> maps = await db.query(
      tableSharedContactsRequestModel,
      where: where,
      whereArgs: whereArgs,
    );
    if (maps.isEmpty) {
      Log.e(tag, 'SharedContactsRequestModel not found by id: $pk');
      return null;
    }
    final Map<String, dynamic> result = maps[0];
    return toModel(result);
  }

  Future<List<SharedContactsRequestModel>> getForFriend(
      String ownerJid, String friendJid, {bool? answered}) async {
    final db = await openDB();
    List<String> args = [ownerJid, friendJid];
    String query = 'owner_jid = ? AND friend_jid=?';
    if (answered != null) {
      if (answered) {
        query += ' AND answer is NOT NULL';
      } else {
        query += ' AND answer is NULL';
      }
    }
    Log.d(tag, '$query, $args');
    final List<Map<String, dynamic>> maps = await db.query(
      tableSharedContactsRequestModel,
      where: query,
      whereArgs: args,
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
  }

  Future<void> checkNewAnswer(ChatMessageModel receivedMessage, String myJid, String fromJid) async {
    /* Вызывается на новое сообщение из jabber_manager
       При условии, что сообщения нет в базе
       Если это ответ на запрос (answer)
       тогда надо вытащить все неотвеченные SharedContactsRequestModel
       и сделать их отвеченными (чтобы кнопки больше нельзя было клацать)
       По сути это получение истории запросов (например, при переустановке)
    */
    if (receivedMessage.body == 'answer' &&
        receivedMessage.customText != null) {
      try {
        Map<String, dynamic> customText =
        jsonDecode(receivedMessage.customText ?? '{}');
        if (customText['type'] == 'answer' && myJid != fromJid) {
          // 1) Найти запросы на права, который мы делали и зафиксировать ответ
          List<SharedContactsRequestModel> notAnswered =
          await SharedContactsRequestModel().getForFriend(
            myJid,
            fromJid,
            answered: false,
          );
          //print("-----_____ ${notAnswered.toString()} ${notAnswered.isNotEmpty}");
          if (notAnswered.isNotEmpty) {
            for (int i = 0; i < notAnswered.length; i++) {
              SharedContactsRequestModel req = notAnswered[i];
              await req.updatePartial(req.id, {
                'answer': customText['answer'].toString(),
              });
            }
          } else {
            /* Если у нас нет такого запроса, тогда надо его создать
            */
            SharedContactsRequestModel req = SharedContactsRequestModel(
              ownerJid: myJid,
              friendJid: fromJid,
              date: datetime2String(timestamp2Datetime(receivedMessage.time ??
                  DateTime.now().millisecondsSinceEpoch)),
              answer: customText['answer'].toString(),
            );
            await req.insert2Db();
          }
        }
      } catch (ex) {
        Log.d(tag, '[ERROR]: ${ex.toString()}');
      }
    }
  }
}

class SharedContactsModel extends AbstractModel {
  static const String tag = 'SharedContactsModel';

  @override
  Future<Database> openDB() async {
    return await openSettingsDB();
  }

  Key key = UniqueKey();

  int? id; // null if we need new row
  int? requestId;
  String? login;
  String? name;

  String getTableName() {
    return tableSharedContactsModel;
  }

  @override
  String get tableName => getTableName();

  SharedContactsModel({
    this.id,
    this.requestId,
    this.login,
    this.name,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestId': requestId,
      'login': login,
      'name': name,
    };
  }

  /* Перегоняем данные из базы в модельку */
  SharedContactsModel toModel(Map<String, dynamic> dbItem) {
    return SharedContactsModel(
      id: dbItem['id'],
      requestId: dbItem['requestId'],
      login: dbItem['login'],
      name: dbItem['name'],
    );
  }

  Future<List<SharedContactsModel>> getByRequestId(int requestId) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableSharedContactsModel,
      where: 'requestId=?',
      whereArgs: [requestId],
    );
    return List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
  }

  Future<void> dropByRequestId(int requestId) async {
    final db = await openDB();
    await db.rawQuery(
        'DELETE from $tableSharedContactsModel'
        ' WHERE requestId=?',
        [requestId]);
  }

}
