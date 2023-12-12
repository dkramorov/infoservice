import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:infoservice/services/shared_preferences_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/companies/addresses.dart';
import '../models/companies/branches.dart';
import '../models/companies/cat_contpos.dart';
import '../models/companies/catalogue.dart';
import '../models/companies/cats.dart';
import '../models/companies/orgs.dart';
import '../models/companies/phones.dart';
import '../helpers/log.dart';
import '../helpers/network.dart';
import '../settings.dart';

class CompaniesUpdateVersion {
  static const String TAG = 'CompaniesUpateVersion';
  // отладочные сообщения по обновлению,
  // при отладке постоянно скачивается новый каталог
  static bool DEBUG = false;
  static const String CAT_VERSION_KEY = 'catalogue_version';
  final int version;

  CompaniesUpdateVersion({
    required this.version,
  });

  @override
  String toString() {
    return 'version: $version';
  }

  factory CompaniesUpdateVersion.fromJson(Map<String, dynamic> json) {
    return CompaniesUpdateVersion(
      version: json['version'],
    );
  }

  static CompaniesUpdateVersion parseResponse(String responseBody) {
    final parsed = jsonDecode(responseBody);
    return CompaniesUpdateVersion.fromJson(parsed);
  }

  static Future<int> downloadUpdateVersion() async {
    String now = DateTime.now().toIso8601String(); // no cache param
    final url = '$DB_SERVER$DB_UPDATE_VERSION?t=$now';
    if (DEBUG) {
      Log.d(TAG, url);
    }
    Map<String, dynamic> response = await requestsGetJson(url);
    if (DEBUG) {
      Log.d(TAG, 'server version update: ${response.toString()}');
    }
    return response['version'] as int;
  }
}

class CompaniesUpdate {
  static const String TAG = 'CompaniesUpdate';

  final List<Branches>? branches;
  final List<Addresses>? addresses;
  final List<Phones>? phones;
  final List<Catalogue>? catalogue;
  final List<Cats>? cats;
  final List<Orgs>? orgs;
  final List<CatContpos>? catContpos;

  CompaniesUpdate({
    this.branches,
    this.addresses,
    this.phones,
    this.catalogue,
    this.cats,
    this.orgs,
    this.catContpos,
  });

  @override
  String toString() {
    final int branchesLen = branches != null ? branches!.length : 0;
    final int addressesLen = addresses != null ? addresses!.length : 0;
    final int phonesLen = phones != null ? phones!.length : 0;
    final int catalogueLen = catalogue != null ? catalogue!.length : 0;
    final int catsLen = cats != null ? cats!.length : 0;
    final int orgsLen = orgs != null ? orgs!.length : 0;
    final int catContposLen = catContpos != null ? catContpos!.length : 0;

    return 'branches: $branchesLen, addresses: $addressesLen, ' +
        'phones: $phonesLen, catalogue: $catalogueLen, ' +
        'cats: $catsLen, orgs: $orgsLen, ' +
        'catContpos: $catContposLen';
  }

  factory CompaniesUpdate.fromJson(Map<String, dynamic> json) {
    return CompaniesUpdate(
      branches: Branches.jsonFromList(json['branches'] as List<dynamic>),
      addresses: Addresses.jsonFromList(json['addresses'] as List<dynamic>),
      phones: Phones.jsonFromList(json['phones'] as List<dynamic>),
      catalogue: Catalogue.jsonFromList(json['catalogue'] as List<dynamic>),
      cats: Cats.jsonFromList(json['cats'] as List<dynamic>),
      orgs: Orgs.jsonFromList(json['orgs'] as List<dynamic>),
      catContpos: CatContpos.jsonFromList(json['cat_contpos'] as List<dynamic>),
    );
  }
}

class UpdateManagerStream {
  StreamController<String> updateController =
      StreamController<String>.broadcast();
  Stream<String> get updateSection =>
      updateController.stream.asBroadcastStream();

  void sectionChanged(String section) {
    updateController.add(section);
  }

  void close() {
    updateController.close();
  }
}

