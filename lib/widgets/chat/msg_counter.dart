import 'package:flutter/material.dart';

class MsgCounter extends StatelessWidget {
  final double width;
  final double height;
  final int count;

  const MsgCounter({
    Key? key,
    this.width = 14.0,
    this.height = 14.0,
    this.count = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: count > 0
            ? Center(
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              )
            : Container(),
      ),
    );
  }
}
