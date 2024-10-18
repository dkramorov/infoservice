import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:infoservice/helpers/phone_mask.dart';
import 'package:infoservice/models/shared_contacts_model.dart';
import 'package:infoservice/pages/chat/shared_contacts_page.dart';
import 'package:infoservice/settings.dart';
import 'package:uuid/uuid.dart';
import '../../helpers/date_time.dart';
import '../../helpers/log.dart';
import '../../models/bg_tasks_model.dart';
import '../../models/user_settings_model.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../widgets/chat/messages_widgets.dart';
import '../../widgets/text_field_custom.dart';
import '../app_asset_lib.dart';
import '../static_values.dart';
import '../../navigation/generic_appbar.dart';
import '../themes.dart';
import '../../widgets/button.dart';

class RosterProfilePage extends StatefulWidget {
  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  final Object? _arguments;

  const RosterProfilePage(this._sipHelper, this._xmppHelper, this._arguments,
      {Key? key})
      : super(key: key);
  static const String id = '/roster_profile';

  @override
  State<RosterProfilePage> createState() => _RosterProfilePageState();
}

class _RosterProfilePageState extends State<RosterProfilePage> {
  static const tag = 'RosterProfilePage';

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  TextEditingController nameController = TextEditingController();
  UserSettingsModel? userSettings;
  late ChatUser friend;
  List<SharedContactsRequestModel> sharedContactsRequests = [];

  @override
  void initState() {
    List args = (widget._arguments as Set).toList();
    for (Object? arg in args) {
      if (arg is ChatUser) {
        friend = arg;
        Log.d(tag, '---> roster profile ${friend.id}');
        nameController.text = friend.getName();
        break;
      }
    }
    getSharedContactsRequestsList();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> getSharedContactsRequestsList() async {
    userSettings = await UserSettingsModel().getUser();
    if (userSettings != null) {
      sharedContactsRequests = await SharedContactsRequestModel()
          .getForFriend(userSettings!.jid!, friend.jid!);
      if (mounted) {
        setState(() {});
      }
      Log.d(
          tag, 'sharedContactsRequests size ${sharedContactsRequests.length}');
    }
  }

  Widget buildRow(SharedContactsRequestModel contact) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 12.0,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              offset: Offset(0, 2),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          style: UIs.elevatedButtonDefault,
          onPressed: () async {
            Future.delayed(Duration.zero, () {
              Navigator.pushNamed(context, SharedContactsPage.id, arguments: {
                sipHelper,
                xmppHelper,
                contact.id,
                //shared,
              });
            });
          },
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SvgPicture.asset(AssetLib.profileIcon),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      'Список общих контактов',
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: w400,
                        color: black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const SizedBox(height: 4),
                  Text(
                    '${contact.date}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: w400,
                      color: gray100,
                    ),
                  ),
                  contact.answer == 'true'
                      ? const Text(
                          'запрос разрешен',
                          style: TextStyle(color: Colors.green),
                        )
                      : Container(),
                  contact.answer == 'false'
                      ? const Text(
                          'запрос запрещен',
                          style: TextStyle(color: Colors.red),
                        )
                      : Container(),
                  contact.answer == null
                      ? const Text('запрос отправлен')
                      : Container(),
                ],
              ),
              const Spacer(),
              SvgPicture.asset(AssetLib.smallArrow),
            ],
          ),
        ),
      ),
    );
  }

  ListView buildContactsList() {
    return ListView.builder(
      // Не скроллим здесь (скроллим в верхнеуровневом элементе)
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sharedContactsRequests.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        vertical: 30,
      ),
      itemBuilder: (context, index) {
        SharedContactsRequestModel contact = sharedContactsRequests[index];

        return Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) async {
            await SharedContactsModel().dropByRequestId(contact.id ?? 0);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Список ${contact.date} удален')));
            await contact.delete2Db();
            await getSharedContactsRequestsList();
          },
          child: buildRow(contact),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          GenericAppBar(hasBackButton: true, title: phoneMaskHelper(friend.id)),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(UIs.defaultPagePadding),
        child: ListView(
          // Скроллим здесь, а в списке запросов не скролим
          physics: const ScrollPhysics(),
          children: [
            SIZED_BOX_H16,
            TextFieldCustom(
              labelText: 'Имя контакта',
              controller: nameController,
              keyboardType: TextInputType.name,
            ),
            SIZED_BOX_H16,
            const Center(
              child: Text(
                'Общие контакты',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SIZED_BOX_H16,
            PrimaryButton(
              color: blue,
              onPressed: () async {
                DateTime now = DateTime.now();
                String dt = datetime2String(now);
                String text = 'Пользователь ${friend.getName()}'
                    ' запросил проверку общих контактов с вами.\n'
                    'Вы согласны сравнить общие контакты?';
                Map<String, dynamic> data = {
                  'from': userSettings!.jid,
                  'text': text,
                  'to': friend.jid,
                  'now': DateTime.now().millisecondsSinceEpoch,
                  'pk': const Uuid().v4(),
                  'mediaType': MediaType.question.toString(),
                };
                await BGTasksModel.sendTextMessageTask(data);
                SharedContactsRequestModel newRequest =
                    SharedContactsRequestModel(
                  date: dt,
                  ownerJid: userSettings?.jid,
                  friendJid: friend.jid,
                );
                newRequest.insert2Db();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Запрос на сравнение общих контактов отправлен')));
                  // Обновляем контакты
                  await getSharedContactsRequestsList();
                }
              },
              child: Text(
                'Запросить общие контакты',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: w500,
                  color: white,
                ),
              ),
            ),
            SIZED_BOX_H24,
            buildContactsList(),
          ],
        ),
      ),
    );
  }
}
