import 'package:contacts_service/contacts_service.dart';
import 'package:infoservice/services/jabber_manager.dart';
import 'package:infoservice/services/permissions_manager.dart';

import '../helpers/log.dart';
import '../helpers/network.dart';
import '../helpers/phone_mask.dart';
import '../models/contact_model.dart';
import '../models/roster_model.dart';
import '../models/user_settings_model.dart';

class ContactsManager {
  static const String tag = 'ContactsManager';

  static Future<void> refreshContactsHelper() async {
    bool granted = await PermissionsManager().checkPermissions('contacts');
    if (!granted) {
      Log.i(tag, 'Contacts permissions absent!');
      return;
    }
    UserSettingsModel? userSettings = await UserSettingsModel().getUser();
    if (userSettings == null) {
      Log.i(tag, 'User is null!');
      return;
    }

    List<Contact> contactsFromPhone =
        await ContactsService.getContacts(withThumbnails: false);
    Map<String, Contact> contacts =
        await getPhoneContactsMap(contactsFromPhone);

    bool isNew = false;
    List<RosterModel> myRoster =
        await RosterModel().getByOwner(userSettings.jid ?? '');
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
    if (isNew) {
      userSettings.incRosterVersion();
      await userSettings.updatePartial(userSettings.id, {
        'rosterVersion': userSettings.rosterVersion,
      });
    }

    Map<String, ContactModel> touched = {};
    bool needSend2Server = false;
    List<Map<String, dynamic>> allContacts = [];

    Map<String, ContactModel> dbContacts =
        await ContactModel().getAllContacts();

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
        Log.d(tag,
            'Update contactsPages ${i + 1} /'
            ' $contactsPages (${i * by} - ${i * by + by}),'
            ' fieldsCount $fieldsCount');
        List<dynamic> contacts = await ContactModel()
            .prepareTransactionQueries(contacts2db, i * by, i * by + by);
        if (contacts.isNotEmpty) {
          contactsQueriesPages.add(contacts);
        }
      }
      await ContactModel().massTransaction(contactsQueriesPages);
      await sendNames2ServerSimple(allContacts, userSettings.jid ?? '',
          userSettings.credentialsHash ?? '');
    }
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
