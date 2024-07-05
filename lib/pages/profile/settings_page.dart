import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infoservice/helpers/context_extensions.dart';
import 'package:infoservice/pages/profile/personal_data_field.dart';
import 'package:infoservice/settings.dart';
import 'package:intl/intl.dart';
import '../../models/bg_tasks_model.dart';
import '../../models/user_settings_model.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../widgets/text_field_custom.dart';
import '../app_asset_lib.dart';
import '../authorization.dart';
import '../static_values.dart';
import '../generic_appbar.dart';
import '../themes.dart';
import '../../widgets/button.dart';
import '../../widgets/modal.dart';
import '../../widgets/switcher.dart';

class SettingsPage extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  const SettingsPage(this._sipHelper, this._xmppHelper, {Key? key})
      : super(key: key);
  static const String id = '/user_settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  int gender = 1;
  String genderStr = 'Мужской';
  DateFormat inputFormat = DateFormat('dd.MM.yyyy');
  bool dropPersonalDataFlag = false;
  DateTime birthday = DateTime.now();
  UserSettingsModel? userSettings;

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  @override
  void initState() {
    UserSettingsModel().getUser().then((userSettings) {
      if (userSettings != null) {
        setState(() {
          nameController.text = userSettings.name ?? '';
          emailController.text = userSettings.email ?? '';
          gender = userSettings.gender ?? 1;
          if (gender != 1) {
            genderStr = 'Женский';
          }
          if (userSettings.isDropped ?? false) {
            dropPersonalDataFlag = true;
          }
          if (userSettings.photo != null && userSettings.photo != '') {
            //photo = userSettings!.photo!;
          }
          print('received ${userSettings.toString()}');
          if (userSettings.birthday != null && userSettings.birthday != '') {
            List<String> dateArr = userSettings.birthday!.split('.');
            if (dateArr.length == 3) {
              birthday = DateTime(
                int.parse(userSettings.birthday!.split('.')[2]),
                int.parse(userSettings.birthday!.split('.')[1]),
                int.parse(userSettings.birthday!.split('.')[0]),
              );
            }
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void selectBirthday(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  void selectGender(Size size) {
    showModal(
      context,
      size.height * 0.25,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                gender = 1;
                genderStr = 'Мужской';
                setState(() {});
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: transparent,
                width: size.width - 32,
                child: Row(
                  children: [
                    SvgPicture.asset(AssetLib.man),
                    const SizedBox(width: 12),
                    Text(
                      'Мужской',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: w400,
                        color: black,
                      ),
                    ),
                    const Spacer(),
                    if (gender == 1) SvgPicture.asset(AssetLib.check)
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                genderStr = 'Женский';
                gender = 2;
                setState(() {});
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: transparent,
                width: size.width - 32,
                child: Row(
                  children: [
                    SvgPicture.asset(AssetLib.woman),
                    const SizedBox(width: 12),
                    Text(
                      'Женский',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: w400,
                        color: black,
                      ),
                    ),
                    const Spacer(),
                    if (gender != 1) SvgPicture.asset(AssetLib.check)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> dropAccount() async {
    userSettings = await UserSettingsModel().getUser();
    if (userSettings != null) {
      userSettings!.updatePartial(userSettings!.id, {'isDropped': true});
      await logout();
    }
  }

  Future<void> logout() async {
    await BGTasksModel.createUnregisterTask();
    xmppHelper?.setStopFlag(true);
    sipHelper?.setStopFlag(true);
    Future.delayed(Duration.zero, () async {
      Navigator.pushNamed(context, AuthScreenWidget.id, arguments: {
        sipHelper,
        xmppHelper,
      });
    });
  }

  Future<void> saveUserData({
    String? name,
    String? email,
    String? birthdayStr,
    int? gender,
  }) async {
    userSettings = await UserSettingsModel().getUser();
    // Записать в базу
    Map<String, dynamic> values = {
      'name': name,
      'email': email,
      'birthday': birthdayStr,
      'gender': gender,
      'isDropped': dropPersonalDataFlag ? 't' : 'f',
    };

    if (userSettings != null) {
      userSettings?.updatePartial(userSettings?.id, values);
      await BGTasksModel.updateMyVCardTask({
        'FN': name,
        'BDAY': birthdayStr,
        'EMAIL': email,
        'GENDER': gender,
      });
    }
    setState(() {});
  }

  String birthday2Str() {
    return '${birthday.day}.${birthday.month.toString().padLeft(2, '0')}.${birthday.year}';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: const GenericAppBar(hasBackButton: true, title: 'Ваши данные'),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(UIs.defaultPagePadding),
        child: ListView(
          children: [
            SIZED_BOX_H16,
            TextFieldCustom(
              labelText: 'Ваше имя',
              controller: nameController,
              keyboardType: TextInputType.name,
            ),
            SIZED_BOX_H16,
            TextFieldCustom(
              labelText: 'Ваш email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SIZED_BOX_H16,
            PersonalDataField(
                title: 'Дата рождения',
                value: birthday2Str(),
                onPressed: () {
                  selectBirthday(
                    CupertinoDatePicker(
                      initialDateTime: birthday,
                      mode: CupertinoDatePickerMode.date,
                      use24hFormat: true,
                      // This shows day of week alongside day of month
                      showDayOfWeek: true,
                      // This is called when the user changes the date.
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() => birthday = newDate);
                      },
                    ),
                  );
                }),
            SIZED_BOX_H16,
            PersonalDataField(
                title: 'Ваш пол',
                value: genderStr,
                onPressed: () {
                  selectGender(size);
                }),
            SIZED_BOX_H16,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: context.screenSize.width * 0.6,
                  child: Text(
                    'Не хранить на сервере личные данные о себе',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: w400,
                      color: black,
                    ),
                  ),
                ),
                CustomSwitch(
                  onChange: (c) {
                    dropPersonalDataFlag = !dropPersonalDataFlag;
                    setState(() {});
                  },
                  value: dropPersonalDataFlag,
                )
              ],
            ),
            SIZED_BOX_H16,
            PrimaryButton(
              color: blue,
              onPressed: () async {
                await saveUserData(
                  name: nameController.text,
                  email: emailController.text,
                  birthdayStr: birthday2Str(),
                  gender: gender,
                );
              },
              child: Text(
                'Сохранить',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: w500,
                  color: white,
                ),
              ),
            ),
            SIZED_BOX_H24,
            PrimaryButton(
              color: red,
              onPressed: () async {
                showModal(
                  context,
                  context.screenSize.height * 0.8,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          'Вы уверены, что хотите удалить профиль?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: w500,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Профиль и все связанные с ним данные будут удалены.'
                          ' Отменить удаление профиля невозможно.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: w400,
                            color: gray100,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          color: blue,
                          onPressed: () {
                            Navigator.pop(context);
                            dropAccount();
                          },
                          child: Text(
                            'Удалить',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: w500,
                              color: white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          color: surfacePrimary,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Отмена',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: w500,
                              color: black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Text(
                'Удалить профиль',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: w500,
                  color: white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileItemWidget extends StatelessWidget {
  const ProfileItemWidget({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.show = true,
  });
  final bool show;
  final String text;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      splashColor: Theme.of(context).colorScheme.primaryContainer,
      onTap: onTap,
      title: Row(
        children: [
          SvgPicture.asset("assets/icons/$icon.svg"),
          const SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: black,
            ),
          ),
          const Spacer(),
          if (show) SvgPicture.asset(AssetLib.smallArrow),
        ],
      ),
    );
  }
}
