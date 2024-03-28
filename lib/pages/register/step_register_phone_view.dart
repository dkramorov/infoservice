import 'package:flutter/material.dart';

import '../../helpers/dialogs.dart';
import '../../helpers/log.dart';
import '../../helpers/phone_mask.dart';
import '../../models/registration_model.dart';
import '../../settings.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/rounded_input_text.dart';
import '../../widgets/submit_button.dart';

class StepRegisterPhoneView extends StatefulWidget {
  final PageController? pageController;
  final Function? setStateCallback;
  Map<String, dynamic>? userData;

  StepRegisterPhoneView(
      {Key? key, this.pageController, this.setStateCallback, this.userData})
      : super(key: key);

  @override
  _StepRegisterPhoneViewState createState() => _StepRegisterPhoneViewState();
}

class _StepRegisterPhoneViewState extends State<StepRegisterPhoneView> {
  final String TAG = 'StepRegisterPhoneView';
  final Duration _durationPageView = const Duration(milliseconds: 500);
  final Curve _curvePageView = Curves.easeInOut;
  final FocusScopeNode _scopeNode = FocusScopeNode();

  final GlobalKey<FormState> _regFormKey = GlobalKey<FormState>();

  static const _TOTAL_STEPS = 2;
  static const _CURRENT_STEP = 1;

  bool submitted = false;
  String _phone = '8';
  String _name = '';
  String _passwd = '';
  String _type = 'reg';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scopeNode.dispose();
  }

  backPageView() {
    Navigator.pop(context);
    _scopeNode.unfocus();
  }

  nextPageView() {
    widget.pageController
        ?.animateToPage(1, curve: _curvePageView, duration: _durationPageView);
    _scopeNode.unfocus();
  }

  /* Отправка формы регистрации */
  Future<void> regFormSubmit() async {
    if (!_regFormKey.currentState!.validate()) {
      return;
    }
    _regFormKey.currentState?.save();

    if (submitted) {
      return;
    }
    submitted = true;
    widget.setStateCallback!({
      'loading': true,
    });

    widget.userData!['phone'] = _phone;
    widget.userData!['name'] = _name;
    widget.userData!['passwd'] = _passwd;

    final RegistrationModel? reg =
        await RegistrationModel.requestRegistration(_phone, _name, _passwd);

    Log.d(TAG, reg.toString());
    if (reg != null && reg.id != null) {
      widget.userData!['isSimpleReg'] =
          (reg.isSimpleReg != null && reg.isSimpleReg == true);
      nextPageView();
    } else if (reg != null && reg.code == 429) {
      Future.delayed(Duration.zero, () {
        openInfoDialog(
          context,
          null,
          'Попробуйте поздже',
          reg.message ??
              'Мы уже отправили звонок на $_phone, если звонок не пришел, попробуйте через полчаса',
          'Понятно',
        );
      });
    } else {
      Future.delayed(Duration.zero, () {
        openInfoDialog(
          context,
          null,
          'Ошибка регистрации',
          'Не получен ответ от сервера, пожалуйста, попробуйте поздже',
          'Понятно',
        );
      });
    }
    widget.setStateCallback!({
      'loading': false,
    });
    Future.delayed(const Duration(seconds: 1), () {
      submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleTextStyle =
        Theme.of(context).textTheme.headline4?.copyWith(color: Colors.black);
    final subtitleTextStyle = Theme.of(context).textTheme.subtitle2;

    Map<dynamic, dynamic> arguments = <dynamic, dynamic>{};
    if (ModalRoute.of(context)?.settings.arguments != null) {
      arguments = ModalRoute.of(context)?.settings.arguments as Map;
      _type = arguments['type'];
    }

    return Container(
      margin: PAD_ONLY_T40,
      padding: PAD_SYM_H20,
      child: Center(
        child: ListView(
          children: [
            PageViewProgressBar(
              backPageView: () => backPageView(),
              nextPageView: () => nextPageView(),
              totalStep: _TOTAL_STEPS,
              currentStep: _CURRENT_STEP,
            ),
            SIZED_BOX_H30,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _type == 'reg' ? 'Регистрация' : 'Восстановление пароля',
                  style: titleTextStyle,
                  textAlign: TextAlign.center,
                ),
                SIZED_BOX_H30,
                Text(
                  'Введите ваш номер телефона, запросите код, '
                  'вам поступит звонок, '
                  'в звонке будет продиктован код подтверждения. '
                  'Либо придет sms сообщение, '
                  'в котором будет код подтверджения',
                  style: subtitleTextStyle?.copyWith(
                      color: const Color(0xFF95A0AF)),
                  textAlign: TextAlign.center,
                ),
                SIZED_BOX_H30,
                Form(
                  key: _regFormKey,
                  child: Column(
                    children: [
                      RoundedInputText(
                        hint: 'Ваш телефон',
                        onChanged: (String? text) {
                          setState(() {
                            _phone = text ?? '';
                          });
                        },
                        formatters: [PhoneFormatter()],
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) {
                            return 'Например, 89148223223';
                          }
                          bool match =
                              phoneMaskValidator().hasMatch(value ?? '');
                          if (!match) {
                            return '11 цифр, например, 89148223223';
                          }
                        },
                        keyboardType: TextInputType.number,
                        defaultValue: _phone,
                        prefixIcon: const Icon(Icons.phone_android),
                        textAlign: TextAlign.left,
                      ),
                      SIZED_BOX_H30,
                      RoundedInputText(
                        hint: 'Ваше имя',
                        onChanged: (String? text) {
                          setState(() {
                            _name = text ?? '';
                          });
                        },
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) {
                            return 'Введите ваше имя';
                          }
                        },
                        defaultValue: _name,
                        prefixIcon: const Icon(Icons.account_circle_rounded),
                        textAlign: TextAlign.left,
                      ),
                      SIZED_BOX_H30,
                      RoundedInputText(
                        hint: 'Ваш пароль',
                        onChanged: (String? text) {
                          setState(() {
                            _passwd = text ?? '';
                          });
                        },
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) {
                            return 'Придумайте ваш пароль';
                          }
                        },
                        defaultValue: _passwd,
                        prefixIcon: const Icon(Icons.shield),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SIZED_BOX_H30,
            Center(
              child: SubmitButton(
                text: 'Запросить код',
                onPressed: () {
                  regFormSubmit();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
