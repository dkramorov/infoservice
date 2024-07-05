import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app_asset_lib.dart';
import '../../../../static_values.dart';
import '../../../../themes.dart';
import '../../../../format_ends.dart';
import '../side_page/categories_page.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile(this.index, {super.key});
  final int index;
  @override
  Widget build(BuildContext context) {
    return Padding(
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
                builder: (c) => const CategoriesPage(),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: categ[index]["color"],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SvgPicture.asset(
                  "assets/icons/categories/${categ[index]["icon"]}.svg",
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categ[index]["name"],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: w400,
                      color: black,
                    ),
                  ),
                  Text(
                    formatCompanyCount(categ[index]["col"]),
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
}

List<dynamic> categ = [
  {
    "id": 0,
    "name": "Онлайн магазины",
    "icon": "shop",
    "col": 38,
    "color": const Color.fromRGBO(255, 241, 229, 1),
  },
  {
    "id": 1,
    "name": "Госструктуры",
    "icon": "government ",
    "col": 38,
    "color": const Color.fromRGBO(234, 243, 250, 1),
  },
  {
    "id": 2,
    "name": "Автосервис",
    "icon": "car-service",
    "col": 38,
    "color": const Color.fromRGBO(242, 233, 249, 1),
  },
  {
    "id": 3,
    "name": "Красота",
    "icon": "beauty",
    "col": 38,
    "color": const Color.fromRGBO(246, 251, 231, 1),
  },
  {
    "id": 4,
    "name": "Развлечения",
    "icon": "game",
    "col": 38,
    "color": const Color.fromRGBO(250, 236, 236, 1),
  },
  {
    "id": 5,
    "name": "Медицина",
    "icon": "medicine",
    "col": 38,
    "color": const Color.fromRGBO(231, 251, 243, 1),
  },
  {
    "id": 6,
    "name": "Автотовары",
    "icon": "car-product",
    "col": 38,
    "color": const Color.fromRGBO(235, 251, 254, 1),
  },
  {
    "id": 7,
    "name": "Товары",
    "icon": "products",
    "col": 38,
    "color": const Color.fromRGBO(243, 241, 238, 1),
  },
  {
    "id": 8,
    "name": "Услуги",
    "icon": "turizm",
    "col": 38,
    "color": const Color.fromRGBO(238, 241, 248, 1),
  },
  {
    "id": 9,
    "name": "Спецмагазины",
    "icon": "spec-shop",
    "col": 38,
    "color": const Color.fromRGBO(229, 246, 245, 1),
  },
  {
    "id": 10,
    "name": "Продукты",
    "icon": "eat-products",
    "col": 38,
    "color": const Color.fromRGBO(255, 243, 235, 1),
  },
  {
    "id": 11,
    "name": "Спорт",
    "icon": "sport",
    "col": 38,
    "color": const Color.fromRGBO(229, 255, 231, 1),
  },
  {
    "id": 12,
    "name": "Образование",
    "icon": "education",
    "col": 38,
    "color": const Color.fromRGBO(250, 236, 236, 1),
  },
  {
    "id": 13,
    "name": "Власть",
    "icon": "power",
    "col": 38,
    "color": const Color.fromRGBO(234, 243, 250, 1),
  },
  {
    "id": 14,
    "name": "Ремонт, стройка",
    "icon": "repair",
    "col": 38,
    "color": const Color.fromRGBO(246, 251, 231, 1),
  },
  {
    "id": 15,
    "name": "Пром. товары",
    "icon": "prom. products",
    "col": 38,
    "color": const Color.fromRGBO(255, 241, 229, 1),
  },
  {
    "id": 16,
    "name": "B2B-услуги",
    "icon": "B2B services",
    "col": 38,
    "color": const Color.fromRGBO(242, 233, 249, 1),
  },
  {
    "id": 17,
    "name": "Горячие линии",
    "icon": "hotline",
    "col": 38,
    "color": const Color.fromRGBO(254, 251, 234, 1),
  },
  {
    "id": 18,
    "name": "Поесть",
    "icon": "meal",
    "col": 38,
    "color": const Color.fromRGBO(231, 251, 243, 1),
  },
  {
    "id": 19,
    "name": "Логистические компании",
    "icon": "logistics company",
    "col": 38,
    "color": const Color.fromRGBO(238, 241, 248, 1),
  },
  {
    "id": 20,
    "name": "Сеть постоматов",
    "icon": "postamate network",
    "col": 38,
    "color": const Color.fromRGBO(243, 241, 238, 1),
  },
  {
    "id": 21,
    "name": "Остальное",
    "icon": "others",
    "col": 38,
    "color": const Color.fromRGBO(235, 251, 254, 1),
  },
];
