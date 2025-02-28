import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infoservice/helpers/context_extensions.dart';
import 'package:infoservice/helpers/dialogs.dart';
import 'package:infoservice/models/user_chat_model.dart';
import 'package:infoservice/pages/profile/about_page.dart';
import 'package:infoservice/services/shared_preferences_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/log.dart';
import '../../helpers/network.dart';
import '../../models/bg_tasks_model.dart';
import '../../models/user_settings_model.dart';
import '../../services/jabber_manager.dart';
import '../../services/permissions_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../services/update_manager.dart';
import '../../settings.dart';
import '../../widgets/chat/online_indicator.dart';
import '../../widgets/dialog_md.dart';
import '../../widgets/my_elevated_button_widget.dart';
import '../../widgets/rounded_button_widget.dart';
import '../../widgets/user_support_button.dart';
import '../app_asset_lib.dart';
import '../auth/authorization.dart';
import '../profile/settings_page.dart';
import '../themes.dart';

class TabProfileView extends StatefulWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Function setStateCallback;
  final PageController pageController;

  const TabProfileView(
      {this.sipHelper,
      this.xmppHelper,
      required this.pageController,
      required this.setStateCallback,
      Key? key})
      : super(key: key);

  @override
  _TabProfileViewState createState() => _TabProfileViewState();
}

class _TabProfileViewState extends State<TabProfileView> {
  static const String tag = 'TabProfileView';

  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;

  UserChatModel? user = UserChatModel();
  UserSettingsModel? userSettings;
  bool isRegistered = false;
  bool _editModeDisabled = true;
  bool hasInternet = false;
  String photo = DEFAULT_AVATAR;

