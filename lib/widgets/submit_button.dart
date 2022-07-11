import 'package:flutter/material.dart';

import '../../settings.dart';

class SubmitButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final bool disabled;
  final bool expanded;

  const SubmitButton(
      {this.text, this.onPressed,
      this.disabled = false,
      this.expanded = false});

  @override
  Widget build(BuildContext context) => RawMaterialButton(
        fillColor: disabled ? disabledButtonColor : PRIMARY_COLOR,
        constraints: BoxConstraints(
            minHeight: 56,
            minWidth: expanded ? MediaQuery.of(context).size.width : 250),
        onPressed: onPressed,
        shape: const RoundedRectangleBorder(
          borderRadius: BORDER_RADIUS_16,
        ),
        child: Text(
          text!,
          style: Theme.of(context).textTheme.headline6?.copyWith(
                color: backgroundLightColor,
                fontWeight: FontWeight.normal,
                fontSize: 18,
              ),
        ),
      );
}
