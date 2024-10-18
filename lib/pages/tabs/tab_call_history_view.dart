import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infoservice/models/dialpad_model.dart';
import 'package:infoservice/models/user_settings_model.dart';
import 'package:infoservice/sip_ua/dialpadscreen.dart';
import 'package:intl/intl.dart';
import '../../helpers/log.dart';
import '../../helpers/model_utils.dart';
import '../../helpers/phone_mask.dart';
import '../../models/call_history_model.dart';
import '../../models/companies/orgs.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../widgets/companies/company_logo.dart';
import '../app_asset_lib.dart';
import '../themes.dart';

class TabCallHistoryView extends StatefulWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final Function setStateCallback;
  final PageController pageController;

  const TabCallHistoryView(
      {this.sipHelper,
      this.xmppHelper,
      required this.pageController,
      required this.setStateCallback,
      Key? key})
      : super(key: key);

  @override
  _TabCallHistoryViewState createState() => _TabCallHistoryViewState();
}

class _TabCallHistoryViewState extends State<TabCallHistoryView> {
  static const tag = 'TabCallHistoryView';
  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;

  final DateFormat formatter = DateFormat('dd MMMM, HH:mm');
  List<CallHistoryModel> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

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

  // Обновление состояния
  void setStateCallback(Map<String, dynamic> state) {
    setState(() {});
  }

  Future<void> loadHistory() async {
    UserSettingsModel? user = await UserSettingsModel().getUser();
    if (user == null) {
      Log.d(tag, 'user is null');
      return;
    }
    List<CallHistoryModel> result =
        await CallHistoryModel().getAllHistory(user.phone ?? '');
    // Нужно подтянуть имена к звонкам
    await getNamesByPhones();

    setState(() {
      if (mounted) {
        history = result;
      }
    });
  }

  Widget buildIcon(CallHistoryModel item) {
    if (item.company != null) {
      return CompanyLogoWidget(item.company ?? Orgs());
    }
    IconData icon = Icons.phone_forwarded;
    if (item.action == 'incoming') {
      icon = Icons.phone_callback;
    }
    return Icon(
      icon,
      size: 40.0,
      color: Colors.black54,
    );
  }

  ListView buildHistory() {
    Size size = MediaQuery.sizeOf(context);
    final containerMsgTextWidth = size.width * 0.55;
    return ListView.builder(
      itemCount: history.length,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        vertical: 15,
      ),
      itemBuilder: (context, index) {
        final item = history[history.length - index - 1];
        final duration = sipHelper?.calcCallTime(item.duration ?? 0);
        String phone = phoneMaskHelper(item.dest ?? '');
        String name = item.company != null ? item.company!.name ?? '' : phone;
        if (JabberManager.cacheRosterNames[item.dest] != null) {
          name = JabberManager.cacheRosterNames[item.dest] ?? phone;
        }
        return Dismissible(
          key: UniqueKey(),
          background: Container(color: Colors.red),
          onDismissed: (direction) {
            item.delete2Db();
            setState(() {
              history.remove(item);
            });
          },
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, DialpadScreen.id, arguments: {
                sipHelper,
                xmppHelper,
                DialpadModel(
                  phone: item.dest ?? '',
                  isSip: item.isSip == 1 ? true : false,
                  startCall: true,
                  company: item.company,
                ),
              });
            },
            child: Container(
              width: size.width,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: buildIcon(item),
                      /*Image.network(
                        hist[index]["icon"],
                        fit: BoxFit.cover,
                      ),
                      */
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: containerMsgTextWidth,
                        child: Text(
                          name,
                          //maxLines: 4,
                          //overflow: TextOverflow.fade,
                          //softWrap: false,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: w400,
                            color: black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SvgPicture.asset(AssetLib.phoneFill),
                          const SizedBox(width: 6),
                          Text(
                            phoneMaskHelper(item.dest ?? ''),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: w400,
                              color: gray100,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SvgPicture.asset(AssetLib.date),
                          const SizedBox(width: 6),
                          Text(
                            formatter.format(DateTime.parse(item.time ?? '0')),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: w400,
                              color: gray100,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SvgPicture.asset(AssetLib.timeFill),
                          const SizedBox(width: 6),
                          Text(
                            duration ?? '0',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: w400,
                              color: gray100,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  SvgPicture.asset(AssetLib.smallArrow)
                ],
              ),
            ),
            /* /// Старый вариант
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(-2, 0),
                    blurRadius: 7,
                  ),
                ],
              ),
              child: ListTile(
                leading: SizedBox(
                  width: 60,
                  child: buildIcon(item),
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    item.company != null
                        ? Text(
                            item.company!.name ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          )
                        : Container(),
                    Text(
                      item.name ?? phoneMaskHelper(item.dest ?? ''),
                      style: const TextStyle(
                        fontSize: 19.0,
                      ),
                    ),
                  ],
                ),
                subtitle: SizedBox(
                  width: containerMsgTextWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        formatter.format(DateTime.parse(item.time ?? '0')),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      SIZED_BOX_W10,
                      item.isSip == 1
                          ? const Text(
                              'SIP',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            )
                          : const Text(''),
                      SIZED_BOX_W04,
                      const Icon(
                        Icons.access_time,
                        size: 13.0,
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Text(duration ?? '0'),
                    ],
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
              ),
            ),
            */
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PAD_SYM_H10,
      child: history.isNotEmpty
          ? buildHistory()
          : const Center(
              child: Text(
                'История пуста',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
    );
  }
}
