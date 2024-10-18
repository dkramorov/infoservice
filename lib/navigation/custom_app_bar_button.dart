import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../pages/app_asset_lib.dart';

class CustomAppBarButton extends StatelessWidget {
  const CustomAppBarButton({
    this.asset,
    this.onPressed,
    this.padding = 0, // recommended to add 8 when using
    this.width = 32,
    this.height = 32,
    super.key,
  });
  final String? asset;
  final VoidCallback? onPressed;
  final double padding;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.all(padding),
        child: SizedBox(
          width: width,
          height: height,
          child: InkWell(
            onTap: onPressed ?? Navigator.of(context).pop,
            radius: 48,
            borderRadius: BorderRadius.circular(100),
            child:
                Center(child: SvgPicture.asset(asset ?? AssetLib.backButton)),
          ),
        ),
      );
}
