import 'package:flutter/material.dart';

import '../../../../gl.dart';
import '../../../../profile/about_page.dart';
import '../../../../profile/settings_page.dart';

class ProfileItemModel {
  const ProfileItemModel({
    this.appBarTitle = '',
    required this.title,
    required this.icon,
    required this.description,
    this.destinationSpecial,
  });

  final String appBarTitle;
  final String title;
  final String icon;
  final String description;
  final Widget? destinationSpecial;
}

List<ProfileItemModel> get profileItemCurrent =>
    myPhone != null ? profileItemsAuthUser : profileItemsGuest;

const profileItemsGuest = <ProfileItemModel>[
  ProfileItemModel(
    title: 'Политика конфиденциальности',
    icon: 'file',
    description:
        "Политика конфиденциальности — это заявление, в котором раскрываются некоторые или все способы, с помощью которых сайт собирает, использует и раскрывает персональные данные (личную информацию) посетителей сайта, а также управляет ими. Политика отвечает требованиям законодательства по защите конфиденциальности посетителей сайта и клиентов. В разных странах действуют свои законы с различными требованиями к политике конфиденциальности.",
  ),
  ProfileItemModel(
    title: 'Условия предоставления услуг',
    icon: 'file',
    description:
        "Политика конфиденциальности — это заявление, в котором раскрываются некоторые или все способы, с помощью которых сайт собирает, использует и раскрывает персональные данные (личную информацию) посетителей сайта, а также управляет ими. Политика отвечает требованиям законодательства по защите конфиденциальности посетителей сайта и клиентов. В разных странах действуют свои законы с различными требованиями к политике конфиденциальности.",
  ),
  ProfileItemModel(
    title: 'О приложении',
    icon: 'logo',
    description: '',
    destinationSpecial: AboutPage(null, null, []),
  ),
];

const profileItemsAuthUser = <ProfileItemModel>[
  ProfileItemModel(
    title: 'Настройки',
    icon: 'settings',
    description: '',
    destinationSpecial: SettingsPage(null, null),
  ),
  ProfileItemModel(
    title: 'Политика конфиденциальности',
    icon: 'file',
    description:
        "Политика конфиденциальности — это заявление, в котором раскрываются некоторые или все способы, с помощью которых сайт собирает, использует и раскрывает персональные данные (личную информацию) посетителей сайта, а также управляет ими. Политика отвечает требованиям законодательства по защите конфиденциальности посетителей сайта и клиентов. В разных странах действуют свои законы с различными требованиями к политике конфиденциальности.",
  ),
  ProfileItemModel(
    title: 'Условия предоставления услуг',
    icon: 'file',
    description:
        "Политика конфиденциальности — это заявление, в котором раскрываются некоторые или все способы, с помощью которых сайт собирает, использует и раскрывает персональные данные (личную информацию) посетителей сайта, а также управляет ими. Политика отвечает требованиям законодательства по защите конфиденциальности посетителей сайта и клиентов. В разных странах действуют свои законы с различными требованиями к политике конфиденциальности.",
  ),
  ProfileItemModel(
    title: 'О приложении',
    icon: 'logo',
    description: '',
    destinationSpecial: AboutPage(null, null, []),
  ),
  ProfileItemModel(
    title: 'Выйти из профиля',
    icon: 'logout',
    description: '',
  ),
];
