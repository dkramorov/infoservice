import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infoservice/pages/profile/personal_data_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app_asset_lib.dart';
import '../../../static_values.dart';
import '../../../generic_appbar.dart';
import '../../../../widgets/text_field_custom.dart';
import '../../../gl.dart';
import '../../../themes.dart';
import '../../../../widgets/button.dart';
import '../../../../widgets/modal.dart';
import 'side_page/change/change_email.dart';
import 'side_page/change/change_phone.dart';
import 'package:intl/intl.dart';

class PersonalData extends StatefulWidget {
  const PersonalData({super.key});

  @override
  State<PersonalData> createState() => _PersonalDataState();
}

class _PersonalDataState extends State<PersonalData> {
  TextEditingController userName = TextEditingController();
  late String pol;
  DateFormat inputFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    userName.text = name ?? '';
    if (date != null) {
      d = inputFormat.parse(date!);
    } else {
      d = DateTime.now();
    }
    pol = sex ?? 'Мужской';
  }

  DateTime d = DateTime.now();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: const GenericAppBar(hasBackButton: true, title: 'Личные данные'),
      body: Padding(
        padding: const EdgeInsets.all(UIs.defaultPagePadding),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            TextFieldCustom(
              labelText: 'Ваше имя',
              controller: userName,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            /*
            PersonalDataField(
              title: 'E-mail',
              value: email ?? 'Не указан',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => const ChEmail(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            PersonalDataField(
              title: 'Телефон',
              value: formatPhoneNumber(myPhone!),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => const ChPhone(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            */
            PersonalDataField(
              title: 'Дата рождения',
              value: '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}',
              onPressed: () => _showDialog(
                CupertinoDatePicker(
                  initialDateTime: d,
                  mode: CupertinoDatePickerMode.date,
                  use24hFormat: true,
                  // This shows day of week alongside day of month
                  showDayOfWeek: true,
                  // This is called when the user changes the date.
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() => d = newDate);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            PersonalDataField(
              title: 'Ваш пол',
              value: pol,
              onPressed: () => _selectGender(size),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              color: blue,
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('name', userName.text);
                prefs.setString('date',
                    "${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}");
                prefs.setString('sex', pol).then((value) {
                  Navigator.pop(context);
                });
              },
              child: Text(
                'Сохранить',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: w500,
                  color: white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showDialog(Widget child) {
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

  String formatPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'\D+'), '');

    if (cleaned.length < 11) {
      return "";
    }

    // Форматирование номера
    return cleaned
        .replaceFirstMapped(RegExp(r'^8'), (match) => '+7')
        .replaceFirstMapped(RegExp(r'^\+?7'), (match) => '8')
        .replaceFirstMapped(
            RegExp(r'(\d{1})(\d{3})(\d{3})(\d{2})(\d{2})'),
            (match) =>
                '${match[1]} ${match[2]} ${match[3]} ${match[4]} ${match[5]}');
  }

  void _selectGender(Size size) {
    showModal(
      context,
      size.height * 0.2,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                pol = 'Мужской';
                sex = pol;
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
                    if (pol == 'Мужской') SvgPicture.asset(AssetLib.check)
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                pol = 'Женский';
                sex = pol;
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
                    if (pol != 'Мужской') SvgPicture.asset(AssetLib.check)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
