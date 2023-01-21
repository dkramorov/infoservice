import 'dart:math' as math;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infoservice/settings.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';

import '../../helpers/network.dart';
import '../../helpers/string_parser.dart';

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

  @override
  _VoiceMessageState createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer player = AudioPlayer();
  final double maxNoiseHeight = 6.w(), noiseWidth = 26.5.w();
  Duration? _audioDuration;
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
        padding: EdgeInsets.symmetric(horizontal: 4.w(), vertical: 2.8.w()),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _playButton(context),
            SizedBox(width: 3.w()),
            _durationWithNoise(context),
            SizedBox(width: 2.2.w()),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
              )
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
    await player.setUrl(widget.audioSrc);
    player.playerStateStream.listen((playerState) {
      isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
      } else if (processingState == ProcessingState.completed) {
        _stopPlaying();
        player.seek(Duration.zero);
        _controller?.reset();
        setState(() {
          isPlaying = false;
        });
      }
      setState(() {});
    });

    player.bufferedPositionStream.listen((Duration bufferedPosition) {
      // Буферизованный вывод - максимальная позиция
      setState(() {
        if (mounted) {
          maxDurationForSlider = bufferedPosition.inSeconds.toDouble();
        }
      });
    });

    player.positionStream.listen((Duration p) {
      // Текущая позиция
      duration = p.inSeconds;
      final newRemaingTime1 = p.toString().split('.')[0];
      final newRemaingTime2 =
          newRemaingTime1.substring(newRemaingTime1.length - 5);
      if (newRemaingTime2 != remaingTime) {
        setState(() => remaingTime = newRemaingTime2);
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

  void _completeAnimationConfiguration() =>
      setState(() => _audioConfigurationDone = true);

  void _changePlayingStatus() async {
    if (widget.onPlay != null) widget.onPlay!();
    isPlaying ? _stopPlaying() : _startPlaying();
    setState(() => isPlaying = !isPlaying);
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
    setState(() {});
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
  final localPath;

  FileMessage({
    Key? key,
    required this.fileSrc,
    required this.me,
    this.meBgColor = const Color(0xFFFF4550),
    this.contactBgColor = const Color(0xffffffff),
    this.localPath = '',
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
          setState(() {
            isDownloaded = isExists;
          });
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
        setState(() {
          percent = p;
        });
      }
    }).then((success) {
      setState(() {
        isDownloaded = true;
      });
    });
  }

  GestureDetector _sizerChild(BuildContext context) {
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
              setState(() {
                percent = 1;
              });
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
                color: widget.me ? Colors.white : Colors.black,
              ),
              SizedBox(width: 3.w()),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ext,
                    style: TextStyle(
                        color: widget.me ? Colors.white : Colors.black),
                  ),
                  SIZED_BOX_H06,
                  Text(
                    isDownloaded ? 'Файл загружен' : (percent == 0 ? 'Загрузить файл' : 'Загрузка ${percent}%'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12.0),
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