class UpdateManager {
  static const TAG = 'UpdateManager';
  static final UpdateManager _singleton = UpdateManager._internal();
  static Timer? updateTimer;
  static SharedPreferences? preferences;
  static bool enabled = true; // на время отладки можно отключать

  static const int defaultUpdateInterval = 3600;
  // TODO: вернуть обратно на 3600
  //static const int defaultUpdateInterval = 20;
  int intervalUpdateCheck = 1;

  static bool addressesLoaded = false;
  static bool branchesLoaded = false;
  static bool catContposLoaded = false;
  static bool catalogueLoaded = false;
  static bool catsLoaded = false;
  static bool orgsLoaded = false;
  static bool phonesLoaded = false;

  static const String dropCatalogueAction = 'dropCatalogue';
  static const String dropUpdateFileAction = 'dropUpdateFile';
  static const String downloadUpdateFileAction = 'downloadUpdateFile';
  static const String saveDataAction = 'saveData';

  static const String addressesLoadedAction = 'addressesLoaded';
  static const String branchesLoadedAction = 'branchesLoaded';
  static const String catContposLoadedAction = 'catContposLoaded';
  static const String catalogueLoadedAction = 'catalogueLoaded';
  static const String catsLoadedAction = 'catsLoaded';
  static const String orgsLoadedAction = 'orgsLoaded';
  static const String phonesLoadedAction = 'phonesLoaded';
  static const String rubricsIsEmptyAction = 'rubrisIsEmpty';

  static const String updateFName = 'companies_db_helper';

  static UpdateManagerStream? updateStream;

  static showLoaded() {
    print('addressesLoaded, $addressesLoaded');
    print('branchesLoaded, $branchesLoaded');
    print('catContposLoaded, $catContposLoaded');
    print('catalogueLoaded, $catalogueLoaded');
    print('catsLoaded, $catsLoaded');
    print('orgsLoaded, $orgsLoaded');
    print('phonesLoaded, $phonesLoaded');
  }

  static bool allLoaded() {
    if (!addressesLoaded ||
        !branchesLoaded ||
        !catContposLoaded ||
        !catalogueLoaded ||
        !catsLoaded ||
        !orgsLoaded ||
        !phonesLoaded) {
      showLoaded();
      return false;
    }
    return true;
  }

  factory UpdateManager() {
    return _singleton;
  }

  UpdateManager._internal();

  Future<void> dropUpdate() async {
    updateStream?.sectionChanged(dropUpdateFileAction);
    File updateFile = await getUpdatePath();
    if (await updateFile.exists()) {
      Log.d(TAG, 'dropping ${updateFile.path}');
      await updateFile.delete();
    }
    File archiveFile = await getArchivePath();
    if (await archiveFile.exists()) {
      Log.d(TAG, 'dropping ${archiveFile.path}');
      await archiveFile.delete();
    }
    File tarFile = await getTarPath();
    if (await tarFile.exists()) {
      Log.d(TAG, 'dropping ${tarFile.path}');
      await tarFile.delete();
    }
  }

  Future<File> downloadUpdateFile() async {
    String now = DateTime.now().toIso8601String(); // no cache param
    final url = '$DB_SERVER$DB_UPDATE_ENDPOINT?t=$now';
    updateStream?.sectionChanged(downloadUpdateFileAction);
    Log.d('downloadUpdate', url);
    final File dest = await getUpdatePath();
    return await downloadFile(url, dest);
  }

  Future<File> downloadUpdateArchiveFile() async {
    String now = DateTime.now().toIso8601String(); // no cache param
    final url = '$DB_SERVER$DB_UPDATE_ARCHIVE_ENDPOINT?t=$now';
    updateStream?.sectionChanged(downloadUpdateFileAction);
    Log.d('downloadUpdate', url);
    final File dest = await getArchivePath();
    return await downloadFile(url, dest);
  }

  Future<File> getUpdatePath() async {
    return await getLocalFilePath('$updateFName.json');
  }

