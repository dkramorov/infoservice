import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../db/companies_db.dart';
import '../../helpers/log.dart';
import '../../models/abstract_model.dart';
import 'cats.dart';

class Catalogue extends AbstractModel {
  int? id;
  int? count;
  String? searchTerms;
  String? name;
  String? icon;
  int? position;
  String? parents;
  String? img;
  Color? color1;

  static const TAG = 'Catalogue';

  @override
  Future<Database> openDB() async {
    return await openCompaniesDB();
  }

  @override
  String get tableName => 'catalogue';

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'count': count,
      'searchTerms': searchTerms,
      'name': name,
      'icon': icon,
      'position': position,
      'parents': parents,
      'img': img,
    };
  }

  Catalogue({
    this.id,
    this.count,
    this.searchTerms,
    this.name,
    this.icon,
    this.position,
    this.parents,
    this.img,
  });

  //Color get color => Colors.primaries[Random().nextInt(Colors.primaries.length)];
  Color get color {
    if (color1 == null) {
      color1 = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    }
    return color1!;
  }

  @override
  String toString() {
    return 'id: $id, count: $count, searchTerms: $searchTerms, '
        'name: $name, icon: $icon, position: $position, '
        'parents: $parents, img: $img';
  }

  static List<Catalogue> jsonFromList(List<dynamic> arr) {
    List<Catalogue> result = [];
    for (var item in arr) {
      result.add(Catalogue.fromJson(item));
    }
    return result;
  }

  factory Catalogue.fromJson(Map<String, dynamic> json) {
    return Catalogue(
      id: (json['id'] ?? 0) as int,
      count: (json['count'] ?? 0) as int,
      searchTerms: json['search_terms'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      position: (json['position'] ?? 0) as int,
      parents: json['parents'] ?? '',
      img: json['img'] ?? '',
    );
  }

  /* Перегоняем данные из базы в модельку */
  Catalogue toModel(Map<String, dynamic> dbItem) {
    return Catalogue(
      id: dbItem['id'],
      count: dbItem['count'],
      searchTerms: dbItem['searchTerms'],
      name: dbItem['name'],
      icon: dbItem['icon'],
      position: dbItem['position'],
      parents: dbItem['parents'],
      img: dbItem['img'],
    );
  }

  Future<List<Catalogue>> getFullCatalogue(
      {String parents = '', String sort = 'position'}) async {
    final db = await openCompaniesDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'parents=?',
      whereArgs: [parents],
      orderBy: sort,
    );
    return List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
  }

  Future<Catalogue?> getById(int pk) async {
    final db = await openCompaniesDB();
    String where = 'id=?';
    List<Object?> whereArgs = [pk];
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
    );
    if (maps.isEmpty) {
      return null;
    }
    final Map<String, dynamic> catItem = maps[0];
    return toModel(catItem);
  }

  Future<int> getChildrenCount({String parents = ''}) async {
    final db = await openCompaniesDB();
    String query = 'SELECT COUNT(*) FROM $tableName where parents=?';
    int? count = Sqflite.firstIntValue(
        await db.rawQuery(query, [parents]));
    Log.i(tableName, '$query ($parents) => $count');
    return count ?? 0;
  }

  Future<List<Catalogue>> searchCatalogue(String query,
      {int limit = 10, int offset = 0}) async {
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

  Future<List<Catalogue>> getCatsRubrics(List<Cats> cats) async {
    final db = await openCompaniesDB();
    List<int> ids = (cats.map((cat) => (cat.catId ?? 0))).toList();
    final List<Map<String, dynamic>> rubrics = await db.query(
      tableName,
      where: 'id IN (${ids.join(',')})',
    );
    return List.generate(rubrics.length, (i) {
      return toModel(rubrics[i]);
    });
  }
}
