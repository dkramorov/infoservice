import 'package:infoservice/db/tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../helpers/log.dart';

class DBChatInstance {
  static Database? instance;
}

Future<Database> openChatDB() async {
  const int dbVersion = 10; // Версия базы данных
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

  const String createTableUserChatModel = 'CREATE TABLE IF NOT EXISTS' +
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
  const String callHistoryTime = 'time text';
  const String callHistoryDuration = 'duration int';
  const String callHistorySource = 'source text';
  const String callHistoryDest = 'dest text';
  const String callHistoryAction = 'action text';
  const String callHistoryCompanyId = 'companyId int';
  const String callHistoryIsSip = 'isSip int';
  const String createTableCallHistoryModel = 'CREATE TABLE IF NOT EXISTS' +
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
  const String alterTableCallHistoryAddCompanyId =
      'ALTER TABLE $tableCallHistoryModel add $callHistoryIsSip';

  /* ContactsModel (in phone address book) */
  const String contactsIdentifier = 'identifier text';
  const String contactsDisplayName = 'displayName text';
  const String contactsGivenName = 'givenName text';
  const String contactsMiddleName = 'middleName text';
  const String contactsFamilyName = 'familyName text';
  const String contactsPrefix = 'prefix text';
  const String contactsSuffix = 'suffix text';
  const String contactsCompany = 'company text';
  const String contactsJobTitle = 'jobTitle text';
  const String contactsAndroidAccountType = 'androidAccountType text';
  const String contactsAndroidAccountName = 'androidAccountName text';
  const String contactsBirthday = 'birthday text';
  const String contactsAvatar = 'avatar text';
  const String contactsPostalAddresses = 'postalAddresses text';
  const String contactsEmails = 'emails text';
  const String contactsPhones = 'phones text';
  const String contactsHasXMPP = 'hasXMPP int';
  const String contactsUpdated = 'updated int';

  const String createTableContactsModel = 'CREATE TABLE IF NOT EXISTS' +
      ' ${tableContactsModel}(' +
      'id INTEGER PRIMARY KEY' +
      ', $contactsIdentifier' +
      ', $contactsDisplayName' +
      ', $contactsGivenName' +
      ', $contactsMiddleName' +
      ', $contactsFamilyName' +
      ', $contactsPrefix' +
      ', $contactsSuffix' +
      ', $contactsCompany' +
      ', $contactsJobTitle' +
      ', $contactsAndroidAccountType' +
      ', $contactsAndroidAccountName' +
      ', $contactsBirthday' +
      ', $contactsAvatar' +
      ', $contactsPostalAddresses' +
      ', $contactsEmails' +
      ', $contactsPhones' +
      ', $contactsHasXMPP' +
      ', $contactsUpdated' +
      ')';
  const String alterTableContactsAddUpdated =
      'ALTER TABLE $tableContactsModel add $contactsUpdated';
  const String alterTableContactsAddHasXMPP =
      'ALTER TABLE $tableContactsModel add $contactsHasXMPP';

  /* RosterModel */
  const String rosterName = 'name text';
  const String rosterJid = 'jid text';
  const String rosterAvatar = 'avatar text';
  const String rosterLastMessage = 'lastMessage text';
  const String rosterLastMessageTime = 'lastMessageTime int';
  const String rosterNewMessagesCount = 'newMessagesCount int';
  const String rosterOwnerJid = 'ownerJid text';

  const String createTableRosterModel = 'CREATE TABLE IF NOT EXISTS' +
      ' $tableRosterModel(' +
      'id INTEGER PRIMARY KEY' +
      ', $rosterName' +
      ', $rosterJid' +
      ', $rosterAvatar' +
      ', $rosterLastMessage' +
      ', $rosterLastMessageTime' +
      ', $rosterNewMessagesCount' +
      ', $rosterOwnerJid' +
      ')';

  void createTables(Database db) {
    db.execute(createTableUserChatModel);
    db.execute(createTableCallHistoryModel);
    db.execute(createTableContactsModel);
    db.execute(createTableRosterModel);
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
      if (oldVersion <= 5) {
        db.execute(createTableContactsModel);
      }
      if (oldVersion <= 6) {
        db.execute(alterTableContactsAddUpdated);
      }
      if (oldVersion <= 7) {
        db.execute(alterTableContactsAddHasXMPP);
      }
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: dbVersion,
  );
  DBChatInstance.instance = await database;
  return database;
}
