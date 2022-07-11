import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infoservice/models/dialpad_model.dart';
import 'package:infoservice/sip_ua/dialpadscreen.dart';

import '../../models/companies/branches.dart';
import '../../models/companies/catalogue.dart';
import '../../models/companies/orgs.dart';
import '../../helpers/phone_mask.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../widgets/companies/branch_row.dart';
import '../../widgets/companies/company_logo.dart';
import '../../widgets/companies/star_rating_widget.dart';
import '../../widgets/rounded_button_widget.dart';

class TabCompanyView extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;

  final Function setStateCallback;
  final PageController pageController;
  final Orgs company;

  const TabCompanyView(this._sipHelper, this._xmppHelper,
      {required this.pageController,
      required this.setStateCallback,
      required this.company,
      Key? key})
      : super(key: key);

  @override
  _TabCompanyViewState createState() => _TabCompanyViewState();
}

class _TabCompanyViewState extends State<TabCompanyView> {
  static const TAG = 'TabCompanyView';

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  static const companyCardBackgroudColor = Colors.green;
  static const addressIconColor = Color(0xFF961616);
  final int maxRubrics = 3;

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

  StarRatingWidget buildRating() {
    int stars = 0;
    if (company.rating != null) {
      stars = company.rating!;
    }
    return StarRatingWidget(stars);
  }

  Column buildBranchesRows() {
    List<Widget> result = [];
    for (Branches branch in company.branchesArr) {
      result.add(const Divider());
      // Филиал с телефонами
      result.add(BranchRow(
        sipHelper,
        xmppHelper,
        branch,
        phones: company.phonesArr,
        company: company,
      ));
    }
    return Column(
      children: result,
    );
  }

  Widget buildFirstPhone() {
    if (company.phonesArr.isEmpty) {
      return Row();
    }
    final phone = company.phonesArr[0];
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(-2, 0),
            blurRadius: 7,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            phoneMaskHelper(phone.digits ?? ''),
            style: const TextStyle(
              fontSize: 22.0,
            ),
          ),
          RoundedButtonWidget(
            text: const Text(
              'ПОЗВОНИТЬ',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            borderRadius: 8.0,
            color: companyCardBackgroudColor,
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
          ),
        ],
      ),
    );
  }

  Widget buildFirstAddress() {
    if (company.branchesArr.isEmpty) {
      return Column();
    }
    final branch = company.branchesArr[0];
    final branchesLen = company.branchesArr.length;

    return GestureDetector(
      onTap: () {
        widget.setStateCallback({'setPageview': 1});
      },
      child: Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(-2, 0),
              blurRadius: 7,
            ),
          ],
        ),
        child: Column(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                    Icons.domain,
                    size: 40.0,
                    color: addressIconColor,
                  ),
                  title: branch.mapAddress != null
                      ? Text(branch.mapAddress.toString())
                      : const Text(''),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SIZED_BOX_H12,
                      branchesLen > 1
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ещё ${branchesLen - 1}',
                                  style: const TextStyle(fontSize: 17.0),
                                ),
                                Row(
                                  children: const [
                                    Text(
                                      'показать все',
                                      style: TextStyle(fontSize: 17.0),
                                    ),
                                    Icon(Icons.arrow_forward_ios),
                                  ],
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                  /*
                    trailing: Icon(
                      Icons.chevron_right,
                    ),
                    */
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Column buildRubrics() {
    List<Widget> result = [];
    int rcount = 0;
    for (Catalogue rubric in company.rubricsArr) {
      rcount += 1;
      if (rcount > maxRubrics) {
        break;
      }
      result.add(SIZED_BOX_H06);
      result.add(Text(
        rubric.name ?? '',
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      ));
    }
    result.add(SIZED_BOX_H12);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: result,
    );
  }

  BoxDecoration buildCompanyHeader() {
    bool withBackgroundImage = company.getImagePath() != null;

    return BoxDecoration(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32.0),
        bottomRight: Radius.circular(32.0),
      ),
      color: companyCardBackgroudColor,
      image: withBackgroundImage
          ? DecorationImage(
              image: CachedNetworkImageProvider(company.getImagePath()!),
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2),
                BlendMode.dstATop,
              ),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            )
          : null,
    );
  }

  Widget buildCompanyCard() {
    return Column(
      children: [
        Container(
          decoration: buildCompanyHeader(),
          child: ListTile(
            minVerticalPadding: 20.0,
            leading: CompanyLogoWidget(company),
            title: Text(
              company.name ?? '',
              style: const TextStyle(
                fontSize: 24.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildRubrics(),
                /*
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Телефонов: ${company.phones}',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Адресов: ${company.branches}',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                */
                SIZED_BOX_H12,
                buildRating(),
              ],
            ),
          ),
        ),
        SIZED_BOX_H06,
        buildFirstPhone(),
        buildFirstAddress(),
        //buildBranchesRows(),
        /*
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Пожалуйста, оцените компанию, если вы покупатель товаров/услуг этой компании',
            style: TextStyle(color: Colors.black),
          ),
        ),
        RatingBar.builder(
          initialRating: 3,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            print(rating);
          },
        ),
        */
        /*
      ButtonBar(
        alignment: MainAxisAlignment.start,
        children: [
        ],
      ),
      */
      ],
    );
  }

  Widget buildCompanyView() {
    return SingleChildScrollView(
      child: buildCompanyCard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildCompanyView(),
    );
  }
}
