DateTime timestamp2Datetime(int ts) {
  return DateTime.fromMillisecondsSinceEpoch(ts);
}

int datetime2Timestamp(DateTime dt) {
  return dt.millisecondsSinceEpoch;
}