import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_asset_lib.dart';
import '../themes.dart';

class PersonalDataField extends StatelessWidget {
  const PersonalDataField({
    required this.title,
    required this.value,
    required this.onPressed,
    super.key,
  });

  final String title;
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      splashColor: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: borderPrimary,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: w400,
                    color: gray100,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: w400,
                    color: black,
                  ),
                )
              ],
            ),
            const Spacer(),
            SvgPicture.asset(AssetLib.smallArrow),
          ],
        ),
      ),
    );
  }
}
