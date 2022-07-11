import 'dart:async';
import 'package:flutter/material.dart';
import 'package:infoservice/widgets/rounded_input_text.dart';
import 'package:infoservice/widgets/submit_button.dart';

import '../../helpers/phone_mask.dart';
import '../services/jabber_manager.dart';
import '../services/sip_ua_manager.dart';


class SignInFormWidget extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  const SignInFormWidget(this._sipHelper, this._xmppHelper, {Key? key}) : super(key: key);

  @override
  _SignInFormWidgetState createState() => _SignInFormWidgetState();
}

class _SignInFormWidgetState extends State<SignInFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwdController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    loginController.dispose();
    passwdController.dispose();
    super.dispose();
  }

  /* Отправка формы авторизации */
  Future<void> loginFormSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Map<String, dynamic> userData = {
      'phone': loginController.text,
      'passwd': passwdController.text,
      'name': loginController.text,
    };
    xmppHelper?.changeSettings(userData);
    sipHelper?.changeSettings(userData);
  }

  @override
  Widget build(BuildContext context) {
    final titleTextStyle = Theme.of(context).textTheme.subtitle1;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Логин (телефон)
          Text(
            'Ваш телефон',
            style: titleTextStyle,
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(
              top: 10,
              bottom: 20,
            ),
            child: RoundedInputText(
              hint: 'Ваш телефон',
              controller: loginController,
              formatters: [PhoneFormatter()],
              validator: (String? value) {
                if (value?.isEmpty ?? true) {
                  return 'Например, 89148223223';
                }
                bool match = phoneMaskValidator().hasMatch(value ?? '');
                if (!match) {
                  return '11 цифр, например, 89148223223';
                }
              },
              keyboardType: TextInputType.number,
            ),
          ),
          Text(
            'Ваш пароль',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 10, bottom: 30),
            child: RoundedInputText(
              hint: 'Ваш пароль',
              controller: passwdController,
              validator: (String? value) {
                if (value?.isEmpty ?? true) {
                  return 'Ваш пароль';
                }
                return null;
              },
            ),
          ),
          Center(
            child: SubmitButton(
              text: 'Вход',
              onPressed: () {
                loginFormSubmit();
              },
            ),
          ),
        ],
      ),
    );
  }
}
