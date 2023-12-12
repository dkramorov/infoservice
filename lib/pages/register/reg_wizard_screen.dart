import 'package:flutter/material.dart';
import 'package:infoservice/pages/register/step_confirm_phone_view.dart';
import 'package:infoservice/pages/register/step_register_phone_view.dart';

import '../../models/bg_tasks_model.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';

class RegWizardScreenWidget extends StatefulWidget {
  static const String id = '/reg_wizard_screen/';
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  const RegWizardScreenWidget(this._sipHelper, this._xmppHelper, {Key? key}) : super(key: key);

  @override
  _RegWizardScreenWidgetState createState() => _RegWizardScreenWidgetState();
}

class _RegWizardScreenWidgetState extends State<RegWizardScreenWidget> {

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  bool loading = false;
  Map<String, dynamic> userData = {};

  final PageController _pageController = PageController(
    initialPage: 0,
    keepPage: false,
  );

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void setStateCallback(Map<String, dynamic> newState) {
    if (newState['loading'] != null && newState['loading'] != loading) {
      setState(() {
        loading = newState['loading'];
      });
    }
    if (newState['userConfirmed'] != null && newState['userConfirmed']) {
      userData['login'] = userData['phone'];
      BGTasksModel.createRegisterTask(userData);

      //xmppHelper?.changeSettings(userData);
      //sipHelper?.changeSettings(userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _pageViewBuilder(_, index) {
      switch (index) {
        case 1:
          return StepConfirmPhoneView(
            pageController: _pageController,
            setStateCallback: setStateCallback,
            userData: userData,
          );
        default:
          return StepRegisterPhoneView(
            pageController: _pageController,
            setStateCallback: setStateCallback,
            userData: userData,
          );
      }
    }

    return Scaffold(
      body: SafeArea(
          child: PageView.builder(
            itemCount: 2,
            itemBuilder: _pageViewBuilder,
            controller: _pageController,
          ),
        ),
    );
  }
}
