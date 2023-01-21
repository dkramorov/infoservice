import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sip_ua/sip_ua.dart';

import '../services/jabber_manager.dart';
import '../services/sip_ua_manager.dart';
import '../settings.dart';

class RegisterWidget extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;

  const RegisterWidget(this._sipHelper, this._xmppHelper, {Key? key}) : super(key: key);
  static const String id = '/register';
  @override
  _MyRegisterWidget createState() => _MyRegisterWidget();
}

class _MyRegisterWidget extends State<RegisterWidget>
    implements SipUaHelperListener {
  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _wsUriController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _authorizationUserController =
      TextEditingController();
  final Map<String, String> _wsExtraHeaders = {};
  late SharedPreferences _preferences;
  late RegistrationState _registerState;

  @override
  initState() {
    super.initState();
    _registerState = sipHelper!.registerState;
    sipHelper!.addSipUaHelperListener(this);
    _loadSettings();
  }

  @override
  dispose() {
    super.dispose();
    sipHelper!.removeSipUaHelperListener(this);
    _saveSettings();
  }

  void _loadSettings() async {
    _preferences = await sipHelper!.loadSettings();
    setState(() {
      _wsUriController.text =
          _preferences.getString('ws_uri') ?? SIP_WSS;
      _displayNameController.text =
          _preferences.getString('display_name') ?? '89148959223';
      _passwordController.text = _preferences.getString('password') ?? '111';
      _authorizationUserController.text =
          _preferences.getString('auth_user') ?? '';
    });
  }

  void _saveSettings() {
    _preferences.setString('ws_uri', _wsUriController.text);
    _preferences.setString('display_name', _displayNameController.text);
    _preferences.setString('password', _passwordController.text);
    _preferences.setString('auth_user', _authorizationUserController.text);
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    setState(() {
      _registerState = state;
    });
  }

  void _alert(BuildContext context, String alertFieldName) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$alertFieldName is empty'),
          content: Text('Please enter $alertFieldName!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleSave(BuildContext context) {
    if (_wsUriController.text == '') {
      _alert(context, "WebSocket URL");
    }
    sipHelper!.saveSettings(
      webSocketUrl: _wsUriController.text,
      extraHeaders: _wsExtraHeaders,
      authorizationUser: _authorizationUserController.text,
      password: _passwordController.text,
      displayName: _displayNameController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: tealColor,
          title: const Text("SIP Аккаунт"),
        ),
        body: ListView(children: [
          Align(
              alignment: const Alignment(0, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(48.0, 18.0, 48.0, 18.0),
                          child: Center(
                              child: Text(
                            'Статус регистрации: ${EnumHelper.getName(_registerState.state)}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black54),
                          )),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(48.0, 18.0, 48.0, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('WebSocket:'),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
                          child: TextFormField(
                            controller: _wsUriController,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                              border: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Пользователь:'),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
                          child: TextFormField(
                            controller: _authorizationUserController,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10.0),
                              border: const UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black12)),
                              hintText:
                                  _authorizationUserController.text.isEmpty
                                      ? '[Empty]'
                                      : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Пароль:'),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
                          child: TextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10.0),
                              border: const UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black12)),
                              hintText: _passwordController.text.isEmpty
                                  ? '[Empty]'
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Имя:'),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 10.0),
                          child: TextFormField(
                            controller: _displayNameController,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                              border: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(
                        height: 48.0,
                        width: 140.0,
                        child: MaterialButton(
                          color: tealColor,
                          textColor: Colors.white,
                          onPressed: () => _handleSave(context),
                          child: const Text(
                            'Регистрация',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      SizedBox(
                        height: 48.0,
                        width: 140.0,
                        child: MaterialButton(
                          color: tealColor,
                          textColor: Colors.white,
                          onPressed: () => sipHelper!.stop(),
                          child: const Text(
                            'Выход',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ])
                  ])),
        ]));
  }

  @override
  void callStateChanged(Call call, CallState state) {}

  @override
  void transportStateChanged(TransportState state) {}

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void onNewNotify(Notify ntf) {
    // TODO: implement onNewNotify
  }
}
