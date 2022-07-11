import 'package:flutter/material.dart';

import '../../models/companies/orgs.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../widgets/companies/phone_row.dart';

class TabPhonesView extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;

  final Function setStateCallback;
  final PageController pageController;
  final Orgs company;

  const TabPhonesView(this._sipHelper, this._xmppHelper,
      {required this.pageController,
      required this.setStateCallback,
      required this.company,
      Key? key})
      : super(key: key);

  @override
  _TabPhonesViewState createState() => _TabPhonesViewState();
}

class _TabPhonesViewState extends State<TabPhonesView> {
  static const TAG = 'TabPhonesView';

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  Orgs get company => widget.company;

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
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildPhones() {
    return ListView.builder(
      itemCount: widget.company.phonesArr.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        vertical: 15,
      ),
      itemBuilder: (context, index) {
        final item = widget.company.phonesArr[index];
        return PhoneRow(sipHelper, xmppHelper, item, company: company);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PAD_SYM_H10,
      child: buildPhones(),
    );
  }
}
