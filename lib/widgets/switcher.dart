import 'package:flutter/material.dart';

import '../pages/themes.dart';

class CustomSwitch extends StatefulWidget {
  final void Function(bool) onChange;
  final bool value;

  const CustomSwitch({Key? key, required this.onChange, required this.value})
      : super(key: key);

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool _value1 = false;

  @override
  void initState() {
    super.initState();
    _value1 = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _value1 = !_value1;
        });
        widget.onChange(_value1);
      },
      child: Container(
        width: 36,
        height: 20,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _value1 ? blue : gray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              left: _value1 ? 18 : 2,
              right: _value1 ? 2 : 18,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
