import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db/settings_db.dart';
import '../db/tables.dart';
import '../helpers/network.dart';
import 'abstract_model.dart';


/* Фоновые задачи
*/
class BGTasksModel extends AbstractModel {

  static bool bgTimerTaskRunning = false;
  static bool inUpdateTimer = false;
  static int counter = 0;
  static BGTasksModel? prev;

  static const String taskCreatedKey = 'taskCreated';
  static const String taskStartedKey = 'taskStarted';
  static const String taskFinishedKey = 'taskFinished';
  // DB
  static const String registerUserTaskKey = 'registerUserTask';
  static const String unregisterUserTaskKey = 'unregisterUserTask';
  static const String checkRegUserTaskKey = 'checkRegUserTask';
  static const String loadRosterTaskKey = 'loadRosterTaskKey';
  static const String getContactsFromPhoneTaskKey = 'getContactsFromPhoneTaskKey';
  static const String dropRosterTaskKey = 'dropRosterTaskKey';
  static const String addRosterTaskKey = 'addRosterTaskKey';
  static const String addMUCTaskKey = 'addMUCTaskKey';
  static const String sendTextMessageTaskKey = 'sendTextMessageTaskKey';
  static const String sendDeliveryReceiptTaskKey = 'sendDeliveryReceiptTaskKey';
  static const String sendFileMessageTaskKey = 'sendFileMessageTaskKey';
  static const String sendTextGroupMessageTaskKey = 'sendTextGroupMessageTaskKey';
  static const String sendFileGroupMessageTaskKey = 'sendFileGrpupMessageTaskKey';
  static const String checkMeInGroupVCardTaskKey = 'checkMeInGroupVCardTaskKey';
  static const String updateMyVCardTaskKey = 'updateMyVCardTaskKey';
  static const String loginUserTaskKey = 'loginUserTask';

  // SharedPreferences
  static const String addRosterPrefKey = 'addUserResult';

  static const int authPriority = 10;

  @override
  Future<Database> openDB() async {
    //print('___openSettingsDB___');
    return await openSettingsDB();
  }

  Key key = UniqueKey();

  int? id; // null if we need new row
  String? name;
  String? state;
  String? data;
  int? priority;

  String getTableName() {
    return tableBGTasksModel;
  }

  @override
  String get tableName => getTableName();

  BGTasksModel({
    this.id,
    this.name,
    this.state,
    this.data,
    this.priority,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'data': data,
      'priority': priority,
    };
  }

  /* Перегоняем данные из базы в модельку */
  BGTasksModel toModel(Map<String, dynamic> dbItem) {
    return BGTasksModel(
      id: dbItem['id'],
      name: dbItem['name'],
      state: dbItem['state'],
      data: dbItem['data'],
      priority: dbItem['priority'],
    );
  }

  @override
  String toString() {
    final String table = getTableName();
    return '$table{id: $id, name: $name, state: $state, data: $data, priority: $priority}';
  }

  Map<String, dynamic> getJsonData() {
    if (data != null && data != '') {
      return jsonDecode(data!);
    }
    return {};
  }

  Future<BGTasksModel?> getTask() async {
    final db = await openDB();
    if (!db.isOpen) {
      print('--- DB CLOSED ---');
      return null;
    }
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      //where: 'state=?',
      //whereArgs: [taskCreatedKey],
      orderBy: 'priority DESC',
    );
    if (maps.isEmpty) {
      return null;
    }
    final Map<String, dynamic> task = maps[0];
    return toModel(task);
  }

  static Future<BGTasksModel> createTask(String key,
      Map<String, dynamic> data, {int priority = 1}) async {
    /* Вспомогательная функция для создания задачи */
    BGTasksModel task = BGTasksModel(
        name: key,
        state: BGTasksModel.taskCreatedKey,
        data: jsonEncode(data),
        priority: priority,
    );
    int pk = await task.insert2Db();
    task.id = pk;
    return task;
  }

  static Future<BGTasksModel> createLoginUserTask() async {
    /* Создаем задачу на регистрацию в xmpp
    */
    return await createTask(BGTasksModel.loginUserTaskKey,
        {}, priority: authPriority);
  }

  static Future<BGTasksModel> createRegisterTask(Map<String, dynamic> userData) async {
    /* Создаем задачу на регистрацию в xmpp
    */
    // 'value is String || value is num': 'string' OR 'number'
    //await sendAnalyticsEvent('login', userData); // isSimpleReg=false
    return await createTask(BGTasksModel.registerUserTaskKey,
        userData, priority: authPriority);
  }

  static Future<BGTasksModel> createUnregisterTask() async {
    /* Создаем задачу на выход из xmpp
    */
    return await createTask(BGTasksModel.unregisterUserTaskKey,
        {}, priority: authPriority);
  }

  static Future<BGTasksModel> createCheckRegTask() async {
    /* Создаем задачу на проверку авторизации
    */
    return await createTask(BGTasksModel.checkRegUserTaskKey,
        {}, priority: authPriority);
  }

  static Future<BGTasksModel> loadRosterTask() async {
    /* Создаем задачу на получение ростера
    */
    return await createTask(BGTasksModel.loadRosterTaskKey, {});
  }

  static Future<BGTasksModel> getContactsFromPhoneTask() async {
    return await createTask(BGTasksModel.getContactsFromPhoneTaskKey, {});
  }

  static Future<BGTasksModel> dropRosterTask(Map<String, dynamic> data) async {
    return await createTask(BGTasksModel.dropRosterTaskKey, data);
  }

  static Future<BGTasksModel> addRosterTask(Map<String, dynamic> data) async {
    return await createTask(BGTasksModel.addRosterTaskKey, data);
  }

  static Future<BGTasksModel> addMUCTask(Map<String, dynamic> data) async {
    return await createTask(BGTasksModel.addMUCTaskKey, data);
  }

  static Future<BGTasksModel> sendTextMessageTask(Map<String, dynamic> data) async {
    return await createTask(BGTasksModel.sendTextMessageTaskKey, data);
  }

  static Future<BGTasksModel> sendDeliveryReceiptTask(Map<String, dynamic> data) async {
    return await createTask(BGTasksModel.sendDeliveryReceiptTaskKey, data);
  }

  static Future<BGTasksModel> sendFileMessageTask(Map<String, dynamic> data) async {
    return await createTask(BGTasksModel.sendFileMessageTaskKey, data);
  }

  static Future<BGTasksModel> sendTextGroupMessageTask(Map<String, dynamic> data) async {
    return await createTask(BGTasksModel.sendTextGroupMessageTaskKey, data);
  }

  static Future<BGTasksModel> sendFileGroupMessageTask(Map<String, dynamic> data) async {
    return await createTask(BGTasksModel.sendFileGroupMessageTaskKey, data);
  }

  static Future<BGTasksModel> checkMeInGroupVCardTask(Map<String, dynamic> data) async {
    return await createTask(BGTasksModel.checkMeInGroupVCardTaskKey, data);
  }

  static Future<BGTasksModel> updateMyVCardTask(Map<String, dynamic> data) async {
    /* Создаем задачу на обновление своего vCard
    */
    return await createTask(BGTasksModel.updateMyVCardTaskKey, data);
  }
}
