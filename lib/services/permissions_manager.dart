import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helpers/log.dart';

class PermissionsManager {
  static const TAG = 'PermissionsManager';

  Future<bool> checkGranularMediaPermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    bool storage = true;
    bool videos = true;
    bool photos = true;
    bool extStorage = true;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if ((androidInfo.version.sdkInt ?? 0) >= 33) {
      videos = await Permission.videos.status.isGranted;
      photos = await Permission.photos.status.isGranted;
      extStorage = await Permission.manageExternalStorage.status.isGranted;
    } else {
      storage = await Permission.storage.status.isGranted;
    }
    //if (storage && videos && photos && extStorage) {
    if (storage && videos && photos) {
      return true;
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.videos,
        Permission.photos,
        //Permission.manageExternalStorage,
      ].request();

      // granular media permissions
      Log.d(TAG, 'request permissions photos&videos => $statuses');
      bool isPermanentlyDenied = false;
      for (Permission perm in statuses.keys) {
        if (statuses[perm]!.isPermanentlyDenied) {
          isPermanentlyDenied = true;
        }
      }
      if (isPermanentlyDenied) {
        openAppSettings();
      }
      return false;
    }
    return true;
  }

  Future<bool> checkPermissions(String permStr) async {
    Permission perm = Permission.storage;
    switch (permStr) {
      case 'storage':
        perm = Permission.storage;
        break;
      case 'microphone':
        perm = Permission.microphone;
        break;
      case 'contacts':
        perm = Permission.contacts;
        break;
      default:
        perm = Permission.storage;
        break;
    }
    final permStatus = await perm.status;
    Log.d(TAG,
        'checkPermissions $permStr => ${perm.toString()} = ${permStatus.name}');
    return permStatus.isGranted;
  }

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
      case 'contacts':
        perm = Permission.contacts;
        break;
      default:
        perm = Permission.storage;
        break;
    }
    final permStatus = await perm.status;
    Log.d(TAG,
        'requestPermission $permStr => ${perm.toString()}, permStatus => $permStatus');
    if (!permStatus.isGranted) {
      Log.e(TAG, 'Permissions absents ${perm.toString()}');
      final status = await perm.request();
      if (status.isPermanentlyDenied) {
        //openAppSettings();
      }
      // granular media permissions
      if (await checkGranularMediaPermissions()) {
        Log.d(TAG, 'checkGranularMediaPermissions success');
        return true;
      }
      Log.d(TAG, 'request permissions ${perm.toString()} status $status');
      return false;
    }
    return true;
  }
}
