import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../pages/themes.dart';
import '../pages/app_asset_lib.dart';

class PasswordEyeWidget extends StatelessWidget {
  const PasswordEyeWidget(
    this.value, {
    required this.onPressed,
    super.key,
  });
  final bool value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: value
          ? Icon(
              Icons.remove_red_eye_outlined,
              color: gray100,
              size: 24,
            )
          : SvgPicture.asset(AssetLib.passwordEye),
    );
  }
}
