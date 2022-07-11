

import 'package:sqflite/sqflite.dart';

import '../../db/companies_db.dart';
import '../../models/abstract_model.dart';

class Cats extends AbstractModel {
  final int? id;
  final int? catId;
  final int? clientId;

  @override
  Future<Database> openDB() async {
    return await openCompaniesDB();
  }

  @override
  String get tableName => 'cats';

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'catId': catId,
      'clientId': clientId,
    };
  }

  Cats({
    this.id,
    this.catId,
    this.clientId,
  });

  @override
  String toString() {
    return 'catId: $catId, id: $id, ' + 'clientId: $clientId';
  }

  static List<Cats> jsonFromList(List<dynamic> arr) {
    List<Cats> result = [];
    arr.forEach((item) {
      result.add(Cats.fromJson(item));
    });
    return result;
  }

  factory Cats.fromJson(Map<String, dynamic> json) {
    return Cats(
      id: (json['id'] ?? 0) as int,
      catId: (json['cat_id'] ?? 0) as int,
      clientId: (json['client_id'] ?? 0) as int,
    );
  }

  /* Перегоняем данные из базы в модельку */
  Cats toModel(Map<String, dynamic> dbItem) {
    return Cats(
      id: dbItem['id'],
      catId: dbItem['catId'],
      clientId: dbItem['clientId'],
    );
  }

  Future<List<Cats>> getOrgCats(int orgId) async {
    /* Получение связок с рубриками по айди фирмы */
    final db = await openCompaniesDB();
    final List<Map<String, dynamic>> cats = await db.query(
      tableName,
      where: 'clientId = ?',
      whereArgs: [orgId],
    );
    return List.generate(cats.length, (i) {
      return toModel(cats[i]);
    });
  }

}
