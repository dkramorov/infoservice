import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:infoservice/models/chat_message_model.dart';
import 'package:infoservice/models/shared_contacts_model.dart';
import 'package:intl/intl.dart' as intl;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infoservice/settings.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/date_time.dart';
import '../../helpers/network.dart';
import '../../helpers/string_parser.dart';
import '../../models/bg_tasks_model.dart';
import '../../models/user_settings_model.dart';
import '../../pages/themes.dart';
import '../../services/shared_preferences_manager.dart';
import '../button.dart';

final MediaQueryData media =
    MediaQueryData.fromWindow(WidgetsBinding.instance.window);

/// This extention help us to make widget responsive.
extension NumberParsing on num {
  double w() => this * media.size.width / 100;
  double h() => this * media.size.height / 100;
}

class Widgets {
  /// document will be added
  static circle(
    BuildContext context,
    double width,
    Color color, {
    Widget child = const SizedBox(),
  }) =>
      Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        width: width,
        height: width,
        child: child,
      );
}

class VoiceDuration {
  /// document will be added
  static String getDuration(int duration) =>
      duration < 60 ? '00:$duration' : '${duration ~/ 60}:${duration % 60}';
}

class Noises extends StatelessWidget {
  const Noises({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [for (int i = 0; i < 27; i++) _singleNoise(context)],
    );
  }

  _singleNoise(BuildContext context) {
    final double height = 5.74.w() * math.Random().nextDouble() + .26.w();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: .2.w()),
      width: .56.w(),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        color: Colors.white,
      ),
    );
  }
}

class ContactNoise extends StatelessWidget {
  const ContactNoise({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [for (int i = 0; i < 27; i++) _singleNoise(context)],
    );
  }

  _singleNoise(BuildContext context) {
    final double height = 5.74.w() * math.Random().nextDouble() + .26.w();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: .2.w()),
      width: .56.w(),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        color: Colors.grey,
      ),
    );
  }
}

/// This is the main widget.
///
// ignore: must_be_immutable
class VoiceMessage extends StatefulWidget {
  VoiceMessage({
    Key? key,
    required this.audioSrc,
    required this.me,
    this.noiseCount = 27,
    this.meBgColor = const Color(0xFFFF4550),
    this.contactBgColor = const Color(0xffffffff),
    this.contactFgColor = const Color(0xFFFF4550),
    this.mePlayIconColor = Colors.black,
    this.contactPlayIconColor = Colors.black26,
    this.meFgColor = const Color(0xffffffff),
    this.played = false,
    this.onPlay,
    this.createdAt,
    this.readStatus = MessageStatus.none,
  }) : super(key: key);

  final String audioSrc;
  final int noiseCount;
  final Color meBgColor,
      meFgColor,
      contactBgColor,
      contactFgColor,
      mePlayIconColor,
      contactPlayIconColor;
  final bool played, me;
  Function()? onPlay;
  final DateTime? createdAt;
  MessageStatus readStatus;

  @override
  _VoiceMessageState createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer player = AudioPlayer();
  final double maxNoiseHeight = 6.w(), noiseWidth = 26.5.w();
  double maxDurationForSlider = .0000001;
  bool isPlaying = false, _audioConfigurationDone = false;
  int playingStatus = 0;
  int duration = 0;
  String remaingTime = '';
  AnimationController? _controller;