  Future<File> getArchivePath() async {
    final File updateArchivePath = await getLocalFilePath('$updateFName.tar.gz');
    Log.d('getArchivePath', updateArchivePath.path);
    return updateArchivePath;
  }

  Future<File> getTarPath() async {
    final File tarPath = await getLocalFilePath('temp.tar');
    Log.d('getTarPath', tarPath.path);
    return tarPath;
  }

  void extractUpdateArchive(List<String> args) async {
    // UNTAR
    String folder = args[0];
    String archiveFile = args[1];
    //await extractFileToDisk(archiveFile.path, folder, asyncWrite: true);

    final String tarPath = '$folder/temp.tar';
    final input = InputFileStream(archiveFile);
    final output = OutputFileStream(tarPath, bufferSize: 4096);

    GZipDecoder().decodeStream(input, output);

    input.close();
    output.close();

    final input2 = InputFileStream(tarPath);
    final archive = TarDecoder().decodeBuffer(input2);
    extractArchiveToDisk(archive, folder);
    print(folder);
  }

  /* Обрабатываем файл, который только что загрузился и
     мы получили путь до него, либо если null,
     тогда пробуем найти в папке его
  */
  Future<CompaniesUpdate?> parseUpdateFile() async {
    //File updateFile = await downloadUpdateFile();
    File archiveFile = await downloadUpdateArchiveFile();

    // UNTAR
    String folder = await makeAppFolder();
    //await extractFileToDisk(archiveFile.path, folder, asyncWrite: true);


    await compute(extractUpdateArchive, [folder, archiveFile.path]);


    // Тут полагаем, что файл в архиве называется также как наш путь к обновлению
    File updateFile = await getUpdatePath();
    String content = await updateFile.readAsString();
    return compute(parseResponse, content);
  }

  CompaniesUpdate parseResponse(String responseBody) {
    final parsed = jsonDecode(responseBody);
    return CompaniesUpdate.fromJson(parsed);
  }

