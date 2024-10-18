import 'package:flutter/material.dart';
import '../../../services/jabber_manager.dart';
import '../../../services/sip_ua_manager.dart';
import '../../gl.dart';
import '../../../navigation/custom_bottom_navigation_bar.dart';
import 'new_call/new_call.dart';

class Index extends StatefulWidget {
  static const String id = '/index/';
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  final Object? _arguments;
  const Index(this._sipHelper, this._xmppHelper, this._arguments,
      {Key? key})
      : super(key: key);

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = listUserPage;
    return Scaffold(
      extendBody: true,
      body: _buildContent(pages),
      bottomNavigationBar: CustomBottomNavigationBar(
        size: MediaQuery.of(context).size,
        chatMessageCount:
            myPhone == null ? 0 : 2, // TODO implement user message count
        onPressed: (i, unavailable) {
          setState(() {

            unavailable = false;

            /// Page 2 must be called separately
            if (i == 2 && !unavailable) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => const NewCall(),
                ),
              );
              return;
            }

            /// checking for availability is handled here because
            /// you can change the way the app reacts
            /// For example, maybe it's ok to show Chat/Phone Call/History page
            /// when pressed on unavailable buttons
            sel = unavailable && i != 0 ? 4 : i;
            thPage.value = sel;
          });
        },
        activeIndex: sel,
        unauthorized: myPhone == null,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    thPage.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Widget _buildContent(List<Widget> pages) {
    final pageIndex = thPage.value.clamp(0, pages.length - 1);
    return pages[pageIndex];
  }
}
