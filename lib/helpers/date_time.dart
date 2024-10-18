import 'package:intl/intl.dart';

final DateFormat dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');

DateTime timestamp2Datetime(int ts) {
  return DateTime.fromMillisecondsSinceEpoch(ts);
}

int datetime2Timestamp(DateTime dt) {
  return dt.millisecondsSinceEpoch;
}

String datetime2String(DateTime dt) {
  return dateFormat.format(dt);
}
