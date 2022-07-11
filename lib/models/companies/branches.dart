import 'package:sqflite/sqflite.dart';

import '../../db/companies_db.dart';
import '../../models/abstract_model.dart';
import 'addresses.dart';

class Branches extends AbstractModel {
  int? id;
  String? wtime;
  String? searchTerms;
  String? site;
  String? addressAdd;
  int? address;
  String? name;
  int? reg;
  int? client;
  int? position;
  String? email;
  Addresses? mapAddress;

  @override
  Future<Database> openDB() async {
    return await openCompaniesDB();
  }

  @override
  String get tableName => 'branches';

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wtime': wtime,
      'searchTerms': searchTerms,
      'site': site,
      'addressAdd': addressAdd,
      'address': address,
      'name': name,
      'reg': reg,
      'client': client,
      'position': position,
      'email': email,
    };
  }

  Branches({
    this.id,
    this.wtime,
    this.searchTerms,
    this.site,
    this.addressAdd,
    this.address,
    this.name,
    this.reg,
    this.client,
    this.position,
    this.email,
  });

  @override
  String toString() {
    return 'id: $id, wtime: $wtime, searchTerms: $searchTerms, ' +
        'site: $site, addressAdd: $addressAdd, ' +
        'address: $address, ' +
        'name: $name, reg: $reg, client: $client, ' +
        'position: $position, email: $email';
  }

  static List<Branches> jsonFromList(List<dynamic> arr) {
    List<Branches> result = [];
    arr.forEach((item) {
      result.add(Branches.fromJson(item));
    });
    return result;
  }

  factory Branches.fromJson(Map<String, dynamic> json) {
    return Branches(
      id: (json['id'] ?? 0) as int,
      wtime: json['wtime'] ?? '',
      searchTerms: json['search_terms'] ?? '',
      site: json['site'] ?? '',
      addressAdd: json['address_add'] ?? '',
      address: (json['address'] ?? 0) as int,
      name: json['name'] ?? '',
      reg: (json['reg'] ?? 0) as int,
      client: (json['client'] ?? 0) as int,
      position: (json['position'] ?? 0) as int,
      email: json['email'] ?? '',
    );
  }

  /* Перегоняем данные из базы в модельку */
  Branches toModel(Map<String, dynamic> dbItem) {
    return Branches(
      id: dbItem['id'],
      wtime: dbItem['wtime'],
      searchTerms: dbItem['searchTerms'],
      site: dbItem['site'],
      addressAdd: dbItem['addressAdd'],
      address: dbItem['address'],
      name: dbItem['name'],
      reg: dbItem['reg'],
      client: dbItem['client'],
      position: dbItem['position'],
      email: dbItem['email'],
    );
  }

  Future<List<Branches>> getOrgBranches(int orgId) async {
    final db = await openCompaniesDB();
    final List<Map<String, dynamic>> branches = await db.query(
      tableName,
      where: 'client = ?',
      whereArgs: [orgId],
    );
    return List.generate(branches.length, (i) {
      return toModel(branches[i]);
    });
  }
}