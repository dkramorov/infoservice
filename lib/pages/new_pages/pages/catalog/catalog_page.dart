import 'package:flutter/material.dart';
import 'package:infoservice/helpers/context_extensions.dart';
import '../../../gl.dart';
import '../../../themes.dart';
import 'item/category_tile.dart';
import '../../../search_bar_main_page.dart';
import 'item/search_dropdown_item.dart';
import '../../../../widgets/top_bar_item.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  List<DropdownMenuItem<String>> dropdownItems = [];
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  void _handlePageChange() {
    _currentPage = _pageController.page?.round() ?? 0;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_handlePageChange);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => _handlePageChange(),
    );

    for (var item in address) {
      // setState(() {
      //   if (_currentPage < item.length - 1) {
      //     _currentPage++;
      //   } else {
      //     _currentPage = 0;
      //   }
      // });

      ParkingLocation location = ParkingLocation(
        id: item["id"],
        value: item["value"],
      );

      dropdownItems.add(DropdownMenuItem<String>(
        value: location.value,
        child: SearchDropdownItem(location: location),
      ));
      // if (mounted) setState(() {});
    }
    // if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          titleSpacing: 0,
          centerTitle: true,
          surfaceTintColor: transparent,
          backgroundColor: white,
          title: SearchBarMainPageWidget(
            dropdownItems,
            onChanged: (value) => setState(() => inp = value),
            onMicrophone: () {},
          )),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 208,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: item.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: index == 0 ? 0 : 16,
                ),
                child: Wrap(
                  runSpacing: 8,
                  spacing: 9,
                  children: item[index]["list"]
                      .map<Widget>(
                        (Map<String, dynamic> listItem) =>
                            TopBarItem(listItem, size: context.screenSize),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                item.length,
                (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 4,
                      height: 4,
                      margin: EdgeInsets.only(right: index == 0 ? 4 : 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentPage ? black : gray,
                      ),
                    )),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 24,
              bottom: 16,
              left: 16,
            ),
            child: Text(
              "Все категории",
              style: TextStyle(
                fontSize: 20,
                fontWeight: w500,
                color: black,
              ),
            ),
          ),
          ...List.generate(categ.length, (index) => CategoryTile(index)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

List<dynamic> address = [
  {
    "id": 0,
    "value": "Банки",
  },
  {
    "id": 1,
    "value": "Застраховать машину",
  },
  {
    "id": 2,
    "value": "Позвонить в страховую",
  },
];

class ParkingLocation {
  final int id;
  final String value;

  ParkingLocation({
    required this.id,
    required this.value,
  });
}

List<dynamic> item = [
  {
    "id": 0,
    "list": [
      {
        "id": 0,
        "big": true,
        "color-1": 234,
        "color-2": 243,
        "color-3": 250,
        "name": "Авиакомпании",
        "col": 38,
        "height": 100,
        "img": "plane",
      },
      {
        "id": 1,
        "big": false,
        "color-1": 250,
        "color-2": 236,
        "color-3": 236,
        "name": "Страхование",
        "col": 137,
        "height": 74,
        "img": "lifesaving",
      },
      {
        "id": 2,
        "big": false,
        "color-1": 243,
        "color-2": 241,
        "color-3": 238,
        "name": "Красота",
        "col": 80,
        "height": 65,
        "img": "towel",
      },
    ],
  },
  {
    "id": 1,
    "list": [
      {
        "id": 3,
        "big": false,
        "color-1": 254,
        "color-2": 243,
        "color-3": 252,
        "name": "Банки",
        "col": 137,
        "height": 66,
        "img": "pig",
      },
      {
        "id": 4,
        "big": false,
        "color-1": 254,
        "color-2": 240,
        "color-3": 228,
        "name": "Туроператоры",
        "col": 80,
        "height": 67,
        "img": "slippers",
      },
      {
        "id": 5,
        "big": true,
        "color-1": 238,
        "color-2": 241,
        "color-3": 248,
        "name": "Операторы сотовой связи",
        "col": 20,
        "height": 0,
        "img": null,
      },
    ],
  },
];
