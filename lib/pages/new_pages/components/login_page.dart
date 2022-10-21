
import 'package:flutter/material.dart';

import 'new_main.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.only(left: 30, right: 30),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/main.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
                Spacer(),
                Row(
                  children: const [
                    Text(
                      'ДОБРО',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const Text(
                  'ПОЖАЛОВАТЬ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700),
                ),
                Row(
                  children: [
                    const Text(
                      'БЕЗОПАСНЫЕ ЗВОНКИ',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 50,),
                    Image.asset(
                      'assets/images/help.png',
                      width: 83,
                      height: 79,
                    )
                  ],
                ),
                SizedBox(
                  height: 50,
                ),

                textFormField('Номер телефона'),
                const SizedBox(height: 20),
                textFormField('Пароль'),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Еще нет аккаунта? зарегистрироваться',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, NewMainPage.id);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: const Text('Войти',
                        style: TextStyle(
                            color: Color(0xFF9ACFDC),
                            fontSize: 24,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                    child: Text(
                  'Забыли пароль? восстановить ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                )),
                SizedBox(
                  height: 50,
                ),
                const Center(
                  child: Text(
                    '© 2021-2022 все права защищены.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  textFormField(String text) {
    return Container(
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF167B98).withOpacity(0.05),
            Color(0xFF167B98).withOpacity(0.05)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.4],
          tileMode: TileMode.clamp,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF167B98).withOpacity(0.25),
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.transparent, width: 5),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            hintText: text),
      ),
    );
  }
}
