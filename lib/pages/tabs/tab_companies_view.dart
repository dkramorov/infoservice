import 'package:flutter/material.dart';
import 'package:infoservice/settings.dart';

import '../../models/companies/catalogue.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../widgets/companies/cat_row.dart';
import '../../widgets/companies/catalogue_in_update.dart';
import '../../widgets/companies/floating_search_widget.dart';

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

  @override
  void initState() {
    super.initState();
    loadCatalogue();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Обновление состояния
  void setStateCallback(Map<String, dynamic> state) {
    setState(() {});
  }

  loadCatalogue() {
    Catalogue().getFullCatalogue().then((cats) {
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
                  itemCount: rubrics.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  itemBuilder: (context, index) {
                    final item = rubrics[index];
                    return CatRow(sipHelper, xmppHelper, item);
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
