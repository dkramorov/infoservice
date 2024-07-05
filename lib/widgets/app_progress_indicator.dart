import 'package:flutter/material.dart';

import '../pages/themes.dart';

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          color: blue,
          key: const Key('ProgressIndicator'),
        ),
      );
}
