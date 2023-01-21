import 'package:flutter/material.dart';
import 'package:infoservice/sip_ua/dialpad.dart';

import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';

class TabCallScreenView extends StatefulWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Function setStateCallback;
  final PageController pageController;

  TabCallScreenView(
      {this.sipHelper,
      this.xmppHelper,
      required this.pageController,
      required this.setStateCallback,
      Key? key})
      : super(key: key);

  @override
  _TabCallScreenViewState createState() => _TabCallScreenViewState();
}

class _TabCallScreenViewState extends State<TabCallScreenView> {
  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return DialPadWidget(sipHelper, xmppHelper);
  }
}
