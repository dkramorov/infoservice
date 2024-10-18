import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infoservice/helpers/dialogs.dart';
import 'package:infoservice/models/bg_tasks_model.dart';
import 'package:infoservice/services/shared_preferences_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/phone_mask.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../widgets/rounded_button_widget.dart';
import '../../widgets/rounded_input_text.dart';

class TabAddContact extends StatefulWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Function setStateCallback;
  final PageController pageController;

  const TabAddContact(
      {this.sipHelper,
      this.xmppHelper,
      required this.pageController,
      required this.setStateCallback,
      Key? key})
      : super(key: key);

  @override
  State<TabAddContact> createState() => _TabAddContactState();
}

class _TabAddContactState extends State<TabAddContact> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static const tag = 'TabAddContact';
  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;
  late Timer updateTimer;

  String newUser = '';

  @override
  void dispose() {
    updateTimer.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      updateTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
        await checkNewUser();
      });
    });
  }

  Future<void> checkNewUser() async {
    SharedPreferences prefs = await SharedPreferencesManager.getSharedPreferences();
    bool? addUserResult = prefs.getBool(BGTasksModel.addRosterPrefKey);
    if (addUserResult != null) {
      if (addUserResult) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Пользователь $newUser добавлен'),
            ),
          );
        }
        Future.delayed(Duration.zero, () async {
          Navigator.pop(context);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Пользователь $newUser не найден'),
            ),
          );
        }
      }
      await prefs.remove(BGTasksModel.addRosterPrefKey);
    }
  }

  /* Отправка формы добавление контакта */
  Future<void> addUserFormSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState?.save();
    await showLoading();
    SharedPreferences prefs = await SharedPreferencesManager.getSharedPreferences();
    await prefs.remove(BGTasksModel.addRosterPrefKey);
    String phone = cleanPhone(newUser);
    BGTasksModel.addRosterTask({
      'login': phone,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 40.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 15.0,
            ),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Добавление нового контакта',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  RoundedInputText(
                    hint: 'Логин пользователя',
                    onChanged: (String? text) {
                      setState(() {
                        newUser = text ?? '';
                      });
                    },
                    /*
                          validator: (String value) {
                            bool match = RegExp(r'^[a-z0-9]+@[a-z0-9\.]+$')
                                .hasMatch(value);
                            if (value.isEmpty || !match) {
                              return 'Неправильный логин';
                            }
                          },
                    */
                    // ФОРМАТИРОВАНИЕ ПОКА УБИРАЕМ
                    //formatters: [PhoneFormatter()],
                    validator: (String? value) {
                      String v = value ?? '';
                      /* ВАЛИДАТОР ПОКА УБИРАЕМ
                      bool match = phoneMaskValidator().hasMatch(v);
                      if (v.isEmpty || !match) {
                        return 'Телефон нового контакта';
                      }
                      */
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    defaultValue: newUser,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  RoundedButtonWidget(
                    text: const Text(
                      'Добавить',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: tealColor,
                    onPressed: () async {
                      await addUserFormSubmit();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