  @override
  void initState() {
    initPlayer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => _sizerChild(context);

  Container _sizerChild(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: .8.w()),
      constraints: BoxConstraints(maxWidth: 100.w() * .7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.w()),
          bottomLeft:
              widget.me ? Radius.circular(6.w()) : Radius.circular(2.w()),
          bottomRight:
              !widget.me ? Radius.circular(6.w()) : Radius.circular(1.2.w()),
          topRight: Radius.circular(6.w()),
        ),
        color: widget.me ? widget.meBgColor : widget.contactBgColor,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w(), vertical: 2.8.w()),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _playButton(context),
            SizedBox(width: 3.w()),
            _durationWithNoise(context),
            //SizedBox(width: 2.2.w()),
          ],
        ),
      ),
    );
  }

  _playButton(BuildContext context) => InkWell(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.me ? widget.meFgColor : widget.contactFgColor,
          ),
          width: 8.w(),
          height: 8.w(),
          child: InkWell(
            onTap: () =>
                !_audioConfigurationDone ? null : _changePlayingStatus(),
            child: !_audioConfigurationDone
                ? Container(
                    padding: const EdgeInsets.all(8),
                    width: 10,
                    height: 0,
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      color:
                          widget.me ? widget.meFgColor : widget.contactFgColor,
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: widget.me
                        ? widget.mePlayIconColor
                        : widget.contactPlayIconColor,
                    size: 5.w(),
                  ),
          ),
        ),
      );

  _durationWithNoise(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _noise(context),
          SizedBox(height: .3.w()),
          Row(
            children: [
              if (!widget.played)
                Widgets.circle(context, 1.w(),
                    widget.me ? widget.meFgColor : widget.contactFgColor),
              SizedBox(width: 1.2.w()),
              Text(
                remaingTime,
                style: TextStyle(
                  fontSize: 10,
                  color: widget.me ? widget.meFgColor : widget.contactFgColor,
                ),
              ),
              const SizedBox(width: 15),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.createdAt == null
                        ? ''
                        : intl.DateFormat('HH:mm').format(widget.createdAt!),
                    style: TextStyle(
                      color: widget.me ? Colors.white : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  DashChat.buildReadMessageStatus(
                      chatMessageOptions, widget.me, widget.readStatus),
                ],
              ),
            ],
          ),
        ],
      );

  /// Noise widget of audio.
  _noise(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final newTHeme = theme.copyWith(
      sliderTheme: SliderThemeData(
        trackShape: CustomTrackShape(),
        thumbShape: SliderComponentShape.noThumb,
        minThumbSeparation: 0,
      ),
    );

    /// document will be added
    return Theme(
      data: newTHeme,
      child: SizedBox(
        height: 6.5.w(),
        width: noiseWidth,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            widget.me ? const Noises() : const ContactNoise(),
            if (_audioConfigurationDone)
              AnimatedBuilder(
                animation:
                    CurvedAnimation(parent: _controller!, curve: Curves.ease),
                builder: (context, child) {
                  return Positioned(
                    left: _controller!.value,
                    child: Container(
                      width: noiseWidth,
                      height: 6.w(),
                      color: widget.me
                          ? widget.meBgColor.withOpacity(.4)
                          : widget.contactBgColor.withOpacity(.35),
                    ),
                  );
                },
              ),
            Opacity(
              opacity: .0,
              child: Container(
                width: noiseWidth,
                color: Colors.amber.withOpacity(1),
                child: Slider(
                  min: 0.0,
                  max: maxDurationForSlider,
                  onChangeStart: (__) => _stopPlaying(),
                  onChanged: (_) => _onChangeSlider(_),
                  value: duration + .0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _startPlaying() async {
    await player.play();
    _controller!.forward();
  }

  _stopPlaying() async {
    await player.pause();
    _controller!.stop();
  }

  void initPlayer() async {
    if (widget.audioSrc.startsWith('http')) {
      await player.setUrl(widget.audioSrc);
    } else {
      await player.setFilePath(widget.audioSrc);
    }
    player.playerStateStream.listen((playerState) {
      isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
      } else if (processingState == ProcessingState.completed) {
        _stopPlaying();
        player.seek(Duration.zero);
        _controller?.reset();
        isPlaying = false;
      }
      if (mounted) {
        Future.delayed(Duration.zero, () {
          setState(() {});
        });
      }
    });

    player.bufferedPositionStream.listen((Duration bufferedPosition) {
      // Буферизованный вывод - максимальная позиция
      if (mounted) {
        setState(() {
          maxDurationForSlider = bufferedPosition.inSeconds.toDouble();
        });
      }
    });

    player.positionStream.listen((Duration p) {
      // Текущая позиция
      duration = p.inSeconds;
      final newRemaingTime1 = p.toString().split('.')[0];
      final newRemaingTime2 =
          newRemaingTime1.substring(newRemaingTime1.length - 5);
      if (newRemaingTime2 != remaingTime) {
        if (mounted) {
          setState(() => remaingTime = newRemaingTime2);
        }
      }
    });

    _controller = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: noiseWidth,
      duration: Duration(seconds: maxDurationForSlider.toInt()),
    );

    _controller!.addListener(() {});
    _setAnimationCunfiguration(Duration(seconds: duration));
  }

  void _setAnimationCunfiguration(Duration? audioDuration) async {
    remaingTime = VoiceDuration.getDuration(duration);
    _completeAnimationConfiguration();
  }

  void _completeAnimationConfiguration() {
    if (mounted) {
      setState(() => _audioConfigurationDone = true);
    }
  }

  void _changePlayingStatus() async {
    if (widget.onPlay != null) widget.onPlay!();
    isPlaying ? _stopPlaying() : _startPlaying();
    if (mounted) {
      setState(() => isPlaying = !isPlaying);
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  _onChangeSlider(double d) async {
    if (isPlaying) _changePlayingStatus();
    duration = d.round();
    _controller?.value = (noiseWidth) * duration / maxDurationForSlider;
    remaingTime = VoiceDuration.getDuration(duration);
    await player.seek(Duration(seconds: duration));
    if (mounted) {
      setState(() {});
    }
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const double trackHeight = 10;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class FileMessage extends StatefulWidget {
  static const fileIcon = 'assets/svg/file.svg';

  final String fileSrc;
  final Color meBgColor, contactBgColor;
  final bool me;
  final String localPath;
  final DateTime? createdAt;
  MessageStatus readStatus;

  FileMessage({
    Key? key,
    required this.fileSrc,
    required this.me,
    this.meBgColor = const Color(0xFFFF4550),
    this.contactBgColor = const Color(0xffffffff),
    this.localPath = '',
    this.createdAt,
    this.readStatus = MessageStatus.none,
  }) : super(key: key);

  @override
  _FileMessageState createState() => _FileMessageState();
}

class _FileMessageState extends State<FileMessage> {
  late final String ext;
  final int maxFnameLen = 15;
  int percent = 0;
  bool isDownloaded = false;
  late String fname;

  @override
  void initState() {
    super.initState();
    fname = uri2rus(widget.fileSrc.split('/').last);
    if (fname.length > maxFnameLen) {
      ext = '...${fname.substring(fname.length - maxFnameLen, fname.length)}';
    } else {
      ext = fname;
    }

    // Если файл пользователя
    if (widget.me && widget.localPath != '') {
      if (mounted) {
        setState(() {
          isDownloaded = true;
        });
      }
    } else {
      //fname = translit(fname);
      getLocalFilePath(fname).then((file) {
        file.exists().then((isExists) {
          if (mounted) {
            setState(() {
              isDownloaded = isExists;
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) => _sizerChild(context);

  Future<void> launchInWebViewOrVC(String url) async {
    Uri urla = Uri.parse(url);
    if (!await launchUrl(
      urla,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(
          headers: <String, String>{'my_header_key': 'my_header_value'}),
    )) {
      print('Could not launch $url');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Не удалось открыть файл'),
        ));
      }
    }
  }

  Future<void> download2Local(String url) async {
    final file = await getLocalFilePath(fname);
    Dio dio = Dio();
    dio.download(url, file.path, onReceiveProgress: (actualBytes, totalBytes) {
      int p = (actualBytes / totalBytes * 100).toInt();
      if (p > 1) {
        if (mounted) {
          setState(() {
            percent = p;
          });
        }
      }
    }).then((success) {
      if (mounted) {
        setState(() {
          isDownloaded = true;
        });
      }
    });
  }

  GestureDetector _sizerChild(BuildContext context) {
    Color curColor = widget.me ? Colors.white : Colors.black;
    return GestureDetector(
      onTap: () async {
        // Deprecated: open link
        //await launchInWebViewOrVC(widget.fileSrc);
        File file = await getLocalFilePath(fname);

        if (widget.me && widget.localPath != '') {
          file = File(widget.localPath);
        }

        if (isDownloaded) {
          print('opening ${file.path}...');
          final result = await OpenFile.open(file.path);
          print('opening result ${result.message}');
        } else {
          if (percent > 0) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Файл еще загружается, пожалуйста, подождите'),
              ));
            }
          } else {
            if (percent == 0) {
              if (mounted) {
                setState(() {
                  percent = 1;
                });
              }
              await download2Local(widget.fileSrc);
            }
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: .8.w()),
        constraints: BoxConstraints(maxWidth: 100.w() * .7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6.w()),
            bottomLeft:
                widget.me ? Radius.circular(6.w()) : Radius.circular(2.w()),
            bottomRight:
                !widget.me ? Radius.circular(6.w()) : Radius.circular(1.2.w()),
            topRight: Radius.circular(6.w()),
          ),
          color: widget.me ? widget.meBgColor : widget.contactBgColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w(), vertical: 2.8.w()),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                FileMessage.fileIcon,
                width: 32,
                height: 32,
                color: curColor,
              ),
              SizedBox(width: 3.w()),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ext,
                    style: TextStyle(color: curColor),
                  ),
                  SIZED_BOX_H06,
                  Text(
                    isDownloaded
                        ? 'Файл загружен'
                        : (percent == 0
                            ? 'Загрузить файл'
                            : 'Загрузка $percent%'),
                    style: TextStyle(color: curColor, fontSize: 12.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.createdAt == null
                              ? ''
                              : intl.DateFormat('HH:mm')
                                  .format(widget.createdAt!),
                          style: TextStyle(
                            color: widget.me ? Colors.white : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        DashChat.buildReadMessageStatus(
                            chatMessageOptions, widget.me, widget.readStatus),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(width: 2.2.w()),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionMessage extends StatefulWidget {
  final bool me;
  final String senderJid;
  final DateTime? createdAt;
  final String mid; // ид сообщения (надо промаркировать отвеченным)
  bool disabled;

  QuestionMessage({
    Key? key,
    required this.me,
    required this.senderJid,
    this.createdAt,
    required this.mid,
    this.disabled = true,
  }) : super(key: key);

  @override
  _QuestionMessageState createState() => _QuestionMessageState();
}

class _QuestionMessageState extends State<QuestionMessage> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildButtons() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PrimaryButton(
          color: widget.disabled ? Colors.grey : Colors.green,
          onPressed: () async {
            if (widget.disabled) {
              print('--- disabled ---');
              setState(() {});
              return;
            }
            setState(() {
              widget.disabled = true;
            });
            await grantAccessSharedContacts(widget.senderJid, widget.mid);
          },
          child: Text(
            'Да',
            style: TextStyle(
              fontSize: 16,
              fontWeight: w500,
              color: white,
            ),
          ),
        ),
        PrimaryButton(
          color: widget.disabled ? Colors.grey : red,
          onPressed: () async {
            if (widget.disabled) {
              print('--- disabled ---');
              setState(() {});
              return;
            }
            setState(() {
              widget.disabled = true;
            });
            await denyAccessSharedContacts(widget.senderJid, widget.mid);
          },
          child: Text(
            'Нет',
            style: TextStyle(
              fontSize: 16,
              fontWeight: w500,
              color: white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        widget.me
            ? const Text(
                'Вы запросили проверку общих контактов',
                style: TextStyle(
                  fontSize: 15,
                ),
              )
            : const Text(
                'У вас запросили проверку общих контактов.\n'
                'Согласны ли вы предоставить доступ к своим контактам'
                ' и получить информацию по контактам пользователя?',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
        SIZED_BOX_H16,
        widget.me ? Container() : buildButtons()
      ],
    );
  }
}

Future<void> setAccessSharedContacts(
    bool answer, String text, String friendJid, String mid) async {
  UserSettingsModel? userSettings = await UserSettingsModel().getUser();
  if (userSettings != null) {
    /* Если ответ утвердительный,
       тогда надо создать запрос на сверку контактов
    */

    if (answer) {
      SharedContactsRequestModel newRequest =
      SharedContactsRequestModel(
        date: datetime2String(DateTime.now()),
        ownerJid: userSettings.jid,
        friendJid: friendJid,
      );
      newRequest.insert2Db();
    }

    // Маркируем сообщение отвеченным
    ChatMessageModel msg = await ChatMessageModel().getByMid(mid);
    msg.updatePartial(msg.id, {
      'answered': 1,
    });

    Map<String, dynamic> data = {
      'from': userSettings.jid,
      'text': text,
      'to': friendJid,
      'now': DateTime.now().millisecondsSinceEpoch,
      'pk': const Uuid().v4(),
      'mediaType': MediaType.answer.toString(),
      'answer': answer,
    };
    await BGTasksModel.sendTextMessageTask(data);
  } else {
    print('setAccessSharedContacts failed, user is null');
  }
}

Future<void> grantAccessSharedContacts(String friendJid, String mid) async {
  String text = 'Разрешение на проверку общих контактов дано';
  await setAccessSharedContacts(true, text, friendJid, mid);
}

Future<void> denyAccessSharedContacts(String friendJid, String mid) async {
  String text = 'Разрешение на проверку общих контактов отклонено';
  await setAccessSharedContacts(false, text, friendJid, mid);
}

class AnswerMessage extends StatefulWidget {
  final bool me;
  final bool answer;
  final DateTime? createdAt;
  MessageStatus readStatus;

  AnswerMessage({
    Key? key,
    required this.me,
    required this.answer,
    this.createdAt,
    this.readStatus = MessageStatus.none,
  }) : super(key: key);

  @override
  _AnswerMessageState createState() => _AnswerMessageState();
}

class _AnswerMessageState extends State<AnswerMessage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color color = Colors.green;
    String text = 'Запрос общих контактов разрешен';
    if (!widget.answer) {
      color = red;
      text = 'Запрос общих контактов отклонен';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
