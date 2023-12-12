import 'package:flutter/material.dart';

import '../settings.dart';
import 'dialog_md.dart';

class TermsWidget extends StatelessWidget {
  const TermsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SIZED_BOX_H20,
        SIZED_BOX_H20,
        GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return DialogMDWidget(
                      mdFileName: 'privacy_policy.md');
                });
          },
          child: const Text(
            'Политика конфиденциальности',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: tealColor,
            ),
          ),
        ),
        SIZED_BOX_H20,
        GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return DialogMDWidget(mdFileName: 'terms_and_conditions.md');
                });
          },
          child: const Text(
            'Условия предоставления услуг',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: tealColor,
            ),
          ),
        ),
        SIZED_BOX_H20,
        SIZED_BOX_H20,
      ],
    );
  }
}
