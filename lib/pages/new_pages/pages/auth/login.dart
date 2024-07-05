import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:infoservice/pages/new_pages/pages/auth/registr.dart';
import 'package:infoservice/pages/new_pages/pages/auth/utils/auth_validators.dart';
import 'package:infoservice/pages/new_pages/pages/auth/utils/cleanup_phone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xmpp_plugin/ennums/xmpp_connection_state.dart';

import '../../../../helpers/network.dart';
import '../../../app_asset_lib.dart';
import '../../../static_values.dart';
import '../../../back_button_custom.dart';
import '../../../../widgets/password_eye_widget.dart';
import '../../../../widgets/text_field_custom.dart';
import '../../../gl.dart';
import '../../../themes.dart';
import '../../../../widgets/button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    // mainListener.status.addListener(() {
    //   if (mainListener.status.value == XmppConnectionState.authenticated) {
    //     Navigator.pop(context);
    //   } else {
    //     print("error");
    //   }
    // });
    if (mounted) setState(() {});
  }

  int log = -1;

  bool pass = false;

  final phone = MaskedTextController(mask: '+0 (000) 000-00-00');
  final password = TextEditingController();

  bool loading = false;
  final formKey = GlobalKey<FormState>();

  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                  // pass ?
                  "Войти по паролю",
                  // : "Вход или регистрация",
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
                  "Войдите или зарегистрируйтесь, чтобы начать звонить и общаться",
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
                keyboardType: TextInputType.phone,
                validator: (value) => validatePhone(cleanUpPhone(value)),
              ),
              // if (pass)
              ...[
                const SizedBox(height: 16),
                TextFieldCustom(
                  labelText: "Пароль",
                  controller: password,
                  keyboardType: TextInputType.text,
                  validator: validatePassword,
                  obscureText: hidePassword,
                  suffix: PasswordEyeWidget(
                    hidePassword,
                    onPressed: () =>
                        setState(() => hidePassword = !hidePassword),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                child: PrimaryButton(
                  loading: loading,
                  onPressed: () async {
                    formKey.currentState!.save();
                    if (formKey.currentState!.validate()) {
                      setState(() => loading = true);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final phoneCleanedUp = cleanUpPhone(phone.text);

                      /*
                      mainListener
                          .connect(phoneCleanedUp, password.text)
                          .then((value) {
                        prefs.setString('phone', phoneCleanedUp);
                        prefs.setString('password', password.text);
                        Future.delayed(const Duration(milliseconds: 200))
                            .then((value) {
                          setState(() => loading = false);
                          if (mainListener.status.value ==
                              XmppConnectionState.authenticated) {
                            log++;
                            if (log == 0) {
                              myPhone = phoneCleanedUp;
                              thPage.value = 0;
                              if (mounted) setState(() {});
                              Navigator.pop(context);
                              startTimer(phoneCleanedUp, password.text);
                              sendToken(phoneCleanedUp, FB_TOKEN);
                            }
                            print(log);
                          } else {
                            print(mainListener.status.value);
                          }
                        });
                      });
                      */
                    }
                  },
                  color: blue,
                  child: Text(
                    // pass ?
                    "Войти",
                    // : "Получить код",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: w500,
                      color: white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // if (pass)
              //   GestureDetector(
              //     onTap: () {},
              //     child: Text(
              //       "Не помню пароль",
              //       style: TextStyle(
              //         fontSize: 14,
              //         fontWeight: w500,
              //         color: blue,
              //       ),
              //     ),
              //   )
              // else
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const RegistrPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Зарегистрироваться",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: w500,
                        color: blue,
                      ),
                    ),
                  ),
                  // const SizedBox(height: 10),
                  // GestureDetector(
                  //   onTap: () {
                  //     setState(() {
                  //       pass = true;
                  //     });
                  //   },
                  //   child: Text(
                  //     "Войти по паролю",
                  //     style: TextStyle(
                  //       fontSize: 14,
                  //       fontWeight: w500,
                  //       color: blue,
                  //     ),
                  //   ),
                  // ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void startTimer(String ph, String ps) {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      //mainListener.connect(ph, ps);
    });
  }
}
