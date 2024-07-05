import 'package:flutter/material.dart';

import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../back_button_custom.dart';
import '../themes.dart';

class AboutPage extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  final Object? _arguments;
  const AboutPage(this._sipHelper, this._xmppHelper, this._arguments,
      {Key? key})
      : super(key: key);
  static const String id = '/about_us';

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: surfacePrimary,
        surfaceTintColor: surfacePrimary,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppBarButtonCustom(),
            Text(
              "О приложении",
              style: TextStyle(
                fontSize: 18,
                fontWeight: w500,
                color: black,
              ),
            ),
            const SizedBox(width: 24)
          ],
        ),
      ),
      body: Container(
        color: surfacePrimary,
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Приложение 8800: Ваш универсальный инструмент связи с компаниями в любой точке мира",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: w500,
                  color: black,
                ),
                // textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "В наше время мобильные приложения становятся неотъемлемой частью нашей повседневной жизни, обеспечивая нам доступ к широкому спектру услуг и возможностей. Одним из таких инновационных приложений является 8800, представляющее собой универсальный инструмент связи с компаниями, где бы вы ни находились.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: w400,
                  color: black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Чат и звонки из любой точки мира",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: w500,
                  color: black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "С помощью приложения 8800 пользователи могут связаться с различными компаниями в любой точке мира, обмениваться сообщениями или даже совершать голосовые и видеозвонки. Для использования этой возможности вам нужен лишь доступ в интернет, что делает приложение идеальным спутником для путешественников и тех, кто часто взаимодействует с компаниями за границей.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: w400,
                  color: black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Многофункциональность и удобство",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: w500,
                  color: black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Приложение 8800 обеспечивает связь не только с банками, но и со страховыми компаниями, авиакомпаниями и многими другими сервисными организациями. Благодаря этому пользователи могут получать оперативную помощь и консультации по различным вопросам, будь то финансовые операции, бронирование билетов или решение проблем, связанных с страхованием.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: w400,
                  color: black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Бесплатная и доступная связь",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: w500,
                  color: black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Одним из ключевых преимуществ приложения 8800 является его бесплатность. Пользователи могут общаться с компаниями из-за границы без каких-либо дополнительных затрат, что делает сервис доступным и привлекательным для широкой аудитории.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: w400,
                  color: black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Поддержка и улучшение сервиса",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: w500,
                  color: black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Команда разработчиков активно работает над расширением сети компаний, доступных для связи через приложение 8800. В настоящее время внедрение функционала чатов с компаниями находится в стадии активного развития, что позволит пользователям не только звонить, но и отправлять сообщения для получения помощи и консультаций.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: w400,
                  color: black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Подведение итогов",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: w500,
                  color: black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Приложение 8800 стало незаменимым инструментом для многих тысяч пользователей, предоставляя им удобный и бесплатный способ связи с компаниями из разных уголков мира. Благодаря его многофункциональности и доступности оно обеспечивает оперативное решение различных вопросов и ситуаций, с которыми сталкиваются люди в повседневной жизни.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: w400,
                  color: black,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
