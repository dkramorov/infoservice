import 'package:flutter/material.dart';
import 'package:infoservice/pages/companies/tab_branches_view.dart';
import 'package:infoservice/pages/companies/tab_company_view.dart';
import 'package:infoservice/pages/companies/tab_phones_view.dart';

import '../../models/companies/addresses.dart';
import '../../models/companies/branches.dart';
import '../../models/companies/catalogue.dart';
import '../../models/companies/cats.dart';
import '../../models/companies/orgs.dart';
import '../../helpers/log.dart';
import '../../models/companies/phones.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';

class CompanyWizardScreen extends StatefulWidget {
  static const String id = '/company_screen/';
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  final Object? _arguments;
  const CompanyWizardScreen(this._sipHelper, this._xmppHelper, this._arguments,
      {Key? key})
      : super(key: key);

  @override
  _CompanyWizardScreenState createState() => _CompanyWizardScreenState();
}

class _CompanyWizardScreenState extends State<CompanyWizardScreen> {
  static const TAG = 'CompanyWizardScreen';

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  final Duration _durationPageView = const Duration(milliseconds: 500);
  final Curve _curvePageView = Curves.easeInOut;

  late Orgs? company;

  final PageController _pageController = PageController(
    initialPage: 0,
    keepPage: false,
  );

  int _pageIndex = 0;
  String title = NavigationData.nav[0]['title'];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    List args = (widget._arguments as Set).toList();
    for (Object? arg in args) {
      if (arg is Orgs) {
        company = arg;
        Log.d(TAG, '---> org is ${company.toString()}');
        title = company!.name ?? title;
        loadCompany();
        break;
      }
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  Future<void> loadCompany() async {
    company!.branchesArr = await Branches().getOrgBranches(company!.id!);
    for (Branches branch in company!.branchesArr) {
      if (branch.address != null) {
        branch.mapAddress = await Addresses().getAddress(branch.address!);
      }
    }
    company!.phonesArr = await Phones().getOrgPhones(company!.id!);
    company!.catsArr = await Cats().getOrgCats(company!.id!);
    company!.rubricsArr = await Catalogue().getCatsRubrics(company!.catsArr);
    setState(() {});
  }

  setPageview(int index) {
    setState(() {
      _pageIndex = index;
    });
    _pageController.animateToPage(index,
        curve: _curvePageView, duration: _durationPageView);
  }

  void setStateCallback(Map<String, dynamic> newState) {
    setState(() {
      if (newState['curCompany'] != null) {
        company = newState['curCompany'];
        title = company!.name ?? '';
      }
    });
    if (newState['setPageview'] != null) {
      setPageview(newState['setPageview']);
    }
  }

  @override
  Widget build(BuildContext context) {
    void _onPageChanged(int page) {
      setState(() {
        title = NavigationData.nav[page]['title'];
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
        ),
        backgroundColor: PRIMARY_COLOR,
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            TabCompanyView(
              sipHelper,
              xmppHelper,
              pageController: _pageController,
              setStateCallback: setStateCallback,
              company: company!,
            ),
            TabBranchesView(
              sipHelper,
              xmppHelper,
              pageController: _pageController,
              setStateCallback: setStateCallback,
              company: company!,
            ),
            TabPhonesView(
              sipHelper,
              xmppHelper,
              pageController: _pageController,
              setStateCallback: setStateCallback,
              company: company!,
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
        child: SizedBox(
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _pageIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey.shade300,
            backgroundColor: Colors.green,
            // Показывать подписи к вкладкам
            //showSelectedLabels: false,
            //showUnselectedLabels: false,
            elevation: 0,
            onTap: (index) {
              setPageview(index);
              setState(() => _pageIndex = index);
            },
            items: NavigationData.nav
                .map(
                  (navItem) => BottomNavigationBarItem(
                    icon: Icon(
                      navItem['icon'],
                    ),
                    tooltip: navItem['tooltip'],
                    label: navItem['label'],
                    backgroundColor: Colors.white,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class NavigationData {
  static List<dynamic> nav = [
    {
      'icon': Icons.info_outline,
      'index': 0,
      'label': 'Информация',
      'tooltip': 'Информация',
      'title': 'Информация',
    },
    {
      'icon': Icons.domain,
      'index': 1,
      'label': 'Адреса',
      'tooltip': 'Адреса',
      'title': 'Адреса',
    },
    {
      'icon': Icons.settings_phone_outlined,
      'index': 2,
      'label': 'Телефоны',
      'tooltip': 'Телефоны',
      'title': 'Телефоны',
    },
  ];
}
