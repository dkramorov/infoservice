import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../pages/themes.dart';
import '../settings.dart';
import 'dialog_md.dart';

class TermsWidget extends StatelessWidget {
  const TermsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            fontWeight: w400,
            color: black,
          ),
          children: [
            const TextSpan(text: 'Я соглашаюсь '),
            TextSpan(
              text: "с политикой конфиденциальности",
              style: TextStyle(color: blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return DialogMDWidget(
                            mdFileName: 'privacy_policy.md');
                      });
                },
            ),
            const TextSpan(text: ' и '),
            TextSpan(
              text: 'условием предоставления услуг',
              style: TextStyle(color: blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return DialogMDWidget(mdFileName: 'terms_and_conditions.md');
                      });
                },
            ),
          ],
        ),
      ),
    );


    /* /// Старый вариант
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
    */
  }
}
