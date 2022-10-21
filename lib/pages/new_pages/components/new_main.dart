
import 'package:flutter/material.dart';
import 'package:infoservice/pages/new_pages/components/profile.dart';

import '../../../services/jabber_manager.dart';
import '../../../services/sip_ua_manager.dart';
import 'catalog_page.dart';

class NewMainPage extends StatefulWidget {

  static const String id = '/new_main_page/';

  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  final Object? _arguments;
  const NewMainPage(this._sipHelper, this._xmppHelper, this._arguments,
      {Key? key})
      : super(key: key);

  @override
  State<NewMainPage> createState() => _NewMainPageState();
}

class _NewMainPageState extends State<NewMainPage> {
  int _selectedNow = 0; // Пременная для отслеживания страницы
  List<dynamic> pages = [
    const CatalogPage(),
    const CatalogPage(),
    const CatalogPage(),
    const CatalogPage(),
    const ProfilePage(),
  ]; //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedNow],
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        selectedFontSize: 14.0,
        unselectedFontSize: 14,
        unselectedItemColor: Color(0xFFBDBDBD),
        selectedItemColor: Color(0xFF12CBC4),
        currentIndex: _selectedNow,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _selectedNow = index);
        },
        iconSize: 24,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            activeIcon: Image.asset(
              'assets/images/main-icon.png',
              color: Color(0xFF12CBC4),
            ),
            label: 'Главная',
            icon: Image.asset('assets/images/main-icon.png'),
          ),
          BottomNavigationBarItem(
            label: 'Чат',
            activeIcon: Image.asset(
              'assets/images/chat.png',
              color: Color(0xFF12CBC4),
            ),
            icon: Image.asset('assets/images/chat.png'),
          ),
          BottomNavigationBarItem(
            label: 'Позвонить',
            activeIcon: Image.asset(
              'assets/images/call.png',
              color: Color(0xFF12CBC4),
            ),
            icon: Image.asset('assets/images/call.png'),
          ),
          BottomNavigationBarItem(
            label: 'История',
            activeIcon: Image.asset(
              'assets/images/hystory.png',
              color: Color(0xFF12CBC4),
            ),
            icon: Image.asset('assets/images/hystory.png'),
          ),
          BottomNavigationBarItem(
            label: 'Профиль',
            activeIcon: Image.asset(
              'assets/images/profile.png',
              color: Color(0xFF12CBC4),
            ),
            icon: Image.asset('assets/images/profile.png'),
          ),
        ],
      ),
    );
  }
}
