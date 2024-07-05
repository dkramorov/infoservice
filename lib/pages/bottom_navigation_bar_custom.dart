import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'gl.dart';
import 'themes.dart';

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final Path path = Path()
      ..moveTo(0, 20)
      ..quadraticBezierTo(0, 0, size.width * 0.075, 0)
      ..lineTo(size.width * 0.350, 0)
      ..quadraticBezierTo(size.width * 0.405, 0, size.width * 0.41, 8)
      ..arcToPoint(Offset(size.width * 0.59, 8),
          radius: const Radius.circular(8.0), clockwise: false)
      ..quadraticBezierTo(size.width * 0.595, 0, size.width * 0.65, 0)
      ..lineTo(size.width * 0.925, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 20)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas
      ..drawShadow(path, Colors.black, 5, true)
      ..drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BottomBarButton extends StatelessWidget {
  const BottomBarButton(this.size,
      {required this.title,
      required this.onPressed,
      this.assetName,
      this.active = false,
      this.available = true,
      required this.index,
      super.key});
  final Size size;
  final String title;
  final String? assetName;
  final VoidCallback onPressed;
  final bool active;
  final bool available;
  final int index;

  Color get color => !available
      ? Colors.grey[200]!
      : active
          ? Colors.black
          : Colors.grey;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width * 0.2,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcATop),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 24,
                child: assetName != null
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: onPressed,
                        icon: SvgPicture.asset(assetName!))
                    : const SizedBox.shrink()),
            GestureDetector(
              onTap: onPressed,
              child: Text(
                title,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavigationBarCustom extends StatefulWidget {
  const BottomNavigationBarCustom({
    required this.size,
    required this.onPressed,
    required this.activeIndex,
    required this.unauthorized,
    required this.chatMessageCount,
    super.key,
  });
  final Size size;
  final Function(int index, bool unavailable) onPressed;
  final int activeIndex;
  final bool unauthorized;
  final int chatMessageCount;

  @override
  State<BottomNavigationBarCustom> createState() =>
      _BottomNavigationBarCustomState();
}

class _BottomNavigationBarCustomState extends State<BottomNavigationBarCustom> {
  static const _barSize = 72.0;

  static const _listOfUnavailable = [1, 2, 3];

  bool _unavailable(int i) =>
      widget.unauthorized && _listOfUnavailable.contains(i);

  Size get chatWidgetSize =>
      widget.chatMessageCount <= 0 ? const Size(0, 0) : const Size(20, 20);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _barSize,
      child: Stack(children: [
        CustomPaint(
          size: Size(widget.size.width, 80),
          painter: BNBCustomPainter(),
        ),
        Center(
          heightFactor: 0.3,
          child: FloatingActionButton(
              onPressed: () => widget.onPressed(2, _unavailable(2)),
              backgroundColor: blue,
              shape: const CircleBorder(),
              child: SvgPicture.asset(listUserIcon[2])),
        ),
        SizedBox(
          height: _barSize,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            for (int i = 0; i < listUserIcon.length; i++)
              BottomBarButton(
                widget.size,
                title: listUserText[i],
                onPressed: () => widget.onPressed(i, _unavailable(i)),
                assetName: i == 2 ? null : listUserIcon[i],
                active: widget.activeIndex == i,
                available: widget.unauthorized
                    ? !_listOfUnavailable.contains(i)
                    : true,
                index: i,
              ),
          ]),
        ),
        Positioned(
          left: 108,
          top: 8,
          child: AnimatedContainer(
            duration: Durations.medium1,
            width: chatWidgetSize.width,
            height: chatWidgetSize.height,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(
                width: 2,
                color: Colors.white,
              ),
            ),
            child: Center(
              child: Text(
                widget.chatMessageCount > 9
                    ? '9+'
                    : widget.chatMessageCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }
}
