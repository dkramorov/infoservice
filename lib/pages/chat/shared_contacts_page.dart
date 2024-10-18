import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infoservice/models/shared_contacts_model.dart';

import '../../helpers/log.dart';
import '../../helpers/network.dart';
import '../../helpers/phone_mask.dart';
import '../../navigation/generic_appbar.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../widgets/app_progress_indicator.dart';
import '../app_asset_lib.dart';
import '../static_values.dart';
import '../themes.dart';

class SharedContactsPage extends StatefulWidget {
  static const String id = '/shared_contacts/';
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;
  final Object? _arguments;

  const SharedContactsPage(this.sipHelper, this.xmppHelper, this._arguments,
      {Key? key})
      : super(key: key);

  @override
  _SharedContactsPageState createState() => _SharedContactsPageState();
}

class _SharedContactsPageState extends State<SharedContactsPage> {
  static const tag = 'SharedContactsPage';

  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;

  List<SharedContactsModel> contacts = [];
  bool loading = true;
  bool accessDenied = false;
  String accessDeniedMessage = 'Разрешение на проверку общих контактов не получено';

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    List args = (widget._arguments as Set).toList();
    Log.d(tag, 'args ---> ${args.toString()}');
    for (Object? arg in args) {
      if (arg is int) {
        Log.d(tag, 'arg ---> $arg');
        loadContacts(arg);
      }
    }
  }

  Future<void> loadContacts(int pk) async {
    SharedContactsRequestModel? req =
        await SharedContactsRequestModel().getById(pk);
    if (req != null) {
      contacts = await SharedContactsModel().getByRequestId(pk);
      Log.d(tag, 'contacts ---> ${contacts.toString()}');
      if (contacts.isEmpty) {
        /* если контактов нет - получаем с сервера,
           на сервере проверяется разрешение (оно одноразовое)
           при получении контактов - пишем в базу и возвращаем из базы
        */
        Map<String, dynamic> result =
            await getSharedContacts(cleanPhone(req.friendJid ?? ''));
        if (result['access_denied'] != null) {
          req.updatePartial(req.id, {
            'answer': 'false',
          });
          setState(() {
            accessDenied = true;
            loading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(accessDeniedMessage)));
          }
          return;
        }
        List<dynamic> shared = result['shared'];

        List<SharedContactsModel> contacts2db = [];
        for (int i = 0; i < shared.length; i++) {
          SharedContactsModel newContact = SharedContactsModel(
            requestId: req.id ?? 0,
            login: shared[i]['phone'],
            name: shared[i]['name'],
          );
          contacts2db.add(newContact);
        }

        int maxBy = 999;
        int fieldsCount = SharedContactsModel().toMap().keys.length;
        int by = maxBy ~/ fieldsCount;
        int contactsPages = (shared.length ~/ by) + 1;

        List<dynamic> contactsQueriesPages = [];
        for (var i = 0; i < contactsPages; i++) {
          Log.d(
              tag,
              'Update contactsPages ${i + 1} /'
              ' $contactsPages (${i * by} - ${i * by + by}),'
              ' fieldsCount $fieldsCount');
          List<dynamic> contacts = await SharedContactsModel()
              .prepareTransactionQueries(contacts2db, i * by, i * by + by);
          if (contacts.isNotEmpty) {
            contactsQueriesPages.add(contacts);
          }
        }
        await SharedContactsModel().massTransaction(contactsQueriesPages);
        req.updatePartial(req.id, {
          'answer': 'true',
        });
        contacts = await SharedContactsModel().getByRequestId(pk);
        if (contacts.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Общих контактов не найдено')));
          }
        }
      }
    }
    setState(() {
      loading = false;
    });
  }

  Widget buildRow(SharedContactsModel contact, int index) {
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
            Log.d(tag, 'clicked ${contact.toString()}');
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
                      phoneMaskHelper(contact.login ?? ''),
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
                    '${contact.name}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: w400,
                      color: gray100,
                    ),
                  )
                ],
              ),
              const Spacer(),
              Text('${index + 1}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContacts() {
    if (accessDenied) {
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(accessDeniedMessage),
      );
    }
    return ListView.builder(
      itemCount: contacts.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        vertical: 30,
      ),
      itemBuilder: (context, index) {
        SharedContactsModel contact = contacts[index];
        return buildRow(contact, index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GenericAppBar(
          hasBackButton: true, title: 'Общие контакты (${contacts.length})'),
      /*
      appBar: AppBar(
        title: const Text('Общие контакты'),
        backgroundColor: tealColor,
        actions: [],
      ),
      */
      body: Container(
        child: loading
            ? const SizedBox(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppProgressIndicator(),
                    ],
                  ),
                ),
              )
            : buildContacts(),
      ),
    );
  }
}
