import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../db/chat_db.dart';
import '../db/tables.dart';
import 'abstract_model.dart';
import 'companies/orgs.dart';

class CallHistoryModel extends AbstractModel {
  static const String TAG = 'UserHistoryModel';

  @override
  Future<Database> openDB() async {
    //print('___openChatDB___');
    return await openChatDB();
  }

  Key key = UniqueKey();

  int? id; // null if we need new row
  String? login;
  String? name;
  String? time;
  int? duration;
  String? source; // от кого-то
  String? dest; // кому мы наябываем
  String? action; // outgoing/incoming call/chat
  int? companyId; // Ид компании (т/к компании в другой базе)
  Orgs? company;
  int isSip;

  String getTableName() {
    return tableCallHistoryModel;
  }

  @override
  String get tableName => getTableName();

  CallHistoryModel({
    this.id,
    this.login,
    this.name,
    this.time,
    this.duration,
    this.source,
    this.dest,
    this.action,
    this.companyId,
    this.isSip = 0,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'login': login,
      'name': name,
      'time': time,
      'duration': duration,
      'source': source,
      'dest': dest,
      'action': action,
      'companyId': companyId,
      'isSip': isSip,
    };
  }

  /* Перегоняем данные из базы в модельку */
  static CallHistoryModel toModel(Map<String, dynamic> dbItem) {
    return CallHistoryModel(
      id: dbItem['id'],
      login: dbItem['login'],
      name: dbItem['name'],
      time: dbItem['time'],
      duration: dbItem['duration'],
      source: dbItem['source'],
      dest: dbItem['dest'],
      action: dbItem['action'],
      companyId: dbItem['companyId'],
      isSip: dbItem['isSip'],
    );
  }

  @override
  String toString() {
    final String table = getTableName();
    return '$table{id: $id, login: $login, name: $name, time: $time,'
        ' duration: $duration, source: $source, dest: $dest, action: $action,'
        'companyId: $companyId, isSip: $isSip';
  }

  Future<List<CallHistoryModel>> getAllHistory(String login) async {
    final db = await openDB();

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'login = ?',
      whereArgs: [login],
    );

    HashMap<int, Orgs?> idsCompanies = HashMap();
    for (Map<String, dynamic> item in maps) {
      if (item['companyId'] != null && item['companyId'] != 0) {
        idsCompanies[item['companyId']] = null;
      }
    }

    if (idsCompanies.isNotEmpty) {
      await Orgs().getOrgsByIds(idsCompanies);
    }

    return List.generate(maps.length, (i) {
      CallHistoryModel historyModel = toModel(maps[i]);
      if (historyModel.companyId != null &&
          historyModel.companyId != 0 &&
          idsCompanies.containsKey(historyModel.companyId)) {
        historyModel.company = idsCompanies[historyModel.companyId];
      }
      return historyModel;
    });
  }
}
