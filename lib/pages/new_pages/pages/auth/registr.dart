import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infoservice/pages/new_pages/pages/auth/utils/auth_validators.dart';

import '../../../app_asset_lib.dart';
import '../../../static_values.dart';
import '../../../back_button_custom.dart';
import '../../../../widgets/password_eye_widget.dart';
import '../../../../widgets/text_field_custom.dart';
import '../../../gl.dart';
import '../../../themes.dart';

import 'package:package_info_plus/package_info_plus.dart';

import '../../widgets/alert.dart';
import '../../../../widgets/button.dart';
import '../../../../widgets/switcher.dart';
import '../profil/model/profile_item_model.dart';
import 'code.dart';
import 'generic_info_page.dart';

class RegistrPage extends StatefulWidget {
  const RegistrPage({super.key});

  @override
  State<RegistrPage> createState() => _RegistrPageState();
}

class _RegistrPageState extends State<RegistrPage> {
  bool _value1 = false;

  TextEditingController name = TextEditingController(),
      phone = TextEditingController(),
      email = TextEditingController(),
      pass = TextEditingController();

  bool loading = false;
  final formKey = GlobalKey<FormState>();

  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarButtonCustom(asset: AssetLib.closeButton),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: UIs.signupPagePadding),
          child: ListView(
            children: [
              const SizedBox(height: 32),
              SizedBox(
                width: 64,
                height: 64,
                child: Image.asset(AssetLib.logo),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "Регистрация",
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
                  "Зарегистрируйтесь, чтобы начать звонить и общаться",
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
                labelText: "Ваше имя",
                controller: name,
                keyboardType: TextInputType.name,
                validator: validateName,
              ),
              const SizedBox(height: 16),
              TextFieldCustom(
                labelText: "Телефон",
                controller: phone,
                keyboardType: TextInputType.phone,
                validator: validatePhone,
              ),
              const SizedBox(height: 16),
              TextFieldCustom(
                labelText: "E-mail",
                controller: email,
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 16),
              TextFieldCustom(
                labelText: "Пароль",
                controller: pass,
                keyboardType: TextInputType.text,
                obscureText: hidePassword,
                validator: validatePassword,
                suffix: PasswordEyeWidget(
                  hidePassword,
                  onPressed: () => setState(() => hidePassword = !hidePassword),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: w400,
                          color: black,
                        ),
                        children: [
                          const TextSpan(text: "Я соглашаюсь "),
                          TextSpan(
                            text: "с политикой конфиденциальности",
                            style: TextStyle(color: blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) {
                                      final page = profileItemsGuest.firstWhere(
                                          (e) => e.title.contains('Политика'));
                                      return InfoPage(
                                        title: page.title,
                                        description: page.description,
                                      );
                                    },
                                  ),
                                );
                              },
                          ),
                          const TextSpan(text: " и "),
                          TextSpan(
                            text: "условием предоставления услуг",
                            style: TextStyle(color: blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) {
                                      final page = profileItemsGuest.firstWhere(
                                          (e) => e.title.contains('Условия'));
                                      return InfoPage(
                                        title: page.title,
                                        description: page.description,
                                      );
                                    },
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomSwitch(
                    onChange: (c) {
                      _value1 = !_value1;
                      setState(() {});
                    },
                    value: _value1,
                  )
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: () {
                  formKey.currentState!.save();
                  if (formKey.currentState!.validate()) {
                    registrUser(phone.text, name.text, pass.text).then((value) {
                      print(value.statusCode);
                      if (value.statusCode == 200) {
                        print(value.data);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => CodePage(
                              name: name.text,
                              phone: phone.text,
                              email: email.text,
                              pass: pass.text,
                            ),
                          ),
                        );
                      } else if (value.statusCode == 429) {
                        /*
                        showOverlayNotification((context) {
                          return ErrorAlert(
                            text:
                                "Слишком много попыток, повторите регистрацию через полчаса",
                            color: error100,
                          );
                        });
                        print("object");
                        */
                      }
                    });
                  }
                },
                color: blue,
                child: Text(
                  "Зарегистрироваться",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: w500,
                    color: white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> registrUser(
    String login,
    String name,
    String passwd,
  ) async {
    try {
      final appInfo = await PackageInfo.fromPlatform();
      final response =
          await dio.get("/jabber/register_user/", queryParameters: {
        'action': 'registration',
        'phone': login,
        'name': name,
        'passwd': passwd,
        'platform': Platform.operatingSystem,
        'version': '${appInfo.version} : ${appInfo.buildNumber}',
        'simple_reg': '1',
      });

      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }
}
