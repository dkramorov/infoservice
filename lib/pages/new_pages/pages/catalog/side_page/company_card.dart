import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../services/sip_ua_manager.dart';
import '../../../../app_asset_lib.dart';
import '../../../../static_values.dart';
import '../../../../../navigation/custom_app_bar_button.dart';
import '../../../../themes.dart';
import '../../../../../widgets/button.dart';
import '../../../../../widgets/switcher.dart';
import '../../call_page.dart';

class CompanyCardPage extends StatefulWidget {
  const CompanyCardPage({super.key});

  @override
  State<CompanyCardPage> createState() => _CompanyCardPageState();
}

class _CompanyCardPageState extends State<CompanyCardPage> {
  bool vis = true;
  bool shad = false;
  bool _value1 = false;
  final SIPUAManager _sipManager = SIPUAManager();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
          elevation: shad ? 0 : 10,
          shadowColor: shad ? black.withOpacity(0.12) : null,
          titleSpacing: 0,
          centerTitle: true,
          surfaceTintColor: transparent,
          backgroundColor: white,
          title: !vis
              ? Text(
                  "СберБанк",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: w500,
                    color: black,
                  ),
                )
              : const SizedBox.shrink(),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (vis)
                    CustomAppBarButton(
                      asset: AssetLib.searchBigButton,
                      onPressed: () {},
                    )
                  else
                    Row(
                      children: [
                        SvgPicture.asset(
                          AssetLib.smallPhoneButton,
                          // ignore: deprecated_member_use
                          color: black,
                        ),
                        const SizedBox(width: 16),
                        SvgPicture.asset(AssetLib.smallChatButton)
                      ],
                    )
                ],
              ),
            ),
          ]),
      body: Container(
          color: white,
          width: size.width,
          height: size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                VisibilityDetector(
                  key: const Key("dsf"),
                  onVisibilityChanged: (info) {
                    var visible = info.visibleFraction * 100;
                    if (visible == 100) {
                      shad = false;
                      if (mounted) setState(() {});
                    } else {
                      shad = true;
                      if (mounted) setState(() {});
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.only(top: 6, bottom: 16),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        width: 1,
                        color: borderPrimary,
                      ),
                    ),
                    child: Image.network(
                        "https://sun6-21.userapi.com/s/v1/ig2/6nBCZiIVxXgCQ4iTX9g_JXKu-uB12fl6IArEM_PeaAQHmqENhV7W5-QwOAHKf32oUGFb4Ttj5NvZDV2hJ2BVr1ef.jpg?size=2007x2008&quality=96&crop=149,76,2007,2008&ava=1"),
                  ),
                ),
                Text(
                  "СберБанк",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: w500,
                    color: black,
                  ),
                ),
                const SizedBox(height: 8),
                RatingStars(
                  value: 4,
                  starBuilder: (index, color) => SvgPicture.asset(
                    AssetLib.star,
                    // ignore: deprecated_member_use
                    color: color,
                  ),
                  starCount: 5,
                  starSize: 16,
                  maxValue: 5,
                  starSpacing: 1,
                  maxValueVisibility: false,
                  valueLabelVisibility: false,
                  starOffColor: const Color.fromRGBO(194, 196, 199, 1),
                  starColor: blue,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 5,
                        top: 3,
                      ),
                      decoration: BoxDecoration(
                        color: surfacePrimary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Банки",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: w400,
                          color: gray100,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                VisibilityDetector(
                  key: const Key("sf"),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: size.width / 2 - 20,
                          child: PrimaryButton(
                            onPressed: () {},
                            color: surfacePrimary,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(AssetLib.smallChatButton),
                                const SizedBox(width: 8),
                                Text(
                                  "Написать",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: w500,
                                    color: black,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width / 2 - 20,
                          child: PrimaryButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => CallPage(
                                    phone: '',
                                    sip: _sipManager,
                                  ),
                                ),
                              );
                            },
                            color: blue,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(AssetLib.smallPhoneButton),
                                const SizedBox(width: 8),
                                Text(
                                  "Позвонить",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: w500,
                                    color: white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  onVisibilityChanged: (visibilityInfo) {
                    var visiblePercentage =
                        visibilityInfo.visibleFraction * 100;
                    if (visiblePercentage == 0) {
                      vis = false;
                      if (mounted) setState(() {});
                    } else {
                      vis = true;
                      if (mounted) setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  width: size.width - 32,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.08),
                        offset: Offset(0, 2),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Подписаться на новости",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: w500,
                              color: black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Иногда будем присылать полезную\nинформацию о компании",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: w400,
                              color: gray100,
                            ),
                          ),
                        ],
                      ),
                      CustomSwitch(
                        onChange: (c) {
                          _value1 = !_value1;
                          if (_value1) {
                            /*
                            showOverlayNotification((context) {
                              return SuccessAlert(
                                text:
                                    "Вы подписались на новости компании СберБанк",
                                color: success,
                              );
                            });
                            */
                          }
                          setState(() {});
                        },
                        value: _value1,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  children: List.generate(8, (index) {
                    return const AdressItem(
                      data: "",
                    );
                  }),
                )
              ],
            ),
          )),
    );
  }
}

class AdressItem extends StatelessWidget {
  final dynamic data;
  const AdressItem({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: size.width - 32,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(
          left: 16,
          bottom: 12,
          right: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              offset: Offset(0, 2),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: surfacePrimary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SvgPicture.asset(AssetLib.location),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: size.width * 0.69,
                  child: Text(
                    "​ТЦ Премьера, проспект Вернадского, 105, Москва",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: w400,
                      color: black,
                    ),
                  ),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CustSeparator(
                color: Color.fromRGBO(173, 173, 173, 1),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: surfacePrimary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: SvgPicture.asset(AssetLib.phone),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "8 800 100 00 06",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: w400,
                        color: black,
                      ),
                    )
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: UIs().smallButtonStyle,
                  child: Text(
                    "Позвонить",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: w500,
                      color: black,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustSeparator extends StatelessWidget {
  const CustSeparator({
    Key? key,
    this.height = 1,
    this.color = Colors.black,
  }) : super(key: key);
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: 1,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
