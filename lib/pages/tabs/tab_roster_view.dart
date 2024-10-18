import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infoservice/models/bg_tasks_model.dart';
import 'package:infoservice/widgets/rounded_button_widget.dart';

import '../../helpers/log.dart';
import '../../helpers/phone_mask.dart';
import '../../models/roster_model.dart';
import '../../models/user_chat_model.dart';
import '../../models/user_settings_model.dart';
import '../../services/jabber_manager.dart';
import '../../services/permissions_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../widgets/chat/my_user.dart';
import '../../widgets/dialog_md.dart';
import '../../widgets/user_widget.dart';
import '../auth/authorization.dart';
import '../chat/add2roster.dart';

class TabRosterView extends StatefulWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Function setStateCallback;
  final PageController pageController;

  const TabRosterView(
      {this.sipHelper,
      this.xmppHelper,
      required this.pageController,
      required this.setStateCallback,
      Key? key})
      : super(key: key);

  @override
  _TabRosterViewState createState() => _TabRosterViewState();
}

class _TabRosterViewState extends State<TabRosterView> {
  static const tag = 'TabRosterView';

  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;

  TextEditingController controller = TextEditingController();
  UserSettingsModel? user;
  List<RosterModel> myRoster = [];
  bool isRegistered = false;
  bool contactsDialogShowed = false;
  bool contactsUpdated = false;
  bool storageDialogShowed = false;
  bool storageGranted = false;
  Timer? updateTimer;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    if (updateTimer != null) {
      updateTimer!.cancel();
    }
    controller.dispose();
    super.dispose();
  }

  // Обновление состояния
  void setStateCallback(Map<String, dynamic> state) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    checkUser().then((result) {
      Future.delayed(Duration.zero, () async {
        updateTimer =
            Timer.periodic(const Duration(seconds: 2), (Timer t) async {
          await checkUser();
          await checkContacts();
          await checkStoragePermissions();
        });
      });
    });

    /* Вылетает без разрешений на контакты */
    /*
    for (int i=0; i<20000; i++) {
      String phone = (89000000001 + i).toString();
      ContactsManager.createContact(name: 'test_$i', phone: phone).then((result) {
        print("+++++++++++ $i");
      });
    }
    ContactsService.getContacts(withThumbnails: false).then((result) {
      List<Contact> all = result;
      print("+++++++++++ ${all.length}");
    });
    */

    controller.addListener(() {
      final text = controller.text.toLowerCase();
      print('Search in roster: $text, len ${text.characters.length}');
      for (int i=0; i<myRoster.length; i++) {
        RosterModel r = myRoster[i];
        if (text.isEmpty) {
          r.visible = true;
        } else {
          if ((r.name ?? '').toLowerCase().contains(text) || (r.jid ?? '').contains(text)) {
            r.visible = true;
          } else {
            r.visible = false;
          }
        }
      }
      setState(() {});
    });
  }

  Future<void> checkUser() async {
    UserSettingsModel? userSettings = await UserSettingsModel().getUser();
    if (userSettings != null) {
      if (isRegistered != (userSettings.isXmppRegistered == 1)) {
        Log.d(tag,
            'isRegistered changed $isRegistered=>${userSettings.isXmppRegistered}');
        setState(() {
          isRegistered = userSettings.isXmppRegistered == 1;
        });
        contactsUpdated = false;
      }
      // Объекты будут разными, проверяем по identical
      if (mounted && !userSettings.isEqual(user ?? UserSettingsModel())) {
        setState(() {
          user = userSettings;
        });
        await loadRoster();
        contactsUpdated = false;
      }
    } else {
      if (isRegistered) {
        setState(() {
          isRegistered = false;
        });
      }
      contactsUpdated = true;
    }
  }

  Future<void> loadRoster() async {
    if (user == null) {
      return;
    }
    String myJid = user?.jid ?? '';
    myRoster = await RosterModel().getByOwner(myJid);
    for (RosterModel r in myRoster) {
      String rJid = r.jid ?? '';
      if (r.name != null) {
        if (rJid.startsWith(r.name!)) {
          await JabberManager.checkMucCompany(r);
        }
      } else {
        /*
        // Проверка по названию комании
        String phone = cleanPhone(rJid);
        Orgs? org = await Orgs().getOrgByChat(phone);
        if (org != null && org.name != null && org.name != '') {
          r.name = org.name;
        }
        */
      }
    }
    myRoster.sort(
        (a, b) => (b.lastMessageTime ?? 0).compareTo((a.lastMessageTime ?? 0)));
    setState(() {});
  }

  Future<void> checkStoragePermissions() async {
    if (storageDialogShowed || storageGranted) {
      return;
    }
    storageDialogShowed = true;
    bool granted = await PermissionsManager().checkPermissions('storage');
    if (granted) {
      storageGranted = true;
    } else {
      await PermissionsManager().requestPermissions('storage');
      storageDialogShowed = true;
    }
  }

  Future<void> checkContacts() async {
    if (contactsUpdated) {
      return;
    }
    bool granted = await PermissionsManager().checkPermissions('contacts');
    if (granted) {
      contactsUpdated = true;
      await BGTasksModel.getContactsFromPhoneTask();
      //await JabberManager.updateChatsWithCompanyNames();
    } else {
      await checkContactsPermission();
    }
  }

  Future<void> checkContactsPermission() async {
    if (!contactsDialogShowed && mounted) {
      contactsDialogShowed = true;
      showDialog(
          context: context,
          builder: (context) {
            return DialogMDWidget(
              mdFileName: 'contacts_warning.md',
              callback: () async {
                await PermissionsManager().requestPermissions('contacts');
              },
            );
          });
    }
  }

  Widget buildAuthButton() {
    return RoundedButtonWidget(
      text: const Text('Вход / Регистрация'),
      minWidth: 200.0,
      onPressed: () {
        Navigator.pushNamed(context, AuthScreenWidget.id);
      },
    );
  }

  Widget buildRosterSearch() {
    return Container(
      margin: PAD_SYM_H20,
      //height: 60.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(.15),
            offset: const Offset(0, 10),
            blurRadius: 20,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 12),
            child: SvgPicture.asset(
              SEARCH_ICON,
              height: 20,
            ),
          ),
          //SIZED_BOX_W20,
          Expanded(
            child: FocusScope(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  decoration: TextDecoration.none,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                      left: 15, top: 5, bottom: 5, right: 10),
                  border: InputBorder.none,
                  hintText: 'Поиск...',
                  suffix: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      controller.clear();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildView() {
    final halfWidth = MediaQuery.of(context).size.width * 0.4;

    return Column(
      children: [
        SIZED_BOX_H20,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                widget.setStateCallback({
                  'setPageview': 4,
                });
              },
              child: MyUser(
                label: 'Я, ${user?.getName() ?? "не авторизован"}',
                imgPath: user?.getPhoto() ?? DEFAULT_AVATAR,
                isReady: true,
                isOnline: user?.getRegistered() ?? false,
                labelWidth: halfWidth,
                showIndicator: true,
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, Add2RosterScreen.id);
              },
              child: MyUser(
                label: 'Добавить...',
                imgPath: 'assets/avatars/add_contact.png',
                isOnline: false,
                labelWidth: halfWidth,
              ),
            ),
          ],
        ),
        SIZED_BOX_H20,
        user != null ? buildRosterSearch() : buildAuthButton(),
        SIZED_BOX_H20,
        Expanded(
          child: buildContacts(),
        ),
      ],
    );
  }

  String formatTime(String time) {
    return time.substring(time.length - 2);
  }

  ListView buildContacts() {
    final String myJid = user?.jid ?? '';
    if (myRoster.isEmpty) {
      return ListView(
        children: const [
          SIZED_BOX_H12,
          Center(
            child: Text('Список контаков пуст'),
          ),
        ],
      );
    }
    return ListView.builder(
      itemCount: myRoster.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        vertical: 30,
      ),
      itemBuilder: (context, index) {
        RosterModel rosterModel = myRoster[index];
        bool visible = rosterModel.visible;
        String login = rosterModel.jid ?? '';
        String phone = cleanPhone(login);
        String prettyPhone = phoneMaskHelper(phone);
        final item = UserChatModel(
          login: login,
          name: rosterModel.name ?? prettyPhone,
        );
        if (rosterModel.isGroup == 1) {
          rosterModel.lastMessage = 'Группа';
          bool isCompany = false;
          bool isChannel = false;
          if (rosterModel.jid!.startsWith('company_')) {
            isCompany = true;
          }
          if (rosterModel.jid!.startsWith('channel_')) {
            isChannel = true;
          }
          if (rosterModel.jid != null && (isCompany || isChannel)) {
            List<String> comparts = rosterModel.jid!.split('@')[0].split('_');
            String comphone = '';
            if (comparts.length == 3) {
              comphone = comparts[2];
            }

            if (isCompany) {
              if (comphone == cleanPhone(myJid)) {
                rosterModel.lastMessage = 'Чат с компанией';
              } else {
                rosterModel.name = comphone;
                rosterModel.lastMessage = 'Обращение в компанию';
              }
            }
            if (isChannel) {
              rosterModel.lastMessage = 'Канал';
              try {
                int.parse(comparts[1]);
              } catch (ex) {
                print(ex);
                rosterModel.name = comparts[1];
              }
            }
          } else {
            item.name = rosterModel.name;
            item.msg = 'Группа';
          }
        }
        if (rosterModel.name == null ||
            rosterModel.name == '' ||
            rosterModel.name!.endsWith(JABBER_SERVER)) {
          rosterModel.name = prettyPhone;
        }
        if (rosterModel.lastMessage == null || rosterModel.lastMessage == '') {
          rosterModel.lastMessage = prettyPhone;
        }
        return Visibility(
          visible: visible,
          child: Dismissible(
            key: UniqueKey(),
            background: Container(color: Colors.red),
            onDismissed: (direction) async {
              RosterModel curItem = myRoster[index];
              await BGTasksModel.dropRosterTask({'id': curItem.id});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${item.getName()} удален из контактов')));
              }
            },
            child: ChatUserWidget(
              xmppHelper: xmppHelper,
              rosterModel: rosterModel,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: buildView());
  }
}
