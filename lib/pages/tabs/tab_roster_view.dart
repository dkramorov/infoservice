import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infoservice/widgets/rounded_button_widget.dart';

import '../../models/user_chat_model.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../widgets/chat/my_user.dart';
import '../../widgets/user_widget.dart';
import '../authorization.dart';
import '../chat/add2roster.dart';

class TabRosterView extends StatefulWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Function setStateCallback;
  final PageController pageController;

  const TabRosterView(
      {this.sipHelper,
      this.xmppHelper,
      required this.pageController,
      required this.setStateCallback,
      Key? key})
      : super(key: key);

  @override
  _TabRosterViewState createState() => _TabRosterViewState();
}

class _TabRosterViewState extends State<TabRosterView> {
  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;

  late StreamSubscription<bool>? jabberSubscription;
  List<Object?> chatUsers = [];
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      xmppHelper?.showConnectionStatus().then((success) {
        isRegistered = xmppHelper?.registered ?? false;
        if (isRegistered) {
          getRoster();
        }
      });
    });

    if (JabberManager.enabled) {
      jabberSubscription =
          xmppHelper?.jabberStream.registration.listen((success) {
            setState(() {
              isRegistered = success;
            });
            if (success) {
              print('getRoster because isRegistered $success');
              getRoster();
            }
          });
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    jabberSubscription?.cancel();
    super.dispose();
  }

  // Обновление состояния
  void setStateCallback(Map<String, dynamic> state) {
    setState(() {});
  }

  Future<void> getRoster() async {
    Future.delayed(const Duration(milliseconds: 1000), () async {
      chatUsers = await xmppHelper?.getRoster();
      setState(() {});
      /* CUSTOM POTESTUA */
      await JabberManager.flutterXmpp?.potestua();
    });
  }

  Widget buildRosterSearch() {
    final inputTextStyle = Theme.of(context).textTheme.subtitle2;
    return Container(
      margin: PAD_SYM_H20,
      padding: PAD_SYM_H20,
      alignment: Alignment.centerLeft,
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(.15),
            offset: const Offset(0, 10),
            blurRadius: 20,
          )
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            SEARCH_ICON,
            height: 16,
          ),
          SIZED_BOX_W20,
          Expanded(
            child: FocusScope(
              child: TextField(
                autofocus: false,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.name,
                style: inputTextStyle,
                expands: true,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Поиск...',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildView() {
    final halfWidth = MediaQuery.of(context).size.width * 0.4;

    return Column(
      children: [
        SIZED_BOX_H20,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                widget.setStateCallback({
                  'setPageview': 4,
                });
              },
              child: MyUser(
                label: 'Я, ${xmppHelper?.getLogin()}',
                imgPath: DEFAULT_AVATAR,
                isReady: true,
                isOnline: xmppHelper?.registered ?? false,
                labelWidth: halfWidth,
                showIndicator: true,
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, Add2RosterScreen.id);
                await getRoster();
              },
              child: MyUser(
                label: 'Добавить контакт',
                imgPath: 'assets/avatars/add_contact.png',
                isOnline: false,
                labelWidth: halfWidth,
              ),
            ),
          ],
        ),
        SIZED_BOX_H20,

        isRegistered
            ? buildRosterSearch()
            : RoundedButtonWidget(
                text: const Text('Вход / Регистрация'),
                minWidth: 200.0,
                onPressed: () {
                  Navigator.pushNamed(context, AuthScreenWidget.id);
                },
              ),

        // Обязательно в Expanded,
        // иначе будет не влазить
        Expanded(
          /*
          child: FutureBuilder<List>(
            future: fetchContacts(),
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              if (snapshot.hasData) {
                return buildContacts(snapshot.data ?? []);
              } else {
                return const Text('Произошла ошибка, попробуйте поздже');
              }
            },
          ),
          */
          child: buildContacts(chatUsers),
        ),
      ],
    );
  }

  String formatTime(String time) {
    return time.substring(time.length - 2);
  }

  ListView buildContacts(List chatUsers) {
    return ListView.builder(
      itemCount: chatUsers.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        vertical: 15,
      ),
      itemBuilder: (context, index) {
        final item = UserChatModel(login: chatUsers[index]);
        return Dismissible(
          key: UniqueKey(),
          background: Container(color: Colors.red),
          onDismissed: (direction) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.login} удален из контактов')));
            xmppHelper?.dropFromRoster(item.login ?? '');
            getRoster();
          },
          child: ChatUserWidget(
            xmppHelper: xmppHelper,
            user: item,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: buildView());
  }
}
