import 'package:flutter/material.dart';

import '../splash_loading_page.dart';
import '../splash_page.dart';

class SplashScreensTestPage extends StatelessWidget {
  const SplashScreensTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          SplashPage(),
          SplashLoadingPage(),
        ],
      ),
    );
  }
}
