import 'package:infoservice/db/tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../helpers/log.dart';

class DBChatInstance {
  static Database? instance;
}

Future<Database> openChatDB() async {
  const int dbVersion = 31; // Версия базы данных
  const String dbName = 'chatDB.db';
  if (DBChatInstance.instance != null) {
    return DBChatInstance.instance!;
  }

  /* PendingMessages */
  const String pendingMessageId = 'msgId int';
  const String pendingMessageTime = 'time int';
  const String pendingMessageUid = 'uid text';

  const String createTablePendingMessageModel = 'CREATE TABLE IF NOT EXISTS'
      ' $tablePendingMessageModel('
      'id INTEGER PRIMARY KEY'
      ', $pendingMessageId'
      ', $pendingMessageTime'
      ', $pendingMessageUid'
      ')';

  const String alterTablePendingMessageAddUid =
      'ALTER TABLE $tablePendingMessageModel add $pendingMessageUid';

  const String createIndexPendingMessageTime = 'CREATE INDEX IF NOT EXISTS idx_pending_message_on_time'
      ' ON $tablePendingMessageModel (time)';

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
  const String userChatDropPersonalData = 'dropPersonalData int';

  const String createTableUserChatModel = 'CREATE TABLE IF NOT EXISTS'
      ' $tableUserChatModel('
      'id INTEGER PRIMARY KEY, login TEXT, passwd TEXT'
      ', $userChatLastLogin'
      ', $userChatPhoto'
      ', $userChatPhotoUrl'
      ', $userChatBirthday'
      ', $userChatGender'
      ', $userChatEmail'
      ', $userChatName'
      ', $userChatStatus'
      ', $userChatTime'
      ', $userChatMsg'
      ', $userChatDropPersonalData'
      ')';
  const String alterTableUserChatAddPersonalData =
      'ALTER TABLE $tableUserChatModel add $userChatDropPersonalData';

  /* CallHistoryModel */
  const String callHistoryName = 'name text';
  const String callHistoryTime = 'time text';
  const String callHistoryDuration = 'duration int';
  const String callHistorySource = 'source text';
  const String callHistoryDest = 'dest text';
  const String callHistoryAction = 'action text';
  const String callHistoryCompanyId = 'companyId int';
  const String callHistoryIsSip = 'isSip int';
  const String createTableCallHistoryModel = 'CREATE TABLE IF NOT EXISTS'
      ' $tableCallHistoryModel('
      'id INTEGER PRIMARY KEY, login TEXT'
      ', $callHistoryName'
      ', $callHistoryTime'
      ', $callHistoryDuration'
      ', $callHistorySource'
      ', $callHistoryDest'
      ', $callHistoryAction'
      ', $callHistoryCompanyId'
      ', $callHistoryIsSip'
      ')';
  const String alterTableCallHistoryAddCompanyId =
      'ALTER TABLE $tableCallHistoryModel add $callHistoryIsSip';
  const String alterTableCallHistoryAddName =
      'ALTER TABLE $tableCallHistoryModel add $callHistoryName';

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
      ' ${tableContactsModel}('
      'id INTEGER PRIMARY KEY'
      ', $contactsIdentifier'
      ', $contactsDisplayName'
      ', $contactsGivenName'
      ', $contactsMiddleName'
      ', $contactsFamilyName'
      ', $contactsPrefix'
      ', $contactsSuffix'
      ', $contactsCompany'
      ', $contactsJobTitle'
      ', $contactsAndroidAccountType'
      ', $contactsAndroidAccountName'
      ', $contactsBirthday'
      ', $contactsAvatar'
      ', $contactsPostalAddresses'
      ', $contactsEmails'
      ', $contactsPhones'
      ', $contactsHasXMPP'
      ', $contactsUpdated'
      ')';
  const String alterTableContactsAddUpdated =
      'ALTER TABLE $tableContactsModel add $contactsUpdated';
  const String alterTableContactsAddHasXMPP =
      'ALTER TABLE $tableContactsModel add $contactsHasXMPP';

  /* RosterModel */
  const String rosterName = 'name text';
  const String rosterJid = 'jid text';
  const String rosterAvatar = 'avatar text';
  const String rosterLastMessageId = 'lastMessageId text';
  const String rosterLastMessage = 'lastMessage text';
  const String rosterLastMessageTime = 'lastMessageTime int';
  const String rosterLastReadMessageTime = 'lastReadMessageTime int';
  const String rosterIsGroup = 'isGroup int';

  const String rosterNewMessagesCount = 'newMessagesCount int';
  const String rosterOwnerJid = 'ownerJid text';

  const String createTableRosterModel = 'CREATE TABLE IF NOT EXISTS' +
      ' $tableRosterModel('
      'id INTEGER PRIMARY KEY'
      ', $rosterName'
      ', $rosterJid'
      ', $rosterAvatar'
      ', $rosterLastMessageId'
      ', $rosterLastMessage'
      ', $rosterLastMessageTime'
      ', $rosterLastReadMessageTime'
      ', $rosterNewMessagesCount'
      ', $rosterOwnerJid'
      ', $rosterIsGroup'
      ')';

  const String alterTableRosterAddLastMessageId =
      'ALTER TABLE $tableRosterModel add $rosterLastMessageId';
  const String alterTableRosterAddLastReadMessageTime =
      'ALTER TABLE $tableRosterModel add $rosterLastReadMessageTime';
  const String alterTableRosterAddIsGroup =
      'ALTER TABLE $tableRosterModel add $rosterIsGroup';

  /* ChatMessageModel */
  const String chatMessageId = 'mid text';
  const String chatMessageCustomText = 'customText text';
  const String chatMessageFrom = 'fromJid text';
  const String chatMessageTo = 'toJid text';
  const String chatMessageSenderJid = 'senderJid text';
  const String chatMessageTime = 'time int';
  const String chatMessageType = 'type text';
  const String chatMessageBody = 'body text';
  const String chatMessageMsgtype = 'msgtype text';
  const String chatMessageBubbleType = 'bubbleType text';
  const String chatMessageMediaURL = 'mediaURL text';
  const String chatMessageIsReadSent = 'isReadSent int';
  const String chatMessageAnswered = 'answered int';

  const String createTableChatMessageModel = 'CREATE TABLE IF NOT EXISTS'
      ' $tableChatMessageModel('
      'id INTEGER PRIMARY KEY '
      ', $chatMessageId'
      ', $chatMessageCustomText'
      ', $chatMessageFrom'
      ', $chatMessageTo'
      ', $chatMessageSenderJid'
      ', $chatMessageTime'
      ', $chatMessageType'
      ', $chatMessageBody'
      ', $chatMessageMsgtype'
      ', $chatMessageBubbleType'
      ', $chatMessageMediaURL'
      ', $chatMessageIsReadSent'
      ', $chatMessageAnswered'
      ')';

  const String createIndexChatMessageFromAndTo = 'CREATE INDEX IF NOT EXISTS idx_chat_message_on_from_and_to'
      ' ON $tableChatMessageModel (fromJid, toJid)';
  const String createIndexChatMessageFrom = 'CREATE INDEX IF NOT EXISTS idx_chat_message_on_from'
      ' ON $tableChatMessageModel (fromJid)';
  const String createIndexChatMessageTo = 'CREATE INDEX IF NOT EXISTS idx_chat_message_on_to'
      ' ON $tableChatMessageModel (toJid)';
  const String createIndexChatMessageTime = 'CREATE INDEX IF NOT EXISTS idx_chat_message_on_time'
      ' ON $tableChatMessageModel (time)';
  const String createIndexChatMessageMid = 'CREATE INDEX IF NOT EXISTS idx_chat_message_on_mid'
      ' ON $tableChatMessageModel (mid)';
  const String createIndexChatMessageIsReadSent = 'CREATE INDEX IF NOT EXISTS idx_chat_message_on_is_read_sent'
      ' ON $tableChatMessageModel (isReadSent)';
  const String createIndexChatMsgType = 'CREATE INDEX IF NOT EXISTS idx_chat_message_on_msgtype'
      ' ON $tableChatMessageModel (msgtype)';

  const String dropTableChatMessageModel = 'DROP TABLE IF EXISTS $tableChatMessageModel';

  Future<void> createTables(Database db) async {
    await db.execute(createTableUserChatModel);
    await db.execute(createTableCallHistoryModel);
    await db.execute(createTableContactsModel);
    await db.execute(createTableRosterModel);
    await db.execute(createTableChatMessageModel);
    await db.execute(createTablePendingMessageModel);

    await db.execute(createIndexChatMessageFromAndTo);
    await db.execute(createIndexChatMessageFrom);
    await db.execute(createIndexChatMessageTo);
    await db.execute(createIndexChatMessageTime);
    await db.execute(createIndexChatMessageMid);
    await db.execute(createIndexChatMessageIsReadSent);
    await db.execute(createIndexPendingMessageTime);
    await db.execute(createIndexChatMsgType);
  }

  const String alterTableChatMessageRenameMyJid2ToJid =
      'ALTER TABLE $tableChatMessageModel RENAME COLUMN myJid TO toJid';

  const String alterTableChatMessageAddAnswered =
      'ALTER TABLE $tableChatMessageModel ADD $chatMessageAnswered';

  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), dbName),

    onCreate: (db, version) async {
      await createTables(db);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      Log.i('--- DB UPGRADE ---', '$oldVersion=>$newVersion');
      await createTables(db);
      if (oldVersion < 3) {
        await db.execute(alterTableCallHistoryAddCompanyId);
      }
      if (oldVersion < 5) {
        await db.execute(createTableContactsModel);
      }
      if (oldVersion < 6) {
        await db.execute(alterTableContactsAddUpdated);
      }
      if (oldVersion < 7) {
        await db.execute(alterTableContactsAddHasXMPP);
      }
      if (oldVersion < 10) {
        await db.execute(alterTableRosterAddLastMessageId);
      }
      if (oldVersion < 18) {
        await db.execute(alterTableChatMessageRenameMyJid2ToJid);
      }
      if (oldVersion < 20) {
        await db.execute(alterTableRosterAddLastReadMessageTime);
      }
      if (oldVersion < 21) {
        await db.execute(dropTableChatMessageModel);
        await db.execute(createTableChatMessageModel);
        await db.execute(createIndexChatMessageFromAndTo);
        await db.execute(createIndexChatMessageFrom);
        await db.execute(createIndexChatMessageTo);
        await db.execute(createIndexChatMessageTime);
        await db.execute(createIndexChatMessageMid);
      }
      if (oldVersion < 22) {
        await db.execute(alterTableRosterAddIsGroup);
      }
      if (oldVersion < 23) {
        await db.execute(alterTableUserChatAddPersonalData);
      }
      if (oldVersion < 24) {
        await db.execute(alterTableCallHistoryAddName);
      }
      if (oldVersion < 26) {
        await db.execute(alterTablePendingMessageAddUid);
      }
      if (oldVersion < 29) {
        await db.execute(createIndexChatMsgType);
      }
      if (oldVersion < 30) {
        await db.execute(alterTableChatMessageAddAnswered);
      }
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: dbVersion,
  );
  DBChatInstance.instance = await database;
  return database;
}
