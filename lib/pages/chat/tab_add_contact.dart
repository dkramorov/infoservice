import 'package:flutter/material.dart';

import '../../helpers/log.dart';
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
  static const TAG = 'TabAddContact';
  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;

  String newUser = '8';

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  /* Отправка формы добавление контакта */
  void addUserFormSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState?.save();

    String phone = cleanPhone(newUser);
    JabberManager.flutterXmpp?.searchUsers(phone).then((List<dynamic> users) {
      List<String> result = [];
      bool founded = false;
      for (String user in users) {
        String curUser = cleanPhone(user);
        result.add(curUser);
        if (curUser == phone) {
          founded = true;
        }
      }
      Log.d(TAG, 'founded by $phone: $result');
      if (founded) {
        xmppHelper?.add2Roster(newUser);
        Navigator.pop(context);
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
                    formatters: [PhoneFormatter()],
                    validator: (String? value) {
                      String v = value ?? '';
                      bool match = phoneMaskValidator().hasMatch(v);
                      if (v.isEmpty || !match) {
                        return 'Телефон нового контакта';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
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
                    onPressed: () {
                      addUserFormSubmit();
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
