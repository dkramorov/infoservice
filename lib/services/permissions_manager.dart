import 'package:permission_handler/permission_handler.dart';

import '../helpers/log.dart';

class PermissionsManager {
  static const TAG = 'PermissionsManager';
  Future<bool> requestPermissions(String permStr) async {
    // Запрос прав на требуемые разрешения (например, хранилище)
    // например: perm = Permission.storage
    Permission perm = Permission.storage;
    switch (permStr) {
      case 'storage':
        perm = Permission.storage;
        break;
      case 'microphone':
        perm = Permission.microphone;
        break;
      default:
        perm = Permission.storage;
        break;
    }
    Log.d(TAG, 'requestPermission $permStr => ${perm.toString()}');
    final permStatus = await perm.status;
    if (!permStatus.isGranted) {
      Log.e(TAG, 'Permissions absents ${perm.toString()}');
      final status = await perm.request();
      if (status.isPermanentlyDenied) {
        //openAppSettings();
      }
      Log.d(TAG, 'request permissions ${perm.toString()} status $status');
      return false;
    }
    return true;
  }
}
