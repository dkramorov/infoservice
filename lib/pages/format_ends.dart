String formatCompanyCount(int count) {
  if (count == 0) {
    return 'Нет компаний';
  } else if (count % 100 >= 11 && count % 100 <= 19) {
    return '$count компаний';
  } else {
    switch (count % 10) {
      case 1:
        return '$count компания';
      case 2:
      case 3:
      case 4:
        return '$count компании';
      default:
        return '$count компаний';
    }
  }
}

String formatPhoneWord(int number) {
  String word = 'телефон';

  if (number % 10 == 1 && number % 100 != 11) {
    word = 'телефон';
  } else if ((number % 10 >= 2 && number % 10 <= 4) &&
      (number % 100 < 10 || number % 100 >= 20)) {
    word = 'телефона';
  } else {
    word = 'телефонов';
  }

  return '$number $word';
}

String formatAddressWord(int number) {
  String word = 'адрес';

  if (number % 10 == 1 && number % 100 != 11) {
    word = 'адрес';
  } else if ((number % 10 >= 2 && number % 10 <= 4) &&
      (number % 100 < 10 || number % 100 >= 20)) {
    word = 'адреса';
  } else {
    word = 'адресов';
  }

  return '$number $word';
}

String extractPhoneNumberFromJid(String jid) {
  RegExp regex = RegExp(r'^(\d+)@');
  Match? match = regex.firstMatch(jid);
  if (match != null && match.groupCount > 0) {
    return match.group(1)!;
  } else {
    return jid;
  }
}

String formatMillisecondsToTime(int millisecondsSinceEpoch) {
  DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  String formattedTime =
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  return formattedTime;
}
