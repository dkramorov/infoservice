import 'package:flutter/material.dart';

import '../helpers/dialogs.dart';
import '../pages/auth/reg_wizard_screen.dart';
import '../pages/themes.dart';
import '../services/jabber_manager.dart';
import '../services/sip_ua_manager.dart';

class RegLinksWidget extends StatelessWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  const RegLinksWidget(this._sipHelper, this._xmppHelper, {Key? key})
      : super(key: key);

  void regProcess(BuildContext context, String type) {
    Future.delayed(Duration.zero, () async {
      Widget? result = await Navigator.of(context).pushNamed(
          RegWizardScreenWidget.id,
          arguments: [_sipHelper, _xmppHelper]);

      if (result != null && (result as Text).data == 'userConfirmed') {
        showLoading(removeAfterSec: 8);
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
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            regProcess(context, 'reg');
          },
          child: Text(
            'Зарегистрироваться',
            style: TextStyle(
              fontSize: 14,
              fontWeight: w500,
              color: blue,
            ),
          ),
        ),
      ],
    );
    /* /// Старый вариант
    return Column(
      children: [
        SIZED_BOX_H20,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                // Переход на регистрацию/восставновление пароля
                regProcess(context, 'reg');
              },
              child: const Text(
                'Регистрация',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: tealColor,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Переход на регистрацию/восстановление пароля
                regProcess(context, 'restore_passwd');
              },
              child: const Text(
                'Не помню пароль',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: tealColor,
                ),
              ),
            ),
          ],
        ),
        const TermsWidget(),
      ],
    );
    */
  }
}
