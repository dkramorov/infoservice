import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app_asset_lib.dart';
import '../../../back_button_custom.dart';
import '../../../generic_appbar.dart';
import '../../../gl.dart';
import '../../../themes.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: GenericAppBar(
        title: 'История',
        controls: [
          AppBarButtonCustom(
            padding: 8,
            asset: AssetLib.searchBigButton,
            onPressed: () {},
          ),
        ],
        controlsCondition: hist.isNotEmpty,
      ),
      body: Container(
        color: white,
        width: size.width,
        height: size.height,
        padding: hist.isEmpty ? null : const EdgeInsets.only(bottom: 30),
        child: hist.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 35, bottom: 8),
                    width: size.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        Text(
                          "История",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: w500,
                            color: black,
                          ),
                        ),
                        const SizedBox(width: 24),
                        // GestureDetector(
                        //   onTap: () {},
                        //   child: SvgPicture.asset(AssetLib.plusButton),
                        // )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "История пуста",
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
                          "Начните звонить и общаться, чтобы она появилась",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: w400,
                            color: gray100,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          thPage.value = 0;
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 32,
                          ),
                          decoration: BoxDecoration(
                            color: blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "В каталог",
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
                  const SizedBox(height: 73),
                ],
              )
            : ListView.separated(
                itemCount: hist.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: size.width,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: Image.network(
                                hist[index]["icon"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hist[index]["name"],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: w400,
                                  color: black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  SvgPicture.asset(AssetLib.phoneFill),
                                  const SizedBox(width: 6),
                                  Text(
                                    hist[index]["phone"],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: w400,
                                      color: gray100,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  SvgPicture.asset(AssetLib.date),
                                  const SizedBox(width: 6),
                                  Text(
                                    hist[index]["date"],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: w400,
                                      color: gray100,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  SvgPicture.asset(AssetLib.timeFill),
                                  const SizedBox(width: 6),
                                  Text(
                                    hist[index]["duration"],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: w400,
                                      color: gray100,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          SvgPicture.asset(AssetLib.smallArrow)
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 1,
                    color: gray200,
                  );
                },
              ),
      ),
    );
  }
}

List<dynamic> hist = [
  {
    "id": 0,
    "icon":
        "https://sun6-21.userapi.com/s/v1/ig2/6nBCZiIVxXgCQ4iTX9g_JXKu-uB12fl6IArEM_PeaAQHmqENhV7W5-QwOAHKf32oUGFb4Ttj5NvZDV2hJ2BVr1ef.jpg?size=2007x2008&quality=96&crop=149,76,2007,2008&ava=1",
    "name": "СберБанк",
    "phone": "8 800 100 00 06",
    "date": "16 Декабря, 00:32",
    "duration": "Звонок продлился 00:32",
  },
  {
    "id": 1,
    "icon":
        "https://sun6-21.userapi.com/s/v1/ig2/6nBCZiIVxXgCQ4iTX9g_JXKu-uB12fl6IArEM_PeaAQHmqENhV7W5-QwOAHKf32oUGFb4Ttj5NvZDV2hJ2BVr1ef.jpg?size=2007x2008&quality=96&crop=149,76,2007,2008&ava=1",
    "name": "СберБанк",
    "phone": "8 800 100 00 06",
    "date": "16 Декабря, 00:32",
    "duration": "Звонок продлился 00:32",
  },
  {
    "id": 2,
    "icon":
        "https://sun6-21.userapi.com/s/v1/ig2/6nBCZiIVxXgCQ4iTX9g_JXKu-uB12fl6IArEM_PeaAQHmqENhV7W5-QwOAHKf32oUGFb4Ttj5NvZDV2hJ2BVr1ef.jpg?size=2007x2008&quality=96&crop=149,76,2007,2008&ava=1",
    "name": "СберБанк",
    "phone": "8 800 100 00 06",
    "date": "16 Декабря, 00:32",
    "duration": "Звонок продлился 00:32",
  },
  {
    "id": 3,
    "icon":
        "https://sun6-21.userapi.com/s/v1/ig2/6nBCZiIVxXgCQ4iTX9g_JXKu-uB12fl6IArEM_PeaAQHmqENhV7W5-QwOAHKf32oUGFb4Ttj5NvZDV2hJ2BVr1ef.jpg?size=2007x2008&quality=96&crop=149,76,2007,2008&ava=1",
    "name": "СберБанк",
    "phone": "8 800 100 00 06",
    "date": "16 Декабря, 00:32",
    "duration": "Звонок продлился 00:32",
  },
  {
    "id": 4,
    "icon":
        "https://sun6-21.userapi.com/s/v1/ig2/6nBCZiIVxXgCQ4iTX9g_JXKu-uB12fl6IArEM_PeaAQHmqENhV7W5-QwOAHKf32oUGFb4Ttj5NvZDV2hJ2BVr1ef.jpg?size=2007x2008&quality=96&crop=149,76,2007,2008&ava=1",
    "name": "СберБанк",
    "phone": "8 800 100 00 06",
    "date": "16 Декабря, 00:32",
    "duration": "Звонок продлился 00:32",
  },
];
