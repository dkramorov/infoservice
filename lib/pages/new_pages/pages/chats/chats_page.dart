import 'package:flutter/material.dart';

import '../../../app_asset_lib.dart';
import '../../common/widgets/big_picture_widget.dart';
import '../../common/widgets/control_button.dart';
import '../../../../navigation/generic_appbar.dart';
import '../../../gl.dart';
import '../../../../widgets/modal.dart';
import 'chat_appbar.dart';
import 'item/modal_items.dart';
import 'item/swipe_item.dart';


class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  TextEditingController search = TextEditingController();
  int selectGroup = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: myRosters.isNotEmpty
          ? ChatAppBar(
              size: size,
              appBarSize: size * 0.225,
              searchController: search,
              group: group,
              selectGroup: selectGroup,
              onPressed: (index) => setState(() => selectGroup = index),
            ) as PreferredSizeWidget
          : const GenericAppBar(title: 'Чаты'),
      body: myRosters.isEmpty
          ? BigPictureWidget(
              asset: AssetLib.chatPic,
              assetSize: const Size(180, 124.14),
              customOffset: 148,
              title: "У вас нет чатов",
              description:
                  "Пригласите друзей или создайте группу, чтобы начать общаться",
              controls: ActionControlButton(
                onPressed: () => showModal(
                  context,
                  size.height * 0.15,
                  const NewChatItem(),
                ),
                title: 'Добавить',
              ),
            )
          : ListView.builder(
              itemCount: myRosters.length,
              itemBuilder: (BuildContext context, int index) {
                // if (index < 3) {
                //   return [][index];
                // }
                return Padding(
                  padding: EdgeInsets.only(bottom: index == 7 ? 50 : 0),
                  child: SwipeItem(
                    name: myRosters[index],
                    data: chats[index],
                    onDel: () {},
                  ),
                );
              }),
    );
  }
}

List<String> group = ["Все", "Контакты", "Компании", "Группы"];

List<dynamic> chats = [
  {
    "id": 0,
    "img":
        "https://sun6-21.userapi.com/s/v1/ig2/6nBCZiIVxXgCQ4iTX9g_JXKu-uB12fl6IArEM_PeaAQHmqENhV7W5-QwOAHKf32oUGFb4Ttj5NvZDV2hJ2BVr1ef.jpg?size=2007x2008&quality=96&crop=149,76,2007,2008&ava=1",
    "type": "bank",
    "name": "Сбербанк",
    "last_msg": "Добрый вечер! Извините, что не смог",
    "date": "13:25",
    "new_mgs_count": 2,
  },
  {
    "id": 1,
    "img":
        "https://avatars.mds.yandex.net/i?id=613f1caf90f050e8379ba60421e97068f1ae247a-8564743-images-thumbs&n=13",
    "type": "bank",
    "name": "Альфа-Банк",
    "last_msg": "Какой кредитный продукт можете посоветовать",
    "date": "12:08",
    "new_mgs_count": 0,
  },
  {
    "id": 2,
    "img": "http://cdn1.flamp.ru/6819b6fd672ed676efb81c416dab1646.jpg",
    "type": "chat",
    "name": "Вячеслав",
    "last_msg": "Привет! Ты когда собираешься выходить",
    "date": "10:32",
    "new_mgs_count": 0,
  },
  {
    "id": 3,
    "img":
        "https://static4.tgstat.ru/channels/_0/63/63891601e49cd29002abad75255825d2.jpg",
    "type": "bank",
    "name": "ВТБ Банк",
    "last_msg": "Не смог до вас дозвониться, вы можете посоветовать",
    "date": "12:08",
    "new_mgs_count": 0,
  },
  {
    "id": 4,
    "img": "https://i.artfile.ru/2048x1152_1362609_[www.ArtFile.ru].jpg",
    "type": "chat",
    "name": "Светлана",
    "last_msg": "Привет! Ты когда собираешься выходить",
    "date": "10:32",
    "new_mgs_count": 1,
  },
];
