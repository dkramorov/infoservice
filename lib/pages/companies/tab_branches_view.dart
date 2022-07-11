import 'package:flutter/material.dart';

import '../../models/companies/orgs.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../widgets/companies/branch_row.dart';
import '../../widgets/companies/catalogue_in_update.dart';

class TabBranchesView extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;

  final Function? setStateCallback;
  final PageController? pageController;
  final Orgs? company;

  TabBranchesView(this._sipHelper, this._xmppHelper,
      {this.pageController, this.setStateCallback, this.company});

  @override
  _TabBranchesViewState createState() => _TabBranchesViewState();
}

class _TabBranchesViewState extends State<TabBranchesView> {
  static const TAG = 'TabBranchesView';

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

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

  Widget buildBranches() {
    if (widget.company == null || widget.company?.branchesArr == null) {
      return CatalogueInUpdate();
    }

    return ListView.builder(
      itemCount: widget.company?.branchesArr.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        vertical: 15,
      ),
      itemBuilder: (context, index) {
        final item = widget.company?.branchesArr[index];
        return BranchRow(
          sipHelper,
          xmppHelper,
          item!,
          phones: widget.company?.phonesArr,
          company: widget.company,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PAD_SYM_H10,
      child: buildBranches(),
    );
  }
}
