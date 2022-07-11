import 'package:flutter/material.dart';

import '../../models/companies/catalogue.dart';
import '../../fonts/funtya.dart';
import '../../pages/companies/companies_listing_screen.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';

class CatRow extends StatelessWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Catalogue cat;

  const CatRow(this.sipHelper, this.xmppHelper, this.cat, {Key? key}) : super(key: key);

  Widget buildAvatar() {
    if (cat.name == null) {
      return const Icon(Icons.home_work_outlined);
    }
    if (cat.icon != null && cat.icon != '') {
      return Icon(
        Funtya.getIcon(cat.icon!),
        size: 32.0,
        color: cat.color,
      );
    }
    return CircleAvatar(
      backgroundColor: cat.color,
      child: Text('${cat.name}'[0]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: UniqueKey(),
      onTap: () {
        Navigator.pushNamed(context, CompaniesListingScreen.id, arguments: {
          sipHelper,
          xmppHelper,
          cat,
        });
      },
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Container(
                width: 60.0,
                alignment: Alignment.center,
                child: buildAvatar(),
              ),
              title: Text(
                cat.name ?? '',
              ),
              subtitle: Text(
                'Компаний: ${cat.count}',
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
