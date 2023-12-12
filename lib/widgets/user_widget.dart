import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:infoservice/helpers/date_time.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../helpers/log.dart';
import '../helpers/phone_mask.dart';
import '../models/roster_model.dart';
import '../pages/chat/chat_page.dart';
import '../pages/chat/group_chat_page.dart';
import '../services/jabber_manager.dart';
import '../services/sip_ua_manager.dart';
import '../settings.dart';
import 'chat/avatar_widget.dart';

class ChatUserWidget extends StatefulWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final RosterModel rosterModel;

  const ChatUserWidget({
    this.sipHelper,
    this.xmppHelper,
    required this.rosterModel,
    Key? key,
  }) : super(key: key);

  @override
  _ChatUserWidgetState createState() => _ChatUserWidgetState();
}

class _ChatUserWidgetState extends State<ChatUserWidget> {
  static const tag = 'ChatUserWidget';

  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;
  RosterModel get rosterModel => widget.rosterModel;

  final DateFormat formatterHHmm = DateFormat('HH:mm');
  final DateFormat formatter = DateFormat('dd/MM/yy');

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildAvatar(String avatar) {
    return Avatar(
      imgPath: avatar,
      isOnline: false,
      showCounter: rosterModel.newMessagesCount ?? 0,
    );
  }

  String getMsgTime() {
    String msgTime = '-- --';
    if (rosterModel.lastMessageTime != null && rosterModel.lastMessageTime != 0) {
      DateTime now = DateTime.now();
      DateTime dt = timestamp2Datetime(rosterModel.lastMessageTime!);
      if (dt.month == now.month && dt.year == now.year) {
        if (dt.day == now.day) {
          msgTime = formatterHHmm.format(dt);
        } else {
          DateTime yesterday = now.subtract(const Duration(days:1));
          if (yesterday.day == dt.day) {
            msgTime = 'Вчера';
          } else {
            msgTime = formatter.format(dt);
          }
        }
      } else {
        msgTime = formatter.format(dt);
      }
    }
    return msgTime;
  }

  @override
  Widget build(BuildContext context) {
    final containerMsgTextWidth = MediaQuery.of(context).size.width * 0.45;

    return GestureDetector(
      onTap: () {
        String login = rosterModel.jid ?? '';
        final String phone = cleanPhone(login);
        String screenId = ChatScreen.id;
        if (rosterModel.isGroup == 1) {
          screenId = GroupChatScreen.id;
        }
        Log.d(tag, 'set screen $screenId');
        Navigator.pushNamed(context, screenId, arguments: {
          sipHelper,
          xmppHelper,
          ChatUser(
            id: login,
            jid: login,
            name: rosterModel.name,
            phone: phone,
          ),
        });
      },
      child: ListTile(
        leading: FutureBuilder<String>(
            future: rosterModel.getPhoto(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return buildAvatar(snapshot.data!);
              } else {
                return buildAvatar(DEFAULT_AVATAR);
              }
            }),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: containerMsgTextWidth,
              child: Text(
                rosterModel.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              getMsgTime(),
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
        subtitle: SizedBox(
          width: containerMsgTextWidth,
          child: Text(
            rosterModel.lastMessage ?? '',
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }
}
