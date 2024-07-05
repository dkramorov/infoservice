import 'package:flutter/material.dart';

import '../../../themes.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({
    this.appBarTitle = '',
    required this.title,
    required this.description,
    super.key,
  });

  final String appBarTitle;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
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
                fontSize: 14,
                fontWeight: w400,
                color: black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
