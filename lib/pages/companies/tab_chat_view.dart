import 'dart:async';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

import '../../helpers/network.dart';
import '../../helpers/phone_mask.dart';
import '../../models/companies/orgs.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../widgets/rounded_button_widget.dart';
import '../authorization.dart';
import '../chat/group_chat_page.dart';

class TabChatView extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;

  final Function? setStateCallback;
  final PageController? pageController;
  final Orgs? company;

  TabChatView(this._sipHelper, this._xmppHelper,
      {this.pageController, this.setStateCallback, this.company});

  @override
  _TabChatViewState createState() => _TabChatViewState();
}

class _TabChatViewState extends State<TabChatView> {
  static const TAG = 'TabChatView';

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;
  // TODO: заменить на активный логин, чтобы работать в оффлайн
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      xmppHelper?.showConnectionStatus().then((result) async {
        registeredCallback(xmppHelper?.registered ?? false);
      });
    });
  }

  void registeredCallback(bool result) {
    setState(() {
      isRegistered = result;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildView() {
    return RoundedButtonWidget(
      text: const Text('Открыть чат'),
      minWidth: 200.0,
      onPressed: () {
        // По принципу добавления группы
        String login = 'TODO: login'; // xmppHelper!.getLogin();
        String myPhone = cleanPhone(login); // номер телефона
        String newMuc = 'company_${widget.company!.id}_$myPhone';

        xmppHelper!.createMUC(newMuc, true).then((createMucResult) {
          // Создаем MUC
          xmppHelper!.joinMucGroup(newMuc).then((joinMucResult) {
            // В базу и обновляем ростер
            xmppHelper?.newMyMucGroup(newMuc);
            // Прикрепиться к MUC
            xmppHelper!.addGroup2VCard(newMuc);
          });
        });
        String newMucJid = '$newMuc${JabberManager.conferenceString}';

        // запросина на добавление на сервере всем представителям компании этот чат
        String credentialsHash = 'TODO: credentialsHash';// xmppHelper?.credentialsHash() ?? '';
        String jid = 'TODO: jid'; // xmppHelper!.getJid()
        requestCompanyChat(jid, credentialsHash, newMucJid);

        Navigator.pushNamed(context, GroupChatScreen.id, arguments: {
          sipHelper,
          xmppHelper,
          ChatUser(
            id: newMucJid,
            jid: newMucJid,
            name: widget.company!.name,
            phone: '-',
          ),
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isRegistered
          ? buildView()
          : RoundedButtonWidget(
              text: const Text('Вход / Регистрация'),
              minWidth: 200.0,
              onPressed: () {
                Navigator.pushNamed(context, AuthScreenWidget.id);
              },
            ),
    );
  }
}
