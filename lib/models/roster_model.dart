import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db/chat_db.dart';
import '../db/tables.dart';
import 'abstract_model.dart';


/* Пользователи ростера + группы чатов
*/
class RosterModel extends AbstractModel {

  @override
  Future<Database> openDB() async {
    return openChatDB();
  }

  Key key = UniqueKey();

  int? id; // null if we need new row
  String? name;
  String? jid;
  String? avatar;
  String? lastMessage;
  int? lastMessageTime;
  int? newMessagesCount;
  String? ownerJid;

  String getTableName() {
    return tableRosterModel;
  }

  @override
  String get tableName => getTableName();

  RosterModel({
    this.id,
    this.name,
    this.jid,
    this.avatar,
    this.lastMessage,
    this.lastMessageTime,
    this.newMessagesCount,
    this.ownerJid,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'jid': jid,
      'avatar': avatar,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'newMessagesCount': newMessagesCount,
      'ownerJid': ownerJid,
    };
  }

  /* Перегоняем данные из базы в модельку */
  RosterModel toModel(Map<String, dynamic> dbItem) {
    return RosterModel(
      id: dbItem['id'],
      name: dbItem['name'],
      jid: dbItem['jid'],
      avatar: dbItem['avatar'],
      lastMessage: dbItem['lastMessage'],
      lastMessageTime: dbItem['lastMessageTime'],
      newMessagesCount: dbItem['newMessagesCount'],
      ownerJid: dbItem['ownerJid'],
    );
  }

  @override
  String toString() {
    final String table = getTableName();
    return '$table{id: $id, name: $name, jid: $jid, ' +
        'avatar: $avatar, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime, ' +
        'newMessagesCount: $newMessagesCount, ownerJid: $ownerJid';
  }

  Future<List<RosterModel>> getByOwner(String userJid) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableRosterModel,
      where: 'ownerJid=?',
      whereArgs: [userJid],
    );
    return List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
  }

}
