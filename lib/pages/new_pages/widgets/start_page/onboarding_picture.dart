import 'package:flutter/material.dart';

import '../../../themes.dart';

class OnboardingPicture extends StatelessWidget {
  const OnboardingPicture({
    required this.asset,
    required this.title,
    required this.description,
    super.key,
  });
  final String asset;
  final String title;
  final String description;
  static const _height = 300.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          SizedBox(
            height: _height,
            child: Image.asset(
              asset,
              fit: BoxFit.fitWidth,
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
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: w400,
              color: gray100,
            ),
          )
        ],
      ),
    );
  }
}
