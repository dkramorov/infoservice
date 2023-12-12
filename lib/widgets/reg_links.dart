import 'package:flutter/material.dart';
import 'package:infoservice/widgets/terms_widget.dart';

import '../../settings.dart';
import '../pages/register/reg_wizard_screen.dart';
import '../services/jabber_manager.dart';
import '../services/sip_ua_manager.dart';

class RegLinksWidget extends StatelessWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  const RegLinksWidget(this._sipHelper, this._xmppHelper, {Key? key})
      : super(key: key);

  void regProcess(BuildContext context, String type) {
    Future.delayed(Duration.zero, () async {
      final result = await Navigator.of(context).pushNamed(
          RegWizardScreenWidget.id,
          arguments: [_sipHelper, _xmppHelper]);
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
  }
}
