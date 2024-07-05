import 'package:flutter/material.dart';

import '../../../themes.dart';

class BigPictureWidget extends StatelessWidget {
  const BigPictureWidget({
    this.asset,
    this.assetSize,
    required this.title,
    required this.description,
    this.controls,
    this.customOffset,
    super.key,
  });

  final String? asset;
  final String title;
  final String description;
  final Size? assetSize;

  /// Use [ActionButtonWidget] for this
  final Widget? controls;

  /// use this to properly align widgets if MainAxisAlignment.center isn't cutting it
  final double? customOffset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: customOffset == null
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        if (customOffset != null) SizedBox(height: customOffset),
        if (asset != null)
          SizedBox(
            width: assetSize?.width,
            height: assetSize?.height,
            child: Image.asset(
              asset!,
            ),
          ),
        const SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: w500,
            color: black,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: w400,
              color: gray100,
            ),
          ),
        ),
        const SizedBox(height: 24),
        controls ?? const SizedBox.shrink(),
      ],
    );
  }
}
