import 'package:flutter/material.dart';

import '../pages/static_values.dart';
import 'app_progress_indicator.dart';

class PrimaryButton extends StatelessWidget {
  final Widget child;
  final double vertical;
  final Color color;
  final VoidCallback onPressed;
  final bool loading;
  const PrimaryButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.color,
    this.vertical = 14,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48,
        child: AnimatedSwitcher(
          duration: Durations.medium1,
          switchInCurve: Curves.easeInExpo,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(opacity: animation, child: child),
          child: loading
              ? const AppProgressIndicator()
              : ElevatedButton(
                  onPressed: loading ? null : onPressed,
                  style: UIs.elevatedButtonDefault.copyWith(
                    backgroundColor: ButtonStyleButton.allOrNull<Color>(color),
                    shape: ButtonStyleButton.allOrNull<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(
                      EdgeInsets.zero,
                    ),
                  ),
                  child: Center(child: child),
                ),
        ),
      );
}

class Button extends StatelessWidget {
  final Widget child;
  final double vertical;
  final VoidCallback onPressed;
  const Button({
    super.key,
    required this.child,
    required this.onPressed,
    this.vertical = 5,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: vertical),
        constraints: const BoxConstraints(minWidth: double.infinity),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: child,
      ),
    );
  }
}
