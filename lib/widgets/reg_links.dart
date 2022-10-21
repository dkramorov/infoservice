import 'package:flutter/material.dart';

import '../../settings.dart';
import '../pages/register/reg_wizard_screen.dart';
import '../services/jabber_manager.dart';
import '../services/sip_ua_manager.dart';


class RegLinksWidget extends StatelessWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  const RegLinksWidget(this._sipHelper, this._xmppHelper, {Key? key}) : super(key: key);

  void regProcess(BuildContext context, String type) {
    Future.delayed(Duration.zero, () async {
      final result = await Navigator.of(context).pushNamed(RegWizardScreenWidget.id, arguments: [
        _sipHelper,
        _xmppHelper
      ]);
      if (result == 1) {
        //UserChatModel user = await logic.userFromDb();
        //Log.d(TAG, 'authorization with ${user.login}, ${user.passwd}');
        //if (user != null) {
        //  logic.authorization(user.login, user.passwd);
        //}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sgnNoAccTextStyle = Theme.of(context).textTheme.subtitle2;
    return Container(
      margin: PAD_SYM_V20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Не зарегистрированы?',
            style: sgnNoAccTextStyle,
          ),
          GestureDetector(
            onTap: () {
              // Переход на регистрацию/восставновление пароля
              regProcess(context, 'reg');
            },
            child: Text(
              'Регистрация',
              style: sgnNoAccTextStyle?.copyWith(
                fontWeight: FontWeight.bold,
                color: tealColor,
              ),
            ),
          ),
          SIZED_BOX_H30,
          GestureDetector(
            onTap: () {
              // Переход на регистрацию/восстановление пароля
              regProcess(context, 'restore_passwd');
            },
            child: Text(
              'Не помню пароль',
              style: sgnNoAccTextStyle?.copyWith(
                fontWeight: FontWeight.bold,
                color: tealColor,
              ),
            ),
          ),
          SIZED_BOX_H30,
        ],
      ),
    );
  }
}
