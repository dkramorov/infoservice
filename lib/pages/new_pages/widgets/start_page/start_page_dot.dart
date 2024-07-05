import 'package:flutter/material.dart';

import '../../../themes.dart';

class StartPageDot extends StatelessWidget {
  const StartPageDot({required this.enabled, super.key});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: SizedBox(
        width: 4,
        height: 4,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled ? black : gray,
          ),
        ),
      ),
    );
  }
}
