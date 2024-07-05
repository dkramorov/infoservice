import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infoservice/helpers/context_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app_asset_lib.dart';
import '../../../gl.dart';
import '../../../themes.dart';
import '../../../../widgets/button.dart';
import '../../../../widgets/modal.dart';
import '../../../../widgets/user_support_button.dart';
import '../auth/generic_info_page.dart';
import '../auth/login.dart';
import '../big_picture_screens.dart';
import '../splash_screens.dart';
import 'model/profile_item_model.dart';
import '../../../profile/settings_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfacePrimary,
      body: SizedBox(
        width: context.screenSize.width,
        height: context.screenSize.height,
        child: Stack(
          children: [
            Container(
              height: 290,
              width: context.screenSize.width,
              decoration: BoxDecoration(
                color: blue,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SizedBox(
                      width: context.screenSize.width * 0.6,
                      child: Image.asset(AssetLib.union1),
                    ),
                  ),
                  if (myPhone == null)
                    Positioned(
                      top: 68,
                      left: 32,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Войдите",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: w500,
                              color: white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Чтобы делать звонки\nи общаться в чатах",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: w500,
                              color: white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                side: BorderSide.none,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => const LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Войти",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: w500,
                                color: black,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  else
                    Positioned(
                      top: 60,
                      left: 32,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                              image: DecorationImage(
                                image: NetworkImage(
                                    "https://celes.club/uploads/posts/2022-06/1654812752_40-celes-club-p-muzhchina-v-kostyume-oboi-krasivie-42.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      showModal(
                                        context,
                                        context.screenSize.height * 0.15,
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 12,
                                                  ),
                                                  color: transparent,
                                                  width:
                                                      context.screenSize.width -
                                                          32,
                                                  child: Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                          AssetLib.camera),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        "Сделать фото",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: w400,
                                                          color: black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  color: transparent,
                                                  width:
                                                      context.screenSize.width -
                                                          32,
                                                  child: Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                          AssetLib.gallery),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        "Загрузить из галереи",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: w400,
                                                          color: black,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Color.fromRGBO(0, 0, 0, 0.08),
                                            blurRadius: 2.0,
                                            spreadRadius: 0.0,
                                            offset: Offset(0, 2),
                                          ),
                                          BoxShadow(
                                            color:
                                                Color.fromRGBO(0, 0, 0, 0.08),
                                            blurRadius: 4.0,
                                            spreadRadius: 0.0,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: SvgPicture.asset(AssetLib.edit),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name ?? 'Пользователь',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: w500,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    )
                ],
              ),
            ),
            Positioned(
              top: token.isEmpty ? 230 : 206,
              left: 16,
              child: Column(
                children: [
                  Container(
                    width: context.screenSize.width - 32,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        children: List.generate(
                            profileItemCurrent.length,
                            (i) => ProfileItemWidget(
                                  text: profileItemCurrent[i].title,
                                  icon: profileItemCurrent[i].icon,
                                  onTap: (i == 4 && myPhone != null)
                                      ? _showModalWindowHere
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (c) =>
                                                  profileItemCurrent[i]
                                                      .destinationSpecial ??
                                                  InfoPage(
                                                    appBarTitle:
                                                        profileItemCurrent[i]
                                                            .appBarTitle,
                                                    title: profileItemCurrent[i]
                                                        .title,
                                                    description:
                                                        profileItemCurrent[i]
                                                            .description,
                                                  ),
                                            ),
                                          );
                                        },
                                )),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const UserSupportButton(),
                  SizedBox(
                    width: context.screenSize.width - 32,
                    child: ProfileItemWidget(
                        text: 'TEST APP PAGES',
                        icon: 'icon',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => const BigPictureScreensTestPage()))),
                  ),
                  SizedBox(
                    width: context.screenSize.width - 32,
                    child: ProfileItemWidget(
                        text: 'SPLASH SCREENS',
                        icon: 'icon',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => const SplashScreensTestPage()))),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showModalWindowHere() {
    showModal(
      context,
      context.screenSize.height * 0.3,
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Вы уверены, что хотите выйти из профиля?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: w500,
                color: black,
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                name = null;
                myPhone = null;
                pass = null;
                sex = null;
                date = null;
                email = null;
                if (prefs.containsKey('name')) {
                  await prefs.remove("name").then((value) {
                    Navigator.pop(context);
                    setState(() {});
                  });
                }
                if (prefs.containsKey('phone')) {
                  prefs.remove("phone");
                }
                if (prefs.containsKey('email')) {
                  prefs.remove("email");
                }
                if (prefs.containsKey('password')) {
                  prefs.remove("password");
                }
                if (prefs.containsKey('sex')) {
                  prefs.remove("sex");
                }
                if (prefs.containsKey('date')) {
                  prefs.remove("date");
                }
              },
              color: blue,
              child: Text(
                "Выйти",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: w500,
                  color: white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              onPressed: () {
                Navigator.pop(context);
              },
              color: surfacePrimary,
              child: Text(
                "Отмена",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: w500,
                  color: black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
