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
    };
  }

  Catalogue({
    this.id,
    this.count,
    this.searchTerms,
    this.name,
    this.icon,
    this.position,
  });

  Color get color => Colors.primaries[Random().nextInt(Colors.primaries.length)];

  @override
  String toString() {
    return 'id: $id, count: $count, searchTerms: $searchTerms, ' +
        'name: $name, icon: $icon, position: $position';
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
    );
  }

  Future<List<Catalogue>> getFullCatalogue(
      {String sort = 'name'}) async {
    final db = await openCompaniesDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: sort,
    );
    return List.generate(maps.length, (i) {
      return toModel(maps[i]);
    });
  }

  Future<List<Catalogue>> searchCatalogue(String query,
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
