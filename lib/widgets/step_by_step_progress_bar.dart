import 'package:flutter/material.dart';

import '../../settings.dart';

class StepByStepProgressBar extends StatelessWidget {
  int _totalStep;
  int _currentStep;

  StepByStepProgressBar({Key? key, required int totalStep, required int currentStep})
      : assert(currentStep <= totalStep),
        assert(currentStep > 0),
        assert(totalStep > 0),
        _currentStep = currentStep,
        _totalStep = totalStep, super(key: key);

  static const double _progressHeight = 8;

  @override
  Widget build(BuildContext context) {
    final _progressWidth = MediaQuery.of(context).size.width / 3;

    return Stack(
      children: [
        Container(
            width: _progressWidth,
            height: _progressHeight,
            decoration: BoxDecoration(
                color: const Color(0xFFEBF3FF),
                borderRadius: BorderRadius.circular(4))),
        Container(
          height: _progressHeight,
          width: _progressWidth * _currentStep / _totalStep,
          decoration: BoxDecoration(
              color: tealColor, borderRadius: BorderRadius.circular(4)),
        )
      ],
    );
  }
}
