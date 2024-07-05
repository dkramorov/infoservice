import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../helpers/log.dart';
import '../../models/companies/catalogue.dart';
import '../../fonts/funtya.dart';
import '../../pages/app_asset_lib.dart';
import '../../pages/companies/cats_listing_screen.dart';
import '../../pages/companies/companies_listing_screen.dart';
import '../../pages/format_ends.dart';
import '../../pages/static_values.dart';
import '../../pages/themes.dart';
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
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 12.0,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              offset: Offset(0, 2),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          style: UIs.elevatedButtonDefault,
          onPressed: () async {
            int childrenCount = await Catalogue().getChildrenCount(parents: '${cat.parents}_${cat.id}');
            Log.d('onTap', 'cat=${cat.id}, parents=${cat.parents}, children_count=$childrenCount');
            Future.delayed(Duration.zero, () {
              if (childrenCount > 0) {
                Navigator.pushNamed(context, CatsListingScreen.id, arguments: {
                  sipHelper,
                  xmppHelper,
                  cat,
                });
              } else {
                Navigator.pushNamed(context, CompaniesListingScreen.id, arguments: {
                  sipHelper,
                  xmppHelper,
                  cat,
                });
              }
            });
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: white, //UIs.colors[Random().nextInt(UIs.colors.length)],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: buildAvatar(),
                /*
                SvgPicture.asset(
                  "assets/icons/categories/icon.svg",
                ),
                */
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      cat.name ?? '',
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: w400,
                        color: black,
                      ),
                    ),
                  ),
                  Text(
                    formatCompanyCount(cat.count ?? 0),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: w400,
                      color: gray100,
                    ),
                  )
                ],
              ),
              const Spacer(),
              SvgPicture.asset(AssetLib.smallArrow)
            ],
          ),
        ),
      ),
    );

    /* /// Старая реализация CatRow
    return GestureDetector(
      key: UniqueKey(),
      onTap: () async {
        int childrenCount = await Catalogue().getChildrenCount(parents: '${cat.parents}_${cat.id}');
        Log.d('onTap', 'cat=${cat.id}, parents=${cat.parents}, children_count=$childrenCount');
        Future.delayed(Duration.zero, () {
          if (childrenCount > 0) {
            Navigator.pushNamed(context, CatsListingScreen.id, arguments: {
              sipHelper,
              xmppHelper,
              cat,
            });
          } else {
            Navigator.pushNamed(context, CompaniesListingScreen.id, arguments: {
              sipHelper,
              xmppHelper,
              cat,
            });
          }
        });
      },
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
    */
  }
}
