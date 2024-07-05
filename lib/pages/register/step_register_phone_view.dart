import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

import '../../helpers/dialogs.dart';
import '../../helpers/log.dart';
import '../../helpers/phone_mask.dart';
import '../../helpers/string_parser.dart';
import '../../models/registration_model.dart';
import '../../settings.dart';
import '../../widgets/auth/yandex_oauth_button.dart';
import '../../widgets/button.dart';
import '../../widgets/password_eye_widget.dart';
import '../../widgets/switcher.dart';
import '../../widgets/terms_widget.dart';
import '../../widgets/text_field_custom.dart';
import '../app_asset_lib.dart';
import '../back_button_custom.dart';
import '../static_values.dart';
import '../themes.dart';

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

  //final GlobalKey<FormState> _regFormKey = GlobalKey<FormState>();

  static const _TOTAL_STEPS = 2;
  static const _CURRENT_STEP = 1;

  bool submitted = false;
  /*
  String _phone = '8';
  String _name = '';
  String _passwd = '';
  String _type = 'reg';
  */

  final phone = MaskedTextController(mask: '8 (900) 000-00-00');

  bool _value1 = false;
  TextEditingController name = TextEditingController(),
      email = TextEditingController(),
      pass = TextEditingController();
  bool loading = false;
  final formKey = GlobalKey<FormState>();
  bool hidePassword = true;

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
    formKey.currentState!.save();
    if (!formKey.currentState!.validate()) {
      return;
    }
    if (submitted) {
      return;
    }
    submitted = true;
    widget.setStateCallback!({
      'loading': true,
    });

    widget.userData?['phone'] = cleanPhone(phone.text);
    widget.userData?['name'] = name.text;
    widget.userData?['passwd'] = pass.text;

    final RegistrationModel? reg = await RegistrationModel.requestRegistration(
        widget.userData?['phone'],
        widget.userData?['name'],
        widget.userData?['passwd'],
    );

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
              'Мы уже отправили звонок на ${phone.text}, '
              'если звонок не пришел, попробуйте через полчаса',
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
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarButtonCustom(asset: AssetLib.closeButton),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: UIs.signupPagePadding),
          child: ListView(
            children: [
              const SizedBox(height: 32),
              SizedBox(
                width: 64,
                height: 64,
                child: Image.asset(AssetLib.logo),
              ),
              SIZED_BOX_H24,
              Center(
                child: Text(
                  'Войти через',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: w500,
                    color: black,
                  ),
                ),
              ),
              SIZED_BOX_H12,
              const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    YandexOauthButton(),
                  ]),
              SIZED_BOX_H24,
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "Регистрация",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: w500,
                    color: black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                child: Text(
                  "Зарегистрируйтесь, чтобы начать звонить и общаться",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: w400,
                    color: gray100,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFieldCustom(
                labelText: 'Ваше имя',
                controller: name,
                keyboardType: TextInputType.name,
                validator: validateName,
              ),
              const SizedBox(height: 16),
              TextFieldCustom(
                labelText: 'Телефон',
                controller: phone,
                keyboardType: TextInputType.phone,
                validator: (value) => validatePhone(cleanUpPhone(value)),
              ),
              const SizedBox(height: 16),
              /*
              TextFieldCustom(
                labelText: "E-mail",
                controller: email,
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 16),
              */
              TextFieldCustom(
                labelText: 'Пароль',
                controller: pass,
                keyboardType: TextInputType.text,
                obscureText: hidePassword,
                validator: validatePassword,
                suffix: PasswordEyeWidget(
                  hidePassword,
                  onPressed: () => setState(() => hidePassword = !hidePassword),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TermsWidget(),
                  CustomSwitch(
                    onChange: (c) {
                      _value1 = !_value1;
                      setState(() {});
                    },
                    value: _value1,
                  )
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: () async {
                  await regFormSubmit();
                },
                color: blue,
                child: Text(
                  'Зарегистрироваться',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: w500,
                    color: white,
                  ),
                ),
              ),
              SIZED_BOX_H30,
            ],
          ),
        ),
      ),
    );

    /* /// Старый вариант
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
    */
  }
}
