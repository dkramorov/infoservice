import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/dialogs.dart';
import '../../models/registration_model.dart';
import '../../settings.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/submit_button.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scopeNode.dispose();
  }

  /* Отправка формы кода подтверждения */
  Future<void> regConfirmCodeFormSubmit() async {
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
    String confirmCode = getOtpValue();
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
        widget.userData!['phone'], confirmCode, widget.userData!['isSimpleReg']);
    if (confirm != null && confirm.message != null && mounted) {
      if (confirm.code == RegistrationModel.CODE_PASSWD_CHANGED) {
        await cleanAccount();
        openInfoDialog(context, userConfirmed, 'Ответ от сервера',
            confirm.getMessage(), 'Понятно');
      } else if (confirm.code == RegistrationModel.CODE_REGISTRATION_SUCCESS) {
        await cleanAccount();
        openInfoDialog(context, userConfirmed, 'Ответ от сервера',
            confirm.getMessage(), 'Понятно');
      } else if (confirm.code == RegistrationModel.CODE_ERROR) {
        openInfoDialog(context, nextPageView, 'Ответ от сервера',
            confirm.getMessage(), 'Понятно');
      } else if (confirm.code == RegistrationModel.TOO_MANY_ATTEMPTS) {
        openInfoDialog(context, nextPageView, 'Слишком много попыток',
            confirm.getMessage(), 'Понятно');
      }
    }
    widget.setStateCallback!({
      'loading': false,
    });
  }

  Future<void> cleanAccount() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(widget.userData!['phone']);
    print('account cleaned ${widget.userData!['phone']}');
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
      Navigator.pop(context);
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
  backPageview() {
    widget.pageController
        ?.animateToPage(0, curve: _curvePageView, duration: _durationPageView);
    _scopeNode.unfocus();
  }

  // Forward the next PageView
  nextPageView() {
    widget.pageController
        ?.animateToPage(2, curve: _curvePageView, duration: _durationPageView);
    _scopeNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
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
              backPageView: () => backPageview(),
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
                      ? 'Введите последние 4 цифры телефона, с которого вам только что поступил звонок, проверьте пропущенные звонки'
                      : 'Введите проверочный код, который вы прослушали',
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
