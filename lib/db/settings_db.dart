import 'package:infoservice/db/tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../helpers/log.dart';

class DBSettingsInstance {
  static Database? instance;
}

Future<Database> openSettingsDB() async {
  const int dbVersion = 3; // Версия базы данных
  const String dbName = 'settingsDB.db';
  if (DBSettingsInstance.instance != null) {
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

  const String createTableBGTasks = 'CREATE TABLE IF NOT EXISTS'
      ' $tableBGTasksModel('
      'id INTEGER PRIMARY KEY'
      ', $taskName'
      ', $taskState'
      ', $taskData'
      ')';

  void createTables(Database db) {
    db.execute(createTableUserSettings);
    db.execute(createTableBGTasks);
  }

  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), dbName),

    onCreate: (db, version) {
      createTables(db);
    },
    onUpgrade: (db, oldVersion, newVersion) {
      Log.i('--- DB UPGRADE ---', '$oldVersion=>$newVersion');
      createTables(db);
      if (oldVersion <= 2) {
        db.execute(alterTableUserSettingsModelAddIsXmppRegistered);
      }
      if (oldVersion <= 3) {
        db.execute(alterTableUserSettingsModelAddRosterVersion);
      }
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: dbVersion,
  );
  DBSettingsInstance.instance = await database;
  return database;
}
