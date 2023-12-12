import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/log.dart';

class SharedPreferencesManager {
  // Обновление контактов
  static const String refreshContactsTask = 'refreshContacts-task';
  static const String refreshContactsTaskDone = 'refreshContacts-task-done';

  // Авторизация на сервере ejabberd
  static const String dbUpdateTask = 'dbUpdate-task';
  static const String dbUpdateTaskDone = 'dbUpdate-task-done';

  // Переменные ejabberd
  static const String myJid = 'myJid';
  static const String credentialsHash = 'credentialsHash';

  static Future<SharedPreferences> getSharedPreferences(
      {int retry = 10, bool reload = true}) async {
    SharedPreferences preferences;
    for (int i = 0; i < retry; i++) {
      try {
        preferences = await SharedPreferences.getInstance();
        if (reload) {
          await preferences.reload();
        }
        //Log.d('getSharedPreferences', 'loadSettings success');
        return preferences;
      } catch (ex) {
        await Future.delayed(const Duration(milliseconds: 10));
        Log.e('getSharedPreferences', 'loadSettings error - ${ex.toString()}');
      }
    }
    return await SharedPreferences.getInstance();
  }
}
