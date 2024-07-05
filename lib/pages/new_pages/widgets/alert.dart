import 'package:flutter/material.dart';

import '../../themes.dart';

class SuccessAlert extends StatelessWidget {
  final String text;
  final Color color;
  const SuccessAlert({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      height: 108,
      width: size.width,
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 16,
        right: 20,
        left: 20,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Card(
        elevation: 0,
        color: color,
        shadowColor: null,
        surfaceTintColor: null,
        borderOnForeground: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: w500,
                color: white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ErrorAlert extends StatelessWidget {
  final String text;
  final Color color;
  const ErrorAlert({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      height: 108,
      width: size.width,
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 16,
        right: 20,
        left: 20,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Card(
        elevation: 0,
        color: color,
        shadowColor: null,
        surfaceTintColor: null,
        borderOnForeground: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: w500,
                color: white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
