part of dash_chat_2;

/// @nodoc
class MediaContainer extends StatelessWidget {
  const MediaContainer({
    required this.message,
    required this.isOwnMessage,
    this.messageOptions = const MessageOptions(),
    Key? key,
  }) : super(key: key);

  /// Message that contains the media to show
  final ChatMessage message;

  /// If the message is from the current user
  final bool isOwnMessage;

  /// Options to customize the behaviour and design of the messages
  final MessageOptions messageOptions;

  /// Get the right media widget according to its type
  Widget _getMedia(ChatMedia media, double? height, double? width) {
    final Map<String, dynamic>? customProperties = media.customProperties;
    final Widget loading = Container(
      width: 15,
      height: 15,
      margin: const EdgeInsets.all(10),
      child: const CircularProgressIndicator(),
    );
    switch (media.type) {
      case MediaType.custom:
        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            if (customProperties != null && customProperties['widget'] != null)
              customProperties['widget'] as Widget,
          ],
        );
      case MediaType.video:
        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            GestureDetector(
                onTap: () async {
                  if (customProperties != null &&
                      customProperties['onTap'] != null) {
                    customProperties['onTap']();
                  }
                },
                child: VideoPlayer(url: media.url)),
            if (media.isUploading) loading
          ],
        );
      case MediaType.image:
        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                if (customProperties != null &&
                    customProperties['onTap'] != null) {
                  customProperties['onTap']();
                }
              },
              child: Image(
                height: height,
                width: width,
                fit: BoxFit.cover,
                alignment:
                    isOwnMessage ? Alignment.topRight : Alignment.topLeft,
                image: getImageProvider(media.url),
              ),
            ),
            if (media.isUploading) loading,
            if (messageOptions.showTime)
              Positioned(
                left: 5,
                bottom: 5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      intl.DateFormat('HH:mm').format(message.createdAt),
                      style: TextStyle(
                        color: isOwnMessage ? Colors.white : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    DashChat.buildReadMessageStatus(
                        messageOptions, isOwnMessage, message.status),
                  ],
                ),
              ),
          ],
        );
      case MediaType.file:
      case MediaType.audio:
        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            if (customProperties != null && customProperties['widget'] != null)
              customProperties['widget'] as Widget,
            if (media.isUploading) loading
          ],
        );
      case MediaType.answer:
      case MediaType.question:
        return Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            if (customProperties != null && customProperties['widget'] != null)
              customProperties['widget'] as Widget,
            if (media.isUploading) loading
          ],
        );
      default:
        return TextContainer(
          isOwnMessage: isOwnMessage,
          messageOptions: messageOptions,
          message: message,
          messageTextBuilder: (ChatMessage m, ChatMessage? p, ChatMessage? n) {
            return Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: !media.isUploading
                      ? Icon(
                          Icons.description,
                          size: 18,
                          color: isOwnMessage
                              ? (messageOptions.currentUserTextColor ??
                                  Colors.white)
                              : (messageOptions.textColor ?? Colors.black),
                        )
                      : loading,
                ),
                Flexible(
                  child: Text(
                    media.fileName,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: isOwnMessage
                          ? (messageOptions.currentUserTextColor ??
                              Colors.white)
                          : (messageOptions.textColor ?? Colors.black),
                    ),
                  ),
                ),
              ],
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (message.medias != null && message.medias!.isNotEmpty) {
      final List<ChatMedia> media = message.medias!;
      return Wrap(
        alignment: isOwnMessage ? WrapAlignment.end : WrapAlignment.start,
        children: media.map(
          (ChatMedia m) {
            final double gallerySize =
                (MediaQuery.of(context).size.width * 0.7) / 2 - 5;
            final bool isImage = m.type == MediaType.image;
            double height = MediaQuery.of(context).size.height * 0.5;
            if (m.type == MediaType.audio) {
              height = 70;
            } else if (m.type == MediaType.question || m.type == MediaType.answer) {
              // Автовысота для вопроса/ответа
              height = 0;
            }
            BoxConstraints? constraints = BoxConstraints(
              maxHeight: height,
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            );
            if (height <= 0) {
              constraints = null;
            }
            return Container(
              color: Colors.transparent,
              margin: const EdgeInsets.only(top: 5, right: 5),
              width: media.length > 1 && isImage ? gallerySize : null,
              height: media.length > 1 && isImage ? gallerySize : null,
              constraints: constraints,
              child: GestureDetector(
                onTap: messageOptions.onTapMedia != null
                    ? () => messageOptions.onTapMedia!(m)
                    : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      m.isUploading
                          ? Colors.white54
                          : Colors.white.withOpacity(
                              0.1,
                            ), // Because transparent is causing an issue on flutter web
                      BlendMode.srcATop,
                    ),
                    child: _getMedia(
                      m,
                      media.length > 1 ? gallerySize : null,
                      media.length > 1 ? gallerySize : null,
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      );
    }
    return Container();
  }
}
