import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
  static const headerImage = 'assets/svg/bp_header_login.svg';
  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  late StreamSubscription<bool>? jabberSubscription;

  @override
  initState() {
    super.initState();
    if (JabberManager.enabled) {
      jabberSubscription =
          xmppHelper?.jabberStream.registration.listen((isRegistered) {
            setState(() {});
            /*
          if (helper?.connectionStatus == XmppConnectionState.failed.toString()) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Ошибка подключения, проверьте логин и пароль'),
            ));
          }
          */
          });
    }
  }

  @override
  dispose() {
    jabberSubscription?.cancel();
    super.dispose();
  }

  bool isRegistered() {
    if (xmppHelper?.registered != null && xmppHelper?.registered == true) {
      return true;
    }
    return false;
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
                          isRegistered()
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
                      isRegistered()
                          ? SignOutFormWidget(xmppHelper?.getLogin(), () {
                              xmppHelper?.setStopFlag(true);
                              xmppHelper?.stop();

                              sipHelper?.setStopFlag(true);
                              sipHelper?.stop();
                            })
                          : SignInFormWidget(sipHelper, xmppHelper),
                      isRegistered()
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
