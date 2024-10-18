import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:infoservice/services/shared_preferences_manager.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive_io.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:infoservice/services/permissions_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/log.dart';
import '../helpers/network.dart';
import '../helpers/phone_mask.dart';
import '../models/contact_model.dart';
import '../models/roster_model.dart';
import '../models/user_settings_model.dart';
import '../settings.dart';

class ContactsManager {
  static const String tag = 'ContactsManager';
  static List<String> debugEvents = [];
  static Future<void> createContact(
      {String name = 'Test', String phone = '89000000001'}) async {
    /* Внесение контакта
    for (int i=0; i<20000; i++) {
      String phone = (89000000001 + i).toString();
      ContactsManager.createContact(name: 'test_$i', phone: phone).then((result) {
        print("+++++++++++");
      });
    }
    */
    Contact contact = Contact(
      displayName: name,
      givenName: name,
      middleName: name,
      prefix: '',
      suffix: '',
      familyName: '',
      company: '',
      jobTitle: '',
      phones: [Item(label: 'mobile', value: phone)],
    );
    await ContactsService.addContact(contact);
  }

  static Future<void> refreshContactsHelper() async {
    // Отладка
    debugEvents = [];
    SharedPreferences prefs =
        await SharedPreferencesManager.getSharedPreferences();
    final debugOn = prefs.getBool(DEBUG_ON);

    bool granted = await PermissionsManager().checkPermissions('contacts');
    debugEvents.add('Разрешения на контакты: ${granted.toString()}');
    if (!granted) {
      Log.i(tag, 'Contacts permissions absent!');
      return;
    }
    UserSettingsModel? userSettings = await UserSettingsModel().getUser();
    debugEvents.add('Пользователь: ${userSettings.toString()}');
    if (userSettings == null) {
      Log.i(tag, 'User is null!');
      return;
    }

    List<Contact> contactsFromPhone =
        await ContactsService.getContacts(withThumbnails: false);
    debugEvents
        .add('Получено контактов с телефона: ${contactsFromPhone.length}');
    Map<String, Contact> contacts =
        await getPhoneContactsMap(contactsFromPhone);
    debugEvents.add('Подготовлено к сверке: ${contacts.length}');

    bool isNew = false;
    List<RosterModel> myRoster =
        await RosterModel().getByOwner(userSettings.jid ?? '');
    debugEvents.add('Кол-во контактов в ростере: ${myRoster.length}');
    for (RosterModel rosterModel in myRoster) {
      String login = rosterModel.jid ?? '';
      String phone = cleanPhone(login);
      if (contacts[phone] != null) {
        String displayName = (contacts[phone]!.displayName ?? '').trim();
        if (rosterModel.name != displayName) {
          rosterModel.name = displayName;
          await rosterModel
              .updatePartial(rosterModel.id, {'name': displayName});
          isNew = true;
        }
      }
    }
    debugEvents.add('Различия контактов с ростером: ${isNew.toString()}');
    if (isNew) {
      userSettings.incRosterVersion();
      await userSettings.updatePartial(userSettings.id, {
        'rosterVersion': userSettings.rosterVersion,
      });
    }

    Map<String, ContactModel> touched = {};
    bool needSend2Server = false;
    List<Map<String, dynamic>> allContacts = [];

    int dbContactsCount = await ContactModel().getCount();
    if (dbContactsCount > contactsFromPhone.length) {
      debugEvents.add('Кол-во контактов в бд приложения больше чем в телефоне:'
          ' $dbContactsCount > ${contactsFromPhone.length},'
          ' будет выполнено полное обновление (очистка в бд приложения)');
      await ContactModel().dropAllRows();
    }
    Map<String, ContactModel> dbContacts =
        await ContactModel().getAllContacts();
    debugEvents.add('Кол-во контактов в бд приложения: $dbContactsCount');

    for (Contact contact in contactsFromPhone) {
      Map<String, dynamic> dest = ContactModel().toMap();
      Map<dynamic, dynamic> src = contact.toMap();
      for (var key in dest.keys) {
        dest[key] = src[key];
      }
      ContactModel contactModel = ContactModel().toModel(dest);
      List<String> phones = contactModel.phones!.split('|');
      for (String phone in phones) {
        String checkedPhone = cleanPhone(phone);
        // Если номер повторяется, игнорируем
        if (checkedPhone.length != 11 || touched[checkedPhone] != null) {
          continue;
        }
        touched[checkedPhone] = contactModel;
        if (dbContacts[contactModel.identifier] == null ||
            dbContacts[contactModel.identifier]?.displayName !=
                contactModel.displayName) {
          needSend2Server = true;
        }
      }
      allContacts.add(contactModel.toMap());
    }

    // DEBUG
    //needSend2Server = true;
    debugEvents
        .add('Отправить контакты на сервер: ${needSend2Server.toString()}');

    Log.d(
        tag,
        'contactsFromPhone count ${contactsFromPhone.length}\n'
        'dbContacts count ${dbContacts.length}\n'
        'needSend2Server $needSend2Server');

    if (needSend2Server) {
      const int maxBy = 999; // смотри SQLITE_LIMIT_VARIABLE_NUMBER

      int fieldsCount = 1;
      int by = 100;

      List<ContactModel> contacts2db = [];
      touched.forEach((k, v) => contacts2db.add(v));
      int contactsCount = contacts2db.length;
      fieldsCount = ContactModel().toMap().keys.length;
      by = maxBy ~/ fieldsCount;
      int contactsPages = (contactsCount ~/ by) + 1;

      List<dynamic> contactsQueriesPages = [];
      for (var i = 0; i < contactsPages; i++) {
        /*
        Log.d(
            tag,
            'Update contactsPages ${i + 1} /'
            ' $contactsPages (${i * by} - ${i * by + by}),'
            ' fieldsCount $fieldsCount');
        */
        List<dynamic> contacts = await ContactModel()
            .prepareTransactionQueries(contacts2db, i * by, i * by + by);
        if (contacts.isNotEmpty) {
          contactsQueriesPages.add(contacts);
        }
      }
      debugEvents.add('Количество транзакций вставки в бд приложения:'
          ' ${contactsQueriesPages.length}');

      await ContactModel().dropAllRows();
      await ContactModel().massTransaction(contactsQueriesPages);

      debugEvents.add('Вставка в бд приложения выполнена');

      // Сохраняем в файл
      String contactsFileName = 'contactsFromPhone.json';
      File contactsFile = await getLocalFilePath(contactsFileName);
      debugEvents
          .add('Путь к файлу для отправки на сервер: ${contactsFile.path}');
      await contactsFile.writeAsString(json.encode(allContacts));
      debugEvents.add('Файл создан');
      final archive = Archive();
      String dir = path.dirname(contactsFile.path);
      String filename = path.relative(contactsFile.path, from: dir);
      debugEvents.add('Путь к архиву для отправки на сервер: $filename');
      final fileStream = InputFileStream(contactsFile.path);
      final af =
          ArchiveFile.stream(filename, contactsFile.lengthSync(), fileStream);
      //af.lastModTime = contactsFile.lastModifiedSync().millisecondsSinceEpoch ~/ 1000;
      //af.mode = contactsFile.statSync().mode;
      archive.addFile(af);
      debugEvents.add('Архив создан');
      final tar = TarEncoder().encode(archive);
      final tarGz = GZipEncoder().encode(tar);

      if (tarGz != null) {
        debugEvents.add('Сжатие архива');
        String compressedContactsFileName = 'contactsFromPhone.tar.gz';
        File compressedContactsFile =
            await getLocalFilePath(compressedContactsFileName);
        debugEvents.add('Путь к сжатому архиву для отправки на сервер'
            ' ${compressedContactsFile.path}');
        compressedContactsFile.writeAsBytesSync(tarGz);
        debugEvents.add('Архив сжат');
        await sendNames2ServerFile(compressedContactsFile.path,
            userSettings.jid ?? '', userSettings.credentialsHash ?? '');
        debugEvents.add('Удаление сжатого архива:'
            ' ${compressedContactsFile.path}');
        await compressedContactsFile.delete();
      } else {
        debugEvents.add('[ERROR]: ошибка сжатия GZipEncoder');
      }
      debugEvents.add('Удаление файла: ${contactsFile.path}');
      await contactsFile.delete();

      // Поместить в нужное место
      for (int i=0; i<debugEvents.length; i++) {
        Log.d('--- $tag ---', debugEvents[i]);
      }

      // DEPRECATED: Отправляем пачками на сервер
      /*
      List<Map<String, dynamic>> part = [];
      for (Map<String, dynamic> contact in allContacts){
        part.add(contact);
        if (part.length > maxBy) {
          await sendNames2ServerSimple(part, userSettings.jid ?? '',
              userSettings.credentialsHash ?? '');
          part = [];
        }
      }
      if (part.isNotEmpty) {
        await sendNames2ServerSimple(part, userSettings.jid ?? '',
            userSettings.credentialsHash ?? '');
      }
      */
    }
  }

  String compressString(String text) {
    String compressedString = '';
    var stringBytes = utf8.encode(text);
    var gzipBytes = GZipEncoder().encode(stringBytes);
    if (gzipBytes != null) {
      compressedString = base64.encode(gzipBytes);
    }
    return compressedString;
  }

  static Future<Map<String, Contact>> getPhoneContactsMap(
      List<Contact> contactsFromPhone) async {
    Map<String, Contact> contacts = {};
    for (Contact contact in contactsFromPhone) {
      if (contact.phones == null ||
          contact.displayName == null ||
          contact.displayName!.trim() == '') {
        continue;
      }
      for (Item phone in contact.phones!) {
        String phoneStr = cleanPhone(phone.value.toString());
        if (phoneStr.length == 11) {
          contacts[phoneStr] = contact;
        }
      }
    }
    return contacts;
  }
}
