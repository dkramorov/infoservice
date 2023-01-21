import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../db/chat_db.dart';
import '../db/tables.dart';
import '../helpers/phone_mask.dart';
import 'abstract_model.dart';


/* Пользователи адресной книги (контакты)
*/
class ContactModel extends AbstractModel {

  @override
  Future<Database> openDB() async {
    return openChatDB();
  }

  Key key = UniqueKey();

  int? id; // null if we need new row
  String? identifier;
  String? displayName;
  String? givenName;
  String? middleName;
  String? familyName;
  String? prefix;
  String? suffix;
  String? company;
  String? jobTitle;
  String? androidAccountType;
  String? androidAccountName;
  String? emails;
  String? phones;
  String? postalAddresses;
  String? avatar;
  String? birthday;
  int? hasXMPP;
  int? updated;

  String getTableName() {
    return tableContactsModel;
  }

  @override
  String get tableName => getTableName();

  ContactModel({
    this.id,
    this.identifier,
    this.displayName,
    this.givenName,
    this.middleName,
    this.familyName,
    this.prefix,
    this.suffix,
    this.company,
    this.jobTitle,
    this.androidAccountType,
    this.androidAccountName,
    this.emails,
    this.phones,
    this.postalAddresses,
    this.avatar,
    this.birthday,
    this.hasXMPP,
    this.updated,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'identifier': identifier,
      'displayName': displayName,
      'givenName': givenName,
      'middleName': middleName,
      'familyName': familyName,
      'prefix': prefix,
      'suffix': suffix,
      'company': company,
      'jobTitle': jobTitle,
      'androidAccountType': androidAccountType,
      'androidAccountName': androidAccountName,
      'emails': emails,
      'phones': phones,
      'postalAddresses': postalAddresses,
      'avatar': avatar,
      'birthday': birthday,
      'hasXMPP': hasXMPP,
      'updated': updated,
    };
  }

  /* Перегоняем данные из базы в модельку */
  ContactModel toModel(Map<String, dynamic> dbItem) {
    String postalAddress = ''; // TODO receive PostalAddress list
    String avatar = ''; // TODO receive avatar
    String birthday = '';
    if (dbItem['birthday'] is DateTime) {
      birthday = dbItem['birthday'].toIso8601String();
    } else if (dbItem['birthday'] is String) {
      birthday = dbItem['birthday'];
    }
    String accountType = dbItem['androidAccountType'] ?? '';
    if (dbItem['androidAccountType'] != null) {
      accountType = dbItem['androidAccountType'].toString();
    }
    String emails = '';
    if (dbItem['emails'] is! String) {
      for(var email in dbItem['emails']) {
        emails += '| ${email['value']} '; // Item
      }
    } else {
      emails = dbItem['emails'];
    }
    String phones = '';
    if (dbItem['phones'] is! String) {
      for(var phone in dbItem['phones']) {
        phones += '| ${cleanPhone(phone['value'])} '; // Item
      }
    } else {
      phones = dbItem['phones'];
    }
    return ContactModel(
      id: dbItem['id'],
      identifier: dbItem['identifier'],
      displayName: dbItem['displayName'],
      givenName: dbItem['givenName'],
      middleName: dbItem['middleName'],
      familyName: dbItem['familyName'],
      prefix: dbItem['prefix'],
      suffix: dbItem['suffix'],
      company: dbItem['company'],
      jobTitle: dbItem['jobTitle'],
      androidAccountType: accountType,
      androidAccountName: dbItem['androidAccountName'],
      emails: emails,
      phones: phones,
      postalAddresses: postalAddress,
      avatar: avatar,
      birthday: birthday,
      hasXMPP: dbItem['hasXMPP'],
      updated: dbItem['updated'],
    );
  }

  @override
  String toString() {
    final String table = getTableName();
    return '$table{id: $id, identifier: $identifier, displayName: $displayName, ' +
        'givenName: $givenName, middleName: $middleName, familyName: $familyName, ' +
        'prefix: $prefix, suffix: $suffix, company: $company, jobTitle: $jobTitle, ' +
        'androidAccountType: $androidAccountType, androidAccountName: $androidAccountName, ' +
        'emails: $emails} phones: $phones, postalAddresses: $postalAddresses, ' +
        'avatar: $avatar, birthday: $birthday, hasXMPP: $hasXMPP, updated: $updated';
  }

  Future<ContactModel?> getByPhone(String phone) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableContactsModel,
      where: 'phones like ?',
      whereArgs: ['%$phone%'],
    );
    if (maps.isEmpty) {
      return null;
    }
    final Map<String, dynamic> user = maps[0];
    return toModel(user);
  }

  Future<List<ContactModel>> getAllContacts(
      {int? limit, int? offset}) async {
    final db = await openDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableContactsModel,
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
  }

}
