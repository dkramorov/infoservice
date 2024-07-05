import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_asset_lib.dart';

import 'new_pages/pages/catalog/catalog_page.dart';
import 'new_pages/pages/chats/chats_page.dart';
import 'new_pages/pages/history/history_page.dart';
import 'new_pages/pages/profil/profil_page.dart';


String token = "";
String apnsToken = "";

bool admin = false;
// ValueNotifier<bool> user = ValueNotifier(true);
int customDigit = 1;
ValueNotifier<int> thPage = ValueNotifier(0);
ValueNotifier<bool> logOut = ValueNotifier(false);
String inp = "Поиск компании";

void delToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  token = "";
  setToken();
  if (prefs.containsKey("token")) {
    prefs.remove("token");
  }
}

String? name, myPhone="83952959223", email, pass, sex, date;

dynamic myRosters = [];
int sel = 0;

int selectCarId = 0;

Dio dio = Dio(
  BaseOptions(
      baseUrl: "https://$jabberServer",
      headers: {"Content-Type": "application/json"}),
);

void setToken() {
  dio.options.headers = token.isEmpty
      ? {"accept": "application/json"}
      : {"accept": "application/json", "Authorization": "Bearer $token"};
}

final List<Widget> listPage = listUserPage;
final List<String> listIcon = listUserIcon;
final List<String> listText = listUserText;

final List<Widget> listUserPage = [
  const CatalogPage(),
  const ChatsPage(),
  const SizedBox(),
  const HistoryPage(),
  const ProfilPage(),
];
final List<Widget> listHostPage = [];
final List<String> listUserText = [
  'Каталог',
  'Чаты',
  'Позвонить',
  'История',
  'Профиль',
];

final List<String> listUserIcon = [
  AssetLib.barCatalog,
  AssetLib.barChat,
  AssetLib.barCall,
  AssetLib.barHistory,
  AssetLib.barProfile,
];

const int phoneMask = 1;

const String sipDomain = 'calls.223-223.ru';
const String sipWss = 'wss://$sipDomain:7443';
const String jabberServer = 'chat.masterme.ru';
