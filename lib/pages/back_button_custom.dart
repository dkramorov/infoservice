import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_asset_lib.dart';

class AppBarButtonCustom extends StatelessWidget {
  const AppBarButtonCustom({
    this.asset,
    this.onPressed,
    this.padding = 0, // recommended to add 8 when using
    super.key,
  });
  final String? asset;
  final VoidCallback? onPressed;
  final double padding;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.all(padding),
        child: SizedBox(
          width: 32,
          height: 32,
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
