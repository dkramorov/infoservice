import 'package:flutter/material.dart';

import '../../settings.dart';

class StepByStepProgressBar extends StatelessWidget {
  final int _totalStep;
  final int _currentStep;

  const StepByStepProgressBar({Key? key, required int totalStep, required int currentStep})
      : assert(currentStep <= totalStep),
        assert(currentStep > 0),
        assert(totalStep > 0),
        _currentStep = currentStep,
        _totalStep = totalStep, super(key: key);

  static const double _progressHeight = 8;

  @override
  Widget build(BuildContext context) {
    final progressWidth = MediaQuery.of(context).size.width / 3;

    return Stack(
      children: [
        Container(
            width: progressWidth,
            height: _progressHeight,
            decoration: BoxDecoration(
                color: const Color(0xFFEBF3FF),
                borderRadius: BorderRadius.circular(4))),
        Container(
          height: _progressHeight,
          width: progressWidth * _currentStep / _totalStep,
          decoration: BoxDecoration(
              color: tealColor, borderRadius: BorderRadius.circular(4)),
        )
      ],
    );
  }
}
