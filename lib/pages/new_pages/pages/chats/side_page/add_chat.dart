import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

import '../../../../app_asset_lib.dart';
import '../../../../static_values.dart';
import '../../../../generic_appbar.dart';
import '../../../../../widgets/text_field_custom.dart';
import '../../../../themes.dart';
import '../../../../../widgets/button.dart';
import '../../auth/utils/auth_validators.dart';
import '../../auth/utils/cleanup_phone.dart';

class AddChatsPage extends StatefulWidget {
  const AddChatsPage({super.key});

  @override
  State<AddChatsPage> createState() => _AddChatsPageState();
}

class _AddChatsPageState extends State<AddChatsPage> {
  TextEditingController phone =
      MaskedTextController(mask: "+0 (000) 000-00-00");

  int selectGroup = 0;

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
              const SizedBox(height: 64),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26.5,
                  vertical: 26,
                ),
                decoration: BoxDecoration(
                  color: surfacePrimary,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(AssetLib.userCirclePlus),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "Добавление контакта",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: w500,
                    color: black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                child: Text(
                  "Введите номер человека, которого хотите добавить",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: w400,
                    color: gray100,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFieldCustom(
                labelText: "Номер телефона",
                controller: phone,
                keyboardType: TextInputType.number,
                validator: (value) => validatePhone(cleanUpPhone(value)),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: _addNew,
                color: blue,
                child: Center(
                  child: Text(
                    "Добавить",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: w500,
                      color: white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _addNew() {
    formKey.currentState!.save();
    if (formKey.currentState!.validate()) {
      print(phone.text);
      //mainListener.addChat(cleanUpPhone(phone.text));
      Navigator.of(context).pop();
    }
  }
}
