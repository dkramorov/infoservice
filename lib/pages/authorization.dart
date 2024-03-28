import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infoservice/models/bg_tasks_model.dart';
import 'package:infoservice/models/user_settings_model.dart';

import '../helpers/dialogs.dart';
import '../helpers/log.dart';
import '../services/jabber_manager.dart';
import '../services/sip_ua_manager.dart';
import '../settings.dart';
import '../widgets/reg_links.dart';
import '../widgets/sign_in_form.dart';
import '../widgets/sign_out_form.dart';

class AuthScreenWidget extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  const AuthScreenWidget(this._sipHelper, this._xmppHelper, {Key? key})
      : super(key: key);
  static const String id = '/create_account';

  @override
  _AuthScreenWidgetState createState() => _AuthScreenWidgetState();
}

class _AuthScreenWidgetState extends State<AuthScreenWidget> {
  static const String tag = 'AuthScreenWidget';
  static const headerImage = 'assets/svg/bp_header_login.svg';
  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  late Timer updateTimer;
  bool isRegistered = false;
  String login = '';

  Future<void> checkUser() async {
    UserSettingsModel? user = await UserSettingsModel().getUser();
    if (user != null) {
      if (isRegistered != (user.isXmppRegistered == 1)) {
        Log.d(tag,
            'isRegistered changed $isRegistered=>${user.isXmppRegistered}');
        setState(() {
          isRegistered = user.isXmppRegistered == 1;
        });
      }
      if (login != user.phone) {
        setState(() {
          login = user.phone ?? '';
        });
      }
      Future.delayed(Duration.zero, () async {
        if (isRegistered) {
          Navigator.popUntil(context, (route) => (route.isFirst));
        }
      });
    } else {
      if (login != '') {
        setState(() {
          login = '';
        });
      }
      if (isRegistered) {
        setState(() {
          isRegistered = false;
        });
      }
    }
  }

  @override
  initState() {
    super.initState();
    showLoading(removeAfterSec: 1);
    Future.delayed(Duration.zero, () async {
      updateTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
        await checkUser();
      });
    });
  }

  @override
  dispose() {
    updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline5;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: SvgPicture.asset(
                  headerImage,
                  alignment: Alignment.bottomCenter,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: PAD_SYM_H30,
                child: Center(
                  child: Column(
                    children: [
                      SIZED_BOX_H30,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Image(
                            image: AssetImage('assets/misc/icon.png'),
                            height: 80.0,
                            fit: BoxFit.fill,
                          ),
                          isRegistered
                              ? Container(
                                  margin: PAD_SYM_V20,
                                  child: Text(
                                    '8800 help',
                                    style: titleStyle,
                                  ),
                                )
                              : Container(
                                  margin: PAD_SYM_V20,
                                  child: Text(
                                    'Регистрация',
                                    style: titleStyle,
                                  ),
                                ),
                        ],
                      ),
                      SIZED_BOX_H30,
                      isRegistered
                          ? SignOutFormWidget(login, () async {
                              await showLoading(removeAfterSec: 3);
                              await BGTasksModel.createUnregisterTask();
                            })
                          : SignInFormWidget(sipHelper, xmppHelper),
                      isRegistered
                          ? Container()
                          : RegLinksWidget(sipHelper, xmppHelper),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
