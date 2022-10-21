import 'package:flutter/material.dart';

class ForgetPassWord extends StatefulWidget {
  const ForgetPassWord({Key? key}) : super(key: key);

  @override
  State<ForgetPassWord> createState() => _ForgetPassWordState();
}

class _ForgetPassWordState extends State<ForgetPassWord> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9ACFDC),
        title: const Text('ЗАБЫТЫЙ ПАРОЛЬ'),
        automaticallyImplyLeading: true,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
            onTap: () {
              // print('sdsad');
              // Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Забыли пароль?',
                      style: TextStyle(
                          color: Color(0xFF313743),
                          fontSize: 24,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Для того, чтобы восстановить пароль введите номер телефона, который указывали при регистрации',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Color(0xFFD2D2D2),
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 25),
                    textFormField('+7 (0000) 00-00-00'),
                    const SizedBox(height: 25),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Color(0xFF12CBC4),
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(colors: <Color>[
                              Color(0xFF167B98),
                              Color(0xFF12CBC4),
                              Color(0xFF10B3D6),
                            ])),
                        alignment: Alignment.center,
                        child: Text(
                          'Отправить',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ))
                  ],
                ),
              )
            ],
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
            const Color(0xFF3C3C3C).withOpacity(0.25),
            const Color(0xFFFFFFFF).withOpacity(0.1)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.4],
          tileMode: TileMode.clamp,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7F7F7),
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            hintText: text),
      ),
    );
  }
}
