import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:infoservice/helpers/phone_mask.dart';
import 'package:infoservice/main.dart';
import 'package:infoservice/pages/chat/chat_page.dart';
import 'package:infoservice/pages/chat/group_chat_page.dart';
import 'package:infoservice/services/jabber_manager.dart';
import 'package:infoservice/services/sip_ua_manager.dart';

class AwesomeNotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
          ReceivedNotification notification) async =>
      print('AwesomeNotifications created stream event: $notification');

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification notification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction action) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction action,
    // SIPUAManager? sipHelper,
    // JabberManager? xmppHelper,
  ) async {
    await onActionReceivedImplementationMethod(action);

    // // Navigate into pages, avoiding to open the notification details page over another details page already opened
    // navigatorKey.currentState?.pushNamedAndRemoveUntil(
    //     '/notification-page',
    //     (route) =>
    //         (route.settings.name != '/notification-page') || route.isFirst,
    //     arguments: receivedAction);
    // print('AwesomeNotifications action stream event: $action');

    // if (action.payload != null) {
    //   if (action.payload!['action'] == 'chat') {
    //     String sender = action.payload!['sender'] ?? '';
    //     String phone = cleanPhone(sender);
    //     String jid = JabberManager().toJid(sender);
    //     String name = phoneMaskHelper(sender);

    //     String screenId = ChatScreen.id;
    //     String group = action.payload!['group'] ?? '';
    //     if (group != '') {
    //       screenId = GroupChatScreen.id;
    //       sender = group;
    //       phone = group;
    //       jid = group;
    //       name = group.split('@')[0];
    //     }

    //     navigatorKey.currentState!.popUntil((route) => (route.isFirst));
    //     navigatorKey.currentState!.pushNamed(screenId, arguments: {
    //       sipHelper,
    //       xmppHelper,
    //       ChatUser(
    //         id: phone,
    //         jid: jid,
    //         phone: sender,
    //         name: name,
    //         customProperties: {'fromPush': true},
    //       ),
    //     });
    //   }
    //   /* else if (action.payload!['action'] == 'call') {
    //   Navigator.popUntil(context, (route) => (route.isFirst));
    //   Navigator.pushNamed(context, CallScreenWidget.id, arguments: {
    //     sipHelper,
    //     xmppHelper,
    //   });
    // }
    // */
    // }

    // print('AwesomeNotifications action stream event: $action');

    // if (action.payload != null) {
    //   if (action.payload!['action'] == 'chat') {
    //     String sender = action.payload!['sender'] ?? '';
    //     String phone = cleanPhone(sender);
    //     String jid = JabberManager().toJid(sender);
    //     String name = phoneMaskHelper(sender);

    //     String screenId = ChatScreen.id;
    //     String group = action.payload!['group'] ?? '';
    //     if (group != '') {
    //       screenId = GroupChatScreen.id;
    //       sender = group;
    //       phone = group;
    //       jid = group;
    //       name = group.split('@')[0];
    //     }

    //     Navigator.popUntil(context, (route) => (route.isFirst));
    //     Navigator.pushNamed(context, screenId, arguments: {
    //       sipHelper,
    //       xmppHelper,
    //       ChatUser(
    //         id: phone,
    //         jid: jid,
    //         phone: sender,
    //         name: name,
    //         customProperties: {'fromPush': true},
    //       ),
    //     });
    //   }
    //   /* else if (action.payload!['action'] == 'call') {
    //   Navigator.popUntil(context, (route) => (route.isFirst));
    //   Navigator.pushNamed(context, CallScreenWidget.id, arguments: {
    //     sipHelper,
    //     xmppHelper,
    //   });
    // }
    // */
    // }
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction action) async {
    print('AwesomeNotifications action stream event: $action');

    if (action.payload != null) {
      if (action.payload!['action'] == 'chat') {
        String sender = action.payload!['sender'] ?? '';
        String phone = cleanPhone(sender);
        String jid = JabberManager.toJid(sender);
        String name = phoneMaskHelper(sender);

        String screenId = ChatScreen.id;
        String group = action.payload!['group'] ?? '';
        if (group != '') {
          screenId = GroupChatScreen.id;
          sender = group;
          phone = group;
          jid = group;
          name = group.split('@')[0];
        }

        navigatorKey.currentState!.popUntil((route) => (route.isFirst));
        // navigatorKey.currentState!.pushNamed(screenId, arguments: {
        //   sipHelper,
        //   xmppHelper,
        //   ChatUser(
        //     id: phone,
        //     jid: jid,
        //     phone: sender,
        //     name: name,
        //     customProperties: {'fromPush': true},
        //   ),
        // });
      }
      /* else if (action.payload!['action'] == 'call') {
      Navigator.popUntil(context, (route) => (route.isFirst));
      Navigator.pushNamed(context, CallScreenWidget.id, arguments: {
        sipHelper,
        xmppHelper,
      });
    }
    */
    }
  }
}
