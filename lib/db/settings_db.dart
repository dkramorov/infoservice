import 'package:infoservice/db/tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../helpers/log.dart';

class DBSettingsInstance {
  static Database? instance;
}

Future<Database> openSettingsDB() async {
  const int dbVersion = 7; // Версия базы данных
  const String dbName = 'settingsDB.db';

  if (DBSettingsInstance.instance != null) {
    /*
    try {
      int version = await DBSettingsInstance.instance!.getVersion();
      print('-----> version $version');
      return DBSettingsInstance.instance!;
    } catch (e) {
      print('_________ $e');
      DBSettingsInstance.instance = null;
    }

    */
    return DBSettingsInstance.instance!;
  }

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

  /* UserSettings */
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
  }

  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), dbName),

    onCreate: (db, version) async {
      await createTables(db);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
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
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: dbVersion,
  );
  DBSettingsInstance.instance = await database;
  return database;
}
