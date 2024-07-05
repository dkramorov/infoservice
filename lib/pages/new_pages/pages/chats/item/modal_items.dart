import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app_asset_lib.dart';
import '../../../../themes.dart';
import '../../../../../widgets/button.dart';
import '../side_page/add_chat.dart';
import '../side_page/add_group.dart';

class DeleteItem extends StatefulWidget {
  const DeleteItem({super.key});

  @override
  State<DeleteItem> createState() => _DeleteItemState();
}

class _DeleteItemState extends State<DeleteItem> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            "Вы действительно хотите удалить чат с Вячеславом?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: w500,
              color: black,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            vertical: 14,
            color: blue,
            child: Center(
              child: Text(
                "Удалить",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: w500,
                  color: white,
                ),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            vertical: 14,
            color: surfacePrimary,
            child: Center(
              child: Text(
                "Отмена",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: w500,
                  color: black,
                ),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class NewChatItem extends StatefulWidget {
  const NewChatItem({
    super.key,
  });

  @override
  State<NewChatItem> createState() => _NewChatItemState();
}

class _NewChatItemState extends State<NewChatItem> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => const AddChatsPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SvgPicture.asset(AssetLib.addPeople),
                  const SizedBox(width: 16),
                  Text(
                    "Добавить контакт",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: w400,
                      color: black,
                    ),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => const AddGroupPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AssetLib.addGroup,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Создать группу",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: w400,
                      color: black,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
