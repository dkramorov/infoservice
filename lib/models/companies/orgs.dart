import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../db/companies_db.dart';
import '../../models/companies/phones.dart';
import '../../helpers/log.dart';
import '../../models/abstract_model.dart';
import '../../settings.dart';

import 'branches.dart';
import 'catalogue.dart';
import 'cats.dart';

class Orgs extends AbstractModel {
  int? id;
  int? rating;
  int? branches;
  String? name;
  String? resume;
  int? phones;
  String? logo;
  String? img;
  String? searchTerms;
  int? reg;
  String? chat;

  List<Cats> catsArr = [];
  List<Catalogue> rubricsArr = [];
  List<Branches> branchesArr = [];
  List<Phones> phonesArr = [];

  static const TAG = 'Orgs';
  @override
  Future<Database> openDB() async {
    return await openCompaniesDB();
  }

  @override
  String get tableName => 'orgs';

  String? getLogoPath() {
    if (id == null || logo == null || logo == '') {
      return null;
    }
    return DB_SERVER + DB_LOGO_PATH.replaceAll('COMPANY_ID', '$id') + logo!;
  }

  String? getImagePath() {
    if (id == null || img == null || img == '') {
      return null;
    }
    return DB_SERVER + '/media/' + img!;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rating': rating,
      'branches': branches,
      'name': name,
      'resume': resume,
      'phones': phones,
      'logo': logo,
      'img': img,
      'searchTerms': searchTerms,
      'reg': reg,
      'chat': chat,
    };
  }

  Orgs({
    this.id,
    this.rating,
    this.branches,
    this.name,
    this.resume,
    this.phones,
    this.logo,
    this.img,
    this.searchTerms,
    this.reg,
    this.chat,
  });

  Color get color => Colors.primaries[Random().nextInt(Colors.primaries.length)];

  @override
  String toString() {
    return 'id: $id, rating: $rating, branches: $branches, '
        'name: $name, resume: $resume, '
        'phones: $phones, logo: $logo, img: $img, '
        'searchTerms: $searchTerms, '
        'reg: $reg, chat: $chat';
  }

  static List<Orgs> jsonFromList(List<dynamic> arr) {
    List<Orgs> result = [];
    arr.forEach((item) {
      result.add(Orgs.fromJson(item));
    });
    return result;
  }

  factory Orgs.fromJson(Map<String, dynamic> json) {
    return Orgs(
      id: (json['id'] ?? 0) as int,
      rating: (json['rating'] ?? 0) as int,
      branches: (json['branches'] ?? 0) as int,
      name: json['name'] ?? '',
      resume: json['resume'] ?? '',
      phones: (json['phones'] ?? 0) as int,
      logo: json['logo'] ?? '',
      img: json['img'] ?? '',
      searchTerms: json['search_terms'] ?? '',
      reg: (json['reg'] ?? 0) as int,
      chat: json['chat'] ?? '',
    );
  }

  /* Перегоняем данные из базы в модельку */
  Orgs toModel(Map<String, dynamic> dbItem) {
    return Orgs(
      id: dbItem['id'],
      rating: dbItem['rating'],
      branches: dbItem['branches'],
      name: dbItem['name'],
      resume: dbItem['resume'],
      phones: dbItem['phones'],
      logo: dbItem['logo'],
      img: dbItem['img'],
      searchTerms: dbItem['searchTerms'],
      reg: dbItem['reg'],
      chat: dbItem['chat'],
    );
  }

  Future<List<Orgs>> getCategoryOrgs(int catId) async {
    final db = await openCompaniesDB();
    String fields = Orgs().toMap().keys.map((key) {
      return '$tableName.$key';
    }).join(', ');
    String query = 'SELECT $fields from $tableName' +
        ' INNER JOIN cats ON cats.clientId = orgs.id' +
        ' WHERE cats.catId = ?';
    // db.rawQuery('SELECT * FROM my_table WHERE name IN (?, ?, ?)', ['cat', 'dog', 'fish']);
    Log.d(TAG, query + ', $catId');
    final List<Map<String, dynamic>> maps = await db.rawQuery(query, [catId]);
    return List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
  }

  Future<Orgs?> getOrg(int orgId) async {
    final db = await openCompaniesDB();
    final List<Map<String, dynamic>> orgs = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [orgId],
    );
    if (orgs.isEmpty) {
      return null;
    }
    return toModel(orgs[0]);
  }

  Future<Orgs?> getOrgByChat(String phone) async {
    final db = await openCompaniesDB();
    final List<Map<String, dynamic>> orgs = await db.query(
      tableName,
      where: 'chat = ?',
      whereArgs: [phone],
    );
    if (orgs.isEmpty) {
      return null;
    }
    return toModel(orgs[0]);
  }

  Future<void> getOrgsByIds(Map<int, dynamic> orgIds) async {
    // Получение компаний по айдишникам
    // на вход получаем словарь {1: null, 2: null}
    final db = await openCompaniesDB();
    List<int> values = orgIds.keys.toList();
    String args = orgIds.keys.map((e) => '?').toList().join(',');

    final List<Map<String, dynamic>> orgs = await db.query(
      tableName,
      where: 'id IN ($args)',
      whereArgs: values,
    );
    for(Map<String, dynamic> org in orgs) {
      Orgs company = toModel(org);
      orgIds[company.id ?? 0] = company;
    }
  }

  Future<List<Orgs>> searchOrgs(String query,
      {int limit: 10, int offset: 0}) async {
    final db = await openCompaniesDB();

    String pattern = 'searchTerms LIKE ?';
    List<String> whereClause = [];
    List<dynamic> args = [];
    for (String word in query.split(' ')) {
      word = word.trim();
      if (word.isNotEmpty) {
        args.add('%$word%');
        whereClause.add(pattern);
      }
    }
    if (args.isEmpty) {
      return List.empty();
    }

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: whereClause.join(' AND '),
      whereArgs: args,
      limit: limit,
      offset: offset,
    );
    Log.d(TAG,
        'SEARCH $tableName: ${whereClause.toString()}, ${args.toString()}');
    return List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
  }

  Future<List<Orgs>> getOrgsByPhones(List<Phones> phones) async {
    final db = await openCompaniesDB();
    List<int> ids = [];

    for (Phones phone in phones) {
      if (phone.client == null) {
        continue;
      }
      ids.add(phone.client!);
    }
    String idsOrgs = ids.join(', ');

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id IN ($idsOrgs)',
    );

    return List.generate(maps.length, (i) {
      Orgs org = toModel(maps[i]);
      // Докидываем телефоны в компанию
      for (Phones phone in phones) {
        if (phone.client == org.id) {
          org.phonesArr.add(phone);
        }
      }
      return org;
    });
  }
}
