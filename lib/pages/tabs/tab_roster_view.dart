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
import '../authorization.dart';
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

  UserSettingsModel? user;
  List<RosterModel> myRoster = [];
  bool isRegistered = false;
  bool contactsDialogShowed = false;
  bool contactsUpdated = false;
  bool storageDialogShowed = false;
  bool storageGranted = false;
  late Timer updateTimer;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    updateTimer.cancel();
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
      if (!userSettings.isEqual(user ?? UserSettingsModel())) {
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
      if (r.name != null && r.jid!.startsWith(r.name!)) {
        await JabberManager.checkMucCompany(r);
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
    } else {
      await checkContactsPermission();
    }
  }

  Future<void> checkContactsPermission() async {
    if (!contactsDialogShowed) {
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
    final inputTextStyle = Theme.of(context).textTheme.subtitle2;
    return Container(
      margin: PAD_SYM_H20,
      padding: PAD_SYM_H20,
      alignment: Alignment.centerLeft,
      width: double.infinity,
      height: 50,
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
        children: [
          SvgPicture.asset(
            SEARCH_ICON,
            height: 16,
          ),
          SIZED_BOX_W20,
          Expanded(
            child: FocusScope(
              child: TextField(
                autofocus: false,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.name,
                style: inputTextStyle,
                expands: true,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Поиск...',
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
                imgPath: DEFAULT_AVATAR,
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
        user != null
            ? buildRosterSearch()
            : buildAuthButton(),
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
        vertical: 15,
      ),
      itemBuilder: (context, index) {
        RosterModel rosterModel = myRoster[index];
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
        return Dismissible(
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: buildView());
  }
}
