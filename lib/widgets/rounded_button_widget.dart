import 'package:flutter/material.dart';

class RoundedButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final Text? text;
  final double height;
  final double borderRadius;
  final double minWidth;

  const RoundedButtonWidget({
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