  String name = '';
  TextEditingController nameController = TextEditingController();
  String email = '';
  TextEditingController emailController = TextEditingController();
  String birthday = '';
  TextEditingController birthdayController = TextEditingController();
  int gender = 1;
  int dropPersonalDataFlag = 0; // пока пишем в user.status
  late Timer updateTimer;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> checkUser() async {
    SharedPreferences prefs =
        await SharedPreferencesManager.getSharedPreferences();
    setState(() {
      hasInternet = prefs.getBool('checkInternetConnection') ?? false;
    });

    if (userSettings != null) {
      return;
    }
    userSettings ??= await UserSettingsModel().getUser();
    if (userSettings != null) {
      setState(() {
        name = userSettings!.name ?? '';
        email = userSettings!.email ?? '';
        gender = userSettings!.gender ?? 1;
        birthday = userSettings!.birthday ?? '';
        if (userSettings!.isDropped ?? false) {
          dropPersonalDataFlag = 1;
        }
        if (userSettings!.photo != null && userSettings!.photo != '') {
          photo = userSettings!.photo!;
        }
        print('received ${userSettings.toString()}');
        nameController.text = name;
        emailController.text = email;
        birthdayController.text = birthday;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkUser().then((result) {
      Future.delayed(Duration.zero, () async {
        updateTimer =
            Timer.periodic(const Duration(seconds: 1), (Timer t) async {
          await checkUser();
        });
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    updateTimer.cancel();
    nameController.dispose();
    emailController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  // Обновление состояния
  void setStateCallback(Map<String, dynamic> newState) {
    setState(() {});
  }

  Future<void> dropAccount() async {
    userSettings = await UserSettingsModel().getUser();
    if (userSettings != null) {
      userSettings!.updatePartial(userSettings!.id, {'isDropped': true});
      await logout();
    }
  }

  Future<void> logout() async {
    await BGTasksModel.createUnregisterTask();
    xmppHelper?.setStopFlag(true);
    sipHelper?.setStopFlag(true);
    Future.delayed(Duration.zero, () async {
      Navigator.pushNamed(context, AuthScreenWidget.id, arguments: {
        sipHelper,
        xmppHelper,
      });
    });
  }

  /* Загрузка изображения */
  void handleImageSelection({ImageSource source = ImageSource.gallery}) async {
    final XFile? result = await _imagePicker.pickImage(
      source: source,
    );
    if (result != null) {
      Log.d(tag, 'handleImageSelection ${result.path}');
      onPickImage(result.path);
    } else {
      // User canceled the picker
    }
  }

  Future<void> onPickImage(String fname) async {
    // Проверка и/или запрос прав на хранилище
    await PermissionsManager().requestPermissions('storage');

    final File file = File(fname);
    final bytes = await file.readAsBytes();
    final imageName = 'my_photo_${file.path.split('/').last}';

    final File dest = await getLocalFilePath(imageName);
    dest.writeAsBytes(bytes);

    // Записать в базу
    Map<String, dynamic> values = {
      'photo': dest.path,
    };

    userSettings = await UserSettingsModel().getUser();
    if (userSettings != null) {
      userSettings!.photo = values['photo'];
      userSettings!.updatePartial(userSettings!.id, values);
      await BGTasksModel.updateMyVCardTask({
        'PHOTO': values['photo'],
      });
    }
    setState(() {
      photo = values['photo'];
    });
    //setStateCallback({'photo': dest.path});
    //uploadImage(bytes, imageName);
  }

  // Старый вариант
  Widget buildView() {
    return Container(
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 250.0,
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        top: 20.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(
                            Icons.phone_iphone,
                            color: Colors.black54,
                            size: 24.0,
                          ),
                          OnlineIndicator(
                            width: 0.26 * 50,
                            height: 0.26 * 50,
                            isOnline: hasInternet,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: Text(
                              userSettings?.phone ?? 'Ваш профиль',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Stack(
                        fit: StackFit.loose,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              buildPhotoImage(),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 90.0,
                              right: 100.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  child: const CircleAvatar(
                                    backgroundColor: tealColor,
                                    radius: 25.0,
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    handleImageSelection();
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 25.0,
                          right: 25.0,
                          top: 25.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Персональная информация',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _editModeDisabled
                                    ? _getEditIcon()
                                    : Container(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 25.0,
                          right: 25.0,
                          top: 25.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Ваше имя',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 25.0,
                          right: 25.0,
                          top: 2.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Flexible(
                              child: TextFormField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Введите ваше имя',
                                ),
                                enabled: !_editModeDisabled,
                                autofocus: !_editModeDisabled,
                                onChanged: (newName) {
                                  setState(() {
                                    name = newName;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 25.0,
                          right: 25.0,
                          top: 25.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Ваш Email',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 25.0,
                          right: 25.0,
                          top: 2.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                              child: TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  hintText: 'Введите ваш Email',
                                ),
                                enabled: !_editModeDisabled,
                                onChanged: (newEmail) {
                                  setState(() {
                                    email = newEmail;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 25.0,
                          right: 25.0,
                          top: 25.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'Дата рождения',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.center,
                                child: const Text(
                                  'Пол',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 25.0,
                          right: 25.0,
                          top: 2.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: TextFormField(
                                  controller: birthdayController,
                                  decoration: const InputDecoration(
                                    hintText: 'Дата рождения',
                                  ),
                                  enabled: !_editModeDisabled,
                                  onChanged: (newBirthday) {
                                    setState(() {
                                      birthday = newBirthday;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: _buildSelectGender(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 25.0,
                          right: 25.0,
                          top: 25.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Flexible(
                              flex: 2,
                              child: Text(
                                'Удалить личные\nданные о себе\nна сервере\n(не хранить)?',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: _buildSelectDropPersonalData(),
                            ),
                          ],
                        ),
                      ),
                      !_editModeDisabled
                          ? _getActionButtons()
                          : buildLogoutButton(),
                    ],
                  ),
                ),
              ),

              /* Теперь нельзя т/к Expanded - высоты нет */
              //const TermsWidget(),

              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: TextButton(
                        child: const Row(
                          children: [
                            Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            Text(
                              'Удалить аккаунт',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                        onPressed: () {
                          openInfoDialog(
                              context,
                              dropAccount,
                              'Удалить аккаунт?',
                              'Вы действительно хотите удалить аккаунт?',
                              'Да, удалить',
                              cancelText: 'Отмена',
                              okColor: Colors.red);
                        },
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(right: 30.0),
                          alignment: Alignment.centerRight,
                          child: FutureBuilder<String>(
                            future: fetchAppVersion(),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  snapshot.data ?? '',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                );
                              } else {
                                return const Text('-');
                              }
                            },
                          ),
                        ),
                        SIZED_BOX_H04,
                        Container(
                          padding: const EdgeInsets.only(right: 30.0),
                          alignment: Alignment.centerRight,
                          child: FutureBuilder<int>(
                              future: fetchUpdateVersion(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<int> snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    'Версия бд: ${snapshot.data}',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                  );
                                } else {
                                  return const Text('');
                                }
                              }),
                        ),
                        FutureBuilder<String>(
                          future: getBgTimer(),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data ?? '',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                              );
                            } else {
                              return const Text('-');
                            }
                          },
                        ),
                      ],
                    )
                  ]),
              SIZED_BOX_H20,
            ],
          ),
        ],
      ),
    );
  }

  Future<String> fetchAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  Future<int> fetchUpdateVersion() async {
    SharedPreferences prefs =
        await SharedPreferencesManager.getSharedPreferences();
    return prefs.getInt(CompaniesUpdateVersion.CAT_VERSION_KEY) ?? 0;
  }

  Future<String> getBgTimer() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    return preferences.getString('bg_timer') ?? '';
  }

  Future<void> saveUserData({
    String? name,
    String? email,
    String? birthday,
    int? gender,
  }) async {
    userSettings = await UserSettingsModel().getUser();
    // Записать в базу
    Map<String, dynamic> values = {
      'name': name,
      'email': email,
      'birthday': birthday,
      'gender': gender,
      'isDropped': dropPersonalDataFlag == 1 ? 't' : 'f',
    };

    if (userSettings != null) {
      userSettings?.updatePartial(userSettings?.id, values);
      await BGTasksModel.updateMyVCardTask({
        'FN': name,
        'BDAY': birthday,
        'EMAIL': email,
      });
    }
    setState(() {});
  }

  Widget _buildSelectGender() {
    return _editModeDisabled
        ? Center(
            child: Text(gender == 1 ? 'Муж' : 'Жен'),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Жен'),
              Switch(
                value: gender == 1 ? true : false,
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      gender = 1;
                    } else {
                      gender = 2;
                    }
                  });
                },
                activeTrackColor: tealColor,
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: tealColor,
              ),
              const Text('Муж'),
            ],
          );
  }

  Widget _getActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: MyElevatedButton(
                color: tealColor,
                onPressed: () async {
                  await saveUserData(
                    name: name,
                    email: email,
                    birthday: birthday,
                    gender: gender,
                  );
                  setState(() {
                    _editModeDisabled = true;
                  });
                },
                child: const Text('Сохранить'),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: MyElevatedButton(
                onPressed: () {
                  setState(() {
                    _editModeDisabled = true;
                  });
                },
                color: Colors.red,
                child: const Text(
                  'Отмена',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 25.0,
        right: 25.0,
        top: 45.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoundedButtonWidget(
            text: const Text(
              'Выход',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            color: Colors.red,
            onPressed: () {
              logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: const CircleAvatar(
        backgroundColor: tealColor,
        radius: 14.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _editModeDisabled = false;
        });
      },
    );
  }

  Widget _buildSelectDropPersonalData() {
    return _editModeDisabled
        ? Center(
            child: Text(dropPersonalDataFlag == 1 ? 'Да' : 'Нет'),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Нет'),
              Switch(
                value: dropPersonalDataFlag == 1 ? true : false,
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      dropPersonalDataFlag = 1;
                    } else {
                      dropPersonalDataFlag = 0;
                    }
                  });
                },
                activeTrackColor: tealColor,
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: tealColor,
              ),
              const Text('Да'),
            ],
          );
  }

  Widget buildPhotoImage() {
    ImageProvider userPhoto = const AssetImage(DEFAULT_AVATAR);

    if (photo != '' && photo != DEFAULT_AVATAR) {
      if (photo.startsWith('http')) {
        return CachedNetworkImage(
          height: 120.0,
          width: 120.0,
          imageUrl: photo,
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) => Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      } else {
        userPhoto = FileImage(File(photo));
      }
    }

    return Container(
      width: 140.0,
      height: 140.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: userPhoto,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Старый вариант
  Widget buildAuthorizedView() {
    return SizedBox(
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
                Positioned(
                  top: 60,
                  left: 32,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        fit: StackFit.loose,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              buildPhotoImage(),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 90.0,
                              right: 100.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  child: const CircleAvatar(
                                    backgroundColor: tealColor,
                                    radius: 25.0,
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    handleImageSelection();
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
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
            top: 206,
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
                      children: [
                        ProfileItemWidget(
                          text: 'Ваши данные',
                          icon: 'settings',
                          onTap: () async {
                            Navigator.pushNamed(context, SettingsPage.id,
                                arguments: {
                                  sipHelper,
                                  xmppHelper,
                                });
                          },
                        ),
                        ProfileItemWidget(
                          text: 'Политика конфиденциальности',
                          icon: 'file',
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return DialogMDWidget(
                                      mdFileName: 'privacy_policy.md');
                                });
                          },
                        ),
                        ProfileItemWidget(
                          text: 'Условия предоставления услуг',
                          icon: 'file',
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return DialogMDWidget(
                                      mdFileName: 'terms_and_conditions.md');
                                });
                          },
                        ),
                        ProfileItemWidget(
                          text: 'Выйти',
                          icon: 'logout',
                          onTap: () async {
                            await logout();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const UserSupportButton(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildUnauthorizedView() {
    /* Показываем для неавторизованного пользователя */
    /* /// Старый вариант
    return Stack(
      children: [
        RoundedButtonWidget(
          text: const Text('Вход / Регистрация'),
          minWidth: 200.0,
          onPressed: () {
            Navigator.pushNamed(context, AuthScreenWidget.id);
          },
        ),
        Positioned(
          left: 0,
          top: 0,
          child: OnlineIndicator(
            width: 0.26 * 50,
            height: 0.26 * 50,
            isOnline: hasInternet,
          ),
        ),
      ],
    );
    */

    return SizedBox(
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
                Positioned(
                  top: 68,
                  left: 32,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Войдите',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: w500,
                          color: white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Чтобы делать звонки\nи общаться в чатах',
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
                          Navigator.pushNamed(context, AuthScreenWidget.id);
                        },
                        child: Text(
                          'Войти',
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
              ],
            ),
          ),
          Positioned(
            top: 230,
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
                      children: [
                        ProfileItemWidget(
                          text: 'Политика конфиденциальности',
                          icon: 'file',
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return DialogMDWidget(
                                      mdFileName: 'privacy_policy.md');
                                });
                          },
                        ),
                        ProfileItemWidget(
                          text: 'Условия предоставления услуг',
                          icon: 'file',
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return DialogMDWidget(
                                      mdFileName: 'terms_and_conditions.md');
                                });
                          },
                        ),
                        ProfileItemWidget(
                          text: 'О приложении',
                          icon: 'logo',
                          onTap: () {
                            Navigator.pushNamed(context, AboutPage.id,
                                arguments: {
                                  sipHelper,
                                  xmppHelper,
                                });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Неавторизованным не показываем
                //const UserSupportButton(),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      //child: userSettings != null ? buildView() : buildUnauthorizedView(),
      child: userSettings != null
          ? buildAuthorizedView()
          : buildUnauthorizedView(),
    );
  }
}
