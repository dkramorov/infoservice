import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../models/companies/orgs.dart';
import '../../models/companies/phones.dart';
import '../../models/dialpad_model.dart';
import '../../pages/app_asset_lib.dart';
import '../../pages/static_values.dart';
import '../../pages/themes.dart';
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: surfacePrimary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SvgPicture.asset(AssetLib.phone),
            ),
            const SizedBox(width: 12),
            Text(
              phone.formattedPhone,
              style: TextStyle(
                fontSize: 14,
                fontWeight: w400,
                color: black,
              ),
            )
          ],
        ),
        ElevatedButton(
          onPressed: () {
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
          style: UIs().smallButtonStyle,
          child: Text(
            'Позвонить',
            style: TextStyle(
              fontSize: 12,
              fontWeight: w500,
              color: black,
            ),
          ),
        )
      ],
    );

    /* /// Старый вариант
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
    */
  }
}
