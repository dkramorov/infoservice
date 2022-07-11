import 'package:sqflite/sqflite.dart';

import '../../db/companies_db.dart';
import '../../models/abstract_model.dart';


class Addresses extends AbstractModel {
  final int? id;
  final String? city;
  final int? branchesCount;
  final String? district;
  final String? additionalData;
  final String? country;
  final String? subdistrict;
  final String? searchTerms;
  final double? longitude;
  final double? latitude;
  final String? county;
  final String? state;
  final String? street;
  final String? place;
  final String? addressLines;
  final String? postalCode;
  final String? houseNumber;

  @override
  Future<Database> openDB() async {
    return await openCompaniesDB();
  }

  @override
  String get tableName => 'addresses';

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'city': city,
      'branchesCount': branchesCount,
      'district': district,
      'additionalData': additionalData,
      'country': country,
      'subdistrict': subdistrict,
      'searchTerms': searchTerms,
      'longitude': longitude,
      'latitude': latitude,
      'county': county,
      'state': state,
      'street': street,
      'place': place,
      'addressLines': addressLines,
      'postalCode': postalCode,
      'houseNumber': houseNumber,
    };
  }

  Addresses({
    this.id,
    this.city,
    this.branchesCount,
    this.district,
    this.additionalData,
    this.country,
    this.subdistrict,
    this.searchTerms,
    this.longitude,
    this.latitude,
    this.county,
    this.state,
    this.street,
    this.place,
    this.addressLines,
    this.postalCode,
    this.houseNumber,
  });

  @override
  String toString() {
    String result = '';
    /*
    return 'id: $id, city: $city, branchesCount: $branchesCount, ' +
        'district: $district, additionalData: $additionalData, ' +
        'country: $country, subdistrict: $subdistrict, ' +
        'searchTerms: $searchTerms, longitude: $longitude, ' +
        'latitude: $latitude, county: $county, state: $state, ' +
        'street: $street, place: $place, addressLines: $addressLines, ' +
        'postalCode: $postalCode, houseNumber: $houseNumber';
    */
    if (postalCode != null && postalCode != '') {
      result += '$postalCode, ';
    }
    if (city != null && city != '') {
      result += '$city';
    }
    if (district != null && district != '') {
      result += ', $district';
    }
    if (subdistrict != null && subdistrict != '') {
      result += ', $subdistrict';
    }
    if (street != null && street != '') {
      result += ', $street';
    }
    if (houseNumber != null && houseNumber != '') {
      result += ', $houseNumber';
    }
    return result;
  }

  static List<Addresses> jsonFromList(List<dynamic> arr) {
    List<Addresses> result = [];
    arr.forEach((item) {
      result.add(Addresses.fromJson(item));
    });
    return result;
  }

  factory Addresses.fromJson(Map<String, dynamic> json) {
    return Addresses(
      id: (json['id'] ?? 0) as int,
      city: json['city'] ?? '',
      branchesCount: (json['branches_count'] ?? 0) as int,
      district: json['district'] ?? '',
      additionalData: json['additionalData'] ?? '',
      country: json['country'] ?? '',
      subdistrict: json['subdistrict'] ?? '',
      searchTerms: json['search_terms'] ?? '',
      longitude: AbstractModel.getDouble(json['longitude'] ?? 0),
      latitude: AbstractModel.getDouble(json['latitude'] ?? 0),
      county: json['county'] ?? '',
      state: json['state'] ?? '',
      street: json['street'] ?? '',
      place: json['place'] ?? '',
      addressLines: json['addressLines'] ?? '',
      postalCode: json['postalCode'] ?? '',
      houseNumber: json['houseNumber'] ?? '',
    );
  }

  /* Перегоняем данные из базы в модельку */
  Addresses toModel(Map<String, dynamic> dbItem) {
    return Addresses(
      id: dbItem['id'],
      city: dbItem['city'],
      branchesCount: dbItem['branchesCount'],
      district: dbItem['district'],
      additionalData: dbItem['additionalData'],
      country: dbItem['country'],
      subdistrict: dbItem['subdistrict'],
      searchTerms: dbItem['searchTerms'],
      longitude: dbItem['longitude'].toDouble(),
      latitude: dbItem['latitude'].toDouble(),
      county: dbItem['county'],
      state: dbItem['state'],
      street: dbItem['street'],
      place: dbItem['place'],
      addressLines: dbItem['addressLines'],
      postalCode: dbItem['postalCode'],
      houseNumber: dbItem['houseNumber'],
    );
  }

  Future<Addresses?> getAddress(int addressId) async {
    final db = await openCompaniesDB();
    final List<Map<String, dynamic>> addresses = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [addressId],
    );
    if (addresses.isEmpty) {
      return null;
    }
    return toModel(addresses[0]);
  }
}
