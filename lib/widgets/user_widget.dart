import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../helpers/phone_mask.dart';
import '../models/user_chat_model.dart';
import '../pages/chat/chat_page.dart';
import '../services/jabber_manager.dart';
import '../services/sip_ua_manager.dart';
import '../settings.dart';
import 'chat/avatar_widget.dart';

class ChatUserWidget extends StatefulWidget {
  final SIPUAManager? sipHelper;
  final JabberManager? xmppHelper;

  final UserChatModel user;

  const ChatUserWidget({
    this.sipHelper,
    this.xmppHelper,
    required this.user,
    Key? key,
  }) : super(key: key);

  @override
  _ChatUserWidgetState createState() => _ChatUserWidgetState();
}

class _ChatUserWidgetState extends State<ChatUserWidget> {
  SIPUAManager? get sipHelper => widget.sipHelper;
  JabberManager? get xmppHelper => widget.xmppHelper;

  final DateFormat formatter = DateFormat('HH:mm');

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
    );
  }

  @override
  Widget build(BuildContext context) {
    final containerMsgTextWidth = MediaQuery.of(context).size.width * 0.40;
    final msgTime = (widget.user.time != null && widget.user.time != '-')
        ? formatter.format(DateTime.parse(widget.user.time!))
        : '-- --';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, ChatScreen.id, arguments: {
          sipHelper,
          xmppHelper,
          ChatUser(id: cleanPhone(widget.user.login ?? '')),
        });
      },
      child: ListTile(
        leading: FutureBuilder<String>(
            future: widget.user.getPhoto(),
            builder:
                (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return buildAvatar(snapshot.data!);
              } else {
                return buildAvatar(DEFAULT_AVATAR);
              }
            }),
        /*
        leading: CircleAvatar(
          backgroundColor: Colors.grey[100],
          backgroundImage: AssetImage(widget.image),
        ),
         */
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: containerMsgTextWidth,
              child: Text(
                widget.user.getName(),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              msgTime,
            ),
          ],
        ),
        subtitle: SizedBox(
          width: containerMsgTextWidth,
          child: Text(
            widget.user.msg ?? widget.user.getName(),
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
