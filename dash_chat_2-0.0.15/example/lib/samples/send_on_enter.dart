import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import '../data.dart';

class SendOnEnter extends StatefulWidget {
  @override
  _SendOnEnterState createState() => _SendOnEnterState();
}

class _SendOnEnterState extends State<SendOnEnter> {
  List<ChatMessage> messages = basicSample;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SendOnEnter example'),
      ),
      body: DashChat(
        currentUser: user,
        onSend: (ChatMessage m) {
          setState(() {
            messages.insert(0, m);
          });
        },
        messages: messages,
        inputOptions: const InputOptions(
          sendOnEnter: true,
        ),
        messageListOptions: MessageListOptions(
          onLoadEarlier: () async {
            await Future.delayed(const Duration(seconds: 3));
          },
        ),
      ),
    );
  }
}
