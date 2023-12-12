import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:infoservice/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/companies/catalogue.dart';
import '../../services/jabber_manager.dart';
import '../../services/shared_preferences_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../services/update_manager.dart';
import '../../widgets/companies/cat_row.dart';
import '../../widgets/companies/catalogue_in_update.dart';
import '../../widgets/companies/floating_search_widget.dart';
import '../companies/companies_listing_screen.dart';

class TabCompaniesView extends StatefulWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Function setStateCallback;
  final PageController pageController;

  const TabCompaniesView(
      {this.sipHelper,
      this.xmppHelper,
      required this.pageController,
      required this.setStateCallback,
      Key? key})
      : super(key: key);

  @override
  _TabCompaniesViewState createState() => _TabCompaniesViewState();
}

class _TabCompaniesViewState extends State<TabCompaniesView> {
  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;

  List<Catalogue> rubrics = [];
  List<Catalogue> sliderRubrics = [];

  late StreamSubscription<String>? updateSubscription;

  int _currentCatInSlider = 0;
  final CarouselController _catsController = CarouselController();

  late Timer updateTimer;

  @override
  void initState() {
    super.initState();
    loadCatalogue();
    // Из фона не приезджает stream?
    updateSubscription =
        UpdateManager.updateStream?.updateSection.listen((section) {
      print('UpdateManager.updateStream.updateSection section $section');
      if (section == UpdateManager.catalogueLoadedAction) {
        loadCatalogue();
      }
    });

    updateTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      SharedPreferences preferences =
      await SharedPreferencesManager.getSharedPreferences();
      bool catalogueLoadedAction =
          preferences.getBool(UpdateManager.catalogueLoadedAction) ?? false;
      if (catalogueLoadedAction) {
        print(
            'UpdateManager.updateStream.updateSection section'
                ' ${UpdateManager.catalogueLoadedAction}');
        preferences.setBool(UpdateManager.catalogueLoadedAction, false);
        loadCatalogue();
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
    super.dispose();
  }

  // Обновление состояния
  void setStateCallback(Map<String, dynamic> state) {
    setState(() {});
  }

  loadCatalogue() {
    Catalogue().getFullCatalogue().then((cats) {
      // Сортируем по позиции рубрики
      for (Catalogue cat in cats) {
        cat.position ??= 9999;
      }
      cats.sort((a, b) => a.position!.compareTo(b.position!));

      setState(() {
        rubrics = cats;
      });
    });
  }

  Widget buildFloatingSearch() {
    return Stack(
      children: [
        CompaniesFloatingSearchWidget(xmppHelper),
      ],
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
            height: 130.0,
            width: 130.0,
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

  Widget buildCatsSlider() {
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
                      .withOpacity(_currentCatInSlider == entry.key ? 0.9 : 0.4)),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  /* Вкладка со всеми категориями */
  Widget buildCatalogue() {
    return rubrics.isEmpty
        ? Column(children: [
            SIZED_BOX_H30,
            CatalogueInUpdate(),
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
