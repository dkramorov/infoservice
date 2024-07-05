String? validatePhone(String? value) {
  print('YOOOOO');
  if (value != null && value.length < 11 || value!.trim().isEmpty) {
    return 'Неверный номер телефона';
  }

  return null;
}

String? validatePassword(String? value) {
  if (value != null && value.length < 6 || value!.trim().isEmpty) {
    return 'Минимальная длина - 6 символов';
  }

  return null;
}

String? validateEmail(String? value) {
  const pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  final regex = RegExp(pattern);

  if (value != null && !regex.hasMatch(value) || value!.trim().isEmpty) {
    return 'Введите верный E-Mail';
  }

  return null;
}

String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Не оставляйте имя пустым';
  }
  return null;
}
