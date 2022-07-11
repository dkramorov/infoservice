import 'package:flutter/material.dart';

import '../../models/companies/phones.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../widgets/companies/cat_row.dart';
import '../../widgets/companies/company_row.dart';
import 'catalogue.dart';
import 'orgs.dart';

class SearchModel {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Function setStateCallback;

  SearchModel({this.sipHelper, this.xmppHelper, required this.setStateCallback});

  String _query = '';
  String get query => _query;

  List<Widget> searchResult = [];

  Future<void> onQueryChanged(String query) async {
    if (query == _query) {
      return;
    }
    _query = query;
    if (query.isEmpty) {
      searchResult.clear();
      setStateCallback(
          {'searchResult': searchResult, 'searchProcessing': false});
      return;
    } else {
      setStateCallback({'searchProcessing': true});

      searchResult.clear();
      // Поиск по рубрикам
      final searchCatalogue = await Catalogue().searchCatalogue(query);
      final searchOrgs = await Orgs().searchOrgs(query);

      final searchPhones = await Phones().searchPhones(query);
      final orgsByPhones = await Orgs().getOrgsByPhones(searchPhones);

      final int catLen = searchCatalogue.length;
      final int orgsLen = searchOrgs.length;
      final int orgsByPhonesLen = orgsByPhones.length;

      final int totalLen = catLen + orgsLen + orgsByPhonesLen;
      searchResult = List.generate(totalLen, (i) {
        if (i >= catLen + orgsLen) {
          int j = i - (catLen + orgsLen);
          Orgs company = orgsByPhones[j];
          return SizedBox(
            width: double.infinity,
            child: CompanyRow(sipHelper, xmppHelper, company),
          );
        } else if (i >= catLen) {
          int j = i - catLen;
          Orgs company = searchOrgs[j];
          return SizedBox(
            width: double.infinity,
            child: CompanyRow(sipHelper, xmppHelper, company),
          );
        } else {
          Catalogue cat = searchCatalogue[i];
          return SizedBox(
            width: double.infinity,
            child: CatRow(sipHelper, xmppHelper, cat),
          );
        }
      });
    }
    setStateCallback({'searchResult': searchResult, 'searchProcessing': false});
  }
}
