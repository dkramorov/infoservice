part of dash_chat_2;

/// {@category Default widgets}
class DefaultMessageText extends StatelessWidget {
  const DefaultMessageText({
    required this.message,
    required this.isOwnMessage,
    this.messageOptions = const MessageOptions(),
    Key? key,
  }) : super(key: key);

  /// Message tha contains the text to show
  final ChatMessage message;

  /// If the message is from the current user
  final bool isOwnMessage;

  /// Options to customize the behaviour and design of the messages
  final MessageOptions messageOptions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          children: getMessage(),
        ),
        if (messageOptions.showTime)
          messageOptions.messageTimeBuilder != null
              ? messageOptions.messageTimeBuilder!(message, isOwnMessage)
              : Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    (messageOptions.timeFormat ?? intl.DateFormat('HH:mm'))
                        .format(message.createdAt),
                    style: TextStyle(
                      color: isOwnMessage
                          ? (messageOptions.currentUserTextColor ??
                              Colors.white70)
                          : (messageOptions.textColor ?? Colors.black54),
                      fontSize: 10,
                    ),
                  ),
                ),
      ],
    );
  }

  List<Widget> getMessage() {
    if (message.mentions != null && message.mentions!.isNotEmpty) {
      String stringRegex = r'([\s\S]*)';
      String stringMentionRegex = '';
      for (final Mention mention in message.mentions!) {
        stringRegex += '(${mention.title})' r'([\s\S]*)';
        stringMentionRegex += stringMentionRegex.isEmpty
            ? '(${mention.title})'
            : '|(${mention.title})';
      }
      final RegExp mentionRegex = RegExp(stringMentionRegex);
      final RegExp regexp = RegExp(stringRegex);

      RegExpMatch? match = regexp.firstMatch(message.text);
      if (match != null) {
        List<Widget> res = <Widget>[];
        match
            .groups(List<int>.generate(match.groupCount, (int i) => i + 1))
            .forEach((String? part) {
          if (mentionRegex.hasMatch(part!)) {
            Mention mention = message.mentions!.firstWhere(
              (Mention m) => m.title == part,
            );
            res.add(getMention(mention));
          } else {
            res.add(getParsePattern(part));
          }
        });
        if (res.isNotEmpty) {
          return res;
        }
      }
    }
    return <Widget>[getParsePattern(message.text)];
  }

  Widget getParsePattern(String text) {
    return ParsedText(
      parse: messageOptions.parsePatterns != null
          ? messageOptions.parsePatterns!
          : defaultPersePatterns,
      text: text,
      style: TextStyle(
        color: isOwnMessage
            ? (messageOptions.currentUserTextColor ?? Colors.white)
            : (messageOptions.textColor ?? Colors.black),
      ),
    );
  }

  Widget getMention(Mention mention) {
    return RichText(
      text: TextSpan(
        text: mention.title,
        recognizer: TapGestureRecognizer()
          ..onTap = () => messageOptions.onPressMention != null
              ? messageOptions.onPressMention!(mention)
              : null,
        style: TextStyle(
          color: isOwnMessage
              ? (messageOptions.currentUserTextColor ?? Colors.white)
              : (messageOptions.textColor ?? Colors.black),
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
