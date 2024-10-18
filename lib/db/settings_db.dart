import 'package:infoservice/db/tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../helpers/log.dart';

class DBSettingsInstance {
  static Database? instance;
}

Future<Database> openSettingsDB() async {
  const int dbVersion = 10; // Версия базы данных
  const String dbName = 'settingsDB.db';

  if (DBSettingsInstance.instance != null) {
    return DBSettingsInstance.instance!;
  }

  /* SharedContacts */
  const String date = 'date text';
  const String ownerJid = 'owner_jid text';
  const String friendJid = 'friend_jid text';
  const String answer = 'answer text';

  const String createTableSharedContactsRequest = 'CREATE TABLE IF NOT EXISTS'
      ' $tableSharedContactsRequestModel('
      'id INTEGER PRIMARY KEY'
      ', $date'
      ', $ownerJid'
      ', $friendJid'
      ', $answer'
      ')';

  const String requestId = 'requestId int';
  const String login = 'login text';
  const String name = 'name text';

  const String alterTableSharedContactsRequestAddAnswer =
      'ALTER TABLE $tableSharedContactsRequestModel add $answer';

  const String createTableSharedContacts = 'CREATE TABLE IF NOT EXISTS'
      ' $tableSharedContactsModel('
      'id INTEGER PRIMARY KEY'
      ', $requestId'
      ', $login'
      ', $name'
      ')';

  const String alterTableSharedContactsAddRequestId =
      'ALTER TABLE $tableSharedContactsModel add $requestId';
  const String alterTableSharedContactsDropOwnerJid =
      'ALTER TABLE $tableSharedContactsModel drop ownerJid';
  const String alterTableSharedContactsDropFriendJid =
      'ALTER TABLE $tableSharedContactsModel drop friendJid';
  const String alterTableSharedContactsDropDate =
      'ALTER TABLE $tableSharedContactsModel drop date';

  /* UserSettings */
  const String userName = 'name text';
  const String userPhoto = 'photo text';
  const String userPasswd = 'passwd text';
  const String userJid = 'jid text';
  const String userCredentialsHash = 'credentialsHash text';
  const String userBirthday = 'birthday text';
  const String userGender = 'gender int';
  const String userEmail = 'email text';
  const String userToken = 'token text';
  const String userPhone = 'phone text';
  const String userIsDropped = 'isDropped int';
  const String userIsXmppRegistered = 'isXmppRegistered int';
  const String userRosterVersion = 'rosterVersion int';

  const String createTableUserSettings = 'CREATE TABLE IF NOT EXISTS'
      ' $tableUserSettingsModel('
      'id INTEGER PRIMARY KEY'
      ', $userName'
      ', $userPhoto'
      ', $userPasswd'
      ', $userJid'
      ', $userCredentialsHash'
      ', $userBirthday'
      ', $userGender'
      ', $userEmail'
      ', $userToken'
      ', $userPhone'
      ', $userIsDropped'
      ', $userIsXmppRegistered'
      ', $userRosterVersion'
      ')';

  const String alterTableUserSettingsModelAddIsXmppRegistered =
      'ALTER TABLE $tableUserSettingsModel add $userIsXmppRegistered';

  const String alterTableUserSettingsModelAddRosterVersion =
      'ALTER TABLE $tableUserSettingsModel add $userRosterVersion';

  /* BGTasks */
  const String taskName = 'name text';
  const String taskState = 'state text';
  const String taskData = 'data text';
  const String taskPriority = 'priority int';

  const String createTableBGTasks = 'CREATE TABLE IF NOT EXISTS'
      ' $tableBGTasksModel('
      'id INTEGER PRIMARY KEY'
      ', $taskName'
      ', $taskState'
      ', $taskData'
      ', $taskPriority'
      ')';

  const String alterTableBGTasksModelAddPriority =
      'ALTER TABLE $tableBGTasksModel add $taskPriority';

  Future<void> createTables(Database db) async {
    await db.execute(createTableUserSettings);
    await db.execute(createTableBGTasks);
    await db.execute(createTableSharedContactsRequest);
    await db.execute(createTableSharedContacts);
  }

  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), dbName),

    onCreate: (db, version) async {
      await createTables(db);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      const String errDbUpgrade = '[ERROR DB UPGRADE]';
      Log.i('--- DB UPGRADE ---', '$oldVersion=>$newVersion');
      await createTables(db);
      if (oldVersion < 2) {
        await db.execute(alterTableUserSettingsModelAddIsXmppRegistered);
      }
      if (oldVersion < 3) {
        await db.execute(alterTableUserSettingsModelAddRosterVersion);
      }
      if (oldVersion < 4) {
        await db.execute(alterTableBGTasksModelAddPriority);
      }
      if (oldVersion <= 8) {
        try {
          await db.execute(alterTableSharedContactsAddRequestId);
        } catch (ex) {
          Log.d(errDbUpgrade,
              'alterTableSharedContactsAddRequestId, ${ex.toString()}');
        }
        try {
          await db.execute(alterTableSharedContactsDropOwnerJid);
        } catch (ex) {
          Log.d(errDbUpgrade,
              'alterTableSharedContactsDropOwnerJid, ${ex.toString()}');
        }
        try {
          await db.execute(alterTableSharedContactsDropFriendJid);
        } catch (ex) {
          Log.d(errDbUpgrade,
              'alterTableSharedContactsDropFriendJid, ${ex.toString()}');
        }
        try {
          await db.execute(alterTableSharedContactsDropDate);
        } catch (ex) {
          Log.d(errDbUpgrade,
              'alterTableSharedContactsDropDate, ${ex.toString()}');
        }
      }
      if (oldVersion <= 9) {
        try {
          await db.execute(alterTableSharedContactsRequestAddAnswer);
        } catch (ex) {
          Log.d(errDbUpgrade,
              'alterTableSharedContactsRequestAddAnswer, ${ex.toString()}');
        }
      }
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: dbVersion,
  );
  DBSettingsInstance.instance = await database;
  return database;
}
