import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9ACFDC),
        title: const Text('АУТЕНФИКАЦИЯ'),
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
                    const SizedBox(height: 10),
                    Text(
                      'Вы ввели +7 (0000) 00-00-00, в течение 2 минут на этот номер прийдет код проверки',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Color(0xFFD2D2D2),
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 25),
                    textFormField('XXXX'),
                    const SizedBox(height: 25),
                    Text(
                      'Не тот номер телефона? вернуться назад',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Color(0xFFD2D2D2),
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
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
            suffixIcon: Container(
              width: 70,
              height: 20,
              margin: EdgeInsets.only(right: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Color(0xFF10B3D6),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                '00:06',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
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
