import 'package:flutter/material.dart';

import '../../../../../static_values.dart';
import '../../../../../../navigation/generic_appbar.dart';
import '../../../../../../widgets/text_field_custom.dart';
import '../../../../../themes.dart';
import '../../../../../../widgets/button.dart';
import '../../../auth/utils/auth_validators.dart';

class ChEmail extends StatefulWidget {
  const ChEmail({super.key});

  @override
  State<ChEmail> createState() => _ChEmailState();
}

class _ChEmailState extends State<ChEmail> {
  TextEditingController email = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(hasBackButton: true),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UIs.signupPagePadding),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const SizedBox(height: 88),
              Center(
                child: Text(
                  "Укажите новый e-mail",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: w500,
                    color: black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Для смены отправим письмо на вашу почту example@gmail.com",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: w400,
                  color: gray100,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFieldCustom(
                labelText: "E-mail",
                controller: email,
                validator: validateEmail,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: _setNewEmail,
                color: blue,
                child: Text(
                  "Отправить письмо",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: w500,
                    color: white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _setNewEmail() {
    formKey.currentState!.save();
    if (formKey.currentState!.validate()) {
      // TODO: implement set new email
      Navigator.of(context).pop();
    }
  }
}
