import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db/chat_db.dart';
import '../db/tables.dart';
import '../helpers/log.dart';
import '../settings.dart';
import 'abstract_model.dart';

/* Пользователи ростера + группы чатов
*/
class RosterModel extends AbstractModel {
  static const String tag = 'RosterModel';
  static Map<String, RosterModel> prefetchedModels = {};

  @override
  Future<Database> openDB() async {
    return await openChatDB();
  }

  Key key = UniqueKey();

  int? id; // null if we need new row
  String? name;
  String? jid;
  String? avatar;
  String? lastMessageId;
  String? lastMessage;
  int? lastMessageTime;
  int? lastReadMessageTime;
  int? newMessagesCount;
  String? ownerJid;
  int? isGroup;

  // Для вывода в виджетах
  bool visible = true;

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
    this.lastMessageId,
    this.lastMessage,
    this.lastMessageTime,
    this.lastReadMessageTime,
    this.newMessagesCount,
    this.ownerJid,
    this.isGroup,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'jid': jid,
      'avatar': avatar,
      'lastMessageId': lastMessageId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastReadMessageTime': lastReadMessageTime,
      'newMessagesCount': newMessagesCount,
      'ownerJid': ownerJid,
      'isGroup': isGroup,
    };
  }

  /* Перегоняем данные из базы в модельку */
  RosterModel toModel(Map<String, dynamic> dbItem) {
    return RosterModel(
      id: dbItem['id'],
      name: dbItem['name'],
      jid: dbItem['jid'],
      avatar: dbItem['avatar'],
      lastMessageId: dbItem['lastMessageId'],
      lastMessage: dbItem['lastMessage'],
      lastMessageTime: dbItem['lastMessageTime'],
      lastReadMessageTime: dbItem['lastReadMessageTime'],
      newMessagesCount: dbItem['newMessagesCount'],
      ownerJid: dbItem['ownerJid'],
      isGroup: dbItem['isGroup'],
    );
  }

  void storeFetched(List<RosterModel> fetchedModels) {
    // Записать в класс вытащенные модели
    for (RosterModel rosterModel in fetchedModels) {
      prefetchedModels[rosterModel.jid ?? ''] = rosterModel;
    }
  }

  Future<RosterModel?> getById(int pk) async {
    final db = await openDB();
    String where = 'id=?';
    List<Object?> whereArgs = [pk];
    final List<Map<String, dynamic>> maps = await db.query(
      tableRosterModel,
      where: where,
      whereArgs: whereArgs,
    );
    if (maps.isEmpty) {
      Log.e(tag, 'roster model not found by id: $pk');
      return null;
    }
    final Map<String, dynamic> rosterItem = maps[0];
    return toModel(rosterItem);
  }

  Future<List<RosterModel>> getBy(String ownerJid,
      {String? jid, bool isGroup = false}) async {
    final db = await openDB();
    String where = 'ownerJid=?';
    List<Object?> whereArgs = [ownerJid];

    if (isGroup) {
      where += ' AND isGroup=1';
    } else {
      // Почему то isGroup!=1 не подходит (если в поле NULL)
      where += ' AND (isGroup is NULL OR isGroup=0)';
    }

    if (jid != null) {
      where += ' AND jid=?';
      whereArgs.add(jid);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      tableRosterModel,
      where: where,
      whereArgs: whereArgs,
    );
    List<RosterModel> result = List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
    storeFetched(result);
    return result;
  }

  Future<List<RosterModel>> getByOwner(String userJid) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableRosterModel,
      where: 'ownerJid=?',
      whereArgs: [userJid],
    );
    List<RosterModel> result = List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
    storeFetched(result);
    return result;
  }

  Future<List<RosterModel>> getAll() async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableRosterModel,
    );
    List<RosterModel> result = List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
    storeFetched(result);
    return result;
  }

  Future<String> getPhoto({Function? ifDownloaded}) async {
    /* Возвращает аватарку пользователя
    */
    if (avatar != null && avatar != '') {
      // TODO: возвращать кэшированное изображение (пишется ссылка в базу)
      return avatar!;
    }
    return DEFAULT_AVATAR;
  }

}
