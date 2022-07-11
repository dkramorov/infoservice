import 'package:flutter/material.dart';

import '../../models/companies/orgs.dart';
import '../../models/companies/phones.dart';
import '../../models/dialpad_model.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../sip_ua/dialpadscreen.dart';

class PhoneRow extends StatelessWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Phones phone;
  final Orgs? company;

  const PhoneRow(this.sipHelper, this.xmppHelper, this.phone,
      {this.company, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: UniqueKey(),
      onTap: () {
        Navigator.pushNamed(context, DialpadScreen.id, arguments: {
          sipHelper,
          xmppHelper,
          DialpadModel(
            phone: phone.digits ?? '',
            isSip: false,
            startCall: true,
            company: company,
          )
        });
      },
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.phone_sharp),
              title: Text(
                phone.formattedPhone,
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${phone.getWhataDisplay(phone.whata)}. ${phone.comment ?? ""}'),
                ],
              ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
