import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infoservice/models/user_chat_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../helpers/log.dart';
import '../../helpers/network.dart';
import '../../helpers/phone_mask.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../services/update_manager.dart';
import '../../settings.dart';
import '../../widgets/my_elevated_button_widget.dart';
import '../../widgets/rounded_button_widget.dart';
import '../authorization.dart';

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
  static const TAG = 'TabProfileView';

  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;

  late StreamSubscription<bool>? jabberSubscription;
  UserChatModel user = UserChatModel();
  bool isRegistered = false;
  bool _editModeDisabled = true;
  String photo = DEFAULT_AVATAR;

  String name = '';
  TextEditingController nameController = TextEditingController();
  String email = '';
  TextEditingController emailController = TextEditingController();
  String birthday = '';
  TextEditingController birthdayController = TextEditingController();
  int gender = 1;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      xmppHelper?.showConnectionStatus().then((success) async {
        isRegistered = xmppHelper?.registered ?? false;
        getUser();
      });
    });
    jabberSubscription =
        xmppHelper?.jabberStream.registration.listen((success) {
      setState(() {
        isRegistered = success;
      });
      if (success) {
        print('getRoster because isRegistered $success');
        getUser();
      }
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
    nameController.dispose();
    emailController.dispose();
    birthdayController.dispose();
    jabberSubscription?.cancel();
    super.dispose();
  }

  // Обновление состояния
  void setStateCallback(Map<String, dynamic> newState) {
    setState(() {});
  }

  void getUser() {
    String login = cleanPhone(xmppHelper?.getLogin() ?? '');
    UserChatModel defaultUser = UserChatModel(login: login);
    if (isRegistered) {
      UserChatModel().getByLogin(login).then((result) {
        setState(() {
          user = result ?? defaultUser;
          if (user.name != null) {
            nameController.text = user.name!;
            name = nameController.text;
          }
          if (user.email != null) {
            emailController.text = user.email!;
            email = emailController.text;
          }
          if (user.birthday != null) {
            birthdayController.text = user.birthday!;
            birthday = birthdayController.text;
          }
          if (user.gender != null) {
            gender = user.gender!;
          }
        });
        Log.i(TAG, 'fetched user from db by login $login: ${user.toString()}');
      });
    } else {
      setState(() {
        user = defaultUser;
        user.login = 'Ваш профиль';
      });
    }
  }

  void ifPhotoDownloaded(String path) {
    /* Если фотка загрузилась с сервера */
    setState(() {
      photo = path;
    });
  }

  /* Загрузка изображения */
  void handleImageSelection({ImageSource source = ImageSource.gallery}) async {
    final XFile? result = await _imagePicker.pickImage(
      source: source,
    );
    if (result != null) {
      Log.d(TAG, 'handleImageSelection ${result.path}');
      onPickImage(result.path);
    } else {
      // User canceled the picker
    }
  }

  Future<void> onPickImage(String fname) async {
    final storagePerms = await Permission.storage.status;
    if (!storagePerms.isGranted) {
      Log.e(TAG, 'Permissions absents');
      await [
        Permission.storage,
      ].request();
    }
    final File file = File(fname);
    final bytes = await file.readAsBytes();
    final imageName = 'my_photo_${file.path.split('/').last}';

    final String destFolder = await makeAppFolder();
    final File dest = File('$destFolder/$imageName');
    dest.writeAsBytes(bytes);

    // Записать в базу
    Map<String, dynamic> values = {
      'photo': dest.path,
    };
    user.photo = dest.path;
    if (user.id != null) {
      await user.updatePartial(
        user.id,
        values,
      );
    } else {
      int pk = await user.insert2Db();
      user.id = pk;
    }
    // Обновить UI

    setState(() {});
    //setStateCallback({'photo': dest.path});
    //uploadImage(bytes, imageName);
  }

  Widget buildView() {
    ImageProvider photo = const AssetImage(DEFAULT_AVATAR);
    if (user.photo != null && user.photo != '') {
      photo = FileImage(File(user.photo!));
    }

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
                          Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: Text(
                              user.login ?? 'Ваш профиль',
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
                              Container(
                                width: 140.0,
                                height: 140.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: photo,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
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
                                    backgroundColor: Colors.green,
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
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
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
                      Padding(
                        padding: const EdgeInsets.only(
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
                              children: const [
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
                      Padding(
                        padding: const EdgeInsets.only(
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
                              children: const [
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
                      !_editModeDisabled
                          ? _getActionButtons()
                          : buildLogoutButton(),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(right: 30.0),
                alignment: Alignment.centerRight,
                child: FutureBuilder<String>(
                  future: fetchAppVersion(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade300,
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
                width: double.infinity,
                padding: const EdgeInsets.only(right: 30.0),
                alignment: Alignment.centerRight,
                child: FutureBuilder<int>(
                    future: fetchUpdateVersion(),
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          'Версия бд: ${snapshot.data}',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                          ),
                        );
                      } else {
                        return const Text('');
                      }
                    }),
              ),
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
    return UpdateManager.preferences
            ?.getInt(CompaniesUpdateVersion.CAT_VERSION_KEY) ??
        0;
  }

  Future<void> saveUserData({
    String? name,
    String? email,
    String? birthday,
    int? gender,
  }) async {
    // Записать в базу
    if (xmppHelper?.registered ?? false) {
      Map<String, dynamic> values = {
        'name': name,
        'email': email,
        'birthday': birthday,
        'gender': gender,
      };
      if (user.id != null) {
        await user.updatePartial(
          user.id,
          values,
        );
      } else {
        user.name = name;
        user.email = email;
        user.birthday = birthday;
        user.gender = gender;
        user.id = await user.insert2Db();
      }
      setState(() {});
    }
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
                activeTrackColor: Colors.green,
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.green,
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
                color: Colors.green,
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
              // в async не пашет почему то await xmppHelper?.stop()
              xmppHelper?.stop();
              xmppHelper?.setStopFlag(true);
              sipHelper?.stop();
              sipHelper?.setStopFlag(true);
              Future.delayed(Duration.zero, () {
                Navigator.pushNamed(context, AuthScreenWidget.id, arguments: {
                  sipHelper,
                  xmppHelper,
                });
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: const CircleAvatar(
        backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isRegistered
          ? buildView()
          : RoundedButtonWidget(
              text: const Text('Вход / Регистрация'),
              minWidth: 200.0,
              onPressed: () {
                Navigator.pushNamed(context, AuthScreenWidget.id);
              },
            ),
    );
  }
}
