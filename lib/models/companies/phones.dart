import 'package:sqflite/sqflite.dart';

import '../../db/companies_db.dart';
import '../../helpers/log.dart';
import '../../helpers/phone_mask.dart';
import '../../models/abstract_model.dart';

class Phones extends AbstractModel {
  int? id;
  String? digits;
  String? comment;
  int? prefix;
  int? client;
  int? whata;
  int? branch;
  int? position;
  String? searchTerms;
  String? number;

  static const TAG = 'Phones';
  @override
  Future<Database> openDB() async {
    return await openCompaniesDB();
  }

  @override
  String get tableName => 'phones';

  Phones({
    this.id,
    this.digits,
    this.comment,
    this.prefix,
    this.client,
    this.whata,
    this.branch,
    this.position,
    this.searchTerms,
    this.number,
  });

  String get formattedPhone => phoneMaskHelper(buildPhoneString());

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'digits': digits,
      'comment': comment,
      'prefix': prefix,
      'client': client,
      'whata': whata,
      'branch': branch,
      'position': position,
      'searchTerms': searchTerms,
      'number': number,
    };
  }

  String getWhataDisplay(digit) {
    if (digit == 1) {
      return 'тел';
    }
    if (digit == 2) {
      return 'факс';
    }
    if (digit == 3) {
      return 'тел/факс';
    }
    if (digit == 4) {
      return 'моб';
    }
    return 'тел';
  }

  String buildPhoneString() {
    String result = '';
    if (prefix != 0 && prefix != null) {
      result += '$prefix';
    }
    if (digits != null) {
      result += '$digits';
    }
    return result;
  }

  String prefixPhone(String phoneStr) {
    if (phoneStr.length == 6) {
      phoneStr = '73952$phoneStr';
    } else if (phoneStr.length == 10) {
      phoneStr = '7$phoneStr';
    }
    return phoneStr;
  }

  String defizPhone(String phone) {
    phone = phone.replaceAll(RegExp('[^0-9]+'), '');
    phone = prefixPhone(phone);
    int phoneLen = phone.length;
    if (phoneLen == 5 || phoneLen == 6) {
      phone = '${phone.substring(0, 3)}-${phone.substring(3, phoneLen)}';
    } else if (phoneLen == 7) {
      phone =
          '${phone.substring(0, 1)}-${phone.substring(1, 4)}-${phone.substring(4, phoneLen)}';
    } else if (phoneLen == 10) {
      if (phone.startsWith('9')) {
        // сотовые
        phone =
            '(${phone.substring(0, 3)}) ${phone.substring(3, 4)}-${phone.substring(4, 7)}-${phone.substring(7, phoneLen)}';
      } else {
        // городские
        phone =
            '(${phone.substring(0, 4)}) ${phone.substring(4, 7)}-${phone.substring(7, phoneLen)}';
      }
    } else if (phoneLen == 11) {
      if (phone[1] == '9') {
        // сотовые
        phone = '${phone.substring(0, 1)} (${phone.substring(1, 4)})' +
            ' ${phone.substring(4, 5)}-${phone.substring(5, 8)}-${phone.substring(8, phoneLen)}';
      } else {
        // городские
        phone = '${phone.substring(0, 1)} (${phone.substring(1, 5)})' +
            ' ${phone.substring(5, 8)}-${phone.substring(8, phoneLen)}';
      }
      if (phone.startsWith('7')) {
        phone = '+$phone';
      }
    }
    return phone;
  }

  @override
  String toString() {
    String result = '';
    if (number != null && number != '') {
      result += getWhataDisplay(whata);
      if (prefix != null && prefix != 0) {
        result += '(${prefix.toString()}) ';
      }
      result += (number ?? '');
      return result;
    }
    return getWhataDisplay(whata) + (digits ?? '');
  }

  static List<Phones> jsonFromList(List<dynamic> arr) {
    List<Phones> result = [];
    for (var item in arr) {
      result.add(Phones.fromJson(item));
    }
    return result;
  }

  factory Phones.fromJson(Map<String, dynamic> json) {
    return Phones(
      id: (json['id'] ?? 0) as int,
      digits: json['digits'] ?? '',
      comment: json['comment'] ?? '',
      prefix: AbstractModel.getInt(json['prefix'] ?? 0),
      client: (json['client'] ?? 0) as int,
      whata: AbstractModel.getInt(json['whata']),
      branch: (json['branch'] ?? 0) as int,
      position: (json['position'] ?? 0) as int,
      searchTerms: json['search_terms'] ?? '',
      number: json['number'] ?? '',
    );
  }

  /* Перегоняем данные из базы в модельку */
  Phones toModel(Map<String, dynamic> dbItem) {
    return Phones(
      id: dbItem['id'],
      digits: dbItem['digits'],
      comment: dbItem['comment'],
      prefix: dbItem['prefix'],
      client: dbItem['client'],
      whata: dbItem['whata'],
      branch: dbItem['branch'],
      position: dbItem['position'],
      searchTerms: dbItem['searchTerms'],
      number: dbItem['number'],
    );
  }

  Future<List<Phones>> getOrgPhones(int orgId) async {
    final db = await openCompaniesDB();
    final List<Map<String, dynamic>> phones = await db.query(
      tableName,
      where: 'client = ?',
      whereArgs: [orgId],
    );
    return List.generate(phones.length, (i) {
      return toModel(phones[i]);
    });
  }

  Future<List<Phones>> searchPhones(String query,
      {int limit = 10, int offset = 0}) async {
    final db = await openCompaniesDB();

    String pattern = 'searchTerms LIKE ?';
    List<String> whereClause = [];
    List<dynamic> args = [];
    for (String word in query.split(' ')) {
      word = word.replaceAll(RegExp('[^0-9]+'), '');;
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
}
