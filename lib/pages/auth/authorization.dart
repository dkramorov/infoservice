import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:infoservice/models/user_settings_model.dart';
import 'package:infoservice/pages/static_values.dart';
import 'package:infoservice/pages/themes.dart';
import 'package:infoservice/settings.dart';

import '../../helpers/dialogs.dart';
import '../../helpers/log.dart';
import '../../helpers/phone_mask.dart';
import '../../helpers/string_parser.dart';
import '../../models/bg_tasks_model.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../widgets/auth/oauth_buttons.dart';
import '../../widgets/password_eye_widget.dart';
import '../../widgets/reg_links.dart';
import '../../widgets/text_field_custom.dart';
import '../app_asset_lib.dart';
import '../../navigation/custom_app_bar_button.dart';
import '../../widgets/button.dart';

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

  final phone = MaskedTextController(mask: '8 (900) 000-00-00');
  final password = TextEditingController();
  bool loading = false;
  final formKey = GlobalKey<FormState>();
  bool hidePassword = true;

  /* Отправка формы авторизации */
  Future<void> loginFormSubmit() async {
    formKey.currentState!.save();

    if (!formKey.currentState!.validate()) {
      return;
    }
    setState(() => loading = true);

    Map<String, dynamic> userData = {
      'login': cleanPhone(phone.text),
      'passwd': password.text,
    };
    UserSettingsModel? user = await UserSettingsModel().getUser();
    if (user != null) {
      Log.d('loginFormSubmit', 'check account for drop => ${user.isDropped}');
      if (user.isDropped != null && user.isDropped!) {
        if (mounted) {
          openInfoDialog(
              context,
              () {},
              'Аккаунт удален',
              'К сожалению, нельзя войти, воспользуйтесь регистрацией',
              'Хорошо');
          return;
        }
      }
    }
    /* Задача на проверку авторизации в фоне
       после выполнения успешной,
       остальные запросы на авторизацию должны быть удалены
    */
    await BGTasksModel.createRegisterTask(userData);
    // Ожидаем результат в authorization.dart
  }

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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const CustomAppBarButton(asset: AssetLib.closeButton),
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
                    SIZED_BOX_W04,
                    GoogleOauthButton(),
                  ]),
              SIZED_BOX_H24,
              Center(
                child: Text(
                  'Войти по паролю',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: w500,
                    color: black,
                  ),
                ),
              ),
              SIZED_BOX_H12,
              SizedBox(
                child: Text(
                  'Войдите или зарегистрируйтесь, чтобы начать звонить и общаться',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: w400,
                    color: gray100,
                  ),
                ),
              ),
              SIZED_BOX_H24,
              TextFieldCustom(
                labelText: 'Номер телефона',
                controller: phone,
                keyboardType: TextInputType.phone,
                validator: (value) => validatePhone(cleanUpPhone(value)),
              ),
              ...[
                SIZED_BOX_H16,
                TextFieldCustom(
                  labelText: 'Пароль',
                  controller: password,
                  keyboardType: TextInputType.text,
                  obscureText: hidePassword,
                  suffix: PasswordEyeWidget(
                    hidePassword,
                    onPressed: () =>
                        setState(() => hidePassword = !hidePassword),
                  ),
                  validator: validatePassword,
                ),
              ],
              SIZED_BOX_H24,
              SizedBox(
                child: PrimaryButton(
                  loading: loading,
                  onPressed: () async {
                    await loginFormSubmit();
                  },
                  color: blue,
                  child: Text(
                    'Войти',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: w500,
                      color: white,
                    ),
                  ),
                ),
              ),
              SIZED_BOX_H16,
              RegLinksWidget(sipHelper, xmppHelper),
              SIZED_BOX_H45,
            ],
          ),
        ),
      ),
    );

    /* Старый вариант
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
    */
  }
}
