import 'package:flutter/material.dart';
import 'package:infoservice/widgets/companies/phone_row.dart';
import 'package:infoservice/widgets/companies/star_rating_widget.dart';

import '../../models/companies/orgs.dart';
import '../../models/companies/phones.dart';
import '../../pages/companies/company_wizard_screen.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import 'company_logo.dart';

class CompanyRow extends StatelessWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Orgs company;
  const CompanyRow(this.sipHelper, this.xmppHelper, this.company, {Key? key})
      : super(key: key);

  Column buildPhonesRows() {
    List<Widget> result = [];
    for (Phones phone in company.phonesArr) {
      result.add(PhoneRow(sipHelper, xmppHelper, phone, company: company));
    }
    return Column(
      children: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: UniqueKey(),
      onTap: () {
        Navigator.pushNamed(context, CompanyWizardScreen.id, arguments: {
          sipHelper,
          xmppHelper,
          company,
        });
      },
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: CompanyLogoWidget(company),
              title: Text(
                company.name ?? '',
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (company.resume != null && company.resume != '')
                      ? Text(company.resume!)
                      : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Телефонов: ${company.phones}',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                      Text(
                        'Адресов: ${company.branches}',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                  StarRatingWidget(
                      company.rating == null ? 0 : company.rating!),
                ],
              ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
            ),
            buildPhonesRows(),
          ],
        ),
      ),
    );
  }
}
