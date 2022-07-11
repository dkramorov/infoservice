import 'package:flutter/material.dart';
import 'package:infoservice/widgets/companies/phone_row.dart';

import '../../models/companies/branches.dart';
import '../../models/companies/orgs.dart';
import '../../models/companies/phones.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';

class BranchRow extends StatelessWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Branches branch;
  final List<Phones>? phones;
  final Orgs? company;

  const BranchRow(this.sipHelper, this.xmppHelper, this.branch,
      {this.phones, this.company, Key? key})
      : super(key: key);

  Column buildPhonesRows() {
    List<Widget> result = [];
    if (phones != null) {
      for (Phones phone in phones!) {
        if (phone.branch == branch.id) {
          result.add(PhoneRow(
            sipHelper,
            xmppHelper,
            phone,
            company: company,
          ));
        }
      }
    }
    return Column(
      children: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: UniqueKey(),
      onTap: () {},
      child: Card(
        color: Colors.grey.shade300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.home_work_outlined),
              title: Text(
                branch.name ?? '',
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  branch.mapAddress != null
                      ? Text(branch.mapAddress.toString())
                      : Container(),
                ],
              ),
              /*
                  trailing: Icon(
                    Icons.chevron_right,
                  ),
                  */
            ),
            buildPhonesRows(),
          ],
        ),
      ),
    );
  }
}
