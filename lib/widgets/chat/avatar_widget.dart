import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infoservice/widgets/chat/msg_counter.dart';

import '../../settings.dart';
import 'online_indicator.dart';

class Avatar extends StatelessWidget {
  final double width;
  final double height;
  final String imgPath;
  final bool isOnline;
  final bool showIndicator;
  final int showCounter;

  const Avatar({
    Key? key,
    this.width = 50.0,
    this.height = 50.0,
    this.imgPath = DEFAULT_AVATAR,
    this.isOnline = false,
    this.showIndicator = false,
    this.showCounter = 0,
  }) : super(key: key);

  ImageProvider getImageProvider(path) {
    if (imgPath.startsWith('assets')) {
      return AssetImage(imgPath);
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return FileImage(File(imgPath));
  }

  @override
  Widget build(BuildContext context) {
    var softShadows = [
      BoxShadow(
        color: Colors.grey.shade400.withOpacity(.15),
        offset: const Offset(2.0, 2.0),
        blurRadius: 2.0,
        spreadRadius: 1.0,
      ),
      const BoxShadow(
        color: Colors.white,
        offset: Offset(-2.0, -2.0),
        blurRadius: 2.0,
        spreadRadius: 1.0,
      ),
    ];
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: softShadows,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: getImageProvider(imgPath),
              ),
            ),
          ),
          showCounter > 0
              ? Positioned(
                  left: 2,
                  top: 2,
                  child: MsgCounter(
                    width: 0.4 * width,
                    height: 0.4 * height,
                    count: showCounter,
                  ),
                )
              : Container(),
          showIndicator
              ? Positioned(
                  right: 2,
                  bottom: 2,
                  child: OnlineIndicator(
                    width: 0.26 * width,
                    height: 0.26 * height,
                    isOnline: isOnline,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
