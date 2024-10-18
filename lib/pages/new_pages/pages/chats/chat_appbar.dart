import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app_asset_lib.dart';
import '../../../../navigation/custom_app_bar_button.dart';
import '../../../themes.dart';
import '../../../../widgets/modal.dart';
import 'item/modal_items.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({
    required this.size,
    required this.appBarSize,
    required this.searchController,
    required this.onPressed,
    required this.group,
    required this.selectGroup,
    super.key,
  });
  final Size size;
  final Size appBarSize;
  final TextEditingController searchController;
  final void Function(int index) onPressed;
  final List group;
  final int selectGroup;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: appBarSize,
      child: Container(
        color: white,
        height: size.height * 0.45,
        padding: const EdgeInsets.only(top: 35),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: size.width,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Text(
                    "Чаты",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: w500,
                      color: black,
                    ),
                  ),
                  Material(
                    child: CustomAppBarButton(
                      padding: 0,
                      asset: AssetLib.plusButton,
                      onPressed: () => showModal(
                        context,
                        size.height * 0.15,
                        const NewChatItem(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: size.width - 32,
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  width: 1,
                  color: borderPrimary,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: SvgPicture.asset(AssetLib.searchButton),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: size.width * 0.7,
                        child: TextField(
                          controller: searchController,
                          scrollPadding: const EdgeInsets.all(0),
                          textCapitalization: TextCapitalization.none,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: w400,
                            color: black,
                            fontFamily: "GolosText",
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.all(0),
                            hintText: "Поиск",
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: w400,
                              color: gray100,
                              fontFamily: "GolosText",
                            ),
                            fillColor: transparent,
                            filled: true,
                            disabledBorder: InputBorder.none,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(group.length, (index) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: selectGroup == index ? blue : borderPrimary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          minimumSize: const Size(64, 32),
                          fixedSize: const Size.fromHeight(32),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () => onPressed(index),
                        child: Text(
                          group[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: w400,
                            color: black,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => appBarSize;
}
