import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PhoneCallButton extends StatelessWidget {
  const PhoneCallButton({
    this.onPressed,
    required this.asset,
    this.backgroundColor = Colors.white,
    this.assetColor,
    super.key,
  });
  final VoidCallback? onPressed;
  final String asset;
  final Color? backgroundColor;
  final Color? assetColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            offset: Offset(0, 2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          elevation: 0,
          fixedSize: const Size(64, 64),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed?.call,
        child: SvgPicture.asset(
          asset,
          // ignore: deprecated_member_use
          color: assetColor,
        ),
      ),
    );
  }
}
