import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app_asset_lib.dart';
import '../../../../static_values.dart';
import '../../../../../navigation/custom_app_bar_button.dart';
import '../../../../../navigation/generic_appbar.dart';
import '../../../../themes.dart';
import '../../../../format_ends.dart';
import 'company_card.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: GenericAppBar(
          hasBackButton: true,
          title: 'Банки',
          controls: [
            CustomAppBarButton(
              padding: 8,
              asset: AssetLib.searchBigButton,
              onPressed: () {},
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) =>
              CategoriesItem(data: mockData),
        ),
      );
}

Map<String, String> mockData = {
  'name': "Мок компании",
  'rating': "4",
  'phones': "3",
  'addresses': "8",
};

class CategoriesItem extends StatelessWidget {
  const CategoriesItem({
    super.key,
    required this.data,
  });
  final Map<String, String> data;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 12.0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.08),
                offset: Offset(0, 2),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            style: UIs.elevatedButtonDefault,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => const CompanyCardPage(),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Image.network(
                    "https://sun6-21.userapi.com/s/v1/ig2/6nBCZiIVxXgCQ4iTX9g_JXKu-uB12fl6IArEM_PeaAQHmqENhV7W5-QwOAHKf32oUGFb4Ttj5NvZDV2hJ2BVr1ef.jpg?size=2007x2008&quality=96&crop=149,76,2007,2008&ava=1",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? 'Ошибка компании',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: w400,
                        color: black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RatingStars(
                      value: double.tryParse(data['rating'] ?? '1') ?? 1,
                      starBuilder: (index, color) => SvgPicture.asset(
                        AssetLib.star,
                        // ignore: deprecated_member_use
                        color: color,
                      ),
                      starCount: 5,
                      starSize: 12,
                      maxValue: 5,
                      starSpacing: 1,
                      maxValueVisibility: false,
                      valueLabelVisibility: false,
                      starOffColor: const Color.fromRGBO(194, 196, 199, 1),
                      starColor: blue,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${formatPhoneWord(int.tryParse(data['phones'] ?? '0') ?? 0)} · ${formatAddressWord(
                        int.tryParse(data['addresses'] ?? '0') ?? 0,
                      )}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: w400,
                        color: gray100,
                      ),
                    )
                  ],
                ),
                const Spacer(),
                SvgPicture.asset(AssetLib.smallArrow)
              ],
            ),
          ),
        ),
      );
}
