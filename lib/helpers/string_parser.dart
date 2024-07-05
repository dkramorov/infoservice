
String translit(String text) {
  // Транслит текста с русского в латиницу
  if (text == '') {
    return '';
  }
  String chars = '-0123456789_abcdefghijklmnopqrstuvwxyz.';
  String rus = 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя №';
  List<String> eng = [
      'a', 'b', 'v', 'g', 'd', 'e', 'yo', 'j', 'z',
      'i', 'y', 'k', 'l', 'm', 'n', 'o', 'p', 'r',
      's', 't', 'u', 'f', 'h', 'c', 'ch', 'sh', 'shh',
      '', 'y', '', 'e', 'yu', 'ya', '-', '-'
  ];
  String result = '';
  String letter = '';
  int ind;
  text.split('').forEach((ch) {
    ch = ch.toLowerCase();
    if (rus.contains(ch)) {
      ind = rus.indexOf(ch);
      letter = eng[ind];
    } else {
      if (chars.contains(ch)) {
        letter = ch;
      }
    }
    result += letter;
  });
  return result;
}

String uri2rus(String url) {
  return Uri.decodeFull(url);
}

String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Не оставляйте имя пустым';
  }
  return null;
}

String? validatePassword(String? value) {
  const int minLen = 3;
  if (value != null && value.length < minLen || value!.trim().isEmpty) {
    return 'Минимальная длина - $minLen символа';
  }
  return null;
}