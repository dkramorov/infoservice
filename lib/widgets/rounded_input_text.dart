import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import '../../settings.dart';

class RoundedInputText extends StatelessWidget {
  final String? hint;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final String? defaultValue;
  final Icon? prefixIcon;
  final TextEditingController? controller;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;
  final bool? showCursor;
  final bool? readOnly;
  final TextAlign? textAlign;

  const RoundedInputText({
    this.hint,
    this.onChanged,
    this.validator,
    this.defaultValue,
    this.prefixIcon,
    this.controller,
    this.formatters,
    this.keyboardType,
    this.showCursor,
    this.readOnly,
    this.textAlign,
  });

  TextInputType getKeyboardType() {
    if (keyboardType != null) {
      return keyboardType!;
    }
    return (hint?.indexOf('Email') ?? -1) >= 0
        ? TextInputType.emailAddress
        : TextInputType.text;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      inputFormatters: formatters,
      textAlign: textAlign ?? TextAlign.center,
      onSaved: onChanged,
      decoration: INPUT_DECORATION.copyWith(
        hintText: hint,
        prefixIcon: prefixIcon,
      ),
      // Для паролей надо в подсказке иметь "пароль"
      obscureText: (hint?.indexOf('пароль') ?? -1 ) >= 0 ? true : false,
      keyboardType: getKeyboardType(),
      validator: validator,
      initialValue: controller == null ? defaultValue : null,
      autovalidateMode: validator == null
          ? AutovalidateMode.disabled
          : AutovalidateMode.onUserInteraction,
      showCursor: showCursor ?? true,
      readOnly: readOnly ?? false,
    );
  }
}
