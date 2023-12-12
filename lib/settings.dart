import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';


const bool SENTRY_ENABLED = false;
const String APP_FOLDER = '8800help';
const int RESULT_SUCCESS = 1;
const int RESULT_EMPTY = 0;
const int RESULT_DEFAULT = -1;

const String DEFAULT_AVATAR = 'assets/avatars/default_avatar.png';
const SEARCH_ICON = 'assets/svg/bp_search_icon.svg';

const String SIP_DOMAIN = 'calls.223-223.ru';
const String SIP_WSS = 'wss://$SIP_DOMAIN:7443';
const String JABBER_SERVER = 'chat.masterme.ru';
const int JABBER_PORT = 5222; // В подключение надо строкой передавать
const String JABBER_REG_ENDPOINT = '/jabber/register_user/';
const String JABBER_VCARD_ENDPOINT = '/jabber/vcard/';
const String JABBER_GROUP_VCARD_ENDPOINT = '/jabber/group_vcard/';
const String JABBER_CONTACTS_ENDPOINT = '/jabber/set_device_contacts/';
const String JABBER_COMPANY_ENDPOINT = '/companies/chat/';
//const String JABBER_NOTIFY_ENDPOINT = '/jabber/notification/infoservice-f0261/';
const String JABBER_NOTIFY_ENDPOINT = '/jabber/notification/mastermechat/';
const String JABBER_NOTIFY_BATCH_ENDPOINT = '/jabber/notification_batch/mastermechat/';

const DB_SERVER = 'https://chat.masterme.ru';
const DB_UPDATE_ENDPOINT = '/media/app_json/companies_db_helper.json';
const DB_UPDATE_ARCHIVE_ENDPOINT = '/media/companies_db_helper.tar.gz';
const DB_LOGO_PATH = '/media/'; // Полный путь передаем, начиная с /media/
// Маршут, который говорит какая версия для обновления доступна
const DB_UPDATE_VERSION = '/media/app_json/version.json';

const int PHONE_MASK = 1;

// SIZE
const SIZED_BOX_W04 = SizedBox(width: 4);
const SIZED_BOX_W06 = SizedBox(width: 6);
const SIZED_BOX_W10 = SizedBox(width: 10);
const SIZED_BOX_W20 = SizedBox(width: 20);
const SIZED_BOX_W45 = SizedBox(width: 45);

const SIZED_BOX_H04 = SizedBox(width: 4);
const SIZED_BOX_H06 = SizedBox(height: 6);
const SIZED_BOX_H12 = SizedBox(height: 12);
const SIZED_BOX_H16 = SizedBox(height: 16);
const SIZED_BOX_H20 = SizedBox(height: 20);
const SIZED_BOX_H24 = SizedBox(height: 24);
const SIZED_BOX_H30 = SizedBox(height: 30);
const SIZED_BOX_H45 = SizedBox(height: 45);

// PADDING
const PAD_ONLY_T10 = EdgeInsets.only(top: 10);
const PAD_ONLY_T20 = EdgeInsets.only(top: 20);
const PAD_ONLY_T40 = EdgeInsets.only(top: 40);
const PAD_ONLY_R20 = EdgeInsets.only(right: 20);
const PAD_SYM_H10 = EdgeInsets.symmetric(horizontal: 10);
const PAD_SYM_H16 = EdgeInsets.symmetric(horizontal: 16);
const PAD_SYM_H20 = EdgeInsets.symmetric(horizontal: 20);
const PAD_SYM_H30 = EdgeInsets.symmetric(horizontal: 30);
const PAD_SYM_V10 = EdgeInsets.symmetric(vertical: 10);
const PAD_SYM_V20 = EdgeInsets.symmetric(vertical: 20);

// Color
const disabledButtonColor = Color(0xFFD2D2D2);
const backgroundLightColor = Color(0xFFFFFFFF);
const Color tealColor = Color(0xFF1595A6);

// Border radius
const BORDER_RADIUS_48 = BorderRadius.all(
  Radius.circular(48.0),
);
const BORDER_RADIUS_32 = BorderRadius.all(
  Radius.circular(32.0),
);
const BORDER_RADIUS_16 = BorderRadius.all(
  Radius.circular(16.0),
);
const BORDER_RADIUS_8 = BorderRadius.all(
  Radius.circular(8.0),
);

const PRIMARY_COLOR = Colors.green;
const GREEN_TEXT_STYLE = TextStyle(
  fontSize: 20.0,
  color: Colors.green,
);


const INPUT_DECORATION = InputDecoration(
  hintText: '',
  contentPadding: EdgeInsets.symmetric(
    vertical: 10.0,
    horizontal: 20.0,
  ),
  border: OutlineInputBorder(
    borderRadius: BORDER_RADIUS_16,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BORDER_RADIUS_16,
    borderSide: BorderSide(
      color: tealColor,
      width: 1.0,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BORDER_RADIUS_16,
    borderSide: BorderSide(
      color: tealColor,
      width: 2.0,
    ),
  ),
);

const MessageOptions chatMessageOptions = MessageOptions(
  unreadStatusIcon:
  Icon(Ionicons.checkmark_outline, size: 16, color: Colors.white),
  readStatusIcon:
  Icon(Ionicons.checkmark_done_outline, size: 16, color: Colors.white),
  showTime: true,
  fontSize: 16,
);