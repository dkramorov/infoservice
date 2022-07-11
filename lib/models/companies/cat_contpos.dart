import 'package:sqflite/sqflite.dart';

import '../../db/companies_db.dart';
import '../../models/abstract_model.dart';


class CatContpos extends AbstractModel {
  final int? id;
  final int? position;
  final int? catId;
  final int? clientId;

  @override
  Future<Database> openDB() async {
    return await openCompaniesDB();
  }

  @override
  String get tableName => 'cat_contpos';

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'position': position,
      'catId': catId,
      'clientId': clientId,
    };
  }

  CatContpos({
    this.id,
    this.position,
    this.catId,
    this.clientId,
  });

  @override
  String toString() {
    return 'id: $id, position: $position, catId: $catId, ' +
        'clientId: $clientId';
  }

  static List<CatContpos> jsonFromList(List<dynamic> arr) {
    List<CatContpos> result = [];
    for (var item in arr) {
      result.add(CatContpos.fromJson(item));
    }
    return result;
  }

  factory CatContpos.fromJson(Map<String, dynamic> json) {
    return CatContpos(
      id: (json['id'] ?? 0) as int,
      position: (json['position'] ?? 0) as int,
      catId: (json['cat_id'] ?? 0) as int,
      clientId: (json['client_id'] ?? 0) as int,
    );
  }

  /* Перегоняем данные из базы в модельку */
  CatContpos toModel(Map<String, dynamic> dbItem) {
    return CatContpos(
      id: dbItem['id'],
      position: dbItem['position'],
      catId: dbItem['catId'],
      clientId: dbItem['clientId'],
    );
  }
}
