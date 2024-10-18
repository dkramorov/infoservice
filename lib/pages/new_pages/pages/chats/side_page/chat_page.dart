import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:xmpp_plugin/models/message_model.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app_asset_lib.dart';
import '../../../../../navigation/custom_app_bar_button.dart';
import '../../../../themes.dart';
import '../../../../format_ends.dart';
import '../chats_page.dart';
import 'photo_view_screen.dart';

class ChatPage extends StatefulWidget {
  final String userPhone;

  const ChatPage({
    super.key,
    required this.userPhone,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController controller = TextEditingController();
  dynamic dataChat;
  int indexChat = -1;
  late String id;
  List<String> lstImg = [];

  // Timer? timer;

  @override
  void initState() {
    super.initState();
    startPeriodicCheck();
    id = widget.userPhone.split("@").first;
    for (int i = 0; i < chats.length; i++) {
      if (chats[i].members.contains(id)) {
        indexChat = i;

        chats[i].onMessage.addListener(() {
          if (mounted) setState(() {});
        });
      }
    }

    if (indexChat == -1) {
      /*
      onNewChat.addListener(() {
        if (indexChat != -1) {
          return;
        }
        for (int i = 0; i < chats.length; i++) {
          if (chats[i].members.contains(id)) {
            indexChat = i;

            chats[i].onMessage.addListener(() {
              if (mounted) setState(() {});
            });
            if (mounted) setState(() {});
          }
        }
      });
      */
    } else {
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  // @override
  // void dispose() {
  //   timer?.cancel(); // Отменить таймер при уничтожении виджета
  //   super.dispose();
  // }

  void startPeriodicCheck() async {
    //dataChat = await mainListener.getMessage(widget.userPhone, "100");

    log("----------------------------------data_chats: $dataChat");
    // String logs = await FlutterLogs.;
    // print('Логи: $logs');
    if (mounted) setState(() {});
  }

  List<MessageChat> events = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CustomAppBarButton(),
                const SizedBox(width: 16),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: gray200,
                    shape: BoxShape.circle,
                    // image: DecorationImage(
                    //   image: NetworkImage(
                    //       "https://mykaleidoscope.ru/x/uploads/posts/2022-09/1663659245_9-mykaleidoscope-ru-p-obraz-uspeshnogo-cheloveka-krasivo-9.jpg"),
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.person,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      extractPhoneNumberFromJid(widget.userPhone),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: w500,
                        color: black,
                      ),
                    ),
                    // Text(
                    //   "",
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     fontWeight: w400,
                    //     color: gray100,
                    //   ),
                    // )
                  ],
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(
                    AssetLib.phoneCall,
                    // ignore: deprecated_member_use
                    color: black,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(
                    AssetLib.searchBigButton,
                    // ignore: deprecated_member_use
                    color: black,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        color: surfacePrimary,
        // padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: (indexChat == -1)
                  ? const Expanded(
                      child: SizedBox(),
                    )
                  : ListView.builder(
                      itemCount: chats[indexChat].messages.length,
                      reverse: true,
                      itemBuilder: (BuildContext context, int index) {
                        int reversedIndex =
                            chats[indexChat].messages.length - 1 - index;
                        // print(chats[indexChat]
                        //                 .messages[reversedIndex].text);
                        print(
                            "${chats[indexChat].messages[reversedIndex].from}  ${chats[indexChat].messages[reversedIndex].text}");
                        if (chats[indexChat]
                            .messages[reversedIndex]
                            .text
                            .isEmpty) {
                          return const SizedBox();
                        }
                        return VisibilityDetector(
                          key: Key(chats[indexChat].messages[reversedIndex].id),
                          onVisibilityChanged: (visibilityInfo) {
                            var visiblePercentage =
                                visibilityInfo.visibleFraction * 100;
                            if (visiblePercentage >= 80) {
                              if (chats[indexChat]
                                          .messages[reversedIndex]
                                          .status !=
                                      "readed" &&
                                  chats[indexChat]
                                          .messages[reversedIndex]
                                          .from !=
                                      id) {
                                /*
                                mainListener.readMess(
                                    widget.userPhone,
                                    chats[indexChat]
                                        .messages[reversedIndex]
                                        .id);

                                */
                              }
                            }
                          },
                          child: Column(
                            children: [
                              // if (reversedIndex > 0 &&
                              //     chats[indexChat].messages[reversedIndex]["new"] &&
                              //     !chats[indexChat][reversedIndex - 1]["new"])
                              //   Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Container(
                              //         height: 1,
                              //         color: borderPrimary,
                              //         width: size.width * 0.35,
                              //         margin: const EdgeInsets.symmetric(vertical: 32),
                              //       ),
                              //       Text(
                              //         "Сегодня",
                              //         style: TextStyle(
                              //           fontSize: 12,
                              //           fontWeight: w400,
                              //           color: gray100,
                              //         ),
                              //       ),
                              //       Container(
                              //         height: 1,
                              //         color: borderPrimary,
                              //         width: size.width * 0.35,
                              //         margin: const EdgeInsets.symmetric(vertical: 32),
                              //       ),
                              //     ],
                              //   ),
                              Container(
                                margin: EdgeInsets.only(
                                  right: chats[indexChat]
                                              .messages[reversedIndex]
                                              .from !=
                                          id
                                      ? 16
                                      : 25,
                                  left: chats[indexChat]
                                              .messages[reversedIndex]
                                              .from !=
                                          id
                                      ? 25
                                      : 16,
                                  bottom: 24,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: chats[indexChat]
                                              .messages[reversedIndex]
                                              .from !=
                                          id
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    if (chats[indexChat]
                                            .messages[reversedIndex]
                                            .from ==
                                        id)
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                "https://mykaleidoscope.ru/x/uploads/posts/2022-09/1663659245_9-mykaleidoscope-ru-p-obraz-uspeshnogo-cheloveka-krasivo-9.jpg"),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    if (chats[indexChat]
                                            .messages[reversedIndex]
                                            .from ==
                                        id)
                                      const SizedBox(width: 10),
                                    Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 0,
                                        maxWidth: 260,
                                      ),
                                      // width: size.width * 0.85,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: chats[indexChat]
                                                    .messages[reversedIndex]
                                                    .from !=
                                                id
                                            ? gray100
                                            : white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: chats[indexChat]
                                                      .messages[reversedIndex]
                                                      .from !=
                                                  id
                                              ? const Radius.circular(12)
                                              : const Radius.circular(12),
                                          topRight: const Radius.circular(12),
                                          bottomRight: chats[indexChat]
                                                      .messages[reversedIndex]
                                                      .from !=
                                                  id
                                              ? const Radius.circular(0)
                                              : const Radius.circular(12),
                                          bottomLeft: chats[indexChat]
                                                      .messages[reversedIndex]
                                                      .from !=
                                                  id
                                              ? const Radius.circular(12)
                                              : const Radius.circular(0),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: chats[indexChat]
                                                    .messages[reversedIndex]
                                                    .from !=
                                                id
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            chats[indexChat]
                                                .messages[reversedIndex]
                                                .text,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: w500,
                                              color: chats[indexChat]
                                                          .messages[
                                                              reversedIndex]
                                                          .from !=
                                                      id
                                                  ? white
                                                  : gray900,
                                            ),
                                          ),
                                          if ((chats[indexChat]
                                                      .messages[reversedIndex]
                                                      .file ??
                                                  "")
                                              .isNotEmpty)
                                            Hero(
                                              tag: chats[indexChat]
                                                  .messages[reversedIndex]
                                                  .time
                                                  .toString(),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PhotoViewScreen(
                                                              tag: chats[
                                                                      indexChat]
                                                                  .messages[
                                                                      reversedIndex]
                                                                  .time
                                                                  .toString(),
                                                              imageUrl: chats[
                                                                      indexChat]
                                                                  .messages[
                                                                      reversedIndex]
                                                                  .file!),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: 236,
                                                  height: 120,
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          chats[indexChat]
                                                              .messages[
                                                                  reversedIndex]
                                                              .file!),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                formatMillisecondsToTime(
                                                  int.parse(
                                                    chats[indexChat]
                                                        .messages[reversedIndex]
                                                        .time,
                                                  ),
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: w500,
                                                  color: chats[indexChat]
                                                              .messages[
                                                                  reversedIndex]
                                                              .from !=
                                                          id
                                                      ? white
                                                      : gray100,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Container(
              width: size.width,
              color: white,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _getImagesFromGallery().then((value) {
                        List<File> parseImagePaths(List<String> imagePaths) {
                          List<File> imageFiles = [];
                          for (String path in imagePaths) {
                            imageFiles.add(File(path));
                            if (mounted) setState(() {});
                          }
                          if (mounted) setState(() {});
                          return imageFiles;
                        }

                        List<File> imageFiles = parseImagePaths(value);
                        /*
                        mainListener.sendtFiles(
                            widget.userPhone,
                            controller.text,
                            DateTime.now().millisecondsSinceEpoch.toString(),
                            imageFiles[0]);

                        */
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: surfacePrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(AssetLib.clip),
                    ),
                  ),
                  Container(
                    width: size.width * 0.68,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    child: TextField(
                      autofocus: false,
                      maxLines: 3,
                      minLines: 1,
                      controller: controller,
                      scrollPadding: const EdgeInsets.all(0),
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) {
                        if (mounted) setState(() {});
                      },
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: w500,
                        color: black,
                        fontFamily: "InterTight",
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(0),
                        hintText: "Напишите сообщение",
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: w500,
                          color: gray100,
                          fontFamily: "InterTight",
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
                  if (controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () async {
                        int id = DateTime.now().millisecondsSinceEpoch;
                        if (controller.text.isEmpty) {
                          return;
                        }
                        /*
                        chats[indexChat].messages.add(
                              Message(
                                id: id.toString(),
                                from: myPhone ?? "",
                                text: controller.text,
                                time: id.toString(),
                              ),
                            );
                        mainListener.sendTypeMess(
                            widget.userPhone.split(" ").first,
                            controller.text,
                            "$id");

                        */
                        controller.text = '';
                        if (mounted) setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(AssetLib.arrowsChat),
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<List<String>> _getImagesFromGallery() async {
    final picker = ImagePicker();
    List<XFile>? images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      List<String> imagePaths = [];

      for (XFile image in images) {
        File file = File(image.path);
        imagePaths.add(file.path);
      }

      return imagePaths;
    }
    return [];
  }
}

// List<dynamic> chats[indexChat] = [
//   {
//     "id": 0,
//     "new": false,
//     "date": "14:08",
//     "from": "me",
//     "message":
//         "Слава, добрый день! Посоветуй пожалуйста в каком банке лучше взять ипотеку?",
//   },
//   {
//     "id": 1,
//     "new": true,
//     "date": "13:32",
//     "from": "servis",
//     "message": "Приветствую!",
//   },
//   {
//     "id": 1,
//     "new": true,
//     "date": "13:33",
//     "from": "servis",
//     "message":
//         "Я бы посоветовал Сбер, там неплохие условия для работников твоей сферы!",
//   },
//   {
//     "id": 2,
//     "new": true,
//     "date": "14:08",
//     "from": "me",
//     "message": "Понял, спасибо большое",
//   },
//   {
//     "id": 3,
//     "new": true,
//     "date": "12:41",
//     "from": "me",
//     "img": "https://www.fonstola.ru/pic/201310/1600x900/fonstola.ru_123406.jpg",
//     "message": "Хочу застраховать свою тачку, посоветую страховую",
//   },
// ];
