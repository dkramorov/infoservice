import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/companies/catalogue.dart';
import '../../models/companies/orgs.dart';
import '../../helpers/log.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../services/update_manager.dart';
import '../../settings.dart';
import '../../widgets/companies/catalogue_in_update.dart';
import '../../widgets/companies/company_row.dart';
import '../../widgets/companies/floating_search_widget.dart';

class CompaniesListingScreen extends StatefulWidget {
  static const String id = '/companies_listing_screen/';

  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  final Object? _arguments;

  const CompaniesListingScreen(this._sipHelper, this._xmppHelper, this._arguments, {Key? key})
      : super(key: key);

  @override
  _CompaniesListingScreenState createState() => _CompaniesListingScreenState();
}

class _CompaniesListingScreenState extends State<CompaniesListingScreen> {
  static const TAG = 'CompaniesListingScreen';

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  late StreamSubscription<String>? updateSubscription;
  late Catalogue? rubric;
  List<Orgs> companies = [];
  String title = 'Каталог компаний';

  @override
  void initState() {
    super.initState();
    List args = (widget._arguments as Set).toList();
    for (Object? arg in args) {
      if (arg is Catalogue) {
        rubric = arg;
        Log.d(TAG, '---> rubric is ${rubric.toString()}');
        title = rubric!.name ?? title;
        loadOrgs();
        break;
      }
    }
    loadOrgs();
    updateSubscription =
        UpdateManager.updateStream?.updateSection.listen((section) {
          print('UpdateManager.updateStream.updateSection section $section');
          if (section == UpdateManager.orgsLoadedAction) {
            loadOrgs();
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

  void loadOrgs() {
    if (rubric != null && rubric!.id != null) {
      Orgs().getCategoryOrgs(rubric!.id!).then((orgs) {
        setState(() {
          companies = orgs;
        });
      });
    } else {
      Log.i(TAG, 'loadOrgs error - rubric is null');
    }
  }

  // Обновление состояния
  void setStateCallback(Map<String, dynamic> state) {
    setState(() {
      if (state['companies'] != null) {
        companies = state['companies'];
      }
      if (state['title'] != null) {
        title = state['title'];
      }
      if (state['loadedCats'] != null) {
        //logic.loadCompanies();
      }
    });
  }

  /* Страничка листинга компаний */
  Widget buildCatalogue() {
    if (companies.isEmpty) {
      return Column(children: [
        SIZED_BOX_H30,
        CatalogueInUpdate(),
      ]);
    }
    return Column(
      children: [
        buildPanelForSearch(),
        SIZED_BOX_H12,
        Expanded(
          child: ListView.builder(
            itemCount: companies.length,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
            itemBuilder: (context, index) {
              final item = companies[index];
              return CompanyRow(sipHelper, xmppHelper, item);
            },
          ),
        ),
      ],
    );
  }

  Widget buildFloatingSearch() {
    return Stack(
      children: [
        CompaniesFloatingSearchWidget(xmppHelper),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
        ),
        backgroundColor: PRIMARY_COLOR,
      ),
      body: Stack(
        children: [
          buildCatalogue(),
          buildFloatingSearch(),
        ],
      ),
    );
  }
}
