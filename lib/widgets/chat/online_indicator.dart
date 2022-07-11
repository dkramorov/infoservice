import 'package:flutter/material.dart';

class OnlineIndicator extends StatelessWidget {
  final double width;
  final double height;
  final bool isOnline;

  const OnlineIndicator({
    Key? key,
    this.isOnline = false,
    this.width = 14.0,
    this.height = 14.0,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(.15),
            blurRadius: 2.0,
            spreadRadius: 0,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isOnline ? Colors.lightGreen : Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
