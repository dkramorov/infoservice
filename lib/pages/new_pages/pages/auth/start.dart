import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../services/jabber_manager.dart';
import '../../../../services/sip_ua_manager.dart';
import '../../../app_asset_lib.dart';
import '../../../themes.dart';
import '../../widgets/start_page/onboarding_picture.dart';
import '../../widgets/start_page/start_page_dot.dart';
import '../index.dart';

class StartOne extends StatefulWidget {

  static const String id = '/start_one/';
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  final Object? _arguments;
  const StartOne(this._sipHelper, this._xmppHelper, this._arguments,
      {Key? key})
      : super(key: key);

  @override
  State<StartOne> createState() => _StartOneState();
}

class _StartOneState extends State<StartOne> {
  int state = 0;
  final controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (c) => Index(
                      widget._sipHelper,
                      widget._xmppHelper,
                      widget._arguments,
                    ),
                  ),
                );
              },
              child: Text(
                "Пропустить",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: w400,
                  color: gray100,
                ),
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Expanded(
            child: ListView( //PageView(
              controller: controller,
              //physics: const NeverScrollableScrollPhysics(),
              children: const [
                OnboardingPicture(
                  asset: AssetLib.start1,
                  title: "Бесплатные звонки из любой точки мира",
                  description:
                      "Звоните в поддержку банка или страховой без ограничений",
                ),
                OnboardingPicture(
                  asset: AssetLib.start2,
                  title: "Большая база компаний из разных отраслей",
                  description:
                      "Привносим пользу в мир телефонии вместе с нашими партнерами",
                ),
                OnboardingPicture(
                  asset: AssetLib.start3,
                  title: "Для звонков достаточно наличие интернета",
                  description:
                      "Можно воспользоваться бесплатным WiFi отеля или кафе",
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StartPageDot(enabled: state == 0),
                        StartPageDot(enabled: state == 1),
                        StartPageDot(enabled: state == 2),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (state < 2) {
                          state++;
                          setState(() {});
                          controller.animateToPage(
                            state,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.ease,
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (c) => Index(
                                widget._sipHelper,
                                widget._xmppHelper,
                                widget._arguments,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: blue,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(AssetLib.smallArrowR)),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
