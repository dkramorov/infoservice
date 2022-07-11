import 'package:infoservice/db/tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../helpers/log.dart';

class DBChatInstance {
  static Database? instance;
}

Future<Database> openChatDB() async {
  const int dbVersion = 3; // Версия базы данных
  const String dbName = 'chatDB.db';
  if (DBChatInstance.instance != null) {
    return DBChatInstance.instance!;
  }

  /* UserChatModel */
  const String userChatLastLogin = 'lastLogin int';
  const String userChatPhoto = 'photo text';
  const String userChatPhotoUrl = 'photoUrl text';
  const String userChatBirthday = 'birthday text';
  const String userChatGender = 'gender int';
  const String userChatEmail = 'email text';
  const String userChatName = 'name text';
  const String userChatStatus = 'status text';
  const String userChatTime = 'time int';
  const String userChatMsg = 'msg text';

  final String createTableUserChatModel = 'CREATE TABLE IF NOT EXISTS' +
      ' $tableUserChatModel(' +
      'id INTEGER PRIMARY KEY, login TEXT, passwd TEXT' +
      ', $userChatLastLogin' +
      ', $userChatPhoto' +
      ', $userChatPhotoUrl' +
      ', $userChatBirthday' +
      ', $userChatGender' +
      ', $userChatEmail' +
      ', $userChatName' +
      ', $userChatStatus' +
      ', $userChatTime' +
      ', $userChatMsg' +
      ')';

  /* CallHistoryModel */
  final String callHistoryTime = 'time text';
  final String callHistoryDuration = 'duration int';
  final String callHistorySource = 'source text';
  final String callHistoryDest = 'dest text';
  final String callHistoryAction = 'action text';
  final String callHistoryCompanyId = 'companyId int';
  final String callHistoryIsSip = 'isSip int';
  final String createTableCallHistoryModel = 'CREATE TABLE IF NOT EXISTS' +
      ' ${tableCallHistoryModel}(' +
      'id INTEGER PRIMARY KEY, login TEXT' +
      ', $callHistoryTime' +
      ', $callHistoryDuration' +
      ', $callHistorySource' +
      ', $callHistoryDest' +
      ', $callHistoryAction' +
      ', $callHistoryCompanyId' +
      ', $callHistoryIsSip'
      ')';
  final String alterTableCallHistoryAddCompanyId =
      'ALTER TABLE $tableCallHistoryModel add $callHistoryIsSip';

  void createTables(Database db) {
    db.execute(createTableUserChatModel);
    db.execute(createTableCallHistoryModel);
  }

  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), dbName),

    onCreate: (db, version) {
      createTables(db);
    },
    onUpgrade: (db, oldVersion, newVersion) {
      Log.i('--- DB UPGRADE ---', '$oldVersion=>$newVersion');
      createTables(db);
      if (oldVersion <= 3) {
        db.execute(alterTableCallHistoryAddCompanyId);
      }
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: dbVersion,
  );
  DBChatInstance.instance = await database;
  return database;
}
