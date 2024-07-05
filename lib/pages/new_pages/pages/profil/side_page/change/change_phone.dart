import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

import '../../../../../static_values.dart';
import '../../../../../generic_appbar.dart';
import '../../../../../../widgets/text_field_custom.dart';
import '../../../../../themes.dart';
import '../../../../../../widgets/button.dart';
import '../../../auth/utils/auth_validators.dart';
import '../../../auth/utils/cleanup_phone.dart';


class ChPhone extends StatefulWidget {
  const ChPhone({super.key});

  @override
  State<ChPhone> createState() => _ChPhoneState();
}

class _ChPhoneState extends State<ChPhone> {
  TextEditingController phone =
      MaskedTextController(mask: '+0 (000) 000-00-00');
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GenericAppBar(hasBackButton: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UIs.signupPagePadding),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const SizedBox(height: 88),
              Center(
                child: Text(
                  "Укажите новый телефон",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: w500,
                    color: black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Вам поступит звонок и будет продиктован код подтверждения",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: w400,
                  color: gray100,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFieldCustom(
                labelText: "Номер телефона",
                validator: (value) => validatePhone(cleanUpPhone(value)),
                controller: phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: _setNewPhone,
                color: blue,
                child: Text(
                  "Получить код",
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

  void _setNewPhone() {
    formKey.currentState!.save();
    if (formKey.currentState!.validate()) {
      // TODO: implement set new phone
      Navigator.of(context).pop();
    }
  }
}
