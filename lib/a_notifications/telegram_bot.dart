import 'package:http/http.dart' as http;

class TelegramBot {
  static final TelegramBot _singleton = TelegramBot._internal();
  static const String TELEGRAM_TOKEN =
      '922327226:AAGeS9rA06g3FfBXjKLYcJYCtJoQf6NYmgI';
  static const String API_DOMAIN = 'api.telegram.org';
  static const String API_URL = '/bot$TELEGRAM_TOKEN';
  static const String ERRORS_CHAT_ID = '-1001566427795';
  static const String PUSH_CHAT_ID = '-1001567702515';
  static const bool disableWebPagePreview = true;
  static const int MAX_MESSAGE_LEN = 4000;
  static String userPhone = '';
  static String userToken = '';

  factory TelegramBot() {
    return _singleton;
  }

  TelegramBot._internal();

  // https://apps.timwhitlock.info/emoji/tables/unicode
  // https://www.unicode.org/emoji/charts/full-emoji-list.html
  static const Map<String, String> emoji = {
    'sos': '🆘',
    'mail': '📨',
    'ouch': '😫',
  };

  /* Отправка ошибки в чат телеги */
  Future<void> sendError(String msg) async {
    if (msg.length > MAX_MESSAGE_LEN) {
      sendLongMessage(msg);
    } else {
      sendMessage(msg, emoji['sos']!, ERRORS_CHAT_ID);
    }
  }

  /* Отправка сообщения в чат телеги */
  Future<void> sendNotify(String msg) async {
    if (msg.length > MAX_MESSAGE_LEN) {
      sendLongMessage(msg);
    } else {
      sendMessage(msg, emoji['mail']!, PUSH_CHAT_ID);
    }
  }

  Future<void> sendLongMessage(String msg) async {
    if (msg.length > MAX_MESSAGE_LEN) {
      for(int i = 0; i < msg.length; i += MAX_MESSAGE_LEN) {
        sendMessage(msg.substring(i, i + MAX_MESSAGE_LEN), emoji['ouch']!, ERRORS_CHAT_ID);
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  /* User data for report */
  String buildUserData() {
    String userData = '';
    userData += ' $userPhone';
    userData += '\n';
    return userData;
  }

  /* Отправка сообщения в чат телеги */
  Future<void> sendMessage(String msg, String emoji, String chatId) async {
    if (msg.length > MAX_MESSAGE_LEN) {
      msg = '${msg.substring(0, MAX_MESSAGE_LEN)}...';
    }

    String userData = buildUserData();
    Map<String, dynamic> params = {
      'chat_id': chatId,
      'text': '$emoji$userData$msg',
      'disable_web_page_preview': disableWebPagePreview ? 'true': 'false',
    };
    var url = Uri.https(API_DOMAIN, '$API_URL/sendMessage', params);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      print('sendMessage: ${response.body}');
    } else {
      print('sendMessage: Request failed with status ${response.statusCode}');
    }
  }
}
