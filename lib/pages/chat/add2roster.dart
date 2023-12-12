import 'package:flutter/material.dart';
import 'package:infoservice/pages/chat/tab_add_contact.dart';
import 'package:infoservice/pages/chat/tab_add_muc.dart';

import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';

class Add2RosterScreen extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  const Add2RosterScreen(this._sipHelper, this._xmppHelper, {Key? key})
      : super(key: key);
  static const String id = '/add2roster_screen/';

  @override
  _Add2RosterScreenState createState() => _Add2RosterScreenState();
}

class _Add2RosterScreenState extends State<Add2RosterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static const tag = 'Add2RosterScreen';
  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  String newUser = '8';

  String title = NavigationData.nav[0]['title'];
  final Duration _durationPageView = const Duration(milliseconds: 500);
  final Curve _curvePageView = Curves.easeInOut;

  int _pageIndex = 0;
  final PageController _pageController = PageController(
    initialPage: 0,
    keepPage: false,
  );
  void setPageview(int index, {gotoInvisible: false}) {
    if (!gotoInvisible) {
      setState(() {
        _pageIndex = index;
      });
    }
    _pageController.animateToPage(index,
        curve: _curvePageView, duration: _durationPageView);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _onPageChanged(int page) {
    setState(() {
      title = NavigationData.nav[page]['title'];
    });
  }

  void setStateCallback(Map<String, dynamic> newState) {
    if (newState['setPageview'] != null) {
      int pind = newState['setPageview'];
      bool gotoInvisible = false;
      // Все странички видимые пока
      if (pind >= NavigationData.nav.length) {
        gotoInvisible = true;
      }
      setPageview(pind, gotoInvisible: gotoInvisible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить контакт'),
        backgroundColor: tealColor,
      ),
      body: Center(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            TabAddContact(
              sipHelper: sipHelper,
              xmppHelper: xmppHelper,
              pageController: _pageController,
              setStateCallback: setStateCallback,
            ),
            TabAddMuc(
              sipHelper: sipHelper,
              xmppHelper: xmppHelper,
              pageController: _pageController,
              setStateCallback: setStateCallback,
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
            selectedItemColor: tealColor,
            unselectedItemColor: Colors.grey.shade500,
            backgroundColor: backgroundLightColor,
            // Показывать подписи к вкладкам
            //showSelectedLabels: false,
            //showUnselectedLabels: false,
            elevation: 0,
            onTap: (index) {
              setPageview(index);
              setState(() => _pageIndex = index);
            },
            items: NavigationData.nav
                .where((navItem) => navItem['hide'] == null) // прячем некоторые
                .map(
                  (navItem) => BottomNavigationBarItem(
                icon: Icon(
                  navItem['icon'],
                ),
                tooltip: navItem['tooltip'],
                label: navItem['label'],
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
      'icon': Icons.person_add,
      'index': 0,
      'label': 'Добавить контакт',
      'tooltip': 'Добавить контакт',
      'title': 'Добавить контакт',
    },
    {
      'icon': Icons.group_add,
      'index': 1,
      'label': 'Добавить группу',
      'tooltip': 'Добавить группу',
      'title': 'Добавить группу',
    },
  ];
}
