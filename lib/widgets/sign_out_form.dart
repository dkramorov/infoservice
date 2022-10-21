import 'package:flutter/material.dart';
import 'package:infoservice/widgets/submit_button.dart';

import '../../helpers/phone_mask.dart';
import '../../settings.dart';

class SignOutFormWidget extends StatelessWidget {
  final String? login;
  final VoidCallback stopHelpers;
  const SignOutFormWidget(this.login, this.stopHelpers, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 10,
            bottom: 20,
          ),
          child: Text(
            login != null && login != ''
                ? 'Вы авторизованы:\n${phoneMaskHelper(login!)}'
                : 'Вы не авторизованы',
            style: const TextStyle(
              fontSize: 20.0,
              color: tealColor,
            ),
          ),
        ),
        Center(
          child: SubmitButton(
            text: 'Вход',
            onPressed: () {
              Navigator.popUntil(context, (route) => (route.isFirst));
            },
          ),
        ),
        SIZED_BOX_H12,
        Center(
          child: SubmitButton(
            text: 'Выход',
            onPressed: stopHelpers,
          ),
        ),
      ],
    );
  }
}
