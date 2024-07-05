import 'package:flutter/material.dart';

import '../pages/themes.dart';
import '../pages/format_ends.dart';

class TopBarItem extends StatelessWidget {
  const TopBarItem(this.listItem, {required this.size, super.key});
  final Map<String, dynamic> listItem;
  final Size size;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        alignment: Alignment.topLeft,
        elevation: 0,
        shadowColor: Colors.transparent,
        fixedSize: Size(
          listItem['big'] ? size.width - 32 : size.width * 0.5 - 20.5,
          100,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Color.fromRGBO(
          listItem['color-1'],
          listItem['color-2'],
          listItem['color-3'],
          1,
        ),
      ),
      onPressed: () {
        if (listItem['onPressed'] != null) {
          listItem['onPressed'](listItem['id']);
        }
      },
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          if (listItem['img'] != null)
            Align(
              alignment: Alignment.bottomRight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/imgs/${listItem["img"]}.png',
                  height: double.parse(
                    listItem['height'].toString(),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listItem['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: w400,
                    color: black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatCompanyCount(listItem['col']),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: w400,
                    color: gray100,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
