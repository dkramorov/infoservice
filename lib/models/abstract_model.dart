import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../helpers/log.dart';

/*
https://stackoverflow.com/questions/1711631/improve-insert-per-second-performance-of-sqlite
https://www.sqlite.org/limits.html
*/

class AbstractModel {
  int? id;
  String get tableName => '';

  Future<Database>? openDB() {
    return null;
  }

  static int getInt(dynamic digit) {
    if (digit == null) {
      return 0;
    }
    digit = '$digit';
    return (digit != '') ? int.parse(digit) : 0;
  }

  static double getDouble(dynamic digit) {
    if (digit == null) {
      return 0.0;
    }
    digit = '$digit';
    return (digit != '') ? double.parse(digit) : 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
    };
  }

  @override
  String toString() {
    return 'Setting{id: $id}';
  }

  Future<int> insert2Db() async {
    final Map<String, dynamic> mapA = toMap();
    Log.i('$tableName insert2Db', mapA.toString());
    final db = await openDB();
    if (db == null) {
      return 0;
    }
    // id null if we need new row
    int pk = await db.insert(
      tableName,
      mapA,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    id = pk;
    return pk;
  }

  Future<void> update2Db() async {
    final Map<String, dynamic> mapA = toMap();
    Log.i('$tableName update2Db', mapA.toString());
    if (id == null) {
      Log.e('$tableName update2Db', 'id is null, we can not update');
      return;
    }
    final db = await openDB();
    if (db == null) {
      return;
    }
    await db.update(
      tableName,
      mapA,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete2Db() async {
    final Map<String, dynamic> mapA = toMap();
    Log.i('$tableName delete2Db', mapA.toString());
    if (id == null) {
      Log.e('$tableName delete2Db', 'id is null, we can not drop');
      return;
    }
    final db = await openDB();
    if (db == null) {
      return;
    }
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> dropAllRows() async {
    final db = await openDB();
    if (db == null) {
      return;
    }
    final dropped = await db.delete(
      tableName,
    );
    Log.w(tableName, 'dropAllRows = $dropped');
  }

  Future<int> getCount() async {
    final db = await openDB();
    if (db == null) {
      return 0;
    }
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
    Log.i(tableName, 'rows count = ${count.toString()}');
    return count ?? 0;
  }

  /* Обновляем выборочные поля */
  Future<int> updatePartial(int? pk, Map<String, dynamic> values) async {
    if (pk == null) {
      Log.e('[ERROR]: $tableName not updated', 'pk is null');
      return 0;
    }
    Log.d('updatePartial $tableName pk=$pk', values.toString());
    final db = await openDB();
    if (db == null) {
      return 0;
    }
    int updated = await db.update(
      tableName,
      values,
      where: 'id = ?',
      whereArgs: [pk],
    );
    return updated;
  }

  /* Вставка в бд через транзакцию,
     запросы должены уже быть готовы к вставке

     'INSERT or REPLACE INTO Test(name, value, num) VALUES(?, ?, ?)',
     ['another name', 12345678, 3.1416]

     В массив ложим запросы с параметрами,
     то есть, первый элемент массива и последующие -
     это массивы, в каждом из которых первый элемент это
     сам запрос, а второй элемент - параметры
  */
  Future<void> transaction(List<dynamic> queriesWithParams) async {
    if (queriesWithParams.isEmpty) {
      Log.d('transaction $tableName', 'empty');
      return;
    }
    final db = await openDB();
    if (db == null) {
      return;
    }
    final elapser = Stopwatch();
    elapser.start();

    String query = queriesWithParams[0];
    List<dynamic> params = queriesWithParams[1];

    await db.transaction((txn) async {
      int count = await txn.rawInsert(query, params);
      //Log.d('transaction $tableName', 'inserted $count for query: $query, with params $params');
    });
    elapser.stop();
    Log.d('transaction ${db.path.split("/").last}.$tableName',
        'queries count: ${params.length}, elapsed ${elapser.elapsed.inMilliseconds}');
  }

  Future<void> massTransaction(List<dynamic> pages) async {
    /* Массовая вставка постранично разбитых запросов разом,
       тоже самое что transaction, только берем сразу много queriesWithParams
       pages = [queriesWithParams = [[query, params], [query, params], ...]]
    */
    final elapser = Stopwatch();
    elapser.start();
    final db = await openDB();
    if (db == null) {
      return;
    }
    await db.transaction((txn) async {
      for (List<dynamic> page in pages) {
        if (page.isEmpty) {
          Log.d('transaction $tableName', 'empty');
          continue;
        }
        String query = page[0];
        List<dynamic> params = page[1];
        if (params.isEmpty) {
          Log.d('transaction $tableName', 'empty params');
          return;
        }
        await txn.rawInsert(query, params);
      }
    });
    elapser.stop();
    Log.d('transaction ${db.path.split("/").last}.$tableName',
        'elapsed ${elapser.elapsed.inMilliseconds}');
  }

  /* Для сохранения всего говнища в базу,
     берем пачку моделей,
     подготавливаем запросы с параметрами
     останется отправить их в transaction()

     Если большой массив, надо делать постранично (start, end)
  */
  Future<List<dynamic>> prepareTransactionQueries(
      List<dynamic> models, int start, int end) async {
    List<dynamic> result = [];
    if (models.isEmpty) {
      return result;
    }
    final keys = models[0].toMap().keys;
    String paramsPlaceholder = '(${'?, ' * (keys.length - 1)}?)';
    String paramsNames = keys.join(',');
    List<String> paramsPlaceholders = [];
    List<dynamic> queryValues = []; // all values in the list

    String query = 'INSERT OR REPLACE INTO $tableName ($paramsNames) VALUES';

    if (end > models.length) {
      end = models.length;
    }
    List<dynamic> curSlice = models.sublist(start, end);
    for (var model in curSlice) {
      paramsPlaceholders.add(paramsPlaceholder); // Добавляем ?,?,? на каждую запись
      Map<String, dynamic> mapa = model.toMap();
      for (String paramName in keys) {
        // Все пихаем в длинный список
        queryValues.add(mapa[paramName]);
      }
    }
    return [query + paramsPlaceholders.join(','), queryValues];
  }
}

