import 'package:flutter/services.dart';

import '../../gl.dart';

String cleanPhone(String phone) {
  /* Приведение телефона к цифровому виду
     Надо сплитить по @ иначе почему-то все восьмерки телефон дублируется
  */
  String newPhone = phone.split('@')[0].replaceAll(RegExp('[^0-9]+'), '');
  if (newPhone.startsWith('7')) {
    newPhone = '8${newPhone.substring(1)}';
  }
  return newPhone;
}

// PHONE_MASK == 1 => 8 (800) 700-11-78
String phoneMaskHelper1(String phone) {
  String newPhone = phone.replaceAll(RegExp('[^0-9]+'), '');
  int newPhoneLen = newPhone.length;
  String result = '';

  for (int i = 0; i < newPhoneLen; i++) {
    if (i >= 11) {
      break;
    }
    if (i == 0) {
      result += newPhone[i];
    } else if (i <= 3) {
      if (i == 1) {
        result += ' (';
      }
      result += newPhone[i];
    } else if (i <= 4) {
      if (i == 4) {
        result += ') ';
      }
      result += newPhone[i];
    } else if (i <= 7) {
      if (i == 7) {
        result += '-';
      }
      result += newPhone[i];
    } else if (i <= 9) {
      if (i == 9) {
        result += '-';
      }
      result += newPhone[i];
    } else {
      result += newPhone[i];
    }
  }
  return result;
}

// PHONE_MASK == 2 => 8 (###) #-###-###
String phoneMaskHelper2(String phone) {
  String newPhone = phone.replaceAll(RegExp('[^0-9]+'), '');
  int newPhoneLen = newPhone.length;
  String result = '';

  for (int i = 0; i < newPhoneLen; i++) {
    if (i >= 11) {
      break;
    }
    if (i == 0) {
      result += newPhone[i];
    } else if (i <= 3) {
      if (i == 1) {
        result += ' (';
      }
      result += newPhone[i];
    } else if (i <= 4) {
      if (i == 4) {
        result += ') ';
      }
      result += newPhone[i];
    } else if (i <= 7) {
      if (i == 5) {
        result += '-';
      }
      result += newPhone[i];
    } else {
      if (i == 8) {
        result += '-';
      }
      result += newPhone[i];
    }
  }
  return result;
}

String phoneMaskHelper(String phone) {
  return phoneMask == 1 ? phoneMaskHelper1(phone) : phoneMaskHelper2(phone);
}

RegExp phoneMaskValidator() {
  return phoneMask == 1
      ? RegExp(r'^8 \([0-9]{3}\) [0-9]{3}-[0-9]{2}-[0-9]{2}$')
      : RegExp(r'^8 \([0-9]{3}\) [0-9]{1}-[0-9]{3}-[0-9]{3}$');
}

class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final int selectionIndexFromTheRight =
        newValue.text.length - newValue.selection.end;
    final String newString = phoneMaskHelper(newValue.text);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(
          offset: newString.length - selectionIndexFromTheRight),
    );
  }
}
