import 'dart:async';
import 'package:flutter/material.dart';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:infoservice/pages/tabs/tab_call_history_view.dart';
import 'package:infoservice/pages/tabs/tab_call_screen_view.dart';
import 'package:infoservice/pages/tabs/tab_companies_view.dart';
import 'package:infoservice/pages/tabs/tab_home_view.dart';
import 'package:infoservice/pages/tabs/tab_profile_view.dart';
import 'package:infoservice/pages/tabs/tab_roster_view.dart';
import 'package:infoservice/sip_ua/callscreen.dart';
import 'package:sip_ua/sip_ua.dart';

import '../notification_services/awesome_notification_controller.dart';
import '../services/jabber_manager.dart';
import '../services/permissions_manager.dart';
import '../services/sip_ua_manager.dart';
import '../navigation/custom_bottom_navigation_bar.dart';

class DefaultPage extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  const DefaultPage(this._sipHelper, this._xmppHelper, {Key? key})
      : super(key: key);
  static const String id = '/';
  @override
  _DefaultPageWidget createState() => _DefaultPageWidget();
}

class _DefaultPageWidget extends State<DefaultPage>
    implements SipUaHelperListener {
  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  late bool awesomeNotificationsPerms = false;
  String inp = "Поиск компаний";

  String title = NavigationData.nav[0]['title'];
  final Duration _durationPageView = const Duration(milliseconds: 700);
  final Curve _curvePageView = Curves.easeInOut;
  int _pageIndex = 0;
  final PageController _pageController = PageController(
    initialPage: 0,
    keepPage: false,
  );
  void setPageview(int index, {gotoInvisible = false, withAnimation = false}) {
    // Будем анимировать если переход на следующую или предыдущую
    if (!withAnimation) {
      if (index == (_pageIndex + 1) || index == (_pageIndex - 1)) {
        withAnimation = true;
      }
    }

    if (!gotoInvisible) {
      setState(() {
        _pageIndex = index;
      });
    }

    if (withAnimation) {
      _pageController.animateToPage(index,
          curve: _curvePageView, duration: _durationPageView);
    } else {
      _pageController.jumpToPage(index);
    }
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
      // После пятой невидимые странички идут
      if (pind >= NavigationData.nav.length - 1) {
        gotoInvisible = true;
      }
      setPageview(pind, gotoInvisible: gotoInvisible);
    }
  }

  void checkPermissions() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      print('AwesomeNotifications isAllowed: $isAllowed');
      if (!isAllowed) {
        AwesomeNotifications()
            .requestPermissionToSendNotifications()
            .then((result) {
          print(
              'AwesomeNotifications notification permissions asked, result is $result');
          if (result) {
            awesomeNotificationsPerms = true;
          }
        });
      } else {
        awesomeNotificationsPerms = true;
      }
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      print('check mic permissions ${timer.tick}');
      if (awesomeNotificationsPerms || timer.tick > 60) {
        timer.cancel();
        PermissionsManager().requestPermissions('microphone');
      }
    });
  }

  @override
  void dispose() {
    sipHelper!.removeSipUaHelperListener(this);
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    checkPermissions();
    if (sipHelper != null && SIPUAManager.enabled) {
      sipHelper!.addSipUaHelperListener(this);
    }

    _listedNotificationActionStream();
  }

  /* Слушаем поток от AwesomeNotifications,
  который получает действие пользователя на уведомление
  action.buttonKeyPressed будет содержать результат
  */
  void _listedNotificationActionStream() {
    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod:
          AwesomeNotificationController.onNotificationCreatedMethod,
      onActionReceivedMethod:
          AwesomeNotificationController.onActionReceivedMethod,
    );
    /*
    AwesomeNotifications().actionStream.listen((action) {
      print('AwesomeNotifications action stream event: $action');

      if (action.payload != null) {
        if (action.payload!['action'] == 'chat') {
          String sender = action.payload!['sender'] ?? '';
          String phone = cleanPhone(sender);
          String jid = JabberManager().toJid(sender);
          String name = phoneMaskHelper(sender);

          String screenId = ChatScreen.id;
          String group = action.payload!['group'] ?? '';
          if (group != '') {
            screenId = GroupChatScreen.id;
            sender = group;
            phone = group;
            jid = group;
            name = group.split('@')[0];
          }

          Navigator.popUntil(context, (route) => (route.isFirst));
          Navigator.pushNamed(context, screenId, arguments: {
            sipHelper,
            xmppHelper,
            ChatUser(
              id: phone,
              jid: jid,
              phone: sender,
              name: name,
              customProperties: {'fromPush': true},
            ),
          });
        }
        /* else if (action.payload!['action'] == 'call') {
          Navigator.popUntil(context, (route) => (route.isFirst));
          Navigator.pushNamed(context, CallScreenWidget.id, arguments: {
            sipHelper,
            xmppHelper,
          });
        }
        */
      }
    });
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      /*
      appBar: AppBar(
        backgroundColor: tealColor,
        title: const Text("8800.help"),
      ),
      */

      /* Пока убрал, чтобы место освободить
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        surfaceTintColor: transparent,
        backgroundColor: white,
        title: const Text("8800.help"),
        /*
        title: SearchBarMainPageWidget(
          const [],
          onChanged: (value) => setState(() => inp = value),
          onMicrophone: () {},
        ),
        */
      ),
      */
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            TabHomeView(
              sipHelper: sipHelper,
              xmppHelper: xmppHelper,
              pageController: _pageController,
              setStateCallback: setStateCallback,
            ),
            TabRosterView(
              sipHelper: sipHelper,
              xmppHelper: xmppHelper,
              pageController: _pageController,
              setStateCallback: setStateCallback,
            ),
            /* и вкладка и отдельный экран */
            TabCallScreenView(
              sipHelper: sipHelper,
              xmppHelper: xmppHelper,
              pageController: _pageController,
              setStateCallback: setStateCallback,
            ),
            TabCallHistoryView(
              sipHelper: sipHelper,
              xmppHelper: xmppHelper,
              pageController: _pageController,
              setStateCallback: setStateCallback,
            ),
            TabProfileView(
              sipHelper: sipHelper,
              xmppHelper: xmppHelper,
              pageController: _pageController,
              setStateCallback: setStateCallback,
            ),
            TabCompaniesView(
              sipHelper: sipHelper,
              xmppHelper: xmppHelper,
              pageController: _pageController,
              setStateCallback: setStateCallback,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        size: MediaQuery.of(context).size,
        chatMessageCount: 0,
        onPressed: (index, unavailable) {
          setState(() {
            /// checking for availability is handled here because
            /// you can change the way the app reacts
            /// For example, maybe it's ok to show Chat/Phone Call/History page
            /// when pressed on unavailable buttons
            setPageview(index);
            setState(() => _pageIndex = index);
          });
        },
        activeIndex: _pageIndex,
        unauthorized: false,
      ),
      /* /// Cтарый вариант нижнего бара
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
      */
    );
  }

  @override
  void callStateChanged(Call call, CallState callState) {
    if (callState.state == CallStateEnum.CALL_INITIATION) {
      Navigator.popUntil(context, (route) => (route.isFirst));
      Navigator.pushNamed(context, CallScreenWidget.id, arguments: {
        sipHelper,
        xmppHelper,
        call,
      });
    }
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void registrationStateChanged(RegistrationState state) {}

  @override
  void transportStateChanged(TransportState state) {}

  @override
  void onNewNotify(Notify ntf) {
    // TODO: implement onNewNotify
  }
}

class NavigationData {
  static List<dynamic> nav = [
    {
      'icon': Icons.format_list_bulleted,
      'index': 0,
      'label': 'Каталог',
      'tooltip': 'Каталог',
      'title': 'Каталог компаний',
    },
    {
      'icon': Icons.forum,
      'index': 1,
      'label': 'Чат',
      'tooltip': 'Чат',
      'title': 'Чат',
    },
    {
      'icon': Icons.dialpad,
      'index': 2,
      'label': 'Позвонить',
      'tooltip': 'Бесплатные звонки',
      'title': 'Бесплатный звонок',
    },
    {
      'icon': Icons.phone_forwarded,
      'index': 3,
      'label': 'История',
      'tooltip': 'История звонков',
      'title': 'История звонков',
    },
    {
      'icon': Icons.account_circle_outlined,
      'index': 4,
      'label': 'Профиль',
      'tooltip': 'Профиль',
      'title': 'Ваш профиль',
    },
    {
      'icon': Icons.domain,
      'index': 5,
      'label': 'Каталог',
      'tooltip': 'Каталог',
      'title': 'Каталог компаний',
      'hide': true,
    },
  ];
}
