import 'package:flutter/material.dart';

import '../../helpers/log.dart';
import '../../helpers/phone_mask.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../widgets/rounded_button_widget.dart';
import '../../widgets/rounded_input_text.dart';

class Add2RosterScreen extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  const Add2RosterScreen(this._sipHelper, this._xmppHelper, {Key? key}) : super(key: key);
  static const String id = '/add2roster_screen/';

  @override
  _Add2RosterScreenState createState() => _Add2RosterScreenState();
}

class _Add2RosterScreenState extends State<Add2RosterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static const TAG = 'Add2RosterScreen';
  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  String newUser = '8';

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  /* Отправка формы авторизации */
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Пользователь $newUser не найден'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить контакт'),
        backgroundColor: tealColor,
      ),
      body: Center(
          child: SingleChildScrollView(
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
          ),
        ),
    );
  }
}