  void init() {

    if (!enabled) {
      Log.i(TAG, '--- UpdateManager DISABLED ---');
      return;
    }

    updateStream ??= UpdateManagerStream();
    if (updateTimer != null) {
      return;
    }
    updateTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      preferences = await SharedPreferencesManager.getSharedPreferences();
      intervalUpdateCheck -= 1;
      if (CompaniesUpdateVersion.DEBUG) {
        Log.d(TAG, 'next update check in $intervalUpdateCheck');
      }
      if (intervalUpdateCheck < 0) {
        intervalUpdateCheck = defaultUpdateInterval;
        int serverVersion =
            await CompaniesUpdateVersion.downloadUpdateVersion();
        if (serverVersion > 0) {
          int curVersion =
              preferences?.getInt(CompaniesUpdateVersion.CAT_VERSION_KEY) ?? 0;

          // Всегда обновляем
          if (CompaniesUpdateVersion.DEBUG) {
            curVersion = 0;
          }

          if (curVersion < serverVersion) {
            if (CompaniesUpdateVersion.DEBUG) {
              Log.d(TAG,
                  'server version update is $serverVersion, curVersion is $curVersion');
            }
            await loadCatalogue(force: true);
            preferences?.setInt(
                CompaniesUpdateVersion.CAT_VERSION_KEY, serverVersion);
          }
        }
      }
      //Log.d(TAG, '${t.tick}');
    });
  }

  Future<void> loadCompaniesUpdate({required String key}) async {
    CompaniesUpdate data = await parseUpdateFile() ?? CompaniesUpdate();
    Log.d(TAG, 'Update data: $data');
    await saveData(data, key: key);
  }

  /* Сохранение всего говнища в базу */
  Future<void> saveData(CompaniesUpdate data, {required String key}) async {
    // Т/к мы вставляем (?,?,?), (?,?,?)... то есть, каждый параметр
    // для каждого поля отдельный, то надо вычислять by по кол-ву полей
    const int maxBy = 999; // смотри SQLITE_LIMIT_VARIABLE_NUMBER

    int now = DateTime.now().millisecondsSinceEpoch;

    int veryStarted = now;
    int started = now;

    int fieldsCount = 1;
    int by = 100;

    updateStream?.sectionChanged(saveDataAction);
    /* CatContpos, update with Catalogue */
    if (key == 'CatContpos' || key == 'Catalogue' || key == 'All') {
      int catContposCount = data.catContpos?.length ?? 0;
      fieldsCount = CatContpos().toMap().keys.length;
      by = maxBy ~/ fieldsCount;
      int catContposPages = (catContposCount ~/ by) + 1;

      List<dynamic> catContposQueriesPages = [];
      for (var i = 0; i < catContposPages; i++) {
        //Log.d(TAG, 'Update catContpos ${i + 1} / $catContposPages (${i * by} - ${i * by + by}), fieldsCount $fieldsCount');
        List<dynamic> catContpos = await CatContpos()
            .prepareTransactionQueries(data.catContpos!, i * by, i * by + by);
        if (catContpos.isNotEmpty) {
          catContposQueriesPages.add(catContpos);
        }
        //await CatContpos().transaction(catContpos);
      }
      await CatContpos().massTransaction(catContposQueriesPages);

      int loadedCatContpos = await CatContpos().getCount();
      print('CatContpos count $loadedCatContpos');
      now = DateTime.now().millisecondsSinceEpoch;
      print('elapsed ${now - started}');
      started = now;
      catContposLoaded = true;

      /* Catalogue */
      int catalogueCount = data.catalogue?.length ?? 0;
      fieldsCount = Catalogue().toMap().keys.length;
      by = maxBy ~/ fieldsCount;
      int cataloguePages = (catalogueCount ~/ by) + 1;

      List<dynamic> catalogueQueriesPages = [];
      for (var i = 0; i < cataloguePages; i++) {
        //Log.d(TAG, 'Update catalogue ${i + 1} / $cataloguePages (${i * by} - ${i * by + by}), fieldsCount $fieldsCount');
        List<dynamic> catalogue = await Catalogue()
            .prepareTransactionQueries(data.catalogue!, i * by, i * by + by);
        if (catalogue.isNotEmpty) {
          catalogueQueriesPages.add(catalogue);
        }
        //await Catalogue().transaction(catalogue);
      }
      await Catalogue().massTransaction(catalogueQueriesPages);

      int loadedCatalogue = await Catalogue().getCount();
      print('Catalogue count $loadedCatalogue');
      now = DateTime.now().millisecondsSinceEpoch;
      print('elapsed ${now - started}');
      started = now;
      catalogueLoaded = true;
      updateStream?.sectionChanged(catalogueLoadedAction);

      SharedPreferences prefs = await SharedPreferencesManager.getSharedPreferences();
      await prefs.setBool(catalogueLoadedAction, true);

      // Update key for next step
      key = 'Cats';
    }
    /* Cats */
    if (key == 'Cats' || key == 'All') {
      int catsCount = data.cats?.length ?? 0;
      fieldsCount = Cats().toMap().keys.length;
      by = maxBy ~/ fieldsCount;
      int catsPages = (catsCount ~/ by) + 1;

      List<dynamic> catsQueriesPages = [];
      for (var i = 0; i < catsPages; i++) {
        //Log.d(TAG, 'Update cats ${i + 1} / $catsPages (${i * by} - ${i * by + by}), fieldsCount $fieldsCount');
        List<dynamic> cats = await Cats()
            .prepareTransactionQueries(data.cats!, i * by, i * by + by);
        if (cats.isNotEmpty) {
          catsQueriesPages.add(cats);
        }
        //await Cats().transaction(cats);
      }
      await Cats().massTransaction(catsQueriesPages);

      int loadedCats = await Cats().getCount();
      print('Cats count $loadedCats');
      now = DateTime.now().millisecondsSinceEpoch;
      print('elapsed ${now - started}');
      started = now;
      catsLoaded = true;
      updateStream?.sectionChanged(catsLoadedAction);
      // Update key for next step
      key = 'Orgs';
    }
    /* Orgs */
    if (key == 'Orgs' || key == 'All') {
      int orgsCount = data.orgs?.length ?? 0;
      fieldsCount = Orgs().toMap().keys.length;
      by = maxBy ~/ fieldsCount;
      int orgsPages = (orgsCount ~/ by) + 1;

      List<dynamic> orgsQueriesPages = [];
      for (var i = 0; i < orgsPages; i++) {
        //Log.d(TAG, 'Update orgs ${i + 1} / $orgsPages (${i * by} - ${i * by + by}), fieldsCount $fieldsCount');
        List<dynamic> orgs = await Orgs()
            .prepareTransactionQueries(data.orgs!, i * by, i * by + by);
        if (orgs.isNotEmpty) {
          orgsQueriesPages.add(orgs);
        }
        //await Orgs().transaction(orgs);
      }
      await Orgs().massTransaction(orgsQueriesPages);

      int loadedOrgs = await Orgs().getCount();
      print('Orgs count $loadedOrgs');
      now = DateTime.now().millisecondsSinceEpoch;
      print('elapsed ${now - started}');
      started = now;
      orgsLoaded = true;
      updateStream?.sectionChanged(orgsLoadedAction);

      SharedPreferences prefs = await SharedPreferencesManager.getSharedPreferences();
      await prefs.setBool(orgsLoadedAction, true);

      // Update key for next step
      key = 'Branches';
    }
    /* Branches */
    if (key == 'Branches' || key == 'All') {
      int branchesCount = data.branches?.length ?? 0;
      fieldsCount = Branches().toMap().keys.length;
      by = maxBy ~/ fieldsCount;
      int branchesPages = (branchesCount ~/ by) + 1;

      List<dynamic> branchesQueriesPages = [];
      for (var i = 0; i < branchesPages; i++) {
        //Log.d(TAG, 'Update branches ${i + 1} / $branchesPages (${i * by} - ${i * by + by}), fieldsCount $fieldsCount');
        List<dynamic> branches = await Branches()
            .prepareTransactionQueries(data.branches!, i * by, i * by + by);
        if (branches.isNotEmpty) {
          branchesQueriesPages.add(branches);
        }
        //await Branches().transaction(branches);
      }
      await Branches().massTransaction(branchesQueriesPages);

      int loadedBranches = await Branches().getCount();
      print('Branches count $loadedBranches');
      now = DateTime.now().millisecondsSinceEpoch;
      print('elapsed ${now - started}');
      started = now;
      branchesLoaded = true;
      updateStream?.sectionChanged(branchesLoadedAction);
      // Update key for next step
      key = 'Phones';
    }
    /* Phones */
    if (key == 'Phones' || key == 'All') {
      int phonesCount = data.phones?.length ?? 0;
      fieldsCount = Phones().toMap().keys.length;
      by = maxBy ~/ fieldsCount;
      int phonesPages = (phonesCount ~/ by) + 1;

      List<dynamic> phonesQueriesPages = [];
      for (var i = 0; i < phonesPages; i++) {
        //Log.d(TAG, 'Update phones ${i + 1} / $phonesPages (${i * by} - ${i * by + by}), fieldsCount $fieldsCount');
        List<dynamic> phones = await Phones()
            .prepareTransactionQueries(data.phones!, i * by, i * by + by);
        if (phones.isNotEmpty) {
          phonesQueriesPages.add(phones);
        }
        //await Phones().transaction(phones);
      }
      await Phones().massTransaction(phonesQueriesPages);

      int loadedPhones = await Phones().getCount();
      print('Phones count $loadedPhones');
      now = DateTime.now().millisecondsSinceEpoch;
      print('elapsed ${now - started}');
      started = now;
      phonesLoaded = true;
      updateStream?.sectionChanged(phonesLoadedAction);
      // Update key for next step
      key = 'Addresses';
    }
    /* Addresses */
    if (key == 'Addresses' || key == 'All') {
      int addressesCount = data.addresses?.length ?? 0;
      fieldsCount = Addresses().toMap().keys.length;
      by = maxBy ~/ fieldsCount;
      int addressesPages = (addressesCount ~/ by) + 1;

      List<dynamic> addressesQueriesPages = [];
      for (var i = 0; i < addressesPages; i++) {
        //Log.d(TAG, 'Update addresses ${i + 1} / $addressesPages (${i * by} - ${i * by + by}), fieldsCount $fieldsCount');
        List<dynamic> addresses = await Addresses()
            .prepareTransactionQueries(data.addresses!, i * by, i * by + by);
        if (addresses.isNotEmpty) {
          addressesQueriesPages.add(addresses);
        }
        //await Addresses().transaction(addresses);
      }
      await Addresses().massTransaction(addressesQueriesPages);

      int loadedAddresses = await Addresses().getCount();
      print('Addresses count $loadedAddresses');
      now = DateTime.now().millisecondsSinceEpoch;
      print('elapsed ${now - started}');
      started = now;
      addressesLoaded = true;
      updateStream?.sectionChanged(addressesLoadedAction);
    }
    now = DateTime.now().millisecondsSinceEpoch;
    print('total elapsed ${now - veryStarted}');
  }

  Future<void> dropCatalogue() async {
    updateStream?.sectionChanged(dropCatalogueAction);
    await Catalogue().dropAllRows();
    await Addresses().dropAllRows();
    await Branches().dropAllRows();
    await CatContpos().dropAllRows();
    await Cats().dropAllRows();
    await Orgs().dropAllRows();
    await Phones().dropAllRows();
  }

  Future<void> loadCatalogue({bool force = false}) async {
    List<Catalogue> rubrics = await Catalogue().getFullCatalogue();
    if (rubrics.isEmpty) {
      updateStream?.sectionChanged(rubricsIsEmptyAction);
      await loadCompaniesUpdate(key: 'Catalogue');
    } else {
      if (allLoaded() && !force) {
        return;
      }

      /* Проверяем количество в остальных таблицах */
      CompaniesUpdate data = await parseUpdateFile() ?? CompaniesUpdate();
      Log.d(TAG, 'Check other data: $data');

      if (!catContposLoaded || force) {
        int catContposCount = await CatContpos().getCount();
        if (catContposCount < (data.catContpos?.length ?? 0) || force) {
          await saveData(data, key: 'CatContpos');
          return;
        } else {
          catContposLoaded = true;
        }
      }

      if (!catalogueLoaded || force) {
        int catalogueCount = await Catalogue().getCount();
        if (catalogueCount < (data.catalogue?.length ?? 0) || force) {
          await saveData(data, key: 'Catalogue');
          return;
        } else {
          catalogueLoaded = true;
        }
      }

      if (!catsLoaded || force) {
        int catsCount = await Cats().getCount();
        if (catsCount < (data.cats?.length ?? 0) || force) {
          await saveData(data, key: 'Cats');
          return;
        } else {
          catsLoaded = true;
        }
      }

      if (!orgsLoaded || force) {
        int orgsCount = await Orgs().getCount();
        if (orgsCount < (data.orgs?.length ?? 0) || force) {
          await saveData(data, key: 'Orgs');
          return;
        } else {
          orgsLoaded = true;
        }
      }

      if (!branchesLoaded || force) {
        int branchesCount = await Branches().getCount();
        if (branchesCount < (data.branches?.length ?? 0) || force) {
          await saveData(data, key: 'Branches');
          return;
        } else {
          branchesLoaded = true;
        }
      }

      if (!phonesLoaded || force) {
        int phonesCount = await Phones().getCount();
        if (phonesCount < (data.phones?.length ?? 0) || force) {
          await saveData(data, key: 'Phones');
          return;
        } else {
          phonesLoaded = true;
        }
      }

      if (!addressesLoaded || force) {
        int addressesCount = await Addresses().getCount();
        if (addressesCount < (data.addresses?.length ?? 0) || force) {
          await saveData(data, key: 'Addresses');
          return;
        } else {
          addressesLoaded = true;
        }
      }
    }
    await dropUpdate();
  }
}
