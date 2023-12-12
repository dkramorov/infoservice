import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/dialogs.dart';
import '../../models/bg_tasks_model.dart';
import '../../services/jabber_manager.dart';
import '../../services/shared_preferences_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../widgets/rounded_button_widget.dart';
import '../../widgets/rounded_input_text.dart';

class TabAddMuc extends StatefulWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Function setStateCallback;
  final PageController pageController;

  const TabAddMuc(
      {this.sipHelper,
      this.xmppHelper,
      required this.pageController,
      required this.setStateCallback,
      Key? key})
      : super(key: key);

  @override
  State<TabAddMuc> createState() => _TabAddMucState();
}

class _TabAddMucState extends State<TabAddMuc> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static const tag = 'TabAddMuc';
  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;
  late Timer updateTimer;

  String newMuc = '';

  @override
  void dispose() {
    updateTimer.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      updateTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
        await checkNewGroup();
      });
    });
  }

  Future<void> checkNewGroup() async {
    SharedPreferences prefs = await SharedPreferencesManager.getSharedPreferences();
    bool? addMUCResult = prefs.getBool(BGTasksModel.addRosterPrefKey);
    if (addMUCResult != null) {
      if (addMUCResult) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Группа $newMuc добавлена'),
            ),
          );
        }
        Future.delayed(Duration.zero, () async {
          Navigator.pop(context);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Группа $newMuc не найдена'),
            ),
          );
        }
      }
      await prefs.remove(BGTasksModel.addRosterPrefKey);
    }
  }

  /* Отправка формы создания MUC */
  Future<void> addMUCFormSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState?.save();
    await showLoading();
    SharedPreferences prefs = await SharedPreferencesManager.getSharedPreferences();
    await prefs.remove(BGTasksModel.addRosterPrefKey);
    BGTasksModel.addMUCTask({
      'group': newMuc,
    });
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
                    onPressed: () async {
                      await addMUCFormSubmit();
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
