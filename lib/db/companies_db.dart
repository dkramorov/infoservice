import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/log.dart';

class DBCompaniesInstance {
  static Database? instance;
}

/* Вспомогательный класс для создания любой модели для базы данных */
class AbstractCompaniesModel {
  int? id; // null if we need new row
  String? tableName;

  String getTableName() {
    return tableName ?? '';
  }

  AbstractCompaniesModel({this.id, this.tableName});

  static getInt(dynamic digit) {
    if (digit == null) {
      return 0;
    }
    digit = '$digit';
    return (digit != '') ? int.parse(digit) : 0;
  }

  static getDouble(dynamic digit) {
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

  Future<void> insert2Db() async {
    final tableName = getTableName();
    Log.i('$tableName insert2Db', '${this.toMap().toString()}');
    final db = await openCompaniesDB();
    // id null if we need new row
    int pk = await db.insert(
      getTableName(),
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    id = pk;
  }

  Future<void> update2Db() async {
    final tableName = getTableName();
    if (id == null) {
      Log.e('$tableName update2Db', 'id is null, we can not update');
      return;
    }
    final db = await openCompaniesDB();
    await db.update(
      tableName,
      toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete2Db() async {
    final tableName = getTableName();
    if (id == null) {
      Log.e('$tableName delete2Db', 'id is null, we can not drop');
      return;
    }
    final db = await openCompaniesDB();
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> dropAllRows() async {
    final tableName = getTableName();
    final db = await openCompaniesDB();
    final dropped = await db.delete(
      tableName,
    );
    Log.w(tableName, 'dropAllRows = $dropped');
  }

  Future<int> getCount() async {
    final tableName = getTableName();
    final db = await openCompaniesDB();
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
    Log.i('$tableName', 'rows count = ${count.toString()}');
    return count ?? 0;
  }

  /* Обновляем выборочные поля */
  Future<int> updatePartial(int? pk, Map<String, dynamic> values) async {
    final tableName = getTableName();
    if (pk == null) {
      Log.e('[ERROR]: $tableName not updated', 'pk is null');
      return 0;
    }
    Log.d('updatePartial $tableName pk=$pk', '${values.toString()}');
    final db = await openCompaniesDB();

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
    final tableName = getTableName();

    if (queriesWithParams.isEmpty) {
      Log.d('transaction $tableName', 'empty');
      return;
    }
    final db = await openCompaniesDB();

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
    final db = await openCompaniesDB();
    final tableName = getTableName();
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
    final tableName = getTableName();
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
      paramsPlaceholders
          .add(paramsPlaceholder); // Добавляем ?,?,? на каждую запись
      Map<String, dynamic> mapa = model.toMap();
      for (String paramName in keys) {
        // Все пихаем в длинный список
        queryValues.add(mapa[paramName]);
      }
    }
    return [query + paramsPlaceholders.join(','), queryValues];
  }
}

/* SQL запросы для базы по фирмам
*/
String orgsIndexChat = 'CREATE INDEX IF NOT EXISTS fk_orgs_chat ON orgs (chat)';
List<String> companiesSQLHelper() {
  List<String> queries = [];
  String catalogueQuery = 'create table if not exists catalogue('
      'id integer primary key autoincrement not null,'
      ' name text,'
      ' count integer,'
      ' icon text,'
      ' img text,'
      ' position integer,'
      ' parents string,'
      ' searchTerms text'
      ')';
  queries.add(catalogueQuery);
  String catsQuery = 'create table if not exists cats('
      'id integer primary key autoincrement not null,'
      ' catId integer,'
      ' clientId integer'
      ')';
  queries.add(catsQuery);
  String catContposQuery = 'create table if not exists cat_contpos('
      'id integer primary key autoincrement not null,'
      ' catId integer,'
      ' clientId integer,'
      ' position integer'
      ')';
  queries.add(catContposQuery);
  String addressesQuery = 'create table if not exists addresses('
      'id integer primary key autoincrement not null,'
      ' postalCode text,'
      ' country text,'
      ' state text,'
      ' county text,'
      ' city text,'
      ' district text,'
      ' subdistrict text,'
      ' street text,'
      ' houseNumber text,'
      ' addressLines text,'
      ' additionalData text,'
      ' latitude decimal(30, 25),'
      ' longitude decimal(30, 25),'
      ' place text,'
      ' branchesCount integer,'
      ' searchTerms text'
      ')';
  queries.add(addressesQuery);
  String orgsQuery = 'create table if not exists orgs('
      'id integer primary key autoincrement not null,'
      ' name text,'
      ' logo text,'
      ' img text,'
      ' resume text,'
      ' branches integer,'
      ' phones integer,'
      ' reg integer,'
      ' rating decimal(2,1),'
      ' chat text,'
      ' searchTerms text'
      ')';
  queries.add(orgsQuery);
  queries.add(orgsIndexChat);
  String branchesQuery = 'create table if not exists branches('
      'id integer primary key autoincrement not null,'
      ' client integer,'
      ' name text,'
      ' address integer,'
      ' addressAdd text,'
      ' site text,'
      ' email text,'
      ' wtime text,'
      ' reg integer,'
      ' position integer,'
      ' searchTerms text'
      ')';
  queries.add(branchesQuery);
  String phonesQuery = 'create table if not exists phones('
      'id integer primary key autoincrement not null,'
      ' client integer,'
      ' branch integer,'
      ' prefix integer,'
      ' number text,'
      ' digits text,'
      ' whata integer,'
      ' comment text,'
      ' position integer,'
      ' searchTerms text'
      ')';
  queries.add(phonesQuery);
  return queries;
}

Future<Database> openCompaniesDB() async {
  const int dbVersion = 9; // Версия базы данных
  const dbName = 'companiesDB.db';
  if (DBCompaniesInstance.instance != null) {
    return DBCompaniesInstance.instance!;
  }

  /* companies sql helper */
  Future<void> companiesSQL(Database db) async {
    List<String> companiesSQLQueries = companiesSQLHelper();
    for (int i = 0; i < companiesSQLQueries.length; i++) {
      Log.d('companiesSQLHelper',
          'query ${i + 1} from ${companiesSQLQueries.length}');
      await db.execute(companiesSQLQueries[i]);
    }
  }

  Future<void> createTables(Database db) async {
    await companiesSQL(db);
  }

  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), dbName),

    onCreate: (db, version) async {
      await createTables(db);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      Log.i('--- DB UPGRADE ---', '$oldVersion=>$newVersion');
      /*
      if (oldVersion <= 8) {
        Log.w('--- DROP TABLE ---', 'catalogue');
        await db.rawQuery('DROP TABLE IF EXISTS catalogue');
      }
      */
      await createTables(db);
      if (oldVersion < 1) {
        const String alterCatalogueAddImg = 'ALTER TABLE catalogue add img TEXT';
        Log.d('ALTER TABLE', alterCatalogueAddImg);
        await db.execute(alterCatalogueAddImg);
      }
      if (oldVersion < 2) {
        const String alterOrgsAddChat = 'ALTER TABLE orgs add chat TEXT';
        Log.d('ALTER TABLE', alterOrgsAddChat);
        await db.execute(alterOrgsAddChat);
      }
      if (oldVersion < 3) {
        Log.d('CREATE INDEX', orgsIndexChat);
        await db.execute(orgsIndexChat);
      }
      if (oldVersion < 6) {
        const String alterCatalogueAddParents = 'ALTER TABLE catalogue add parents TEXT';
        Log.d('ALTER TABLE', alterCatalogueAddParents);
        await db.execute(alterCatalogueAddParents);
      }
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: dbVersion,
  );
  DBCompaniesInstance.instance = await database;
  Log.d('openCompaniesDB', join(await getDatabasesPath(), dbName));
  return database;
}
