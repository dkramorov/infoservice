import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infoservice/widgets/companies/phone_row.dart';

import '../../models/companies/branches.dart';
import '../../models/companies/orgs.dart';
import '../../models/companies/phones.dart';
import '../../pages/app_asset_lib.dart';
import '../../pages/static_values.dart';
import '../../pages/themes.dart';
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

class AddressRow extends StatelessWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Branches branch;
  final List<Phones>? phones;
  final Orgs? company;

  const AddressRow(this.sipHelper, this.xmppHelper, this.branch,
      {this.phones, this.company, Key? key})
      : super(key: key);


  String getBranchInfo() {
    String result = branch.name ?? '';
    if (branch.mapAddress != null) {
      result += '\n${branch.mapAddress}';
    }
    return result;
  }

  List<Widget> buildPhones() {
    List<Widget> result = [];
    if (phones != null) {
      for (Phones phone in phones!) {
        if (phone.branch == branch.id) {
          result.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: CustSeparator(
              color: Color.fromRGBO(173, 173, 173, 1),
            ),
          ));
          result.add(PhoneRow(
            sipHelper,
            xmppHelper,
            phone,
            company: company,
          ));
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: size.width - 32,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(
          left: 16,
          bottom: 12,
          right: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              offset: Offset(0, 2),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: surfacePrimary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SvgPicture.asset(AssetLib.location),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: size.width * 0.69,
                  child: Text(
                    getBranchInfo(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: w400,
                      color: black,
                    ),
                  ),
                )
              ],
            ),
            ...buildPhones(),
          ],
        ),
      ),
    );
  }
}

class CustSeparator extends StatelessWidget {
  const CustSeparator({
    Key? key,
    this.height = 1,
    this.color = Colors.black,
  }) : super(key: key);
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: 1,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
