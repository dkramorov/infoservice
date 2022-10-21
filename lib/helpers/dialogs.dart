import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/* Предупреждение, что недостаточно прав */
void permissionsErrorDialog(String permDesc, BuildContext context) {
  final isIOS = Platform.isIOS || Platform.isMacOS;
  String openSettingsString = 'Сейчас мы откроем настройки приложения';
  if (isIOS) {
    // На ибучем элпе пиздят, что мнение пользователя чего то стоит
    openSettingsString = '';
  }
  openInfoDialog(context, () {
    if (!isIOS) {
      openAppSettings();
    }
  },
      'Нет доступа к $permDesc',
      'Вы не дали разрешение на использование $permDesc.\n' +
          'Пожалуйста, добавьте разрешение в настройках.\n' +
          openSettingsString,
      'Понятно');
}

Future<bool> permsCheck(
    Permission permission, String permDesc, BuildContext context) async {
  /* For example: permission = Permission.microphone */
  final permStatus = await permission.status;
  if (!permStatus.isGranted) {
    final isIOS = Platform.isIOS || Platform.isMacOS;
    if (await permStatus.isPermanentlyDenied ||
        (isIOS && permStatus.isDenied)) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      permissionsErrorDialog(permDesc, context);
    } else {
      await [
        permission,
      ].request();
    }
    return false;
  }
  return true;
}

Future<String?> openInfoDialog(BuildContext context, Function? callback,
    String title, String text, String okText,
    {String? cancelText, Color? okColor}) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: <Widget>[
        if (cancelText != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
            child: Text(cancelText),
          ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Cancel');
            if (callback != null) {
              callback();
            }
          },
          child: Text(okText, style: TextStyle(color: okColor)),
        ),
      ],
    ),
  );
}
