import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:infoservice/widgets/pin_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../../../../navigation/custom_app_bar_button.dart';
import '../../../gl.dart';
import '../../../themes.dart';
import '../../widgets/alert.dart';
import '../../../../widgets/button.dart';
import '../index.dart';

class CodePage extends StatefulWidget {
  const CodePage({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.pass,
  });
  final String name, phone, email, pass;
  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  @override
  void initState() {
    super.initState();
    _startCountdown();
    if (mounted) setState(() {});
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isCountdownComplete = true;
          });
        }
      }
    });
  }

  int _secondsRemaining = 60;
  bool _isCountdownComplete = false;
  @override
  Widget build(BuildContext context) {
    String minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    String seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Container(
        color: white,
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 54),
              Container(
                width: size.width - 32,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomAppBarButton(),
                  ],
                ),
              ),
              const SizedBox(height: 98),
              Text(
                "Проверочный код",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: w500,
                  color: black,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: size.width * 0.8,
                child: Text(
                  "Введите код продиктованный нашим роботом помошником",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: w400,
                    color: gray100,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PinCodeTextField(
                    pinTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: w400,
                      color: black,
                    ),
                    onDone: (text) {
                      confirmRegistration(widget.phone, text)
                          .then((value) async {
                        print(value.data);
                        if (value.statusCode == 200) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          name = widget.name;
                          myPhone = widget.phone;
                          email = widget.phone;
                          pass = widget.pass;
                          if (mounted) setState(() {});
                          prefs.setString('name', widget.name);
                          prefs.setString('phone', widget.phone);
                          prefs.setString('email', widget.email);
                          prefs
                              .setString('password', widget.pass)
                              .then((value) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (c) => const Index(
                                  null, null, null,
                                ),
                              ),
                            );
                          });
                        } else if (value.statusCode == 429) {
                          /*
                          showOverlayNotification((context) {
                            return ErrorAlert(
                              text:
                                  "Слишком много попыток, повторите регистрацию через полчаса",
                              color: error100,
                            );
                          });
                          */
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: size.width - 60,
                child: PrimaryButton(
                  onPressed: _isCountdownComplete
                      ? () {
                          _secondsRemaining = 60;
                          _isCountdownComplete = false;
                          _startCountdown();
                          setState(() {});
                        }
                      : () {},
                  color: _isCountdownComplete ? blue : surfacePrimary,
                  child: Text(
                    _isCountdownComplete
                        ? "Получить новый код"
                        : "Получить новый код через $minutes:$seconds",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: w500,
                      color: _isCountdownComplete
                          ? white
                          : const Color.fromRGBO(192, 193, 195, 1),
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

  Future<dynamic> confirmRegistration(
    String phone,
    String code,
  ) async {
    try {
      final response =
          await dio.get("/jabber/register_user/", queryParameters: {
        'action': 'confirm',
        'phone': phone,
        'code': code,
      });

      return response;
    } on DioException catch (e) {
      return e.response;
    }
  }
}
