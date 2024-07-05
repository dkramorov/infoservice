import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infoservice/widgets/companies/phone_row.dart';
import 'package:infoservice/widgets/companies/star_rating_widget.dart';

import '../../models/companies/orgs.dart';
import '../../models/companies/phones.dart';
import '../../pages/app_asset_lib.dart';
import '../../pages/companies/company_wizard_screen.dart';
import '../../pages/format_ends.dart';
import '../../pages/static_values.dart';
import '../../pages/themes.dart';
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
          onPressed: () {
            Navigator.pushNamed(context, CompanyWizardScreen.id, arguments: {
              sipHelper,
              xmppHelper,
              company,
            });
          },
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: CompanyLogoWidget(company),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      company.name ?? '',
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: w400,
                        color: black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  RatingStars(
                    value: Random().nextDouble() + 3.6,
                    starBuilder: (index, color) => SvgPicture.asset(
                      AssetLib.star,
                      // ignore: deprecated_member_use
                      color: color,
                    ),
                    starCount: 5,
                    starSize: 12,
                    maxValue: 5,
                    starSpacing: 1,
                    maxValueVisibility: false,
                    valueLabelVisibility: false,
                    starOffColor: const Color.fromRGBO(194, 196, 199, 1),
                    starColor: blue,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${formatPhoneWord(company.phones ?? 0)} · ${formatAddressWord(company.branches ?? 0)}",
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

    /* /// Старый вариант компаниий
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
    */
  }
}
