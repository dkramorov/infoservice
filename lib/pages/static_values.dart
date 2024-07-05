import 'package:flutter/material.dart';

import 'themes.dart';

class UIs {
  static const borderRadiusTextField = 8.0;
  static const signupPagePadding = 30.0;
  static const defaultPagePadding = 16.0;

  static final elevatedButtonDefault = ButtonStyle(
    backgroundColor: ButtonStyleButton.allOrNull<Color>(white),
    surfaceTintColor: ButtonStyleButton.allOrNull<Color>(white),
    padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(
        const EdgeInsets.all(defaultPagePadding)),
    elevation: ButtonStyleButton.allOrNull<double>(0),
    shape: ButtonStyleButton.allOrNull<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  ButtonStyle get smallButtonStyle => elevatedButtonDefault.copyWith(
        backgroundColor: ButtonStyleButton.allOrNull<Color>(surfacePrimary),
        minimumSize: ButtonStyleButton.allOrNull<Size>(
          Size.zero,
        ),
        fixedSize: ButtonStyleButton.allOrNull<Size>(
          const Size.fromHeight(32),
        ),
        padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 16),
        ),
        shape: ButtonStyleButton.allOrNull<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  static final List<Color> colors = [
      const Color.fromRGBO(229, 246, 245, 1),
      const Color.fromRGBO(255, 243, 235, 1),
      const Color.fromRGBO(229, 255, 231, 1),
      const Color.fromRGBO(250, 236, 236, 1),
      const Color.fromRGBO(234, 243, 250, 1),
      const Color.fromRGBO(246, 251, 231, 1),
      const Color.fromRGBO(255, 241, 229, 1),
      const Color.fromRGBO(242, 233, 249, 1),
      const Color.fromRGBO(254, 251, 234, 1),
      const Color.fromRGBO(231, 251, 243, 1),
      const Color.fromRGBO(238, 241, 248, 1),
      const Color.fromRGBO(243, 241, 238, 1),
      const Color.fromRGBO(235, 251, 254, 1),
  ];
}
