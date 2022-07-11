import 'package:flutter/material.dart';

import '../../settings.dart';
import 'avatar_widget.dart';

class MyUser extends StatelessWidget {
  final String? label;
  final bool isReady;
  final String imgPath;
  final bool isOnline;
  final double labelWidth;
  final bool showIndicator;

  MyUser({
    this.label,
    this.isReady = true,
    this.imgPath = DEFAULT_AVATAR,
    this.isOnline = false,
    this.labelWidth = 100.0,
    this.showIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(
        right: 10.0,
        left: 10.0,
        top: 6.0,
      ),
      child: Column(
        children: <Widget>[
          Avatar(
            imgPath: imgPath,
            isOnline: isOnline,
            showIndicator: showIndicator,
          ),
          SIZED_BOX_H04,
          SizedBox(
            width: labelWidth,
            child: Text(
              label ?? '?',
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
