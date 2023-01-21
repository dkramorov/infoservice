import 'package:flutter/material.dart';

import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../widgets/rounded_button_widget.dart';
import '../../widgets/rounded_input_text.dart';

class TabAddMuc extends StatefulWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Function setStateCallback;
  final PageController pageController;

  const TabAddMuc({
    this.sipHelper,
    this.xmppHelper,
    required this.pageController,
    required this.setStateCallback,
    Key? key
  }) : super(key: key);

  @override
  State<TabAddMuc> createState() => _TabAddMucState();
}

class _TabAddMucState extends State<TabAddMuc> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static const TAG = 'TabAddMuc';
  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;

  String newMuc = '';

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

  /* Отправка формы создания MUC */
  void addMUCFormSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState?.save();
    if (xmppHelper == null) {
      return;
    }
    if (newMuc.isNotEmpty) {
      //String me = '${cleanPhone(xmppHelper!.getLogin())}@$JABBER_SERVER';
      xmppHelper!.createMUC(newMuc, true).then((createMucResult) { // Создаем MUC
        xmppHelper!.joinMucGroup(newMuc).then((joinMucResult) { // Прикрепиться к MUC
          xmppHelper!.group2VCard(newMuc);
          //xmppHelper!.addAdminsInGroup(newMuc, [me]); // Добавиться админом
          //xmppHelper!.getMembers(newMuc);
          //xmppHelper!.getAdmins(newMuc);
          //xmppHelper!.getOwners(newMuc);
          //xmppHelper!.removeMember(newMuc, [me]);
        });
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 40.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 15.0,
            ),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Добавление новой группы',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  RoundedInputText(
                    hint: 'Название группы',
                    onChanged: (String? text) {
                      setState(() {
                        newMuc = text ?? '';
                      });
                    },
                    validator: (String? value) {
                      String v = value ?? '';
                      if (v.trim().isEmpty) {
                        return 'Введите название группы';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    defaultValue: newMuc,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  RoundedButtonWidget(
                    text: const Text(
                      'Добавить',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: tealColor,
                    onPressed: () {
                      addMUCFormSubmit();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


