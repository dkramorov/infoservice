import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:infoservice/helpers/context_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/companies/catalogue.dart';
import '../../fonts/funtya.dart';
import '../../helpers/log.dart';
import '../../services/jabber_manager.dart';
import '../../services/shared_preferences_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../services/update_manager.dart';
import '../../settings.dart';
import '../../widgets/companies/cat_row.dart';
import '../../widgets/companies/catalogue_in_update.dart';
import '../../widgets/companies/floating_search_widget.dart';
import '../../widgets/top_bar_item.dart';
import '../companies/cats_listing_screen.dart';
import '../companies/companies_listing_screen.dart';

class TabHomeView extends StatefulWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Function setStateCallback;
  final PageController pageController;

  const TabHomeView(
      {this.sipHelper,
      this.xmppHelper,
      required this.pageController,
      required this.setStateCallback,
      Key? key})
      : super(key: key);

  @override
  _TabHomeViewState createState() => _TabHomeViewState();
}

class _TabHomeViewState extends State<TabHomeView> {
  static const TAG = 'TabHomeView';

  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;

  late StreamSubscription<String>? updateSubscription;
  List<Catalogue> rubrics = [];

  int _currentCatInSlider = 0;
  final CarouselController _catsController = CarouselController();

  bool isRubricsSorted = false;

  late Timer updateTimer;

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
    loadRubrics();
    // Из фона не приезджает stream?
    updateSubscription =
        UpdateManager.updateStream?.updateSection.listen((section) {
      print('UpdateManager.updateStream.updateSection section $section');
      if (section == UpdateManager.catalogueLoadedAction) {
        loadRubrics();
      }
    });

    updateTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      SharedPreferences preferences =
          await SharedPreferencesManager.getSharedPreferences();
      bool catalogueLoadedAction =
          preferences.getBool(UpdateManager.catalogueLoadedAction) ?? false;
      if (catalogueLoadedAction) {
        print('UpdateManager.updateStream.updateSection section'
            ' ${UpdateManager.catalogueLoadedAction}');
        preferences.setBool(UpdateManager.catalogueLoadedAction, false);
        loadRubrics();
        updateTimer.cancel();
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    updateSubscription?.cancel();
    updateTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void loadRubrics() {
    Catalogue().getFullCatalogue().then((result) {
      isRubricsSorted = false;
      setState(() {
        rubrics = result;
        //sortRubrics(); // cортировка есть в getFullCatalogue
      });
    });
  }

  void sortRubrics() {
    if (rubrics.isEmpty || isRubricsSorted) {
      return;
    }
    Log.d(TAG, 'sorting rubrics ${rubrics.length}');
    // Сортируем по позиции рубрики
    for (Catalogue rubric in rubrics) {
      if (rubric.position == null) {
        Log.d(TAG, 'pos null: $rubric');
        rubric.position = 9999;
      }
    }
    rubrics.sort((a, b) => a.position!.compareTo(b.position!));
    isRubricsSorted = true;
  }

  // Обновление состояния
  void setStateCallback(Map<String, dynamic> state) {
    setState(() {
      if (state['rubrics'] != null) {
        sortRubrics();
        rubrics = state['rubrics'];
      }
    });
  }

  Widget buildFloatingSearch() {
    return Stack(
      children: [
        CompaniesFloatingSearchWidget(xmppHelper),
      ],
    );
  }

  Widget buildAvatar(Catalogue rubric) {
    if (rubric.name == null) {
      return const Icon(Icons.home_work_outlined);
    }
    if (rubric.icon != null && rubric.icon != '') {
      return Icon(
        Funtya.getIcon(rubric.icon!),
        size: 42.0,
        color: rubric.color,
      );
    }
    return CircleAvatar(
      backgroundColor: rubric.color,
      child: Text('${rubric.name}'[0]),
    );
  }

  Widget buildCatImage(Catalogue rubric) {
    if (rubric.img != null && rubric.img != '') {
      return CachedNetworkImage(
        height: double.infinity,
        imageUrl: '$DB_SERVER${rubric.img}',
        fit: BoxFit.cover,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 3.0),
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      backgroundColor: rubric.color,
      child: Text('${rubric.name}'[0]),
    );
  }

  Widget buildRubricForSlider(Catalogue rubric) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, CompaniesListingScreen.id, arguments: {
          sipHelper,
          xmppHelper,
          rubric,
        });
      },
      child: Column(
        children: [
          SizedBox(
            height: 120.0,
            width: 120.0,
            child: buildCatImage(rubric),
          ),
          SIZED_BOX_H12,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              rubric.name ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 2.0,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
        autoPlay: false,
      ),
      items: imageSliders,
    );
  }

  Widget buildCatsSlider() {
    if (rubrics.length < 6) {
      return Container();
    }
    final List<dynamic> item = [
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
    onPressed(int catId) async {
      Catalogue? cat = await Catalogue().getById(catId);
      if (cat == null) {
        return;
      }
      int childrenCount = await Catalogue().getChildrenCount(parents: '${cat.parents}_${cat.id}');
      Log.d('onTap', 'cat=${cat.id}, parents=${cat.parents}, children_count=$childrenCount');
      Future.delayed(Duration.zero, () {
        if (childrenCount > 0) {
          Navigator.pushNamed(context, CatsListingScreen.id, arguments: {
            sipHelper,
            xmppHelper,
            cat,
          });
        } else {
          Navigator.pushNamed(context, CompaniesListingScreen.id, arguments: {
            sipHelper,
            xmppHelper,
            cat,
          });
        }
      });
    }
    for (int i = 0; i < 3; i++) {
      item[0]['list'][i]['id'] = rubrics[i].id;
      item[0]['list'][i]['name'] = rubrics[i].name;
      item[0]['list'][i]['col'] = rubrics[i].count;
      item[0]['list'][i]['onPressed'] = onPressed;
    }
    for (int i = 3; i < 6; i++) {
      item[1]['list'][i - 3]['id'] = rubrics[i].id;
      item[1]['list'][i - 3]['name'] = rubrics[i].name;
      item[1]['list'][i - 3]['col'] = rubrics[i].count;
      item[1]['list'][i - 3]['onPressed'] = onPressed;
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 208,
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            itemCount: imageSliders.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: index == 0 ? 0 : 16,
              ),
              child: Wrap(
                runSpacing: 8,
                spacing: 9,
                children: item[index]['list']
                    .map<Widget>(
                      (Map<String, dynamic> listItem) =>
                          TopBarItem(listItem, size: context.screenSize),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );

    /* /// Старый вариант
    List<Widget> topCats = [];
    for (int i = 0; i < 10; i++) {
      if (rubrics[i].img != null &&
          rubrics[i].img != '' &&
          !rubrics[i].img!.endsWith('.svg')) {
        topCats.add(buildRubricForSlider(rubrics[i]));
      }
    }
    return Column(children: [
      const Text(
        'Популярное',
        style: TextStyle(fontSize: 18.0),
      ),
      SIZED_BOX_H12,
      CarouselSlider(
        //items: imageSliders,
        items: topCats,
        carouselController: _catsController,
        options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 2.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCatInSlider = index;
              });
            }),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: topCats.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _catsController.animateToPage(entry.key),
            child: Container(
              width: 12.0,
              height: 12.0,
              margin:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 3.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(
                          _currentCatInSlider == entry.key ? 0.9 : 0.4)),
            ),
          );
        }).toList(),
      ),
    ]);
    */
  }

  /* Вкладка со всеми категориями */
  Widget buildCatalogue() {
    return rubrics.isEmpty
        ? Column(children: [
            SIZED_BOX_H30,
            CatalogueInUpdate(),
            SIZED_BOX_H24,
            buildSlider(),
          ])
        : Column(
            children: [
              buildPanelForSearch(),
              Expanded(
                child: ListView.builder(
                  itemCount: rubrics.length + 1,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return buildCatsSlider();
                    } else {
                      final item = rubrics[index - 1];
                      return CatRow(sipHelper, xmppHelper, item);
                    }
                  },
                ),
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildCatalogue(),
        buildFloatingSearch(),
      ],
    );
  }
}

final List<String> imgList = [
  '$DB_SERVER${DB_LOGO_PATH}app_slider/1.jpg',
  '$DB_SERVER${DB_LOGO_PATH}app_slider/2.jpg',
];

final List<Widget> imageSliders = imgList
    .map((item) => Container(
          margin: const EdgeInsets.all(5.0),
          child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              child: Stack(
                children: <Widget>[
                  //Image.network(item, fit: BoxFit.cover, width: 1000.0),
                  CachedNetworkImage(
                    height: double.infinity,
                    width: 1000.0,
                    imageUrl: item,
                    fit: BoxFit.cover,
                  ),

                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      /*
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(200, 0, 0, 0),
                                Color.fromARGB(0, 0, 0, 0)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          */
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      /* Test for each slide */
                      /*
                          child: Text(
                            'No. ${imgList.indexOf(item)} image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          */
                    ),
                  ),
                ],
              )),
        ))
    .toList();
