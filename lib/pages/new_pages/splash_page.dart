import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_asset_lib.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          ColoredBox(
            color: const Color(0xFF00B4CD),
            child: Center(
              child: SvgPicture.asset(AssetLib.logoSplash),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: SvgPicture.asset(AssetLib.unionSplash),
          ),
        ],
      );
}
