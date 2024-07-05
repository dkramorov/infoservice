import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app_asset_lib.dart';
import '../../../../static_values.dart';
import '../../../../generic_appbar.dart';
import '../../../../../widgets/text_field_custom.dart';
import '../../../../themes.dart';
import '../../../../../widgets/button.dart';
import '../../auth/utils/auth_validators.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  TextEditingController name = TextEditingController();
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
                child: SvgPicture.asset(AssetLib.largeUsers),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "Создание группы",
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
                  "Придумайте интересное название для вашей группы",
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
                labelText: "Название группы",
                controller: name,
                validator: validateName,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: _addGroup,
                color: blue,
                child: Center(
                  child: Text(
                    "Создать",
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

  void _addGroup() {
    formKey.currentState!.save();
    if (formKey.currentState!.validate()) {
      // TODO implement add group
      Navigator.of(context).pop();
    }
  }
}
