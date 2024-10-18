import 'package:flutter/material.dart';

import '../../../../../static_values.dart';
import '../../../../../../navigation/generic_appbar.dart';
import '../../../../../../widgets/password_eye_widget.dart';
import '../../../../../../widgets/text_field_custom.dart';
import '../../../../../themes.dart';
import '../../../../../../widgets/button.dart';
import '../../../auth/utils/auth_validators.dart';

class ChPassData extends StatefulWidget {
  const ChPassData({super.key});

  @override
  State<ChPassData> createState() => _ChPassDataState();
}

class _ChPassDataState extends State<ChPassData> {
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final repeatPassword = TextEditingController();

  bool hidePassword = true;

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
              const SizedBox(height: 96),
              Center(
                child: Text(
                  "Изменить пароль",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: w500,
                    color: black,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFieldCustom(
                labelText: "Старый пароль",
                controller: oldPassword,
                obscureText: hidePassword,
                validator: validatePassword,
                keyboardType: TextInputType.text,
                suffix: PasswordEyeWidget(
                  hidePassword,
                  onPressed: _changeHidePassword,
                ),
              ),
              const SizedBox(height: 16),
              TextFieldCustom(
                labelText: "Новый пароль",
                controller: newPassword,
                obscureText: hidePassword,
                validator: validatePassword,
                keyboardType: TextInputType.text,
                suffix: PasswordEyeWidget(
                  hidePassword,
                  onPressed: _changeHidePassword,
                ),
              ),
              const SizedBox(height: 16),
              TextFieldCustom(
                labelText: "Повторите новый пароль",
                controller: repeatPassword,
                obscureText: hidePassword,
                validator: validatePassword,
                keyboardType: TextInputType.text,
                suffix: PasswordEyeWidget(
                  hidePassword,
                  onPressed: _changeHidePassword,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: _setNewPassword,
                color: blue,
                child: Text(
                  "Сохранить",
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

  void _changeHidePassword() => setState(() => hidePassword = !hidePassword);
  void _setNewPassword() {
    formKey.currentState!.save();
    if (formKey.currentState!.validate()) {
      // TODO: implement set new password
      Navigator.of(context).pop();
    }
  }
}
