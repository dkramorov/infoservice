import 'package:flutter/material.dart';
import 'package:infoservice/models/dialpad_model.dart';
import 'package:infoservice/sip_ua/dialpad.dart';

import '../helpers/log.dart';
import '../services/jabber_manager.dart';
import '../services/sip_ua_manager.dart';
import '../settings.dart';

class DialpadScreen extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  final Object? _arguments;
  const DialpadScreen(this._sipHelper, this._xmppHelper, this._arguments,
      {Key? key})
      : super(key: key);
  static const String id = '/dialpad_screen';
  @override
  _DialpadScreen createState() => _DialpadScreen();
}

class _DialpadScreen extends State<DialpadScreen> {
  static const String TAG = 'DialpadScreen';

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  late DialpadModel? dialpadModel;

  @override
  initState() {
    super.initState();
    List args = (widget._arguments as Set).toList();
    for (Object? arg in args) {
      if (arg is DialpadModel) {
        dialpadModel = arg;
        Log.d(TAG, '---> call with ${dialpadModel.toString()}');
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: tealColor,
        title: const Text('Dialpad'),
      ),
      body: DialPadWidget(sipHelper, xmppHelper, dialpadModel: dialpadModel),
    );
  }
}
