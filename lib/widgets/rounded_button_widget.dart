import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../pages/app_asset_lib.dart';

class RoundedButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final Text? text;
  final double height;
  final double borderRadius;
  final double minWidth;

  const RoundedButtonWidget({
    super.key,
    this.text,
    this.color,
    this.onPressed,
    this.height = 42.0,
    this.borderRadius = 25.0,
    this.minWidth = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5.0,
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0),),
      child: MaterialButton(
        padding: const EdgeInsets.all(0),
        height: height,
        onPressed: onPressed,
        minWidth: minWidth,
        child: text,
      ),
    );
  }
}

class RoundedButtonWithIconWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final Text? text;
  final SvgPicture? icon;
  final double height;
  final double borderRadius;
  final double minWidth;

  const RoundedButtonWithIconWidget({
    super.key,
    this.text,
    this.icon,
    this.color,
    this.onPressed,
    this.height = 42.0,
    this.borderRadius = 25.0,
    this.minWidth = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      //icon: Icon(Icons.thumb_up_alt_outlined),
      icon: SvgPicture.asset(AssetLib.yandexIcon),
      //icon: icon ?? const Icon(null),
      label: text ?? const Text(''),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        //foregroundColor: color, // текст
        surfaceTintColor: color,
        shadowColor: color,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );
  }
}
