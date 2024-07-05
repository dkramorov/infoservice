import 'package:flutter/material.dart';

extension ContextExtenstion on BuildContext {
  static Size? _localScreenSize;
  Size get screenSize => _localScreenSize ??= MediaQuery.sizeOf(this);
}
