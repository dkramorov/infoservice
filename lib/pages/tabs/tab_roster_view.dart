import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infoservice/widgets/rounded_button_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../helpers/log.dart';
import '../../helpers/phone_mask.dart';
import '../../models/contact_model.dart';
import '../../models/roster_model.dart';
import '../../models/user_chat_model.dart';
import '../../services/jabber_manager.dart';
import '../../services/permissions_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../widgets/chat/my_user.dart';
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
  static const TAG = 'TabRosterView';

  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;

  late StreamSubscription<bool>? jabberSubscription;

  /* Нужна логика на показ ростера
     1) Запрос в бд и вывод ростера
     2) Запрос ростера с сервера (лучше не постоянно, пишем JabberManager время)
        Запрос getMyVCard для групп и добавление их к ростеру
        TODO: 1) при добавлении/удалении контакта/группы обновляем на сервере и в бд
     3) Обогащение бд ростером с сервера и обновление выведенного ростера
     4) Запрос адресной книги и запись в бд (лучше не постоянно - раз в сутки)
     5) Обогащение ростера адресной книгой и запись в бд
     6) Вывод результата
  */
  bool isRegistered = false;

  Map<String, ContactModel> contacts = {};
  List<RosterModel> rosterList = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      xmppHelper?.showConnectionStatus().then((success) {
        isRegistered = xmppHelper?.registered ?? false;
        if (isRegistered) {
          getRoster();
        }
      });
    });

    if (JabberManager.enabled) {
      jabberSubscription =
          xmppHelper?.jabberStream.registration.listen((success) {
        setState(() {
          isRegistered = success;
        });
        if (success) {
          getRoster();
        }
      });
    }

    loadContactsFromDb();
    checkContactsPermission();
    Future.delayed(const Duration(seconds: 3), () async {
      await checkNewChats();
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
    jabberSubscription?.cancel();
    super.dispose();
  }

  // Обновление состояния
  void setStateCallback(Map<String, dynamic> state) {
    setState(() {});
  }

  Future<void> addRosterItem2DB(RosterModel newRosterItem) async {
    /* Добавляем новый контакт в ростер */
    int pk = await newRosterItem.insert2Db();
    newRosterItem.id = pk;
    rosterList.add(newRosterItem);
  }

  Future<void> getRoster() async {
    isRegistered = xmppHelper?.registered ?? false;
    if (!isRegistered) {
      Log.d(TAG, '[ERROR]: not registered, do nothing');
      return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - JabberManager.lastRosterFetchTime - JabberManager.rosterFetchInterval;
    if (elapsed < 0) {
      Log.i(TAG, 'Next roster fetch will after ${elapsed / 1000} sec, pass...');
      return;
    }

    Future.delayed(const Duration(seconds: 1), () async {
      final List<Object?> chatUsers = await xmppHelper?.getRoster();
      List<Object?> chatMUCs = [];
      final String myJid = xmppHelper?.getJid() ?? '';
      // не получилось с MUC получением - при разлогине они пустые
      // если подключаться по getMyVcard, то на йосе хрен получишь свои - все НА
      // chatMUCs = await xmppHelper?.getMyMUCs();
      // Будем работать через getMyVCard

      Map<String, RosterModel> rosterMap = {};
      for (RosterModel rosterModel in rosterList) {
        rosterMap[rosterModel.jid ?? ''] = rosterModel;
      }

      Map<String, dynamic> descObj =
          await xmppHelper?.getVCardDescAsDict() ?? {};
      if (descObj['groups'] != null) {
        for (String group in descObj['groups'].keys) {
          final String groupJid = '$group@conference.$JABBER_SERVER';
          chatMUCs.add(groupJid);

          // Заибошиваем в ростер группы, которых там нет
          if (!rosterMap.containsKey(groupJid)) {
            RosterModel newRosterItem = RosterModel(jid: groupJid, ownerJid: myJid);
            await addRosterItem2DB(newRosterItem);
            rosterMap[newRosterItem.jid ?? ''] = newRosterItem;
          }
        }
      }

      for (Object? chatUser in chatUsers) {
        // Заибошиваем в ростер контакты, которых там нет
        String userJid = chatUser.toString();
        if (!rosterMap.containsKey(userJid)) {
          RosterModel newRosterItem = RosterModel(jid: userJid, ownerJid: myJid);
          await addRosterItem2DB(newRosterItem);
          rosterMap[newRosterItem.jid ?? ''] = newRosterItem;
        }
      }

      JabberManager.lastRosterFetchTime = now;
      setState(() {});

    });
  }

  Future<void> checkNewChats() async {
    // Смотрим кого не хватает в чатах из списка контактов
    Map<String, RosterModel> rosterMap = {};
    for (RosterModel rosterModel in rosterList) {
      rosterMap[cleanPhone(rosterModel.jid ?? '')] = rosterModel;
    }

    for (var phone in contacts.keys) {
      if (rosterMap[phone] != null) {
        // пользователь уже в ростере
        continue;
      }
      ContactModel curContact = contacts[phone]!;
      if (curContact.hasXMPP == 1) {
        // пользователь не в ростере, но имеет аккаунт XMPP
        Log.d(
            TAG, '$phone not in roster, but have XMPP account, try to add...');
        await searchUserForAdd2Roster(phone, curContact);
      } else if (contacts[phone]!.hasXMPP == 2) {
        // пользователь не в ростере, и не имеет аккаунт XMPP
        Log.d(
            TAG, '$phone not in roster and do not have XMPP account, pass...');
      } else {
        Log.d(TAG, '$phone not checked, checking...');
        // надо узнать имеет ли пользователь аккаунт в XMPP и записать
        await searchUserForAdd2Roster(phone, curContact);
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  Future<void> searchUserForAdd2Roster(
      String phone, ContactModel curContact) async {
    bool founded = false;
    List<dynamic>? users =
        await JabberManager.flutterXmpp?.searchUsers(phone) ?? [];
    List<String> result = [];
    for (String user in users) {
      String curUser = cleanPhone(user);
      result.add(curUser);
      if (curUser == phone) {
        founded = true;
        Log.d(TAG, 'founded by $phone: $result');
        curContact.hasXMPP = 1;
        curContact.insert2Db();
        xmppHelper?.add2Roster(curUser);
        Future.delayed(const Duration(seconds: 2), () async {
          await getRoster();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                  'Найден пользователь $curUser из списка контактов, чат добавлен'),
            ),
          );
        }
        break;
      }
    }
    if (!founded) {
      curContact.hasXMPP = 2;
      curContact.insert2Db();
    }
  }

  Future<Map<String, ContactModel>> loadContactsFromDb() async {

    rosterList = await RosterModel().getByOwner(xmppHelper?.getJid() ?? '');
    Log.d(TAG, 'DB roster received: ${rosterList.toString()}');
    setState(() {});

    if (contacts.isNotEmpty) {
      Log.d(TAG, 'Contacts already loaded ${contacts.toString()}');
      return contacts;
    }
    Map<String, ContactModel> result = {};
    List<ContactModel> dbContacts = await ContactModel().getAllContacts();
    // Если есть контакты, проверяем как давно обновляли их - раз в день пока
    int now = DateTime.now().millisecondsSinceEpoch;
    int longAgo = now - 60 * 60 * 12 * 1000;
    if (dbContacts.isNotEmpty) {
      if (dbContacts[0].updated != null) {
        if (dbContacts[0].updated! < longAgo) {
          dbContacts = await refreshContacts();
        }
      }
    } else {
      dbContacts = await refreshContacts();
    }
    for (ContactModel contact in dbContacts) {
      if (contact.phones == null) {
        continue;
      }
      List<String> phones = contact.phones!.split('|');
      for (String phone in phones) {
        String checkedPhone = cleanPhone(phone);
        if (checkedPhone.length == 11) {
          result[checkedPhone] = contact;
        }
      }
    }
    contacts = result;
    Log.d(TAG, 'Contacts loaded ${contacts.toString()}');
    return result;
  }

  Future<List<ContactModel>> refreshContacts() async {
    // Обработка контактов
    List<ContactModel> result = [];
    bool hasContactsPerms = await Permission.contacts.isGranted;
    if (!hasContactsPerms) {
      Log.i(TAG, 'Contacts permission absent');
      return result;
    }
    int now = DateTime.now().millisecondsSinceEpoch;
    List<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);
    // Удаляем нахер все контакты (т/к новые будем заливать)
    await ContactModel().dropAllRows();
    // Обновляем полученные из книги в БД
    for (Contact contact in contacts) {
      Map<String, dynamic> dest = ContactModel().toMap();
      Map<dynamic, dynamic> src = contact.toMap();
      for (var key in dest.keys) {
        dest[key] = src[key];
      }
      ContactModel contactModel = ContactModel().toModel(dest);
      contactModel.updated = now;
      await contactModel.insert2Db();
      result.add(contactModel);
    }
    return result;
  }

  Future<void> checkContactsPermission() async {
    await PermissionsManager().requestPermissions('contacts');
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
                label: 'Я, ${xmppHelper?.getLogin()}',
                imgPath: DEFAULT_AVATAR,
                isReady: true,
                isOnline: xmppHelper?.registered ?? false,
                labelWidth: halfWidth,
                showIndicator: true,
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, Add2RosterScreen.id);
                await getRoster();
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

        isRegistered
            ? buildRosterSearch()
            : RoundedButtonWidget(
                text: const Text('Вход / Регистрация'),
                minWidth: 200.0,
                onPressed: () {
                  Navigator.pushNamed(context, AuthScreenWidget.id);
                },
              ),

        // Обязательно в Expanded,
        // иначе будет не влазить
        Expanded(
          /*
          child: FutureBuilder<List>(
            future: fetchContacts(),
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              if (snapshot.hasData) {
                return buildContacts(snapshot.data ?? []);
              } else {
                return const Text('Произошла ошибка, попробуйте поздже');
              }
            },
          ),
          */
          child: buildContacts(),
        ),
      ],
    );
  }

  String formatTime(String time) {
    return time.substring(time.length - 2);
  }

  ListView buildContacts() {
    if (rosterList.isEmpty) {
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
      itemCount: rosterList.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        vertical: 15,
      ),
      itemBuilder: (context, index) {
        final item = UserChatModel(login: rosterList[index].jid);
        String login = item.login ?? '';
        String phone = cleanPhone(login);
        item.name = phoneMaskHelper(phone);
        if (contacts[phone] != null) {
          item.name = contacts[phone]?.displayName;
        } else if (JabberManager.isConference(login)) {
          item.name = login.split('@')[0];
          item.msg = 'Группа';
        }
        return Dismissible(
          key: UniqueKey(),
          background: Container(color: Colors.red),
          onDismissed: (direction) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.login} удален из контактов')));
            }
            // TODO: удаление группы

            xmppHelper?.dropFromRoster(item.login ?? '');
            getRoster();
          },
          child: ChatUserWidget(
            xmppHelper: xmppHelper,
            user: item,
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
