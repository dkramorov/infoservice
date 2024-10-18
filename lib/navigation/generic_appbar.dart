import 'package:flutter/material.dart';

import '../pages/themes.dart';

class GenericAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GenericAppBar({
    this.title = '',
    this.titleWidget,
    this.controls,
    this.controlsCondition,
    this.hasBackButton = false,
    this.height = 56,
    super.key,
  });

  final String title;
  final Widget? titleWidget;
  final List<Widget>? controls;
  final bool? controlsCondition;
  final bool hasBackButton;
  final double height;

  @override
  Widget build(BuildContext context) => PreferredSize(
        preferredSize: Size.fromHeight(height),
        child: AppBar(
          automaticallyImplyLeading: hasBackButton,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: titleWidget ??
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: w500,
                  color: black,
                ),
              ),
          actions: [
            controlsCondition ?? true
                ? Row(children: controls ?? [])
                : const SizedBox.shrink()
          ],
        ),
      );
  @override
  Size get preferredSize => const Size.fromHeight(56);
}
