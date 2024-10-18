import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../helpers/dialogs.dart';
import '../../models/registration_model.dart';
import '../../settings.dart';
import '../../widgets/button.dart';
import '../../widgets/pin_code.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/submit_button.dart';
import '../../navigation/custom_app_bar_button.dart';
import '../themes.dart';

class StepConfirmPhoneView extends StatefulWidget {
  final Function? setStateCallback;
  final PageController? pageController;
  Map<String, dynamic>? userData;

  StepConfirmPhoneView(
      {Key? key, this.pageController, this.setStateCallback, this.userData})
      : super(key: key);

  @override
  _StepConfirmPhoneViewState createState() => _StepConfirmPhoneViewState();
}

class _StepConfirmPhoneViewState extends State<StepConfirmPhoneView> {
  final Duration _durationPageView = const Duration(milliseconds: 500);
  final Curve _curvePageView = Curves.easeInOut;

  static const _TOTAL_STEPS = 2;
  static const _CURRENT_STEP = 2;
  static const _OTP_SIZE = 4;
  List<OtpField> otpList = [];

  // This use to switch from a TextField to anothers.
  final FocusScopeNode _scopeNode = FocusScopeNode();

  int _secondsRemaining = 60;
  bool _isCountdownComplete = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    if (mounted) setState(() {});
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isCountdownComplete = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scopeNode.dispose();
  }

  /* Отправка формы кода подтверждения */
  Future<void> regConfirmCodeFormSubmit(String confirmCode) async {
    if (widget.userData!['phone'] == null) {
      openInfoDialog(
        context,
        null,
        'Не введен номер телефона',
        'Вернитесь к вводу номера телефона',
        'Понятно',
      );
      return;
    }

    //String confirmCode = getOtpValue();
    if (confirmCode.length != _OTP_SIZE) {
      openInfoDialog(
        context,
        null,
        'Не введен проверочный код',
        'Введите 4 цифры проверочного кода, который вы получили по телефону',
        'Понятно',
      );
      return;
    }

    widget.setStateCallback!({
      'loading': true,
    });

    final confirm = await RegistrationModel.confirmRegistration(
        widget.userData!['phone'],
        confirmCode,
        widget.userData!['isSimpleReg']);
    if (confirm != null && confirm.message != null && mounted) {
      if (confirm.code == RegistrationModel.CODE_PASSWD_CHANGED) {
        await userConfirmed();
        //await showDialog(confirm.getMessage(), userConfirmed);
      } else if (confirm.code == RegistrationModel.CODE_REGISTRATION_SUCCESS) {
        await userConfirmed();
        //await showDialog(confirm.getMessage(), userConfirmed);
      } else if (confirm.code == RegistrationModel.CODE_ERROR) {
        await showDialog(confirm.getMessage(), nextPageView);
      } else if (confirm.code == RegistrationModel.TOO_MANY_ATTEMPTS) {
        await showDialog(confirm.getMessage(), nextPageView,
            title: 'Слишком много попыток');
      }
    }
    widget.setStateCallback!({
      'loading': false,
    });
  }

  Future<void> showDialog(String message, Function function,
      {String title = 'Ответ от сервера'}) async {
    Future.delayed(Duration.zero, () async {
      await openInfoDialog(context, function, title, message, 'Понятно');
    });
  }

  /* Регистрация пройдена или
     паролька изменена,
     записываем пользователя
     переходим на авторизацию (а автологином)
   */
  Future<void> userConfirmed() async {
    widget.setStateCallback!({
      'userConfirmed': true,
    });
    Future.delayed(Duration.zero, () {
      Navigator.pop(context, const Text('userConfirmed'));
    });
  }

  // Get value of OTP when user done
  String getOtpValue() {
    String otpString = '';
    for (var otp in otpList) {
      otpString = otp.value != null ? otpString += otp.value! : otpString;
    }
    return otpString;
  }

  otpGenerate(int length) => List<OtpField>.generate(length, (index) {
        if (index == 0) {
          return OtpField(isStart: true, onFocus: true);
        } else {
          return OtpField();
        }
      })
        ..forEach((otp) {
          otp.scopeNode = _scopeNode;
          otpList.add(otp);
        })
        ..last.isEnd = true;

  // Back the previous PageView
  void backPageView() {
    widget.pageController
        ?.animateToPage(0, curve: _curvePageView, duration: _durationPageView);
    _scopeNode.unfocus();
  }

  // Forward the next PageView
  void nextPageView() {
    widget.pageController
        ?.animateToPage(2, curve: _curvePageView, duration: _durationPageView);
    _scopeNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    String minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    String seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Container(
        color: white,
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 54),
              Container(
                width: size.width - 32,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomAppBarButton(),
                  ],
                ),
              ),
              const SizedBox(height: 98),
              Text(
                'Проверочный код',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: w500,
                  color: black,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: size.width * 0.8,
                child: Text(
                  'Введите код продиктованный нашим роботом помощником',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: w400,
                    color: gray100,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PinCodeTextField(
                    pinTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: w400,
                      color: black,
                    ),
                    onDone: (text) async {
                      await regConfirmCodeFormSubmit(text);
                      /*
                      confirmRegistration(widget.phone, text)
                          .then((value) async {
                        print(value.data);
                        if (value.statusCode == 200) {
                          SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                          name = widget.name;
                          myPhone = widget.phone;
                          email = widget.phone;
                          pass = widget.pass;
                          if (mounted) setState(() {});
                          prefs.setString('name', widget.name);
                          prefs.setString('phone', widget.phone);
                          prefs.setString('email', widget.email);
                          prefs
                              .setString('password', widget.pass)
                              .then((value) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (c) => const Index(
                                  null, null, null,
                                ),
                              ),
                            );
                          });
                        } else if (value.statusCode == 429) {
                          /*
                          showOverlayNotification((context) {
                            return ErrorAlert(
                              text:
                                  "Слишком много попыток, повторите регистрацию через полчаса",
                              color: error100,
                            );
                          });
                          */
                        }
                      });
                      */
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: size.width - 60,
                child: PrimaryButton(
                  onPressed: _isCountdownComplete
                      ? () {
                    _secondsRemaining = 60;
                    _isCountdownComplete = false;
                    _startCountdown();
                    setState(() {});
                  }
                      : () {},
                  color: _isCountdownComplete ? blue : surfacePrimary,
                  child: Text(
                    _isCountdownComplete
                        ? 'Получить новый код'
                        : 'Получить новый код через $minutes:$seconds',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: w500,
                      color: _isCountdownComplete
                          ? white
                          : const Color.fromRGBO(192, 193, 195, 1),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );

    /* /// Старый вариант
    final titleTextStyle =
        Theme.of(context).textTheme.headline4?.copyWith(color: Colors.black);
    final subtitleTextStyle = Theme.of(context).textTheme.subtitle2;

    final screenWidth = MediaQuery.of(context).size.width;

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
                  'Подтвердите телефон',
                  style: titleTextStyle,
                  textAlign: TextAlign.center,
                ),
                SIZED_BOX_H30,
                Text(
                  widget.userData!['isSimpleReg'] == true
                      ? 'Введите проверочный код, '
                          'который вы прослушали если вам поступил звонок. '
                          'Либо, если вам поступило sms сообщение, '
                          'введите проверочный код из него'
                      : 'Введите проверочный код, '
                          'который вы прослушали если вам поступил звонок. '
                          'Либо, если вам поступило sms сообщение, '
                          'введите проверочный код из него',
                  style: subtitleTextStyle?.copyWith(
                      color: const Color(0xFF95A0AF), height: 1.5),
                  textAlign: TextAlign.center,
                ),
                SIZED_BOX_H30,
                Container(
                  margin: PAD_SYM_V20,
                  alignment: Alignment.center,
                  width: screenWidth / 2,
                  child: FocusScope(
                    node: _scopeNode,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: otpGenerate(_OTP_SIZE),
                    ),
                  ),
                ),
                /*
                SIZED_BOX_H30,
                Text(
                  SGP_RESEND_TEXT,
                  style: _sgpSendMessageTextStyle.copyWith(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 */
              ],
            ),
            SIZED_BOX_H30,
            Center(
              child: SubmitButton(
                text: 'Подтвердить',
                onPressed: () {
                  regConfirmCodeFormSubmit();
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

class OtpField extends StatefulWidget {
  OtpField({
    Key? key,
    this.isEnd = false,
    this.isStart = false,
    this.scopeNode,
    this.onFocus = false,
    this.value,
  }) : super(key: key);
  bool isStart;
  bool isEnd;
  FocusScopeNode? scopeNode;
  bool onFocus;
  String? value;

  @override
  _OtpFieldState createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  hideHasValueBox(String value) {
    // Set value for parent get OTP when user done
    setState(() {
      widget.value = value.isNotEmpty ? value : null;
    });

    // When user type a TextField, If that Input have a value, forward next one.
    // When user remove a value in TextField, backward previous one
    if (widget.value != null) {
      if (!widget.isEnd) {
        widget.scopeNode?.nextFocus();
      } else {
        widget.scopeNode?.unfocus();
      }
    } else if (!widget.isStart) {
      widget.scopeNode?.previousFocus();
    } else {
      widget.scopeNode?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 6,
          left: 10,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.value != null
                  ? Colors.transparent
                  : disabledButtonColor,
            ),
          ),
        ),
        // Main TextField for OTP
        SizedBox(
          width: 40.0,
          height: 40.0,
          child: TextField(
            // Input acceptable for number and only 1 number for each TextField
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
              LengthLimitingTextInputFormatter(1),
            ],
            autofocus: widget.onFocus,
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.center,
            cursorHeight: 0,
            cursorColor: Colors.transparent,
            cursorWidth: 0,
            style: Theme.of(context).textTheme.headline3,
            keyboardType: TextInputType.number,
            onChanged: (value) => hideHasValueBox(value),
          ),
        ),
      ],
    );
  }
}
