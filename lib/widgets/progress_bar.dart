import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infoservice/widgets/step_by_step_progress_bar.dart';

class PageViewProgressBar extends StatelessWidget {
  final VoidCallback? backPageView;
  final VoidCallback? nextPageView;
  final int totalStep;
  final int currentStep;

  const PageViewProgressBar(
      {this.backPageView,
      this.nextPageView,
      required this.totalStep,
      required this.currentStep,
      Key? key})
      : super(key: key);

  static const backIcon = 'assets/svg/bp_backward_icon.svg';
  static const forwardTitle = 'Далее';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
            onTap: backPageView,
            child: SizedBox(width: 26, child: SvgPicture.asset(backIcon))),
        StepByStepProgressBar(totalStep: totalStep, currentStep: currentStep),
        GestureDetector(
          onTap: nextPageView,
          child: Text(
            forwardTitle,
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}
