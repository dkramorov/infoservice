import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../models/companies/catalogue.dart';
import '../../fonts/funtya.dart';
import '../../helpers/log.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../services/update_manager.dart';
import '../../settings.dart';
import '../../widgets/companies/catalogue_in_update.dart';
import '../../widgets/companies/floating_search_widget.dart';
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

  @override
  void initState() {
    super.initState();
    loadRubrics();
    updateSubscription =
        UpdateManager.updateStream?.updateSection.listen((section) {
      print('UpdateManager.updateStream.updateSection section $section');
      if (section == UpdateManager.catalogueLoadedAction) {
        loadRubrics();
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
    super.dispose();
  }

  void loadRubrics() {
    Catalogue().getFullCatalogue().then((result) {
      setState(() {
        rubrics = result;
      });
    });
  }

  // Обновление состояния
  void setStateCallback(Map<String, dynamic> state) {
    setState(() {
      if (state['rubrics'] != null) {
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

  Widget buildRubricForRowMore() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.setStateCallback({
            'setPageview': 5,
          });
        },
        child: Column(
          children: [
            const SizedBox(
              height: 60.0,
              child: Icon(
                Icons.more_horiz,
                size: 42.0,
                color: Colors.green,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: const Text(
                'Показать все',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRubricForRow(Catalogue rubric) {
    return Expanded(
      child: GestureDetector(
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
              height: 60.0,
              child: buildAvatar(rubric),
            ),
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

  Widget buildCatalogue() {
    if (rubrics.isEmpty) {
      return Column(
        children: [
          SIZED_BOX_H30,
          CatalogueInUpdate(),
          SIZED_BOX_H24,
          buildSlider(),
        ],
      );
    }
    // Сортируем по позиции рубрики
    for (Catalogue rubric in rubrics) {
      if (rubric.position == null) {
        Log.d(TAG, 'pos null: $rubric');
        rubric.position = 9999;
      }
    }
    rubrics.sort((a, b) => a.position!.compareTo(b.position!));

    return Column(
      children: [
        // Подложка для поиска
        buildPanelForSearch(),
        SIZED_BOX_H12,
        Expanded(
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: const Offset(-2, 0),
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildRubricForRow(rubrics[0]),
                        buildRubricForRow(rubrics[1]),
                        buildRubricForRow(rubrics[2]),
                        buildRubricForRow(rubrics[3]),
                      ],
                    ),
                    SIZED_BOX_H20,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildRubricForRow(rubrics[5]),
                        buildRubricForRow(rubrics[6]),
                        buildRubricForRow(rubrics[7]),
                        buildRubricForRowMore(),
                      ],
                    ),
                  ],
                ),
              ),
              SIZED_BOX_H24,
              buildSlider(),
            ],
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
