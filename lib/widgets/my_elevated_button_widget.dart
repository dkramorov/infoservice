import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color color;

  const MyElevatedButton(
      {required this.child, required this.onPressed, required this.color, Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(25.0),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(this.color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
