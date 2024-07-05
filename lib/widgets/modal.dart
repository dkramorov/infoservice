import 'package:flutter/material.dart';

import '../pages/themes.dart';

Future showModal(BuildContext context, double height, Widget child) async {
  Size size = MediaQuery.sizeOf(context);
  await showModalBottomSheet<void>(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    isScrollControlled: true,
    context: context,
    useRootNavigator: true,
    barrierColor: black.withOpacity(0.1),
    builder: (BuildContext context) {
      return Container(
        height: height,
        width: size.width,
        decoration: BoxDecoration(
          color: white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: gray,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            SizedBox(
              width: size.width,
              height: height - 20,
              child: child,
            )
          ],
        ),
      );
    },
  );
}

Future showModalOne(BuildContext context, double height, Widget child) async {
  Size size = MediaQuery.sizeOf(context);
  await showModalBottomSheet<void>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      isScrollControlled: true,
      context: context,
      useRootNavigator: true,
      barrierColor: black.withOpacity(0.1),
      builder: (BuildContext context) {
        return Container(
            height: height,
            width: size.width,
            decoration: BoxDecoration(
              color: white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 3),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: gray,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(
                  width: size.width,
                  height: height - 16,
                  child: child,
                )
              ],
            ));
      });
}
