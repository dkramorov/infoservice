import 'dart:developer';

class Log {
  static LogLevel logLevel = LogLevel.VERBOSE;
  static bool logXmpp = true;
  //final Function logi = log;
  static final Function logi = print;

  static void v(String tag, String message) {
    if (logLevel.index <= LogLevel.VERBOSE.index) {
      logi('V/[$tag]: $message');
    }
  }

  static void d(String tag, String message) {
    if (logLevel.index <= LogLevel.DEBUG.index) {
      logi('D/[$tag]: $message');
    }
  }

  static void i(String tag, String message) {
    if (logLevel.index <= LogLevel.INFO.index) {
      logi('I/[$tag]: $message');
    }
  }

  static void w(String tag, String message) {
    if (logLevel.index <= LogLevel.WARNING.index) {
      logi('W/[$tag]: $message');
    }
  }

  static void e(String tag, String message) {
    if (logLevel.index <= LogLevel.ERROR.index) {
      logi('E/[$tag]: $message');
    }
  }

  static void xmppp_receiving(String message) {
    if (logXmpp) {
      logi('---Xmpp Receiving:---');
      logi('$message');
    }
  }

  static void xmppp_sending(String message) {
    if (logXmpp) {
      logi('---Xmpp Sending:---');
      logi('$message');
    }
  }

}

enum LogLevel { VERBOSE, DEBUG, INFO, WARNING, ERROR, OFF }